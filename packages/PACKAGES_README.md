# 📦 Packages Campbnb Québec - Documentation Complète

## 🎯 Vue d'ensemble

Ce monorepo contient tous les packages de l'application Campbnb Québec, organisés pour faciliter le développement et la maintenance.

## 📁 Structure des Packages

```
packages/
├── shared/              # Package partagé (core, features, shared)
│   ├── lib/
│   │   ├── core/       # Configuration, services, monitoring
│   │   ├── features/   # Features métier (DDD)
│   │   └── shared/     # Modèles, services, widgets partagés
│   ├── assets/         # Assets partagés (images, fonts, translations)
│   ├── pubspec.yaml
│   └── README.md
│
├── mobile/              # Application mobile (iOS & Android)
│   ├── lib/
│   │   └── main.dart   # Point d'entrée mobile
│   ├── android/        # Configuration Android
│   ├── ios/            # Configuration iOS
│   ├── pubspec.yaml
│   └── README.md
│
└── web/                # Application web (Flutter Web)
    ├── lib/
    │   └── main.dart   # Point d'entrée web
    ├── web/            # Configuration web
    ├── pubspec.yaml
    └── README.md
```

## 🚀 Démarrage Rapide

### Installation

```bash
# Installer toutes les dépendances
cd packages/shared && flutter pub get
cd ../mobile && flutter pub get
cd ../web && flutter pub get
```

### Développement

```bash
# Lancer l'application mobile
cd packages/mobile
flutter run

# Lancer l'application web
cd packages/web
flutter run -d chrome
```

## 📦 Détails des Packages

### 1. Package Shared (`packages/shared/`)

**Description** : Package Dart contenant tout le code partagé entre mobile et web.

**Contenu** :
- **Core** : Configuration, routing, thème, services de base, monitoring
- **Features** : Toutes les fonctionnalités métier (auth, listing, reservation, etc.)
- **Shared** : Modèles, services et widgets partagés

**Dépendances** : Toutes les dépendances communes (Supabase, Riverpod, GoRouter, etc.)

**Utilisation** :
```dart
import 'package:campbnb_shared/core/config/app_config.dart';
import 'package:campbnb_shared/features/auth/presentation/screens/login_screen.dart';
```

### 2. Package Mobile (`packages/mobile/`)

**Description** : Application Flutter pour iOS et Android.

**Contenu** :
- Point d'entrée mobile (`lib/main.dart`)
- Configuration Android (`android/`)
- Configuration iOS (`ios/`)

**Dépendances** :
- `campbnb_shared` (package partagé)
- Dépendances spécifiques mobile (image_picker, permission_handler, etc.)

**Build** :
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

### 3. Package Web (`packages/web/`)

**Description** : Application Flutter Web.

**Contenu** :
- Point d'entrée web (`lib/main.dart`)
- Configuration web (`web/index.html`, `web/manifest.json`)

**Dépendances** :
- `campbnb_shared` (package partagé)
- Dépendances spécifiques web (url_strategy)

**Build** :
```bash
flutter build web --release
```

## 🔄 Workflow de Développement

### Modifier le Code Partagé

1. Éditer les fichiers dans `packages/shared/lib/`
2. Les modifications sont automatiquement disponibles dans mobile et web
3. Tester sur les deux plateformes

### Ajouter une Nouvelle Feature

1. Créer la feature dans `packages/shared/lib/features/`
2. Suivre l'architecture DDD (domain, data, presentation)
3. Utiliser Riverpod pour la gestion d'état
4. Tester sur mobile et web

### Dépendances Spécifiques à une Plateforme

- **Mobile** : Ajouter dans `packages/mobile/pubspec.yaml`
- **Web** : Ajouter dans `packages/web/pubspec.yaml`
- **Partagé** : Ajouter dans `packages/shared/pubspec.yaml`

## 🧪 Tests

### Tests du Package Shared

```bash
cd packages/shared
flutter test
```

### Tests Mobile

```bash
cd packages/mobile
flutter test
```

### Tests Web

```bash
cd packages/web
flutter test
```

## 📦 Build et Déploiement

### Mobile

1. Build l'application
2. Tester sur les appareils
3. Publier sur App Store / Google Play

### Web

1. Build l'application web
2. Déployer sur Netlify / Vercel
3. Configurer le CDN si nécessaire

## 🔧 Configuration

### Variables d'Environnement

Créer un fichier `.env` dans chaque package (mobile/web) :

```env
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_KEY=votre_cle_publique
MAPBOX_ACCESS_TOKEN=votre_token_mapbox
GEMINI_API_KEY=votre_cle_gemini
SENTRY_DSN=votre_dsn_sentry
```

### GitHub Actions

Les workflows CI/CD sont configurés dans `.github/workflows/` :
- `mobile-ci.yml` : Tests et build mobile
- `web-ci.yml` : Tests et build web

## 📚 Documentation

- [Guide du Monorepo](MONOREPO_GUIDE.md) - Guide complet du monorepo
- [Guide de Migration](MIGRATION_GUIDE.md) - Comment migrer le code existant
- [README Principal](../README.md) - Documentation principale du projet

## 🆘 Dépannage

### Erreur : Package not found

```bash
# Vérifier que le package shared est bien référencé
cd packages/mobile
flutter pub get
```

### Erreur : Asset not found

Vérifier que les assets sont bien dans `packages/shared/assets/` et que le `pubspec.yaml` du package shared les référence.

### Erreur : Import error

Vérifier que les imports utilisent `package:campbnb_shared/...` dans mobile/web.

## 🤝 Contribution

Voir le [Guide de Contribution](../.github/CONTRIBUTING.md) pour plus d'informations.

