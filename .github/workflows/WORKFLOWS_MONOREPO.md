# 🔄 Workflows GitHub Actions - Structure Monorepo

## 📋 Vue d'ensemble

Tous les workflows GitHub Actions ont été mis à jour pour fonctionner avec la nouvelle structure monorepo.

## 🔧 Workflows Mis à Jour

### 1. **Lint & Format** (`.github/workflows/lint.yml`)

Vérifie le formatage et l'analyse du code pour tous les packages :
- `packages/shared/`
- `packages/mobile/`
- `packages/web/`

### 2. **CI - Build & Tests** (`.github/workflows/ci.yml`)

Workflow principal de CI/CD avec :
- **Lint & Format Check** : Vérifie le formatage et l'analyse
- **Unit Tests** : Exécute les tests pour tous les packages
- **Build Android** : Build l'APK depuis `packages/mobile/`
- **Build iOS** : Build iOS depuis `packages/mobile/`
- **Security Scan** : Scan de sécurité avec Trivy

### 3. **Deploy to Production** (`.github/workflows/deploy.yml`)

Déploiement en production :
- **Tests et Validation** : Tests Flutter pour tous les packages
- **Déployer Migrations Supabase** : Déploie les migrations DB
- **Déployer sur Netlify** : Build et déploie l'app web depuis `packages/web/`

### 4. **Security Scan** (`.github/workflows/security.yml`)

Scan de sécurité avec Trivy et détection de secrets.

### 5. **Mobile CI** (`.github/workflows/mobile-ci.yml`)

CI spécifique pour l'application mobile.

### 6. **Web CI** (`.github/workflows/web-ci.yml`)

CI spécifique pour l'application web.

## 📝 Changements Principaux

### Structure des Commandes

Tous les workflows utilisent maintenant la structure monorepo :

```yaml
- name: Install dependencies
  run: |
    cd packages/shared && flutter pub get
    cd ../mobile && flutter pub get
    cd ../web && flutter pub get
```

### Chemins de Build

- **Android APK** : `packages/mobile/build/app/outputs/flutter-apk/app-release.apk`
- **Web Build** : `packages/web/build/web`
- **Coverage** : `packages/shared/coverage/lcov.info`, etc.

### Génération de Code

La génération de code se fait uniquement dans `packages/shared/` :

```yaml
- name: Generate code
  run: |
    cd packages/shared
    flutter pub run build_runner build --delete-conflicting-outputs
```

## 🚀 Utilisation

Les workflows se déclenchent automatiquement sur :
- **Push** vers `main`, `develop`, `feature/**`, `bugfix/**`
- **Pull Request** vers `main` ou `develop`

## ⚙️ Variables d'Environnement Requises

Assurez-vous que les secrets suivants sont configurés dans GitHub :

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF`
- `MAPBOX_ACCESS_TOKEN`
- `GEMINI_API_KEY`
- `NETLIFY_SITE_ID`
- `NETLIFY_AUTH_TOKEN`

## 🔍 Dépannage

### Erreur : "unable to find directory"

Vérifiez que les assets sont bien dans `packages/shared/assets/`.

### Erreur : "package not found"

Exécutez `flutter pub get` dans chaque package.

### Erreur : "code generation failed"

Exécutez `flutter pub run build_runner build --delete-conflicting-outputs` dans `packages/shared/`.

