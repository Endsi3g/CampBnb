-- ============================================
-- Migration 003: Internationalisation
-- Support multi-langues et régionalisation
-- ============================================

-- Extension pour les traductions JSON
CREATE EXTENSION IF NOT EXISTS "hstore";

-- ============================================
-- TABLE: listing_translations (Traductions des listings)
-- ============================================
CREATE TABLE public.listing_translations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
    language_code TEXT NOT NULL CHECK (language_code IN ('en', 'fr', 'es', 'de', 'it', 'pt', 'ja', 'zh', 'ko', 'hi')),
    country_code TEXT, -- Optionnel pour variantes régionales (fr-CA, en-US, etc.)
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    house_rules TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_listing_language UNIQUE (listing_id, language_code, country_code)
);

CREATE INDEX idx_listing_translations_listing_id ON public.listing_translations(listing_id);
CREATE INDEX idx_listing_translations_language ON public.listing_translations(language_code, country_code);

-- ============================================
-- TABLE: activity_translations (Traductions des activités)
-- ============================================
CREATE TABLE public.activity_translations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES public.activities(id) ON DELETE CASCADE,
    language_code TEXT NOT NULL,
    country_code TEXT,
    title TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_activity_language UNIQUE (activity_id, language_code, country_code)
);

CREATE INDEX idx_activity_translations_activity_id ON public.activity_translations(activity_id);

-- ============================================
-- TABLE: regions (Régions géographiques)
-- ============================================
CREATE TABLE public.regions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT UNIQUE NOT NULL, -- Code ISO (ex: CA-QC, US-CA, FR-IDF)
    name TEXT NOT NULL,
    country_code TEXT NOT NULL,
    parent_region_id UUID REFERENCES public.regions(id),
    timezone TEXT NOT NULL,
    currency_code TEXT NOT NULL,
    default_language_code TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb, -- Informations supplémentaires (taxes locales, réglementations, etc.)
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_regions_country_code ON public.regions(country_code);
CREATE INDEX idx_regions_code ON public.regions(code);

-- Insertion des régions principales
INSERT INTO public.regions (code, name, country_code, timezone, currency_code, default_language_code) VALUES
    ('CA-QC', 'Québec', 'CA', 'America/Toronto', 'CAD', 'fr'),
    ('CA-ON', 'Ontario', 'CA', 'America/Toronto', 'CAD', 'en'),
    ('CA-BC', 'British Columbia', 'CA', 'America/Vancouver', 'CAD', 'en'),
    ('US-CA', 'California', 'US', 'America/Los_Angeles', 'USD', 'en'),
    ('US-NY', 'New York', 'US', 'America/New_York', 'USD', 'en'),
    ('FR-IDF', 'Île-de-France', 'FR', 'Europe/Paris', 'EUR', 'fr'),
    ('ES-MAD', 'Madrid', 'ES', 'Europe/Madrid', 'EUR', 'es'),
    ('MX-CDMX', 'Mexico City', 'MX', 'America/Mexico_City', 'MXN', 'es'),
    ('BR-SP', 'São Paulo', 'BR', 'America/Sao_Paulo', 'BRL', 'pt'),
    ('JP-13', 'Tokyo', 'JP', 'Asia/Tokyo', 'JPY', 'ja');

-- ============================================
-- TABLE: regional_settings (Paramètres régionaux)
-- ============================================
CREATE TABLE public.regional_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    region_code TEXT NOT NULL REFERENCES public.regions(code),
    -- Taxes et frais
    tax_rate DECIMAL(5, 2) DEFAULT 0, -- Taux de taxe en pourcentage
    service_fee_rate DECIMAL(5, 2) DEFAULT 10.00,
    -- Unités
    distance_unit TEXT DEFAULT 'km' CHECK (distance_unit IN ('km', 'mi')),
    temperature_unit TEXT DEFAULT 'celsius' CHECK (temperature_unit IN ('celsius', 'fahrenheit')),
    -- Formats
    date_format TEXT DEFAULT 'YYYY-MM-DD',
    time_format TEXT DEFAULT '24h' CHECK (time_format IN ('12h', '24h')),
    -- Paiements
    supported_payment_methods JSONB DEFAULT '["stripe", "paypal"]'::jsonb,
    -- Métadonnées
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_region_settings UNIQUE (region_code)
);

