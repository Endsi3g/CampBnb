-- ============================================
-- Campbnb Québec - Row Level Security (RLS)
-- ============================================
-- Politiques de sécurité pour protéger les données utilisateurs

-- ============================================
-- ENABLE RLS sur toutes les tables
-- ============================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blocked_dates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- ============================================
-- POLICIES: profiles
-- ============================================

-- Les utilisateurs peuvent lire leur propre profil
CREATE POLICY "Users can read own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

-- Les utilisateurs peuvent lire les profils publics (pour afficher les hôtes)
CREATE POLICY "Users can read public profiles"
    ON public.profiles FOR SELECT
    USING (is_active = TRUE);

-- Les utilisateurs peuvent mettre à jour leur propre profil
CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Les utilisateurs peuvent insérer leur propre profil (via trigger)
CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ============================================
-- POLICIES: listings
-- ============================================

-- Tout le monde peut lire les listings actifs
CREATE POLICY "Anyone can read active listings"
    ON public.listings FOR SELECT
    USING (status = 'active' AND is_available = TRUE);

-- Les utilisateurs peuvent lire leurs propres listings (même non actifs)
CREATE POLICY "Users can read own listings"
    ON public.listings FOR SELECT
    USING (auth.uid() = host_id);

-- Les hôtes peuvent créer des listings
CREATE POLICY "Hosts can create listings"
    ON public.listings FOR INSERT
    WITH CHECK (
        auth.uid() = host_id AND
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_host = TRUE
        )
    );

-- Les hôtes peuvent mettre à jour leurs propres listings
CREATE POLICY "Hosts can update own listings"
    ON public.listings FOR UPDATE
    USING (auth.uid() = host_id)
    WITH CHECK (auth.uid() = host_id);

-- Les hôtes peuvent supprimer leurs propres listings (soft delete)
CREATE POLICY "Hosts can delete own listings"
    ON public.listings FOR DELETE
    USING (auth.uid() = host_id);

-- ============================================
-- POLICIES: reservations
-- ============================================

-- Les utilisateurs peuvent lire leurs propres réservations
CREATE POLICY "Users can read own reservations"
    ON public.reservations FOR SELECT
    USING (auth.uid() = guest_id OR auth.uid() = host_id);

-- Les invités peuvent créer des réservations
CREATE POLICY "Guests can create reservations"
    ON public.reservations FOR INSERT
    WITH CHECK (
        auth.uid() = guest_id AND
        EXISTS (
            SELECT 1 FROM public.listings
            WHERE id = listing_id AND status = 'active' AND is_available = TRUE
        )
    );

-- Les invités peuvent mettre à jour leurs propres réservations (annulation)
CREATE POLICY "Guests can update own reservations"
    ON public.reservations FOR UPDATE
    USING (auth.uid() = guest_id)
    WITH CHECK (auth.uid() = guest_id);

-- Les hôtes peuvent mettre à jour les réservations de leurs listings (confirmation/rejet)
CREATE POLICY "Hosts can update reservations for own listings"
    ON public.reservations FOR UPDATE
    USING (
        auth.uid() = host_id AND
        EXISTS (
            SELECT 1 FROM public.listings
            WHERE id = listing_id AND host_id = auth.uid()
        )
    )
    WITH CHECK (
        auth.uid() = host_id AND
        EXISTS (
            SELECT 1 FROM public.listings
            WHERE id = listing_id AND host_id = auth.uid()
        )
    );

-- ============================================
-- POLICIES: messages
-- ============================================

-- Les utilisateurs peuvent lire les messages où ils sont expéditeur ou destinataire
CREATE POLICY "Users can read own messages"
    ON public.messages FOR SELECT
    USING (auth.uid() = sender_id OR auth.uid() = recipient_id);

-- Les utilisateurs peuvent créer des messages
CREATE POLICY "Users can create messages"
    ON public.messages FOR INSERT
    WITH CHECK (auth.uid() = sender_id);

-- Les utilisateurs peuvent mettre à jour leurs propres messages (marquer comme lu)
CREATE POLICY "Users can update received messages"
    ON public.messages FOR UPDATE
    USING (auth.uid() = recipient_id)
    WITH CHECK (auth.uid() = recipient_id);

-- ============================================
-- POLICIES: reviews
-- ============================================

-- Tout le monde peut lire les reviews publiques
CREATE POLICY "Anyone can read public reviews"
    ON public.reviews FOR SELECT
    USING (is_public = TRUE);

-- Les utilisateurs peuvent lire leurs propres reviews (même non publiques)
CREATE POLICY "Users can read own reviews"
    ON public.reviews FOR SELECT
    USING (auth.uid() = reviewer_id OR auth.uid() = reviewee_id);

-- Les utilisateurs peuvent créer des reviews pour leurs réservations
CREATE POLICY "Users can create reviews"
    ON public.reviews FOR INSERT
    WITH CHECK (
        auth.uid() = reviewer_id AND
        EXISTS (
            SELECT 1 FROM public.reservations
            WHERE id = reservation_id AND
            (guest_id = auth.uid() OR host_id = auth.uid()) AND
            status = 'completed'
        )
    );

-- Les utilisateurs peuvent mettre à jour leurs propres reviews
CREATE POLICY "Users can update own reviews"
    ON public.reviews FOR UPDATE
    USING (auth.uid() = reviewer_id)
    WITH CHECK (auth.uid() = reviewer_id);

