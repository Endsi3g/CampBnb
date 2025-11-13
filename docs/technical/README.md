# 🔧 Documentation Technique - Campbnb Québec

Documentation technique complète pour les développeurs travaillant sur Campbnb Québec.

## 📚 Structure de la Documentation

### 📦 Modules

Documentation détaillée pour chaque module de l'application :

- **[Module Authentification](modules/auth-module.md)** - Gestion de l'authentification
- **[Module Listings](modules/listing-module.md)** - Gestion des annonces de camping
- **[Module Réservations](modules/reservation-module.md)** - Système de réservation
- **[Module Messagerie](modules/messaging-module.md)** - Communication entre utilisateurs
- **[Module Cartes](modules/map-module.md)** - Intégration Mapbox
- **[Module IA](modules/ai-module.md)** - Intégration Gemini AI
- **[Module Profil](modules/profile-module.md)** - Gestion des profils utilisateurs
- **[Module Recherche](modules/search-module.md)** - Recherche intelligente

### 🤖 Agents

Documentation pour chaque agent du système :

- **[Agent Flutter](agents/flutter-agent.md)** - Développement Flutter
- **[Agent Backend](agents/backend-agent.md)** - Backend Supabase
- **[Agent IA](agents/ai-agent.md)** - Intégration Gemini
- **[Agent UI/UX](agents/ui-ux-agent.md)** - Design et interface
- **[Agent Mapbox](agents/mapbox-agent.md)** - Cartes et géolocalisation
- **[Agent GitHub](agents/github-agent.md)** - CI/CD et workflows

### 🔌 API

Documentation de l'API :

- **[Vue d'ensemble API](api/api-overview.md)** - Introduction à l'API
- **[API Authentification](api/authentication-api.md)** - Endpoints d'authentification
- **[API Listings](api/listings-api.md)** - Endpoints des annonces
- **[API Réservations](api/reservations-api.md)** - Endpoints de réservation
- **[Référence API](api/api-reference.md)** - Référence complète

## 🏗️ Architecture

### Stack Technique

- **Frontend** : Flutter 3.0+
- **Backend** : Supabase (PostgreSQL + Edge Functions)
- **Authentification** : Supabase Auth
- **Cartes** : Mapbox
- **IA** : Google Gemini 2.5
- **Paiements** : Stripe
- **CI/CD** : GitHub Actions

### Structure du Code

```
lib/
├── core/                    # Configuration, routing, thème
├── features/                # Features métier (domain-driven)
│   ├── auth/
│   ├── listing/
│   ├── reservation/
│   ├── messaging/
│   ├── map/
│   ├── ai_chat/
│   └── ...
└── shared/                  # Code partagé
    ├── models/
    ├── services/
    └── widgets/
```

## 🚀 Démarrage Rapide

### Pour les Développeurs

1. **Lire l'architecture** : [ARCHITECTURE.md](../ARCHITECTURE.md)
2. **Configuration** : [SETUP.md](../SETUP.md)
3. **Choisir un module** : Consulter la documentation du module
4. **Comprendre l'agent** : Consulter la documentation de l'agent

### Pour les Contributeurs

1. **Git Workflow** : [GIT_WORKFLOW.md](../GIT_WORKFLOW.md)
2. **Standards de code** : Voir les fichiers du module
3. **Tests** : Consulter les exemples de tests
4. **Pull Requests** : Suivre le processus de review

## 📖 Navigation

### Par Rôle

**Développeur Frontend (Flutter)**
- [Agent Flutter](agents/flutter-agent.md)
- [Module Authentification](modules/auth-module.md)
- [Module UI/UX](agents/ui-ux-agent.md)

**Développeur Backend**
- [Agent Backend](agents/backend-agent.md)
- [API Overview](api/api-overview.md)
- [Module Réservations](modules/reservation-module.md)

**Développeur IA**
- [Agent IA](agents/ai-agent.md)
- [Module IA](modules/ai-module.md)

**DevOps**
- [Agent GitHub](agents/github-agent.md)
- [DEPLOYMENT.md](../DEPLOYMENT.md)

## 🔄 Mise à Jour

Cette documentation est maintenue à jour par l'équipe de développement.

**Dernière mise à jour :** 2024  
**Version :** 1.0.0

---

**Pour toute question technique** : Ouvrez une issue sur GitHub avec le label `technical`

