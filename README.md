# 🏕️ CampBnb - Plateforme de Réservation de Campings

[![CI](https://github.com/Endsi3g/CampBnb/workflows/CI/badge.svg)](https://github.com/Endsi3g/CampBnb/actions)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.24.0-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0.0-blue.svg)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)](https://supabase.com)

Plateforme de réservation de campings au Québec développée avec Flutter et Supabase. Application multiplateforme (iOS, Android, Web) avec architecture monorepo et intégration IA.

## ✨ Fonctionnalités Principales

- 🔐 **Authentification sécurisée** - Connexion via email, Google, Apple
- 🗺️ **Recherche intelligente** - Recherche de campings avec filtres avancés et IA
- 📅 **Réservations** - Système de réservation complet avec gestion des dates
- 💳 **Paiements** - Intégration Stripe pour les transactions sécurisées
- 💬 **Messagerie** - Communication en temps réel entre hôtes et invités
- ⭐ **Avis et évaluations** - Système de notation et commentaires
- 🤖 **IA Gemini** - Suggestions intelligentes, analyse de recherche, génération d'itinéraires
- 🗺️ **Cartographie** - Intégration Mapbox pour la visualisation interactive
- 🌍 **Multilingue** - Support FR/EN avec traduction automatique
- 📱 **Multiplateforme** - iOS, Android et Web

## 🏗️ Architecture

Le projet suit une architecture **Domain-Driven Design (DDD)** organisée en **monorepo** :

```
CampBnb/
├── packages/
│   ├── shared/      # Code partagé (core, features, shared)
│   ├── mobile/       # Application mobile (iOS & Android)
│   └── web/         # Application web (Flutter Web)
├── supabase/        # Backend Supabase (migrations, functions)
├── docs/            # Documentation complète
└── scripts/         # Scripts utilitaires
```

## 🚀 Démarrage Rapide

### Prérequis

- Flutter 3.24.0+
- Dart 3.0.0+
- Node.js (pour les scripts)
- Compte Supabase
- Clés API (Mapbox, Gemini, Stripe)

### Installation

```bash
# 1. Cloner le repository
git clone https://github.com/Endsi3g/CampBnb.git
cd CampBnb

# 2. Installer les dépendances globales
flutter pub get

# 3. Installer les dépendances de chaque package
cd packages/shared && flutter pub get
cd ../mobile && flutter pub get
cd ../web && flutter pub get
cd ../../

# 4. Configurer les variables d'environnement
# Voir CREATE_ENV_FILE.md pour les instructions détaillées
# Ou utiliser le script automatique :
.\scripts\create_env.ps1  # Windows
./scripts/create_env.sh   # Linux/Mac
```

### Lancer l'application

**Application Mobile :**
```bash
cd packages/mobile
flutter run
```

**Application Web :**
```bash
cd packages/web
flutter run -d chrome
```

## 📚 Documentation du Github


### Documentation Utilisateur

- **[Guides Utilisateurs](docs/user-guides/README.md)** - Guides pour invités et hôtes
- **[Tutoriels](docs/tutorials/README.md)** - Tutoriels pas à pas
- **[FAQ](docs/faq/README.md)** - Questions fréquentes
- **[Onboarding](docs/onboarding/README.md)** - Guides d'intégration

### Documentation Technique

- **[Architecture](docs/ARCHITECTURE.md)** - Architecture DDD et structure du projet
- **[API](docs/API.md)** - Documentation des endpoints API
- **[Déploiement](docs/DEPLOYMENT.md)** - Guide de déploiement
- **[Sécurité](docs/SECURITY.md)** - Politiques de sécurité
- **[Tests](docs/TESTING_GUIDE.md)** - Guide de tests
- **[Intégration Gemini](GEMINI_INTEGRATION.md)** - Documentation IA

### Configuration

- **[Guide de Configuration](docs/GUIDE_CONFIGURATION_COMPLETE.md)** - Configuration GitHub complète
- **[Variables d'Environnement](CREATE_ENV_FILE.md)** - Configuration des clés API
- **[Monorepo](packages/README.md)** - Guide de la structure monorepo
- **[Git Workflow](docs/GIT_WORKFLOW.md)** - Processus de développement

## 🛠️ Stack Technique

### Frontend
- **Flutter 3.24.0** - Framework multiplateforme
- **Dart 3.0.0** - Langage de programmation
- **Riverpod 2.5.1** - Gestion d'état
- **GoRouter 13.0.0** - Navigation
- **Mapbox** - Cartographie interactive

### Backend
- **Supabase** - Backend as a Service
  - PostgreSQL - Base de données
  - Auth - Authentification
  - Storage - Stockage de fichiers
  - Edge Functions - Fonctions serveur

### Services Externes
- **Google Gemini 2.0** - Intelligence artificielle
- **Stripe** - Paiements
- **Sentry** - Monitoring et erreurs
- **Mapbox** - Cartes et géolocalisation

### Outils de Développement
- **GitHub Actions** - CI/CD
- **Codecov** - Couverture de code
- **CodeQL** - Analyse de sécurité

## 📦 Structure Monorepo

Le projet est organisé en monorepo avec trois packages principaux :

- **`packages/shared/`** - Code partagé (core, features, shared)
- **`packages/mobile/`** - Application mobile (iOS & Android)
- **`packages/web/`** - Application web (Flutter Web)

Voir [packages/README.md](packages/README.md) pour plus de détails.

## 🤝 Contribution

Nous accueillons les contributions ! Veuillez consulter :

- **[Guide de Contribution](.github/CONTRIBUTING.md)** - Standards et processus
- **[Git Workflow](docs/GIT_WORKFLOW.md)** - Processus de développement
- **[Code de Conduite](.github/CODE_OF_CONDUCT.md)** - Règles de communauté

### Processus de Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 🔒 Sécurité

- Toutes les entrées utilisateur sont sanitizées
- Authentification sécurisée avec Supabase Auth
- Paiements via Stripe (PCI compliant)
- Variables d'environnement pour les clés API
- Row Level Security (RLS) sur Supabase

Voir [docs/SECURITY.md](docs/SECURITY.md) pour plus d'informations.

## 📄 Licence

Propriétaire - Campbnb Québec. Tous droits réservés.

## 📞 Support

- **Documentation** : [docs/README.md](docs/README.md)
- **FAQ** : [docs/faq/README.md](docs/faq/README.md)
- **Issues** : [GitHub Issues](https://github.com/Endsi3g/CampBnb/issues)

---

**Développé avec ❤️ pour les amoureux du camping au Québec**
