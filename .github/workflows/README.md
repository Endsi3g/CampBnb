# GitHub Actions Workflows - CampBnb

Ce dossier contient tous les workflows GitHub Actions pour le projet CampBnb.

## 📋 Workflows Disponibles

### 1. CI - Build & Tests (`.github/workflows/ci.yml`)

Workflow principal de CI/CD qui s'exécute sur chaque push et PR :

- ✅ Lint et format checks
- ✅ Tests unitaires avec coverage
- ✅ Build Android (APK)
- ✅ Build iOS
- ✅ Security scanning (Trivy)

**Déclencheurs :**
- Push sur `main`, `develop`, `feature/**`, `bugfix/**`
- Pull requests vers `main` ou `develop`

### 2. Deploy to Production (`.github/workflows/deploy.yml`)

Déploiement automatique vers Supabase et Netlify :

- ✅ Tests et validation
- ✅ Déploiement des migrations Supabase
- ✅ Déploiement des Edge Functions
- ✅ Déploiement Netlify
- ✅ Notifications

**Déclencheurs :**
- Push sur `main` ou `master`
- Pull requests vers `main` ou `master`
- Workflow dispatch manuel

### 3. Lint & Format (`.github/workflows/lint.yml`)

Vérification du formatage et du linting :

- ✅ Format Dart
- ✅ Analyse du code
- ✅ Lint checks

**Déclencheurs :**
- Pull requests vers `main` ou `develop`
- Push sur `main` ou `develop`

### 4. Security Scan (`.github/workflows/security.yml`)

Scan de sécurité automatisé :

- ✅ Scan de vulnérabilités (Trivy)
- ✅ Détection de secrets (TruffleHog)
- ✅ Upload vers GitHub Security

**Déclencheurs :**
- Push sur `main` ou `develop`
- Pull requests vers `main` ou `develop`
- Planification hebdomadaire (dimanche)

### 5. Sync Stitch Screens (`.github/workflows/sync-stitch-screens.yml`)

Synchronisation automatique des screens Google Stitch :

- ✅ Scan des screens Stitch
- ✅ Comparaison avec le manifest
- ✅ Génération de rapports
- ✅ Création automatique de PR

**Déclencheurs :**
- Planification quotidienne (2h UTC)
- Workflow dispatch manuel

### 6. PR Checks (`.github/workflows/pr-checks.yml`)

Validation automatique des Pull Requests :

- ✅ Validation du format du titre (Conventional Commits)
- ✅ Vérification des fichiers volumineux
- ✅ Détection de secrets

**Déclencheurs :**
- Pull requests (ouvertes, synchronisées, rouvertes)

## 🔐 Secrets Requis

### Obligatoires

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF` (ou `SUPABASE_PROJECT_ID`)
- `GOOGLE_MAPS_API_KEY`
- `GEMINI_API_KEY`

### Optionnels

- `NETLIFY_AUTH_TOKEN`
- `NETLIFY_SITE_ID`
- `STITCH_API_KEY`
- `SLACK_WEBHOOK_URL`
- `MAPBOX_ACCESS_TOKEN`

## 📊 Badges de Statut

Ajoutez ces badges à votre README :

```markdown
[![CI](https://github.com/Endsi3g/CampBnb/workflows/CI/badge.svg)](https://github.com/Endsi3g/CampBnb/actions)
[![Deploy](https://github.com/Endsi3g/CampBnb/workflows/Deploy%20to%20Production/badge.svg)](https://github.com/Endsi3g/CampBnb/actions)
```

## 🔧 Configuration

Tous les workflows sont configurés pour :
- Flutter 3.24.0
- Node.js 18
- Ubuntu Latest (pour la plupart)
- macOS Latest (pour iOS)

## 📚 Documentation

Pour plus d'informations :
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [Supabase CLI](https://supabase.com/docs/reference/cli)


