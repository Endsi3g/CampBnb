# 📦 Structure des Packages - Campbnb Québec

## 🎯 Vue d'ensemble

Le projet Campbnb Québec est maintenant organisé en **monorepo** avec des packages séparés pour l'application mobile et l'application web.

## 📁 Structure

```
CampBnb/
├── packages/
│   ├── shared/          # Package partagé (core, features, shared)
│   ├── mobile/          # Application mobile (iOS & Android)
│   └── web/             # Application web (Flutter Web)
├── supabase/            # Backend Supabase
├── scripts/             # Scripts utilitaires
└── docs/                # Documentation
```

## 🚀 Démarrage Rapide

### Installation

```bash
# Installer les dépendances de chaque package
cd packages/shared && flutter pub get
cd ../mobile && flutter pub get
cd ../web && flutter pub get
```

### Développement

```bash
# Application mobile
cd packages/mobile
flutter run

# Application web
cd packages/web
flutter run -d chrome
```

## 📦 Packages

### 1. Package Shared (`packages/shared/`)

**Description** : Package Dart contenant tout le code partagé entre mobile et web.

**Contenu** :
- `lib/core/` : Configuration, routing, thème, services, monitoring
- `lib/features/` : Toutes les fonctionnalités métier (DDD)
- `lib/shared/` : Modèles, services, widgets partagés
- `assets/` : Assets partagés (images, fonts, translations)

**Documentation** : [packages/shared/README.md](packages/shared/README.md)

### 2. Package Mobile (`packages/mobile/`)

**Description** : Application Flutter pour iOS et Android.

**Contenu** :
- `lib/main.dart` : Point d'entrée mobile
- `android/` : Configuration Android
- `ios/` : Configuration iOS

**Documentation** : [packages/mobile/README.md](packages/mobile/README.md)

### 3. Package Web (`packages/web/`)

**Description** : Application Flutter Web.

**Contenu** :
- `lib/main.dart` : Point d'entrée web
- `web/` : Configuration web (index.html, manifest.json)

**Documentation** : [packages/web/README.md](packages/web/README.md)

## 📚 Documentation Complète

- **[Guide du Monorepo](packages/MONOREPO_GUIDE.md)** - Guide complet du monorepo
- **[Guide de Migration](packages/MIGRATION_GUIDE.md)** - Comment migrer le code existant
- **[Documentation des Packages](packages/PACKAGES_README.md)** - Documentation détaillée

## 🔄 Migration du Code Existant

Pour migrer le code existant vers la nouvelle structure :

```bash
# Script Bash
./scripts/migrate_to_monorepo.sh

# Script PowerShell (Windows)
.\scripts\migrate_to_monorepo.ps1
```

Voir [packages/MIGRATION_GUIDE.md](packages/MIGRATION_GUIDE.md) pour plus de détails.

## 🧪 Tests et CI/CD

### Tests

```bash
# Tests du package shared
cd packages/shared && flutter test

# Tests mobile
cd packages/mobile && flutter test

# Tests web
cd packages/web && flutter test
```

### CI/CD

Les workflows GitHub Actions sont configurés :
- `.github/workflows/mobile-ci.yml` : Tests et build mobile
- `.github/workflows/web-ci.yml` : Tests et build web

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

Des fichiers `.env.example` sont fournis dans chaque package.

## 📝 Notes Importantes

1. **Code Partagé** : Tout le code commun est dans `packages/shared/`
2. **Imports** : Utiliser `package:campbnb_shared/...` dans mobile/web
3. **Assets** : Les assets sont partagés depuis `packages/shared/assets/`
4. **Dépendances** : Les dépendances communes sont dans `packages/shared/pubspec.yaml`

## 🆘 Dépannage

### Erreur : Package not found

```bash
cd packages/mobile
flutter pub get
```

### Erreur : Asset not found

Vérifier que les assets sont dans `packages/shared/assets/` et référencés dans `packages/shared/pubspec.yaml`.

### Erreur : Import error

Vérifier que les imports utilisent `package:campbnb_shared/...` dans mobile/web.

## 🤝 Contribution

Voir le [Guide de Contribution](.github/CONTRIBUTING.md) pour plus d'informations.