-- Insertion des paramètres par défaut
INSERT INTO public.regional_settings (region_code, tax_rate, distance_unit, temperature_unit, time_format, supported_payment_methods) VALUES
    ('CA-QC', 15.00, 'km', 'celsius', '24h', '["stripe", "paypal", "apple_pay"]'::jsonb),
    ('US-CA', 8.25, 'mi', 'fahrenheit', '12h', '["stripe", "paypal", "apple_pay", "google_pay"]'::jsonb),
    ('FR-IDF', 20.00, 'km', 'celsius', '24h', '["stripe", "paypal"]'::jsonb);

-- ============================================
-- TABLE: payment_methods (Méthodes de paiement par région)
-- ============================================
CREATE TABLE public.payment_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    region_code TEXT NOT NULL REFERENCES public.regions(code),
    method_type TEXT NOT NULL CHECK (method_type IN ('stripe', 'paypal', 'apple_pay', 'google_pay', 'local_card', 'bank_transfer', 'crypto')),
    provider_name TEXT NOT NULL, -- Ex: "Stripe", "PayPal", "Mercado Pago" (pour Amérique latine)
    is_enabled BOOLEAN DEFAULT TRUE,
    config JSONB DEFAULT '{}'::jsonb, -- Configuration spécifique (clés API, endpoints, etc.)
    supported_currencies JSONB DEFAULT '[]'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_region_method UNIQUE (region_code, method_type)
);

-- Insertion des méthodes de paiement par région
INSERT INTO public.payment_methods (region_code, method_type, provider_name, supported_currencies) VALUES
    ('CA-QC', 'stripe', 'Stripe', '["CAD", "USD"]'::jsonb),
    ('CA-QC', 'paypal', 'PayPal', '["CAD", "USD", "EUR"]'::jsonb),
    ('CA-QC', 'apple_pay', 'Apple Pay', '["CAD"]'::jsonb),
    ('US-CA', 'stripe', 'Stripe', '["USD"]'::jsonb),
    ('US-CA', 'paypal', 'PayPal', '["USD"]'::jsonb),
    ('US-CA', 'apple_pay', 'Apple Pay', '["USD"]'::jsonb),
    ('US-CA', 'google_pay', 'Google Pay', '["USD"]'::jsonb),
    ('MX-CDMX', 'stripe', 'Stripe', '["MXN"]'::jsonb),
    ('MX-CDMX', 'paypal', 'PayPal', '["MXN", "USD"]'::jsonb),
    ('BR-SP', 'stripe', 'Stripe', '["BRL"]'::jsonb),
    ('BR-SP', 'paypal', 'PayPal', '["BRL", "USD"]'::jsonb);

-- ============================================
-- TABLE: catalog_categories (Catégories de catalogues par région)
-- ============================================
CREATE TABLE public.catalog_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT NOT NULL, -- Code unique (ex: "tent", "rv", "cabin")
    region_code TEXT REFERENCES public.regions(code),
    name_translations JSONB NOT NULL, -- {"en": "Tent", "fr": "Tente", "es": "Tienda"}
    description_translations JSONB,
    icon_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_category_region UNIQUE (code, region_code)
);

