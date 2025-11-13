-- ============================================
-- Campbnb Québec - Schéma de Base de Données
-- ============================================
-- Migration initiale : Création de toutes les tables
-- Base de données : PostgreSQL (Supabase)

-- Extension pour UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- TABLE: profiles (Extension de auth.users)
-- ============================================
CREATE TABLE public.profiles (
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
    -- Adresse
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    province TEXT,
    postal_code TEXT,
    country TEXT DEFAULT 'Canada',
    -- Préférences
    preferred_language TEXT DEFAULT 'fr',
    notification_preferences JSONB DEFAULT '{}'::jsonb,
    -- Statistiques
    total_reviews INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    -- Métadonnées
    last_login_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE
);

-- Index pour recherches fréquentes
CREATE INDEX idx_profiles_email ON public.profiles(email);
CREATE INDEX idx_profiles_is_host ON public.profiles(is_host);
CREATE INDEX idx_profiles_city ON public.profiles(city);

-- ============================================
-- TABLE: listings (Annonces de campings)
-- ============================================
CREATE TABLE public.listings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    -- Informations de base
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    property_type TEXT NOT NULL CHECK (property_type IN ('tent', 'rv', 'cabin', 'yurt', 'treehouse', 'other')),
    -- Localisation
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    address_line1 TEXT NOT NULL,
    address_line2 TEXT,
    city TEXT NOT NULL,
    province TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    country TEXT DEFAULT 'Canada',
    -- Capacité et équipements
    max_guests INTEGER NOT NULL CHECK (max_guests > 0),
    bedrooms INTEGER DEFAULT 0,
    beds INTEGER DEFAULT 0,
    bathrooms DECIMAL(3, 1) DEFAULT 0,
    -- Équipements (JSON pour flexibilité)
    amenities JSONB DEFAULT '[]'::jsonb,
    -- Règles et informations
    house_rules TEXT,
    check_in_time TIME DEFAULT '15:00:00',
    check_out_time TIME DEFAULT '11:00:00',
    -- Tarification
    base_price_per_night DECIMAL(10, 2) NOT NULL CHECK (base_price_per_night > 0),
    cleaning_fee DECIMAL(10, 2) DEFAULT 0,
    service_fee_percentage DECIMAL(5, 2) DEFAULT 10.00,
    -- Disponibilité
    is_available BOOLEAN DEFAULT TRUE,
    minimum_nights INTEGER DEFAULT 1,
    maximum_nights INTEGER,
    -- Images
    cover_image_url TEXT,
    image_urls JSONB DEFAULT '[]'::jsonb,
    -- Statut
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'pending', 'active', 'suspended', 'deleted')),
    -- Statistiques
    total_reservations INTEGER DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    view_count INTEGER DEFAULT 0,
    -- Métadonnées
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    published_at TIMESTAMPTZ
);

-- Index pour recherches géographiques et filtres
CREATE INDEX idx_listings_host_id ON public.listings(host_id);
CREATE INDEX idx_listings_status ON public.listings(status);
CREATE INDEX idx_listings_city ON public.listings(city);
CREATE INDEX idx_listings_province ON public.listings(province);
CREATE INDEX idx_listings_property_type ON public.listings(property_type);
CREATE INDEX idx_listings_created_at ON public.listings(created_at DESC);
-- Index GIST pour recherches géographiques (nécessite l'extension postgis si disponible)
-- CREATE INDEX idx_listings_location ON public.listings USING GIST (point(longitude, latitude));

-- ============================================
-- TABLE: reservations (Réservations)
-- ============================================
CREATE TABLE public.reservations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
    guest_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    host_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    -- Dates
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    -- Invités
    number_of_guests INTEGER NOT NULL CHECK (number_of_guests > 0),
    number_of_adults INTEGER NOT NULL,
    number_of_children INTEGER DEFAULT 0,
    -- Tarification
    base_price DECIMAL(10, 2) NOT NULL,
    cleaning_fee DECIMAL(10, 2) DEFAULT 0,
    service_fee DECIMAL(10, 2) NOT NULL,
    taxes DECIMAL(10, 2) DEFAULT 0,
    total_price DECIMAL(10, 2) NOT NULL,
    -- Statut
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed', 'rejected')),
    cancellation_reason TEXT,
    -- Dates de réservation
    requested_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    confirmed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    -- Messages et notes
    guest_message TEXT,
    host_message TEXT,
    -- Métadonnées
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    -- Contraintes
    CONSTRAINT check_dates_valid CHECK (check_out_date > check_in_date)
);