-- Les hôtes peuvent répondre aux reviews (mise à jour de host_response)
CREATE POLICY "Hosts can respond to reviews"
    ON public.reviews FOR UPDATE
    USING (
        auth.uid() = reviewee_id AND
        review_type = 'guest' AND
        EXISTS (
            SELECT 1 FROM public.listings
            WHERE id = listing_id AND host_id = auth.uid()
        )
    )
    WITH CHECK (
        auth.uid() = reviewee_id AND
        review_type = 'guest'
    );

-- ============================================
-- POLICIES: favorites
-- ============================================

-- Les utilisateurs peuvent lire leurs propres favoris
CREATE POLICY "Users can read own favorites"
    ON public.favorites FOR SELECT
    USING (auth.uid() = user_id);

-- Les utilisateurs peuvent créer des favoris
CREATE POLICY "Users can create favorites"
    ON public.favorites FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Les utilisateurs peuvent supprimer leurs propres favoris
CREATE POLICY "Users can delete own favorites"
    ON public.favorites FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- POLICIES: activities
-- ============================================

-- Tout le monde peut lire les activités publiées
CREATE POLICY "Anyone can read published activities"
    ON public.activities FOR SELECT
    USING (status = 'published');

-- Les hôtes peuvent lire leurs propres activités
CREATE POLICY "Hosts can read own activities"
    ON public.activities FOR SELECT
    USING (auth.uid() = host_id);

-- Les hôtes peuvent créer des activités
CREATE POLICY "Hosts can create activities"
    ON public.activities FOR INSERT
    WITH CHECK (
        auth.uid() = host_id AND
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_host = TRUE
        )
    );

-- Les hôtes peuvent mettre à jour leurs propres activités
CREATE POLICY "Hosts can update own activities"
    ON public.activities FOR UPDATE
    USING (auth.uid() = host_id)
    WITH CHECK (auth.uid() = host_id);

-- Les hôtes peuvent supprimer leurs propres activités
CREATE POLICY "Hosts can delete own activities"
    ON public.activities FOR DELETE
    USING (auth.uid() = host_id);

-- ============================================
-- POLICIES: activity_bookings
-- ============================================

-- Les utilisateurs peuvent lire leurs propres réservations d'activités
CREATE POLICY "Users can read own activity bookings"
    ON public.activity_bookings FOR SELECT
    USING (auth.uid() = user_id);

-- Les hôtes peuvent lire les réservations de leurs activités
CREATE POLICY "Hosts can read bookings for own activities"
    ON public.activity_bookings FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.activities
            WHERE id = activity_id AND host_id = auth.uid()
        )
    );

-- Les utilisateurs peuvent créer des réservations d'activités
CREATE POLICY "Users can create activity bookings"
    ON public.activity_bookings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Les utilisateurs peuvent mettre à jour leurs propres réservations d'activités
CREATE POLICY "Users can update own activity bookings"
    ON public.activity_bookings FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ============================================
-- POLICIES: blocked_dates
-- ============================================

-- Les hôtes peuvent lire les dates bloquées de leurs listings
CREATE POLICY "Hosts can read blocked dates for own listings"
    ON public.blocked_dates FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.listings
            WHERE id = listing_id AND host_id = auth.uid()
        )
    );

-- Les utilisateurs peuvent lire les dates bloquées des listings actifs (pour vérifier disponibilité)
CREATE POLICY "Users can read blocked dates for active listings"
    ON public.blocked_dates FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.listings
            WHERE id = listing_id AND status = 'active'
        )
    );

-- Les hôtes peuvent créer des dates bloquées
CREATE POLICY "Hosts can create blocked dates"
    ON public.blocked_dates FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.listings
            WHERE id = listing_id AND host_id = auth.uid()
        )
    );

-- Les hôtes peuvent supprimer les dates bloquées de leurs listings
CREATE POLICY "Hosts can delete blocked dates for own listings"
    ON public.blocked_dates FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.listings
            WHERE id = listing_id AND host_id = auth.uid()
        )
    );

-- ============================================
-- POLICIES: notifications
-- ============================================

-- Les utilisateurs peuvent lire leurs propres notifications
CREATE POLICY "Users can read own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = user_id);

-- Les utilisateurs peuvent mettre à jour leurs propres notifications (marquer comme lu)
CREATE POLICY "Users can update own notifications"
    ON public.notifications FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Les utilisateurs peuvent supprimer leurs propres notifications
CREATE POLICY "Users can delete own notifications"
    ON public.notifications FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- FUNCTION: Créer automatiquement un profil lors de l'inscription
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, first_name, last_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour créer automatiquement un profil
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- FUNCTION: Vérifier si une date est disponible pour un listing
-- ============================================
CREATE OR REPLACE FUNCTION public.is_listing_available(
    p_listing_id UUID,
    p_check_in DATE,
    p_check_out DATE
)
RETURNS BOOLEAN AS $$
DECLARE
    v_listing RECORD;
    v_conflicting_reservation INTEGER;
    v_blocked_date_count INTEGER;
BEGIN
    -- Vérifier que le listing existe et est actif
    SELECT * INTO v_listing
    FROM public.listings
    WHERE id = p_listing_id AND status = 'active' AND is_available = TRUE;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

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


