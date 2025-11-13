-- ============================================
-- Campbnb Québec - Analytics RLS Policies
-- ============================================
-- Politiques de sécurité supplémentaires pour les analytics
-- Permet aux admins de lire toutes les données analytics

-- Fonction pour vérifier si un utilisateur est admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid()
        AND (email LIKE '%@campbnb.ca' OR email LIKE '%@admin.campbnb.ca')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Permettre aux admins de lire toutes les données analytics
CREATE POLICY "Admins can read all analytics events"
    ON public.analytics_events FOR SELECT
    USING (public.is_admin());

CREATE POLICY "Admins can read all analytics sessions"
    ON public.analytics_sessions FOR SELECT
    USING (public.is_admin());

CREATE POLICY "Admins can read all analytics conversions"
    ON public.analytics_conversions FOR SELECT
    USING (public.is_admin());

CREATE POLICY "Admins can read all analytics satisfaction"
    ON public.analytics_satisfaction FOR SELECT
    USING (public.is_admin());

CREATE POLICY "Admins can read all analytics behaviors"
    ON public.analytics_user_behaviors FOR SELECT
    USING (public.is_admin());