-- Index pour recherches
CREATE INDEX idx_reservations_listing_id ON public.reservations(listing_id);
CREATE INDEX idx_reservations_guest_id ON public.reservations(guest_id);
CREATE INDEX idx_reservations_host_id ON public.reservations(host_id);
CREATE INDEX idx_reservations_status ON public.reservations(status);
CREATE INDEX idx_reservations_dates ON public.reservations(check_in_date, check_out_date);
CREATE INDEX idx_reservations_created_at ON public.reservations(created_at DESC);

-- ============================================
-- TABLE: messages (Messages entre utilisateurs)
-- ============================================
CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    -- Contenu
    content TEXT NOT NULL,
    -- Référence à une réservation (optionnel)
    reservation_id UUID REFERENCES public.reservations(id) ON DELETE SET NULL,
    -- Statut
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    -- Métadonnées
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index pour conversations
CREATE INDEX idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX idx_messages_recipient_id ON public.messages(recipient_id);
CREATE INDEX idx_messages_reservation_id ON public.messages(reservation_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX idx_messages_is_read ON public.messages(is_read) WHERE is_read = FALSE;

-- ============================================
-- TABLE: reviews (Avis et évaluations)
-- ============================================
CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reservation_id UUID NOT NULL REFERENCES public.reservations(id) ON DELETE CASCADE,
    listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reviewee_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    -- Type de review (guest review ou host review)
    review_type TEXT NOT NULL CHECK (review_type IN ('guest', 'host')),
    -- Évaluations (1-5)
    rating_overall INTEGER NOT NULL CHECK (rating_overall >= 1 AND rating_overall <= 5),
    rating_cleanliness INTEGER CHECK (rating_cleanliness >= 1 AND rating_cleanliness <= 5),
    rating_communication INTEGER CHECK (rating_communication >= 1 AND rating_communication <= 5),
    rating_check_in INTEGER CHECK (rating_check_in >= 1 AND rating_check_in <= 5),
    rating_accuracy INTEGER CHECK (rating_accuracy >= 1 AND rating_accuracy <= 5),
    rating_location INTEGER CHECK (rating_location >= 1 AND rating_location <= 5),
    rating_value INTEGER CHECK (rating_value >= 1 AND rating_value <= 5),
    -- Commentaire
    comment TEXT,
    -- Réponse de l'hôte (si review_type = 'guest')
    host_response TEXT,
    host_response_at TIMESTAMPTZ,
    -- Statut
    is_public BOOLEAN DEFAULT TRUE,
    -- Métadonnées
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    -- Contrainte unique : un utilisateur ne peut laisser qu'un avis par réservation
    CONSTRAINT unique_review_per_reservation UNIQUE (reservation_id, reviewer_id, review_type)
);

-- Index
CREATE INDEX idx_reviews_reservation_id ON public.reviews(reservation_id);
CREATE INDEX idx_reviews_listing_id ON public.reviews(listing_id);
CREATE INDEX idx_reviews_reviewer_id ON public.reviews(reviewer_id);
CREATE INDEX idx_reviews_reviewee_id ON public.reviews(reviewee_id);
CREATE INDEX idx_reviews_rating_overall ON public.reviews(rating_overall);
CREATE INDEX idx_reviews_created_at ON public.reviews(created_at DESC);

