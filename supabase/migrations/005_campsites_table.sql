-- ============================================
-- Campbnb Québec - Table campsites
-- ============================================
-- Migration pour la table des emplacements de camping
-- Utilisée pour l'intégration Mapbox

-- Extension PostGIS pour les recherches géographiques
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================
-- TABLE: campsites
-- ============================================
CREATE TABLE public.campsites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Informations de base
    name TEXT NOT NULL,
    description TEXT,
    
    -- Localisation géographique
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    
    -- Géométrie PostGIS pour recherches spatiales
    location GEOGRAPHY(POINT, 4326),
    
    -- Type d'emplacement
    type TEXT NOT NULL CHECK (type IN (
        'tent',      -- Tente
        'rv',        -- VR (Véhicule récréatif)
        'cabin',     -- Chalet/Prêt-à-camper
        'wild',      -- Camping sauvage
        'lake',      -- Emplacement au bord d'un lac
        'forest',     -- Emplacement en forêt
        'beach',     -- Emplacement sur la plage
        'mountain'   -- Emplacement en montagne
    )),
    
    -- Propriétaire/Hôte
    host_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    
    -- Tarification
    price_per_night DOUBLE PRECISION CHECK (price_per_night >= 0),
    
    -- Images
    image_url TEXT,
    
    -- Évaluations
    rating DOUBLE PRECISION DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    review_count INTEGER DEFAULT 0 CHECK (review_count >= 0),
    
    -- Disponibilité
    is_available BOOLEAN DEFAULT TRUE,
    
    -- Région (pour filtrage)
    region TEXT,
    
    -- Métadonnées
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index pour recherches géographiques
CREATE INDEX idx_campsites_location ON public.campsites USING GIST (location);
CREATE INDEX idx_campsites_lat_lon ON public.campsites (latitude, longitude);
CREATE INDEX idx_campsites_type ON public.campsites (type);
CREATE INDEX idx_campsites_host_id ON public.campsites (host_id);
CREATE INDEX idx_campsites_is_available ON public.campsites (is_available);
CREATE INDEX idx_campsites_region ON public.campsites (region);
CREATE INDEX idx_campsites_rating ON public.campsites (rating DESC);

-- Trigger pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_campsites_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER campsites_updated_at
    BEFORE UPDATE ON public.campsites
    FOR EACH ROW
    EXECUTE FUNCTION update_campsites_updated_at();

-- Trigger pour créer la géométrie PostGIS depuis latitude/longitude
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

CREATE TRIGGER campsites_location_trigger
    BEFORE INSERT OR UPDATE ON public.campsites
    FOR EACH ROW
    EXECUTE FUNCTION update_campsites_location();

-- Fonction pour recherche par proximité (nécessite PostGIS)
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

-- Mettre à jour les emplacements existants pour créer la géométrie
UPDATE public.campsites
SET location = ST_SetSRID(
    ST_MakePoint(longitude, latitude),
    4326
)::geography
WHERE location IS NULL;

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE public.campsites ENABLE ROW LEVEL SECURITY;

-- Tout le monde peut lire les campsites disponibles
CREATE POLICY "Anyone can read available campsites"
    ON public.campsites FOR SELECT
    USING (is_available = TRUE);

-- Les utilisateurs authentifiés peuvent lire tous les campsites (pour les hôtes)
CREATE POLICY "Authenticated users can read all campsites"
    ON public.campsites FOR SELECT
    TO authenticated
    USING (TRUE);

-- Les hôtes peuvent créer leurs propres campsites
CREATE POLICY "Hosts can create campsites"
    ON public.campsites FOR INSERT
    TO authenticated
    WITH CHECK (
        auth.uid() = host_id
        AND EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_host = TRUE
        )
    );

-- Les hôtes peuvent mettre à jour leurs propres campsites
CREATE POLICY "Hosts can update own campsites"
    ON public.campsites FOR UPDATE
    TO authenticated
    USING (auth.uid() = host_id)
    WITH CHECK (auth.uid() = host_id);

-- Les hôtes peuvent supprimer leurs propres campsites
CREATE POLICY "Hosts can delete own campsites"
    ON public.campsites FOR DELETE
    TO authenticated
    USING (auth.uid() = host_id);

-- Commentaires pour documentation
COMMENT ON TABLE public.campsites IS 'Emplacements de camping pour l''intégration Mapbox';
COMMENT ON COLUMN public.campsites.location IS 'Géométrie PostGIS pour recherches spatiales';
COMMENT ON FUNCTION get_campsites_nearby IS 'Recherche les campsites à proximité d''un point donné';

