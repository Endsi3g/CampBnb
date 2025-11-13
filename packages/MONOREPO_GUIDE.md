# 📚 Guide du Monorepo Campbnb Québec

Ce guide explique comment travailler avec la structure monorepo de Campbnb Québec.

## 🏗️ Architecture

Le projet est organisé en monorepo avec trois packages principaux :

```
CampBnb/
├── packages/
│   ├── shared/      # Code partagé (core, features, shared)
│   ├── mobile/      # Application mobile
│   └── web/          # Application web
├── supabase/         # Backend Supabase
├── scripts/          # Scripts utilitaires
└── docs/             # Documentation
```

## 📦 Packages

### Package Shared (`packages/shared/`)

**Rôle** : Contient tout le code partagé entre mobile et web.

**Structure** :
```
lib/
├── core/              # Configuration, services, monitoring
├── features/          # Features métier (DDD)
│   ├── domain/        # Entités, repositories, use cases
│   ├── data/          # Datasources, models, repositories impl
│   └── presentation/  # Screens, widgets, providers
└── shared/            # Modèles, services, widgets partagés
```

**Utilisation** :
- Importé comme dépendance dans `mobile/` et `web/`
- Tous les imports utilisent `package:campbnb_shared/...`

### Package Mobile (`packages/mobile/`)

**Rôle** : Application Flutter pour iOS et Android.

**Structure** :
```
lib/
└── main.dart          # Point d'entrée mobile
```

**Spécificités** :
- Dépend de `campbnb_shared`
- Configuration Android dans `android/`
- Configuration iOS dans `ios/`

### Package Web (`packages/web/`)

**Rôle** : Application Flutter Web.

**Structure** :
```
lib/
└── main.dart          # Point d'entrée web
web/
├── index.html         # Point d'entrée HTML
└── manifest.json      # Manifeste PWA
```

**Spécificités** :
- Dépend de `campbnb_shared`
- Utilise `url_strategy` pour les URLs propres
- Configuration web dans `web/`

## 🔄 Workflow de Développement

### 1. Modifier le Code Partagé

```bash
# Éditer les fichiers dans packages/shared/lib/
cd packages/shared
# Faire vos modifications
flutter pub get
```

### 2. Tester les Modifications

```bash
# Tester sur mobile
cd packages/mobile
flutter pub get
flutter run

# Tester sur web
cd packages/web
flutter pub get
flutter run -d chrome
```

### 3. Build

```bash
# Build mobile
cd packages/mobile
flutter build apk --release        # Android
flutter build ios --release        # iOS

# Build web
cd packages/web
flutter build web --release
```

## 📝 Règles Importantes

### Imports dans le Package Shared

Tous les imports doivent être relatifs à `lib/` :

```dart
// ✅ Correct
import 'package:campbnb_shared/core/config/app_config.dart';
import 'package:campbnb_shared/features/auth/presentation/screens/login_screen.dart';

// ❌ Incorrect
import '../core/config/app_config.dart';
```

### Imports dans Mobile/Web

Utiliser le package shared :

```dart
// ✅ Correct
import 'package:campbnb_shared/core/config/app_config.dart';
import 'package:campbnb_shared/features/auth/presentation/screens/login_screen.dart';

// ❌ Incorrect (ne pas utiliser de chemins relatifs vers shared)
import '../../shared/core/config/app_config.dart';
```

### Dépendances Spécifiques à une Plateforme

- **Mobile** : `image_picker`, `permission_handler`, etc.
- **Web** : `url_strategy`, etc.
- **Shared** : Toutes les dépendances communes

## 🚀 Déploiement

### Mobile

1. Build l'application
2. Tester sur les appareils
3. Publier sur App Store / Google Play

### Web

1. Build l'application web
2. Déployer sur Netlify / Vercel
3. Configurer le CDN si nécessaire

## 🔧 Scripts Utilitaires

### Installer toutes les dépendances

```bash
# À la racine du projet
./scripts/install_all.sh
```

### Build toutes les applications

```bash
./scripts/build_all.sh
```

### Tests

```bash
# Tests du package shared
cd packages/shared
flutter test

# Tests mobile
cd packages/mobile
flutter test

# Tests web
cd packages/web
flutter test
```

## 📚 Ressources

- [Documentation Flutter](https://flutter.dev/docs)
- [Guide des Packages Dart](https://dart.dev/guides/packages)
- [Architecture du Projet](../docs/ARCHITECTURE.md)

