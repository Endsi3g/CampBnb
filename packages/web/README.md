# 🌐 Campbnb Web

Application web Campbnb Québec développée avec Flutter Web.

## 🚀 Démarrage Rapide

### Prérequis

- Flutter 3.24.0 ou supérieur
- Dart 3.0.0 ou supérieur
- Chrome ou Edge (pour le développement)

### Installation

```bash
# Installer les dépendances
flutter pub get

# Configurer les variables d'environnement
# Copier .env.example vers .env et remplir les valeurs
cp .env.example .env

# Lancer l'application en mode développement
flutter run -d chrome
```

### Build pour Production

```bash
# Build web
flutter build web --release

# Les fichiers seront dans build/web/
```

### Déploiement

#### Netlify

```bash
# Build
flutter build web --release

# Déployer sur Netlify
netlify deploy --prod --dir=build/web
```

#### Vercel

```bash
# Build
flutter build web --release

# Déployer sur Vercel
vercel --prod build/web
```

## 📁 Structure

```
lib/
└── main.dart          # Point d'entrée de l'application web
web/                   # Configuration web spécifique
└── index.html         # Point d'entrée HTML
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

### Configuration Web

Les fichiers de configuration web sont dans le dossier `web/` :
- `index.html` : Point d'entrée HTML
- `manifest.json` : Manifeste PWA
- `favicon.png` : Icône de l'application

## 📝 Notes

- Cette application utilise le package `campbnb_shared` pour le code commun
- Les fonctionnalités spécifiques au web peuvent être ajoutées ici
- Les assets sont partagés depuis le package shared
- Optimisé pour le responsive design et mobile-first