-- ============================================
-- TABLE: favorites (Favoris)
-- ============================================
CREATE TABLE public.favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    -- Contrainte unique : un utilisateur ne peut ajouter qu'une fois un listing en favori
    CONSTRAINT unique_user_listing_favorite UNIQUE (user_id, listing_id)
);

-- Index
CREATE INDEX idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX idx_favorites_listing_id ON public.favorites(listing_id);

-- ============================================
-- TABLE: activities (Activités et événements)
-- ============================================
CREATE TABLE public.activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE,
    host_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    -- Informations
    title TEXT NOT NULL,
    description TEXT,
    activity_type TEXT NOT NULL CHECK (activity_type IN ('hiking', 'fishing', 'kayaking', 'wildlife', 'campfire', 'workshop', 'other')),
    -- Localisation
    location_name TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    -- Dates et horaires
    start_date DATE,
    start_time TIME,
    end_date DATE,
    end_time TIME,
    duration_minutes INTEGER,
    -- Capacité
    max_participants INTEGER,
    current_participants INTEGER DEFAULT 0,
    -- Tarification
    price_per_person DECIMAL(10, 2) DEFAULT 0,
    is_free BOOLEAN DEFAULT FALSE,
    -- Images
    image_url TEXT,
    -- Statut
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'cancelled', 'completed')),
    -- Métadonnées
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index
CREATE INDEX idx_activities_listing_id ON public.activities(listing_id);
CREATE INDEX idx_activities_host_id ON public.activities(host_id);
CREATE INDEX idx_activities_activity_type ON public.activities(activity_type);
CREATE INDEX idx_activities_start_date ON public.activities(start_date);
CREATE INDEX idx_activities_status ON public.activities(status);

-- ============================================
-- TABLE: activity_bookings (Réservations d'activités)
-- ============================================
CREATE TABLE public.activity_bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES public.activities(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    number_of_participants INTEGER NOT NULL CHECK (number_of_participants > 0),
    total_price DECIMAL(10, 2) NOT NULL,
    status TEXT DEFAULT 'confirmed' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_user_activity_booking UNIQUE (activity_id, user_id)
);

-- Index
CREATE INDEX idx_activity_bookings_activity_id ON public.activity_bookings(activity_id);
CREATE INDEX idx_activity_bookings_user_id ON public.activity_bookings(user_id);

-- ============================================
-- TABLE: blocked_dates (Dates bloquées pour listings)
-- ============================================
CREATE TABLE public.blocked_dates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
    blocked_date DATE NOT NULL,
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_listing_date UNIQUE (listing_id, blocked_date)
);

-- Index
CREATE INDEX idx_blocked_dates_listing_id ON public.blocked_dates(listing_id);
CREATE INDEX idx_blocked_dates_blocked_date ON public.blocked_dates(blocked_date);

-- ============================================
-- TABLE: notifications (Notifications utilisateurs)
-- ============================================
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('reservation_request', 'reservation_confirmed', 'reservation_cancelled', 'message', 'review', 'favorite', 'activity', 'system')),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    data JSONB DEFAULT '{}'::jsonb,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read) WHERE is_read = FALSE;
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);

-- ============================================
-- TRIGGERS: Mise à jour automatique de updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Application des triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_listings_updated_at BEFORE UPDATE ON public.listings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reservations_updated_at BEFORE UPDATE ON public.reservations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON public.messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_activities_updated_at BEFORE UPDATE ON public.activities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- FUNCTIONS: Fonctions utilitaires
-- ============================================

-- Fonction pour calculer le prix total d'une réservation
CREATE OR REPLACE FUNCTION calculate_reservation_total(
    p_listing_id UUID,
    p_check_in DATE,
    p_check_out DATE,
    p_number_of_guests INTEGER
)
RETURNS TABLE (
    base_price DECIMAL,
    cleaning_fee DECIMAL,
    service_fee DECIMAL,
    taxes DECIMAL,
    total_price DECIMAL
) AS $$
DECLARE
    v_listing RECORD;
    v_nights INTEGER;
    v_base_price DECIMAL;
    v_cleaning_fee DECIMAL;
    v_service_fee DECIMAL;
    v_taxes DECIMAL;
    v_total DECIMAL;