-- Insertion des catégories de base
INSERT INTO public.catalog_categories (code, region_code, name_translations) VALUES
    ('tent', NULL, '{"en": "Tent", "fr": "Tente", "es": "Tienda", "pt": "Barraca"}'::jsonb),
    ('rv', NULL, '{"en": "RV", "fr": "VR", "es": "Autocaravana", "pt": "Motorhome"}'::jsonb),
    ('cabin', NULL, '{"en": "Cabin", "fr": "Chalet", "es": "Cabaña", "pt": "Cabana"}'::jsonb),
    ('yurt', NULL, '{"en": "Yurt", "fr": "Yourte", "es": "Yurta", "pt": "Iurta"}'::jsonb),
    ('treehouse', NULL, '{"en": "Treehouse", "fr": "Cabane dans les arbres", "es": "Casa del árbol", "pt": "Casa na árvore"}'::jsonb);

-- ============================================
-- TABLE: local_experiences (Expériences locales par région)
-- ============================================
CREATE TABLE public.local_experiences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    region_code TEXT NOT NULL REFERENCES public.regions(code),
    category TEXT NOT NULL, -- "gastronomy", "nature", "culture", "adventure", etc.
    name_translations JSONB NOT NULL,
    description_translations JSONB,
    image_url TEXT,
    location_latitude DECIMAL(10, 8),
    location_longitude DECIMAL(11, 8),
    price_range TEXT, -- "budget", "mid", "luxury"
    duration_hours INTEGER,
    is_seasonal BOOLEAN DEFAULT FALSE,
    seasonal_months INTEGER[], -- [6, 7, 8] pour été
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_local_experiences_region ON public.local_experiences(region_code);
CREATE INDEX idx_local_experiences_category ON public.local_experiences(category);

-- ============================================
-- Mise à jour de la table profiles pour inclure la région
-- ============================================
ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS region_code TEXT REFERENCES public.regions(code),
    ADD COLUMN IF NOT EXISTS timezone TEXT,
    ADD COLUMN IF NOT EXISTS preferred_currency TEXT;

-- Mise à jour de la table listings pour inclure la région
-- ============================================
ALTER TABLE public.listings
    ADD COLUMN IF NOT EXISTS region_code TEXT REFERENCES public.regions(code);

CREATE INDEX idx_listings_region_code ON public.listings(region_code);

-- ============================================
-- Fonction pour obtenir les traductions d'un listing
-- ============================================
CREATE OR REPLACE FUNCTION get_listing_translation(
    p_listing_id UUID,
    p_language_code TEXT,
    p_country_code TEXT DEFAULT NULL
)
RETURNS TABLE (
    title TEXT,
    description TEXT,
    house_rules TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        lt.title,
        lt.description,
        lt.house_rules
    FROM public.listing_translations lt
    WHERE lt.listing_id = p_listing_id
        AND lt.language_code = p_language_code
        AND (lt.country_code = p_country_code OR (lt.country_code IS NULL AND p_country_code IS NULL))
    LIMIT 1;
    
    -- Si pas de traduction spécifique, retourner la version par défaut
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            l.title,
            l.description,
            l.house_rules
        FROM public.listings l
        WHERE l.id = p_listing_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Trigger pour mettre à jour updated_at
-- ============================================
CREATE TRIGGER update_listing_translations_updated_at
    BEFORE UPDATE ON public.listing_translations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_activity_translations_updated_at
    BEFORE UPDATE ON public.activity_translations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_regions_updated_at
    BEFORE UPDATE ON public.regions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_regional_settings_updated_at
    BEFORE UPDATE ON public.regional_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- COMMENTAIRES
-- ============================================
COMMENT ON TABLE public.listing_translations IS 'Traductions des listings par langue/région';
COMMENT ON TABLE public.activity_translations IS 'Traductions des activités par langue/région';
COMMENT ON TABLE public.regions IS 'Régions géographiques avec paramètres régionaux';
COMMENT ON TABLE public.regional_settings IS 'Paramètres régionaux (taxes, unités, formats)';
COMMENT ON TABLE public.payment_methods IS 'Méthodes de paiement disponibles par région';
COMMENT ON TABLE public.catalog_categories IS 'Catégories de catalogues avec traductions';
COMMENT ON TABLE public.local_experiences IS 'Expériences locales par région';


