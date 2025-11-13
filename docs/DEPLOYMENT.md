# Guide de Déploiement - Campbnb Québec

Ce guide décrit le processus de déploiement de l'application Campbnb Québec.

## Prérequis

- Compte Supabase configuré
- Compte Netlify (si déploiement web)
- Clés API configurées (Google Maps, Gemini)
- Accès aux secrets GitHub

## Déploiement Automatique

### Via GitHub Actions

Le déploiement est automatique lors d'un push sur `main`:

1. **CI Checks**: Tests, lint, build
2. **Deploy Supabase**: Migrations de base de données
3. **Deploy Netlify**: Déploiement web (si applicable)
4. **Notification**: Notification Slack (si configuré)

### Workflow

Voir [.github/workflows/deploy.yml](../.github/workflows/deploy.yml)

## Déploiement Mobile

### Android

#### Build APK

```bash
flutter build apk --release
```

#### Build App Bundle (pour Play Store)

```bash
flutter build appbundle --release
```

#### Configuration

1. Configurer les clés de signature dans `android/key.properties`
2. Configurer les variables d'environnement
3. Build et upload vers Play Store

### iOS

#### Build IPA

```bash
flutter build ipa --release
```

#### Configuration

1. Configurer les certificats dans Xcode
2. Configurer les variables d'environnement
3. Build et upload vers App Store Connect

## ️ Déploiement Supabase

### Migrations

Les migrations sont dans `backend/migrations/` (si applicable)

#### Via CLI

```bash
# Installer Supabase CLI
npm install -g supabase

# Lier le projet
supabase link --project-ref YOUR_PROJECT_ID

# Appliquer les migrations
supabase db push
```

#### Via GitHub Actions

Automatique lors du déploiement sur `main`

### Edge Functions

```bash
# Déployer une function
supabase functions deploy function_name
```

## Déploiement Netlify

### Configuration

1. Créer un site sur Netlify
2. Configurer les variables d'environnement
3. Configurer le build command: `flutter build web`
4. Configurer le publish directory: `build/web`

### Via GitHub Actions

Automatique si `NETLIFY_AUTH_TOKEN` et `NETLIFY_SITE_ID` sont configurés

## Variables d'Environnement

### Production

Configurer dans:

- **Supabase**: Dashboard > Settings > API
- **Netlify**: Site settings > Environment variables
- **GitHub Secrets**: Repository settings > Secrets

### Variables Requises

```
SUPABASE_URL=your_production_url
SUPABASE_ANON_KEY=your_production_key
GOOGLE_MAPS_API_KEY=your_production_key
GEMINI_API_KEY=your_production_key
```

## Monitoring

### Sentry

Configurer Sentry pour le monitoring des erreurs:

1. Créer un projet Sentry
2. Configurer le DSN dans les variables d'environnement
3. Intégrer dans l'application

### Analytics

- Supabase Analytics (utilisé)

## Rollback

### Supabase

```bash
# Revenir à une migration précédente
supabase migration repair --status reverted
```

### Netlify

Via le dashboard Netlify: Deploys > Rollback

### Mobile

- **Android**: Publier une version précédente via Play Console
- **iOS**: Publier une version précédente via App Store Connect

## Checklist de Déploiement

Avant chaque déploiement en production:

- [ ] Tous les tests passent
- [ ] Code review approuvé
- [ ] Variables d'environnement configurées
- [ ] Migrations testées en staging
- [ ] Build de production testé
- [ ] Documentation à jour
- [ ] Changelog mis à jour
- [ ] Backup de la base de données

## Environnement Staging

### Configuration

Créer un environnement de staging séparé:

- Projet Supabase staging
- Site Netlify staging
- Clés API de test

### Déploiement

Déployer sur `develop` pour staging automatique (si configuré)

## Ressources

- [Flutter Deployment](https://docs.flutter.dev/deployment)
- [Supabase Deployment](https://supabase.com/docs/guides/platform)
- [Netlify Deployment](https://docs.netlify.com/)


