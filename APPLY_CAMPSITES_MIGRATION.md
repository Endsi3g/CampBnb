# Appliquer la Migration Campsites dans Supabase

## Vue d'ensemble

Ce guide vous explique comment appliquer la migration `005_campsites_table.sql` dans votre projet Supabase pour activer la fonctionnalité complète d'ajout d'emplacements de camping.

## Prérequis

- Accès à votre projet Supabase : https://supabase.com/dashboard/project/kniaisdkzeflauawmyka
- Les migrations précédentes doivent être appliquées (001, 002, 003, 004)
- Extension PostGIS disponible (activée automatiquement dans la migration)

## Méthode 1 : Via Supabase Dashboard (Recommandé) ⭐

### Étape 1 : Accéder à l'éditeur SQL

1. Allez sur : https://supabase.com/dashboard/project/kniaisdkzeflauawmyka
2. Dans le menu de gauche, cliquez sur **SQL Editor**
3. Cliquez sur **New query**

### Étape 2 : Copier le contenu de la migration

1. Ouvrez le fichier : `supabase/migrations/005_campsites_table.sql`
2. Copiez **tout le contenu** du fichier (Ctrl+A, Ctrl+C)

### Étape 3 : Exécuter la migration

1. Collez le contenu dans l'éditeur SQL de Supabase
2. Cliquez sur **Run** (ou appuyez sur Ctrl+Enter)
3. Attendez la confirmation de succès

### Étape 4 : Vérifier

Vous devriez voir un message de succès. Vérifiez ensuite :

```sql
-- Vérifier que la table existe
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'campsites';

-- Vérifier PostGIS
SELECT PostGIS_version();
```

## Méthode 2 : Via Supabase CLI

### Étape 1 : Installer Supabase CLI (si nécessaire)

```bash
# Windows (via Scoop)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# Ou via npm
npm install -g supabase
```

### Étape 2 : Se connecter à Supabase

```bash
supabase login
```

### Étape 3 : Lier le projet

```bash
supabase link --project-ref kniaisdkzeflauawmyka
```

### Étape 4 : Appliquer la migration

```bash
# Depuis la racine du projet
supabase db push

# Ou appliquer une migration spécifique
supabase migration up
```

## Méthode 3 : Via psql (Avancé)

### Étape 1 : Obtenir les credentials

1. Allez dans Supabase Dashboard > Settings > Database
2. Copiez les informations de connexion :
   - Host
   - Database name
   - Port
   - Password

### Étape 2 : Se connecter

```bash
psql -h [HOST] -U postgres -d postgres
```

### Étape 3 : Exécuter la migration

```bash
\i supabase/migrations/005_campsites_table.sql
```

## Vérification Post-Migration

### 1. Vérifier la table

```sql
-- Vérifier la structure
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'campsites' 
ORDER BY ordinal_position;
```

### 2. Vérifier PostGIS

```sql
-- Vérifier que PostGIS est activé
SELECT PostGIS_version();

-- Vérifier les extensions
SELECT * FROM pg_extension WHERE extname = 'postgis';
```

### 3. Vérifier les index

```sql
-- Vérifier les index créés
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'campsites';
```

### 4. Vérifier les triggers

```sql
-- Vérifier les triggers
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE event_object_table = 'campsites';
```

### 5. Vérifier les politiques RLS

```sql
-- Vérifier les politiques RLS
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'campsites';
```

### 6. Tester la fonction de recherche

```sql
-- Tester la recherche par proximité (Québec)
SELECT * FROM get_campsites_nearby(46.8139, -71.2080, 50000);
```

## Test d'Insertion

### Créer un campsite de test

```sql
-- Note: Remplacez [USER_ID] par un UUID d'utilisateur existant dans profiles
INSERT INTO public.campsites (
    name,
    description,
    latitude,
    longitude,
    type,
    host_id,
    price_per_night,
    is_available,
    region
) VALUES (
    'Camping Test',
    'Un camping de test pour vérifier la migration',
    46.8139,
    -71.2080,
    'tent',
    '[USER_ID]', -- Remplacez par un UUID valide
    45.00,
    TRUE,
    'Capitale-Nationale'
);
```

### Vérifier l'insertion

```sql
-- Voir le campsite créé
SELECT * FROM public.campsites WHERE name = 'Camping Test';

-- Vérifier que la géométrie PostGIS a été créée
SELECT name, location FROM public.campsites WHERE name = 'Camping Test';
```

## Dépannage

### Erreur : "extension postgis does not exist"

**Cause** : PostGIS n'est pas disponible dans votre instance Supabase.

**Solutions** :

1. **Vérifier la disponibilité** :
   ```sql
   SELECT * FROM pg_available_extensions WHERE name = 'postgis';
   ```

2. **Si PostGIS n'est pas disponible** :
   - Contactez le support Supabase
   - Ou utilisez une version alternative de la migration sans PostGIS (voir ci-dessous)

### Erreur : "permission denied"

**Cause** : Vous n'avez pas les permissions nécessaires.

**Solution** : Utilisez un compte avec les permissions d'administrateur.

### Erreur : "relation already exists"

**Cause** : La table `campsites` existe déjà.

**Solutions** :

1. **Vérifier l'existence** :
   ```sql
   SELECT * FROM information_schema.tables WHERE table_name = 'campsites';
   ```

2. **Si elle existe** :
   - Supprimez-la : `DROP TABLE public.campsites CASCADE;`
   - Réexécutez la migration

### Erreur : "function already exists"

**Cause** : La fonction `get_campsites_nearby` existe déjà.

**Solution** :
```sql
DROP FUNCTION IF EXISTS get_campsites_nearby(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION);
```
Puis réexécutez la migration.

## Version Alternative (Sans PostGIS)

Si PostGIS n'est pas disponible, voici une version simplifiée :

```sql
-- Version sans PostGIS (recherche par bounds)
CREATE TABLE public.campsites (
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

-- Index simples
CREATE INDEX idx_campsites_lat_lon ON public.campsites (latitude, longitude);
CREATE INDEX idx_campsites_type ON public.campsites (type);
CREATE INDEX idx_campsites_host_id ON public.campsites (host_id);
CREATE INDEX idx_campsites_is_available ON public.campsites (is_available);
CREATE INDEX idx_campsites_region ON public.campsites (region);

-- RLS (même que la version complète)
ALTER TABLE public.campsites ENABLE ROW LEVEL SECURITY;
-- ... (copiez les politiques RLS de la migration originale)
```

## Après la Migration

Une fois la migration appliquée avec succès :

1. ✅ La table `campsites` est créée
2. ✅ Les index sont en place
3. ✅ Les triggers fonctionnent
4. ✅ Les politiques RLS sont actives
5. ✅ La fonction `get_campsites_nearby()` est disponible

Vous pouvez maintenant :
- Ajouter des emplacements depuis l'application
- Rechercher par proximité
- Filtrer par type, région, prix
- Utiliser toutes les fonctionnalités Mapbox

## Support

Si vous rencontrez des problèmes :

1. Vérifiez les logs dans Supabase Dashboard > Logs
2. Consultez la documentation Supabase : https://supabase.com/docs
3. Vérifiez que toutes les migrations précédentes sont appliquées

---

**Migration appliquée avec succès ! 🎉**

