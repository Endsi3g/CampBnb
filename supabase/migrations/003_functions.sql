-- ============================================
-- Campbnb Québec - Fonctions utilitaires supplémentaires
-- ============================================

-- Fonction pour incrémenter le compteur de vues d'un listing
CREATE OR REPLACE FUNCTION increment_listing_views(listing_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE public.listings
    SET view_count = view_count + 1
    WHERE id = listing_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour vérifier la disponibilité d'une période
CREATE OR REPLACE FUNCTION check_availability(
    p_listing_id UUID,
    p_check_in DATE,
    p_check_out DATE
)
RETURNS BOOLEAN AS $$
DECLARE
    v_conflicting_reservation INTEGER;
    v_blocked_date_count INTEGER;
BEGIN
    -- Vérifier les réservations existantes
    SELECT COUNT(*) INTO v_conflicting_reservation
    FROM public.reservations
    WHERE listing_id = p_listing_id
        AND status IN ('pending', 'confirmed')
        AND (
            (check_in_date <= p_check_in AND check_out_date > p_check_in) OR
            (check_in_date < p_check_out AND check_out_date >= p_check_out) OR
            (check_in_date >= p_check_in AND check_out_date <= p_check_out)
        );

    IF v_conflicting_reservation > 0 THEN
        RETURN FALSE;
    END IF;

    -- Vérifier les dates bloquées
    SELECT COUNT(*) INTO v_blocked_date_count
    FROM public.blocked_dates
    WHERE listing_id = p_listing_id
        AND blocked_date >= p_check_in
        AND blocked_date < p_check_out;

    IF v_blocked_date_count > 0 THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour obtenir les statistiques d'un hôte
CREATE OR REPLACE FUNCTION get_host_stats(p_host_id UUID)
RETURNS TABLE (
    total_listings INTEGER,
    active_listings INTEGER,
    total_reservations INTEGER,
    confirmed_reservations INTEGER,
    total_revenue DECIMAL,
    average_rating DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (SELECT COUNT(*)::INTEGER FROM public.listings WHERE host_id = p_host_id),
        (SELECT COUNT(*)::INTEGER FROM public.listings WHERE host_id = p_host_id AND status = 'active'),
        (SELECT COUNT(*)::INTEGER FROM public.reservations WHERE host_id = p_host_id),
        (SELECT COUNT(*)::INTEGER FROM public.reservations WHERE host_id = p_host_id AND status = 'confirmed'),
        (SELECT COALESCE(SUM(total_price), 0) FROM public.reservations WHERE host_id = p_host_id AND status = 'completed'),
        (SELECT COALESCE(AVG(rating_overall), 0.00) FROM public.reviews WHERE reviewee_id = p_host_id AND is_public = TRUE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour rechercher des listings par proximité géographique
CREATE OR REPLACE FUNCTION search_listings_nearby(
    p_latitude DECIMAL,
    p_longitude DECIMAL,
    p_radius_km DECIMAL DEFAULT 50,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    latitude DECIMAL,
    longitude DECIMAL,
    distance_km DECIMAL,
    base_price_per_night DECIMAL,
    cover_image_url TEXT,
    average_rating DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id,
        l.title,
        l.latitude,
        l.longitude,
        -- Calcul de distance approximative (formule Haversine simplifiée)
        (
            6371 * acos(
                cos(radians(p_latitude)) *
                cos(radians(l.latitude)) *
                cos(radians(l.longitude) - radians(p_longitude)) +
                sin(radians(p_latitude)) *
                sin(radians(l.latitude))
            )
        ) AS distance_km,
        l.base_price_per_night,
        l.cover_image_url,
        l.average_rating
    FROM public.listings l
    WHERE l.status = 'active'
        AND l.is_available = TRUE
        -- Filtre approximatif pour améliorer les performances
        AND l.latitude BETWEEN p_latitude - (p_radius_km / 111.0) AND p_latitude + (p_radius_km / 111.0)
        AND l.longitude BETWEEN p_longitude - (p_radius_km / (111.0 * cos(radians(p_latitude)))) AND p_longitude + (p_radius_km / (111.0 * cos(radians(p_latitude))))
    ORDER BY distance_km
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour obtenir les listings favoris d'un utilisateur
CREATE OR REPLACE FUNCTION get_user_favorites(p_user_id UUID)
RETURNS TABLE (
    listing_id UUID,
    title TEXT,
    cover_image_url TEXT,
    base_price_per_night DECIMAL,
    city TEXT,
    province TEXT,
    average_rating DECIMAL,
    favorited_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id,
        l.title,
        l.cover_image_url,
        l.base_price_per_night,
        l.city,
        l.province,
        l.average_rating,
        f.created_at
    FROM public.favorites f
    JOIN public.listings l ON f.listing_id = l.id
    WHERE f.user_id = p_user_id
        AND l.status = 'active'
    ORDER BY f.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour créer une notification
CREATE OR REPLACE FUNCTION create_notification(
    p_user_id UUID,
    p_type TEXT,
    p_title TEXT,
    p_message TEXT,
    p_data JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID AS $$
DECLARE
    v_notification_id UUID;
BEGIN
    INSERT INTO public.notifications (user_id, type, title, message, data)
    VALUES (p_user_id, p_type, p_title, p_message, p_data)
    RETURNING id INTO v_notification_id;
    
    RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour marquer toutes les notifications comme lues
CREATE OR REPLACE FUNCTION mark_all_notifications_read(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE public.notifications
    SET is_read = TRUE, read_at = NOW()
    WHERE user_id = p_user_id AND is_read = FALSE;
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


