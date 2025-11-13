# ⚡ INSTRUCTIONS SIMPLES - APPLIQUER LA MIGRATION

## 🎯 Méthode la plus simple (5 minutes)

### ÉTAPE 1 : Ouvrir Supabase

1. Allez sur : **https://supabase.com/dashboard/project/kniaisdkzeflauawmyka**
2. Connectez-vous

### ÉTAPE 2 : Ouvrir SQL Editor

1. Dans le menu de **GAUCHE**, cherchez **"SQL Editor"**
2. Cliquez dessus
3. Cliquez sur **"New query"** (bouton en haut)

### ÉTAPE 3 : Copier le script

1. Ouvrez le fichier **`MIGRATION_DIRECTE.sql`** dans ce projet
2. **Sélectionnez TOUT** (Ctrl+A)
3. **Copiez** (Ctrl+C)

### ÉTAPE 4 : Coller et exécuter

1. Dans Supabase SQL Editor, **collez** le script (Ctrl+V)
2. Cliquez sur **"Run"** (bouton en bas à droite)
3. **ATTENDEZ** 5-10 secondes

### ÉTAPE 5 : Vérifier

Vous devriez voir **"Success"** en vert.

Testez avec cette requête :

```sql
SELECT * FROM campsites LIMIT 1;
```

Si ça fonctionne (même si la table est vide), **C'EST BON ! ✅**

## 🔴 Si vous avez une erreur PostGIS

Si vous voyez l'erreur : `extension "postgis" does not exist`

**Solution** : Utilisez cette version SANS PostGIS :

```sql
-- Version SANS PostGIS
CREATE TABLE IF NOT EXISTS public.campsites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
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

-- Index
CREATE INDEX IF NOT EXISTS idx_campsites_lat_lon ON public.campsites (latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_campsites_type ON public.campsites (type);
CREATE INDEX IF NOT EXISTS idx_campsites_host_id ON public.campsites (host_id);
CREATE INDEX IF NOT EXISTS idx_campsites_is_available ON public.campsites (is_available);
CREATE INDEX IF NOT EXISTS idx_campsites_region ON public.campsites (region);

-- RLS
ALTER TABLE public.campsites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read available campsites"
    ON public.campsites FOR SELECT
    USING (is_available = TRUE);

CREATE POLICY "Authenticated users can read all campsites"
    ON public.campsites FOR SELECT
    TO authenticated
    USING (TRUE);

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

CREATE POLICY "Hosts can update own campsites"
    ON public.campsites FOR UPDATE
    TO authenticated
    USING (auth.uid() = host_id)
    WITH CHECK (auth.uid() = host_id);

CREATE POLICY "Hosts can delete own campsites"
    ON public.campsites FOR DELETE
    TO authenticated
    USING (auth.uid() = host_id);
```

## 📸 Capture d'écran - Où trouver SQL Editor

1. Dashboard Supabase
2. Menu de gauche → **"SQL Editor"** (icône de base de données)
3. Bouton **"New query"** en haut à droite
4. Collez le script
5. Cliquez **"Run"**

## ✅ Vérification finale

Exécutez ces requêtes pour vérifier :

```sql
-- 1. Vérifier la table
SELECT table_name FROM information_schema.tables 
WHERE table_name = 'campsites';

-- 2. Voir la structure
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'campsites';

-- 3. Vérifier RLS
SELECT policyname FROM pg_policies 
WHERE tablename = 'campsites';
```

Si vous voyez des résultats, **TOUT EST BON ! 🎉**

## 🆘 Besoin d'aide ?

Si ça ne fonctionne toujours pas :
1. Copiez le message d'erreur exact
2. Vérifiez que vous êtes bien connecté à Supabase
3. Vérifiez que vous avez les permissions d'administrateur

