# 📱 Campbnb Mobile

Application mobile Campbnb Québec pour iOS et Android.

## 🚀 Démarrage Rapide

### Prérequis

- Flutter 3.24.0 ou supérieur
- Dart 3.0.0 ou supérieur
- Xcode (pour iOS)
- Android Studio (pour Android)

### Installation

```bash
# Installer les dépendances
flutter pub get

# Configurer les variables d'environnement
# Copier .env.example vers .env et remplir les valeurs
cp .env.example .env

# Lancer l'application
flutter run
```

### Build

#### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

#### iOS

```bash
# Build iOS
flutter build ios --release
```

## 📁 Structure

```
lib/
└── main.dart          # Point d'entrée de l'application mobile
```

Le code principal est dans le package `campbnb_shared`.

## 🔧 Configuration

### Variables d'environnement

Créer un fichier `.env` à la racine avec :

```env
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_KEY=votre_cle_publique
MAPBOX_ACCESS_TOKEN=votre_token_mapbox
GEMINI_API_KEY=votre_cle_gemini
SENTRY_DSN=votre_dsn_sentry
```

### Android

Configuration dans `android/app/build.gradle`

### iOS

Configuration dans `ios/Runner/Info.plist`

## 📝 Notes

- Cette application utilise le package `campbnb_shared` pour le code commun
- Les fonctionnalités spécifiques au mobile peuvent être ajoutées ici
- Les assets sont partagés depuis le package shared

