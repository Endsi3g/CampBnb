# 🚀 APPLIQUER LA MIGRATION - GUIDE SIMPLE

## ⚠️ IMPORTANT : Suivez ces étapes EXACTEMENT

### Étape 1 : Ouvrir Supabase Dashboard

1. Allez sur : **https://supabase.com/dashboard/project/kniaisdkzeflauawmyka**
2. Connectez-vous si nécessaire

### Étape 2 : Ouvrir l'éditeur SQL

1. Dans le menu de **GAUCHE**, cliquez sur **"SQL Editor"** (icône de base de données)
2. Cliquez sur le bouton **"New query"** (en haut à droite)

### Étape 3 : Copier le script SQL

1. Ouvrez le fichier : `supabase/migrations/005_campsites_table.sql`
2. **Sélectionnez TOUT** le contenu (Ctrl+A)
3. **Copiez** (Ctrl+C)

### Étape 4 : Coller et exécuter

1. **Collez** le contenu dans l'éditeur SQL de Supabase (Ctrl+V)
2. Cliquez sur le bouton **"Run"** (en bas à droite, ou appuyez sur Ctrl+Enter)
3. **ATTENDEZ** que le script se termine (peut prendre quelques secondes)

### Étape 5 : Vérifier le succès

Vous devriez voir un message vert "Success" en bas de l'écran.

Ensuite, exécutez cette requête pour vérifier :

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'campsites';
```

Si vous voyez `campsites` dans les résultats, **C'EST BON ! ✅**

## 🔍 Si ça ne fonctionne pas

### Erreur : "extension postgis does not exist"

**Solution** : Exécutez d'abord cette ligne seule :

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

Puis réessayez le script complet.

### Erreur : "relation already exists"

**Solution** : La table existe déjà. Supprimez-la d'abord :

```sql
DROP TABLE IF EXISTS public.campsites CASCADE;
```

Puis réexécutez le script complet.

### Erreur : "permission denied"

**Solution** : Vous devez être connecté avec un compte administrateur.

## 📋 Script SQL Complet (à copier-coller)

Le script complet est dans : `supabase/migrations/005_campsites_table.sql`

**OU** utilisez le script simplifié ci-dessous :

