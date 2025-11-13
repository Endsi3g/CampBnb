-- ============================================
-- Campbnb Québec - Politiques de Stockage
-- ============================================
-- Politiques RLS pour Supabase Storage

-- ============================================
-- BUCKET: listing-images
-- ============================================

-- Politique : Tout le monde peut lire les images de listings
CREATE POLICY "Public listing images are viewable by everyone"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'listing-images');

-- Politique : Seuls les hôtes peuvent uploader des images pour leurs listings
CREATE POLICY "Hosts can upload listing images"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'listing-images' AND
        auth.role() = 'authenticated' AND
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_host = TRUE
        )
    );

-- Politique : Les hôtes peuvent mettre à jour leurs propres images
CREATE POLICY "Hosts can update own listing images"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'listing-images' AND
        auth.role() = 'authenticated' AND
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_host = TRUE
        )
    )
    WITH CHECK (
        bucket_id = 'listing-images' AND
        auth.role() = 'authenticated'
    );

-- Politique : Les hôtes peuvent supprimer leurs propres images
CREATE POLICY "Hosts can delete own listing images"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'listing-images' AND
        auth.role() = 'authenticated' AND
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_host = TRUE
        )
    );

-- ============================================
-- BUCKET: profile-avatars
-- ============================================

-- Politique : Tout le monde peut lire les avatars
CREATE POLICY "Public avatars are viewable by everyone"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'profile-avatars');

-- Politique : Les utilisateurs peuvent uploader leur propre avatar
CREATE POLICY "Users can upload own avatar"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'profile-avatars' AND
        auth.role() = 'authenticated' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

-- Politique : Les utilisateurs peuvent mettre à jour leur propre avatar
CREATE POLICY "Users can update own avatar"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'profile-avatars' AND
        auth.role() = 'authenticated' AND
        (storage.foldername(name))[1] = auth.uid()::text
    )
    WITH CHECK (
        bucket_id = 'profile-avatars' AND
        auth.role() = 'authenticated' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

-- Politique : Les utilisateurs peuvent supprimer leur propre avatar
CREATE POLICY "Users can delete own avatar"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'profile-avatars' AND
        auth.role() = 'authenticated' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

-- ============================================
-- BUCKET: activity-images
-- ============================================

-- Politique : Tout le monde peut lire les images d'activités
CREATE POLICY "Public activity images are viewable by everyone"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'activity-images');

-- Politique : Seuls les hôtes peuvent uploader des images d'activités
CREATE POLICY "Hosts can upload activity images"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'activity-images' AND
        auth.role() = 'authenticated' AND
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_host = TRUE
        )
    );

-- Politique : Les hôtes peuvent mettre à jour leurs propres images d'activités
CREATE POLICY "Hosts can update own activity images"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'activity-images' AND
        auth.role() = 'authenticated' AND
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_host = TRUE
        )
    )
    WITH CHECK (
        bucket_id = 'activity-images' AND
        auth.role() = 'authenticated'
    );

-- Politique : Les hôtes peuvent supprimer leurs propres images d'activités
CREATE POLICY "Hosts can delete own activity images"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'activity-images' AND
        auth.role() = 'authenticated' AND
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_host = TRUE
        )
    );


