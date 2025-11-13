-- ============================================
-- MIGRATION CAMPSITES - À COPIER-COLLER DIRECTEMENT
-- ============================================
-- Instructions :
-- 1. Copiez TOUT ce fichier (Ctrl+A, Ctrl+C)
-- 2. Allez sur Supabase Dashboard > SQL Editor > New query
-- 3. Collez (Ctrl+V)
-- 4. Cliquez sur "Run"
-- ============================================

-- Extension pour UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Activer PostGIS (si disponible)
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================
-- CRÉER LA TABLE PROFILES SI ELLE N'EXISTE PAS
-- ============================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    avatar_url TEXT,
    bio TEXT,
    date_of_birth DATE,
    is_host BOOLEAN DEFAULT FALSE,
    host_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    province TEXT,
    postal_code TEXT,
    country TEXT DEFAULT 'Canada',
    preferred_language TEXT DEFAULT 'fr',
    notification_preferences JSONB DEFAULT '{}'::jsonb,
    total_reviews INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    last_login_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE
);

-- Index pour profiles
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_is_host ON public.profiles(is_host);
CREATE INDEX IF NOT EXISTS idx_profiles_city ON public.profiles(city);

-- ============================================
-- CRÉER LA TABLE CAMPSITES
-- ============================================
CREATE TABLE IF NOT EXISTS public.campsites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    location GEOGRAPHY(POINT, 4326),
    type TEXT NOT NULL CHECK (type IN ('tent', 'rv', 'cabin', 'wild', 'lake', 'forest', 'beach', 'mountain')),
    host_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    price_per_night DOUBLE PRECISION CHECK (price_per_night >= 0),
    image_url TEXT,
    rating DOUBLE PRECISION DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    review_count INTEGER DEFAULT 0 CHECK (review_count >= 0),
    is_available BOOLEAN DEFAULT TRUE,
    region TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Créer les index
CREATE INDEX IF NOT EXISTS idx_campsites_location ON public.campsites USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_campsites_lat_lon ON public.campsites (latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_campsites_type ON public.campsites (type);
CREATE INDEX IF NOT EXISTS idx_campsites_host_id ON public.campsites (host_id);
CREATE INDEX IF NOT EXISTS idx_campsites_is_available ON public.campsites (is_available);
CREATE INDEX IF NOT EXISTS idx_campsites_region ON public.campsites (region);
CREATE INDEX IF NOT EXISTS idx_campsites_rating ON public.campsites (rating DESC);

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_campsites_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour updated_at
DROP TRIGGER IF EXISTS campsites_updated_at ON public.campsites;
CREATE TRIGGER campsites_updated_at
    BEFORE UPDATE ON public.campsites
    FOR EACH ROW
    EXECUTE FUNCTION update_campsites_updated_at();

-- Fonction pour créer la géométrie PostGIS
CREATE OR REPLACE FUNCTION update_campsites_location()
RETURNS TRIGGER AS $$
BEGIN
    NEW.location = ST_SetSRID(
        ST_MakePoint(NEW.longitude, NEW.latitude),
        4326
    )::geography;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour la géométrie
DROP TRIGGER IF EXISTS campsites_location_trigger ON public.campsites;
CREATE TRIGGER campsites_location_trigger
    BEFORE INSERT OR UPDATE ON public.campsites
    FOR EACH ROW
    EXECUTE FUNCTION update_campsites_location();

-- Fonction de recherche par proximité
CREATE OR REPLACE FUNCTION get_campsites_nearby(
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    radius_meters DOUBLE PRECISION
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    type TEXT,
    description TEXT,
    price_per_night DOUBLE PRECISION,
    host_id UUID,
    image_url TEXT,
    rating DOUBLE PRECISION,
    review_count INTEGER,
    is_available BOOLEAN,
    region TEXT,
    distance DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.name,
        c.latitude,
        c.longitude,
        c.type,
        c.description,
        c.price_per_night,
        c.host_id,
        c.image_url,
        c.rating,
        c.review_count,
        c.is_available,
        c.region,
        ST_Distance(
            c.location,
            ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography
        ) AS distance
    FROM public.campsites c
    WHERE ST_DWithin(
        c.location,
        ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography,
        radius_meters
    )
    AND c.is_available = TRUE
    ORDER BY distance
    LIMIT 50;
END;
$$ LANGUAGE plpgsql;

-- Activer RLS
ALTER TABLE public.campsites ENABLE ROW LEVEL SECURITY;

-- Politiques RLS
DROP POLICY IF EXISTS "Anyone can read available campsites" ON public.campsites;
CREATE POLICY "Anyone can read available campsites"
    ON public.campsites FOR SELECT
    USING (is_available = TRUE);

DROP POLICY IF EXISTS "Authenticated users can read all campsites" ON public.campsites;
CREATE POLICY "Authenticated users can read all campsites"
    ON public.campsites FOR SELECT
    TO authenticated
    USING (TRUE);

DROP POLICY IF EXISTS "Hosts can create campsites" ON public.campsites;
CREATE POLICY "Hosts can create campsites"
    ON public.campsites FOR INSERT
    TO authenticated
    WITH CHECK (
        auth.uid() = host_id
        AND (
            -- Si profiles n'existe pas ou si l'utilisateur est hôte
            NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles')
            OR EXISTS (
                SELECT 1 FROM public.profiles
                WHERE id = auth.uid() AND is_host = TRUE
            )
        )
    );

DROP POLICY IF EXISTS "Hosts can update own campsites" ON public.campsites;
CREATE POLICY "Hosts can update own campsites"
    ON public.campsites FOR UPDATE
    TO authenticated
    USING (auth.uid() = host_id)
    WITH CHECK (auth.uid() = host_id);

DROP POLICY IF EXISTS "Hosts can delete own campsites" ON public.campsites;
CREATE POLICY "Hosts can delete own campsites"
    ON public.campsites FOR DELETE
    TO authenticated
    USING (auth.uid() = host_id);

-- Message de confirmation
SELECT 'Migration campsites appliquée avec succès !' AS message;