BEGIN
    -- Récupérer les informations du listing
    SELECT base_price_per_night, cleaning_fee, service_fee_percentage
    INTO v_listing
    FROM public.listings
    WHERE id = p_listing_id AND status = 'active';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Listing not found or not active';
    END IF;

    -- Calculer le nombre de nuits
    v_nights := p_check_out - p_check_in;

    -- Calculer les prix
    v_base_price := v_listing.base_price_per_night * v_nights;
    v_cleaning_fee := COALESCE(v_listing.cleaning_fee, 0);
    v_service_fee := (v_base_price + v_cleaning_fee) * (v_listing.service_fee_percentage / 100);
    v_taxes := (v_base_price + v_cleaning_fee + v_service_fee) * 0.15; -- TPS/TVH Québec (15%)
    v_total := v_base_price + v_cleaning_fee + v_service_fee + v_taxes;

    RETURN QUERY SELECT v_base_price, v_cleaning_fee, v_service_fee, v_taxes, v_total;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour mettre à jour les statistiques d'un listing
CREATE OR REPLACE FUNCTION update_listing_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Mettre à jour le nombre total de réservations
        UPDATE public.listings
        SET total_reservations = (
            SELECT COUNT(*) FROM public.reservations
            WHERE listing_id = NEW.listing_id AND status IN ('confirmed', 'completed')
        )
        WHERE id = NEW.listing_id;

        -- Mettre à jour le nombre total de reviews et la note moyenne
        UPDATE public.listings
        SET 
            total_reviews = (
                SELECT COUNT(*) FROM public.reviews
                WHERE listing_id = NEW.listing_id AND is_public = TRUE
            ),
            average_rating = (
                SELECT COALESCE(AVG(rating_overall), 0.00) FROM public.reviews
                WHERE listing_id = NEW.listing_id AND is_public = TRUE
            )
        WHERE id = NEW.listing_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour les stats après une review
CREATE TRIGGER update_listing_stats_after_review
    AFTER INSERT OR UPDATE ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION update_listing_stats();

-- Fonction pour mettre à jour les statistiques d'un profil
CREATE OR REPLACE FUNCTION update_profile_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Mettre à jour le nombre total de reviews et la note moyenne
        UPDATE public.profiles
        SET 
            total_reviews = (
                SELECT COUNT(*) FROM public.reviews
                WHERE reviewee_id = NEW.reviewee_id AND is_public = TRUE
            ),
            average_rating = (
                SELECT COALESCE(AVG(rating_overall), 0.00) FROM public.reviews
                WHERE reviewee_id = NEW.reviewee_id AND is_public = TRUE
            )
        WHERE id = NEW.reviewee_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour les stats après une review
CREATE TRIGGER update_profile_stats_after_review
    AFTER INSERT OR UPDATE ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION update_profile_stats();

-- ============================================
-- COMMENTAIRES SUR LES TABLES
-- ============================================
COMMENT ON TABLE public.profiles IS 'Profils utilisateurs étendant auth.users';
COMMENT ON TABLE public.listings IS 'Annonces de campings et hébergements';
COMMENT ON TABLE public.reservations IS 'Réservations de campings';
COMMENT ON TABLE public.messages IS 'Messages entre utilisateurs';
COMMENT ON TABLE public.reviews IS 'Avis et évaluations';
COMMENT ON TABLE public.favorites IS 'Listings favoris des utilisateurs';
COMMENT ON TABLE public.activities IS 'Activités proposées par les hôtes';
COMMENT ON TABLE public.activity_bookings IS 'Réservations d''activités';
COMMENT ON TABLE public.blocked_dates IS 'Dates bloquées pour les listings';
COMMENT ON TABLE public.notifications IS 'Notifications utilisateurs';


