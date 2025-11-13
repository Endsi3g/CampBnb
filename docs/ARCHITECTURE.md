# Architecture - Campbnb Québec

## ️ Vue d'ensemble

Campbnb Québec suit une architecture **Domain-Driven Design (DDD)** avec une séparation claire des responsabilités.

## Structure du Projet

```
CampBnb/
├── frontend/ # Application Flutter mobile
│ ├── lib/
│ │ ├── core/ # Code partagé (config, constants, utils)
│ │ ├── features/ # Features métier (architecture DDD)
│ │ ├── shared/ # Composants et widgets partagés
│ │ └── main.dart
│ ├── test/ # Tests unitaires et d'intégration
│ └── pubspec.yaml
│
├── backend/ # Backend Supabase (si applicable)
│ ├── migrations/ # Migrations de base de données
│ ├── functions/ # Edge Functions Supabase
│ └── policies/ # RLS Policies
│
├── docs/ # Documentation technique
│ ├── ARCHITECTURE.md # Ce fichier
│ ├── API.md # Documentation API
│ ├── DEPLOYMENT.md # Guide de déploiement
│ └── STITCH_SCREENS.md # Synchronisation screens
│
├── assets/ # Assets statiques
│ ├── images/
│ ├── icons/
│ ├── animations/
│ └── fonts/
│
├── scripts/ # Scripts utilitaires
│ └── sync_stitch_screens.py # Synchronisation screens
│
└── stitch_reservation_process_screen/ # Screens Google Stitch
```

## Architecture Domain-Driven

### Structure d'une Feature

Chaque feature suit cette structure:

```
lib/features/feature_name/
├── domain/ # Couche domaine (business logic)
│ ├── entities/ # Entités métier
│ ├── repositories/ # Interfaces de repositories
│ └── use_cases/ # Cas d'usage
│
├── data/ # Couche données
│ ├── datasources/ # Sources de données (API, local)
│ ├── models/ # Modèles de données
│ └── repositories/ # Implémentations des repositories
│
└── presentation/ # Couche présentation
├── screens/ # Écrans
├── widgets/ # Widgets spécifiques
└── providers/ # Riverpod providers
```

### Exemple: Feature Reservation

```
lib/features/reservation/
├── domain/
│ ├── entities/
│ │ └── reservation.dart
│ ├── repositories/
│ │ └── reservation_repository.dart
│ └── use_cases/
│ ├── create_reservation.dart
│ └── cancel_reservation.dart
│
├── data/
│ ├── datasources/
│ │ ├── reservation_remote_datasource.dart
│ │ └── reservation_local_datasource.dart
│ ├── models/
│ │ └── reservation_model.dart
│ └── repositories/
│ └── reservation_repository_impl.dart
│
└── presentation/
├── screens/
│ ├── reservation_screen.dart
│ └── reservation_details_screen.dart
├── widgets/
│ └── reservation_card.dart
└── providers/
└── reservation_provider.dart
```

## Flux de Données

```
UI (Presentation)
↓
Provider (Riverpod)
↓
Use Case (Domain)
↓
Repository Interface (Domain)
↓
Repository Implementation (Data)
↓
DataSource (Data)
↓
API / Local Storage
```

## Design System

### Couleurs

Définies dans `lib/core/theme/app_colors.dart`:

- **Primary**: `#2D572C` (Vert forêt)
- **Secondary**: `#3B8EA5` (Bleu lac)
- **Accent**: `#F5E5D5` (Beige bois)
- **Neutral**: `#F5F5DC` (Beige clair)

### Typographie

- **Font Family**: Plus Jakarta Sans
- **Weights**: Regular (400), Medium (500), Bold (700), ExtraBold (800)

## Services Externes

### Supabase

- **Auth**: Authentification utilisateur
- **Database**: PostgreSQL avec RLS
- **Storage**: Stockage d'images
- **Realtime**: Messagerie en temps réel

### Google Services

- **Maps**: Cartographie interactive
- **Gemini**: IA pour recherche intelligente

### Notifications

- **Supabase Realtime**: Notifications push en temps réel
- **Flutter Local Notifications**: Notifications locales

## Tests

### Structure

```
test/
├── unit/ # Tests unitaires
│ ├── features/
│ └── core/
├── widget/ # Tests de widgets
│ └── shared/
└── integration/ # Tests d'intégration
└── features/
```

### Couverture

- **Minimum**: 70% pour le code critique
- **Cible**: 80% global

## Dépendances Principales

### State Management
- `flutter_riverpod`: Gestion d'état réactive

### Navigation
- `go_router`: Navigation déclarative

### Backend
- `supabase_flutter`: Client Supabase

### UI
- `google_fonts`: Polices
- `cached_network_image`: Images en cache
- `flutter_svg`: SVG

### Utilitaires
- `freezed`: Génération de code
- `json_serializable`: Sérialisation JSON
- `logger`: Logging

## Sécurité

### Authentification

- JWT tokens via Supabase
- Refresh tokens automatiques
- Sessions expirées après inactivité

### Données

- RLS (Row Level Security) sur Supabase
- Chiffrement des données sensibles
- Validation côté client et serveur

### API

- HTTPS uniquement
- Tokens dans les headers
- Rate limiting

## Performance

### Optimisations

- Lazy loading des images
- Code splitting
- Cache local (Hive)
- Pagination des listes

### Monitoring

- Sentry pour les erreurs
- Analytics pour les performances
- Logs structurés

## Ressources

- [Flutter Best Practices](https://docs.flutter.dev/development/best-practices)
- [Riverpod Documentation](https://riverpod.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)


