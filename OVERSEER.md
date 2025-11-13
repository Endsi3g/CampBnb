# Campbnb Québec - Document de Supervision Technique

**Agent Overseer** | Dernière mise à jour: 2024

---

## Mission

L'agent Overseer est responsable de la cohérence globale du projet Campbnb Québec, de la coordination entre tous les agents (Flutter, Backend, IA Gemini, UI/UX, GitHub, Mapbox) et de la qualité du produit final.

---

## ️ Architecture du Projet

### Stack Technique

| Composant | Technologie | Statut |
|-----------|------------|--------|
| **Frontend** | Flutter 3.0+ | Actif |
| **Backend** | Supabase (PostgreSQL + Edge Functions) | Actif |
| **Authentification** | Supabase Auth (Email, Google, Apple) | Actif |
| **Base de données** | PostgreSQL (Supabase) | Actif |
| **Storage** | Supabase Storage | Actif |
| **Cartes** | Mapbox | Actif |
| **IA** | Google Gemini 2.5 | Actif |
| **Paiements** | Stripe | ️ À implémenter |
| **Notifications** | Firebase Cloud Messaging | ️ À implémenter |
| **CI/CD** | GitHub Actions | Actif |
| **Hébergement** | Netlify (Frontend) + Supabase (Backend) | Actif |

### Structure du Code

```
lib/
├── core/ # Configuration, routing, thème
├── features/ # Features métier (domain-driven)
│ ├── auth/
│ ├── home/
│ ├── search/
│ ├── listing/
│ ├── reservation/
│ ├── map/
│ ├── profile/
│ ├── settings/
│ ├── host/
│ ├── messaging/
│ ├── onboarding/
│ ├── ai_chat/
│ └── ai_features/
└── shared/ # Code partagé (models, services, widgets)
```

---

## Agents et Responsabilités

### Agent Flutter
**Responsabilités:**
- Développement des screens Flutter (51 screens Google Stitch)
- Implémentation de l'architecture domain-driven
- Intégration des widgets UI/UX
- Gestion d'état avec Riverpod
- Navigation avec GoRouter

**Checklist Qualité:**
- [ ] Tous les screens respectent le design system
- [ ] Tests unitaires pour chaque feature
- [ ] Accessibilité (a11y) validée
- [ ] Performance optimisée (lazy loading, pagination)
- [ ] Mode dark/light fonctionnel

### Agent Backend
**Responsabilités:**
- Développement des Edge Functions Supabase
- Configuration de la base de données PostgreSQL
- Mise en place des politiques RLS (Row Level Security)
- Gestion des migrations
- API REST complète

**Checklist Qualité:**
- [ ] Toutes les tables ont des politiques RLS
- [ ] Validation des entrées utilisateur
- [ ] Gestion d'erreurs robuste
- [ ] Tests d'intégration pour chaque endpoint
- [ ] Documentation API à jour

### Agent IA Gemini
**Responsabilités:**
- Intégration Google Gemini 2.5
- Développement des fonctionnalités IA (chatbot, suggestions, traduction)
- Optimisation des prompts
- Monitoring de l'utilisation API
- Gestion des limites de taux

**Checklist Qualité:**
- [ ] Tous les widgets IA fonctionnent
- [ ] Gestion des erreurs API
- [ ] Monitoring et logs en place
- [ ] Prompts optimisés et testés
- [ ] Documentation des fonctionnalités IA

### Agent UI/UX
**Responsabilités:**
- Respect des 51 screens Google Stitch
- Cohérence du design system
- Validation des flux utilisateurs
- Tests d'utilisabilité
- Accessibilité (contraste, navigation clavier)

**Checklist Qualité:**
- [ ] Tous les screens correspondent aux maquettes Stitch
- [ ] Design system cohérent (couleurs, typographie, espacements)
- [ ] Flux utilisateurs validés
- [ ] Responsive/mobile-first
- [ ] Accessibilité WCAG 2.1 AA

### ️ Agent Mapbox
**Responsabilités:**
- Intégration Mapbox dans l'application
- Géolocalisation et géocodage
- Affichage des campings sur la carte
- Calcul de distances et itinéraires
- Gestion des permissions de localisation

**Checklist Qualité:**
- [ ] Carte interactive fonctionnelle
- [ ] Marqueurs des campings corrects
- [ ] Géolocalisation opérationnelle
- [ ] Performance optimisée (clustering)
- [ ] Gestion des erreurs de localisation

### Agent GitHub
**Responsabilités:**
- Gestion des branches et PRs
- Synchronisation des screens Google Stitch
- CI/CD avec GitHub Actions
- Documentation et changelog
- Gestion des issues

**Checklist Qualité:**
- [ ] Workflow CI/CD fonctionnel
- [ ] Synchronisation automatique des screens Stitch
- [ ] Documentation à jour
- [ ] Code review obligatoire avant merge
- [ ] Tests automatisés avant déploiement

---

## Suivi des Screens Google Stitch (51 screens)

### État d'Implémentation

| Catégorie | Screens | Implémentés | En cours | À faire |
|-----------|---------|-------------|----------|---------|
| **Authentification** | 4 | 4 | - | - |
| **Navigation principale** | 5 | 5 | - | - |
| **Recherche** | 3 | 3 | - | - |
| **Détails camping** | 4 | 1 | 3 | - |
| **Réservation** | 6 | 1 | 5 | - |
| **Profil & Paramètres** | 4 | 2 | 2 | - |
| **Hôte** | 5 | 2 | 3 | - |
| **Messagerie** | 3 | 1 | 2 | - |
| **Carte** | 2 | 2 | - | - |
| **IA & Support** | 4 | 2 | 2 | - |
| **Autres** | 11 | 0 | 5 | ️ 6 |
| **TOTAL** | **51** | **23** | **22** | **6** |

### Priorités d'Implémentation

1. ** Critique (MVP)**
- [ ] Processus de réservation complet
- [ ] Paiement Stripe intégré
- [ ] Gestion des réservations (hôte)
- [ ] Messagerie complète

2. ** Haute Priorité**
- [ ] Édition de listing
- [ ] Détails de réservation
- [ ] Favoris
- [ ] Avis et évaluations

3. ** Moyenne Priorité**
- [ ] Mode hors ligne
- [ ] Notifications push
- [ ] Recherche vocale
- [ ] Partage social

---

## Planification Sprints

### Sprint 1: MVP Backend (Semaine 1-2)
**Objectif:** Backend fonctionnel avec toutes les API

- [ ] Migrations base de données complètes
- [ ] Edge Functions pour listings, réservations, profils
- [ ] Politiques RLS configurées
- [ ] Tests d'intégration API
- [ ] Documentation API complète

### Sprint 2: MVP Frontend Core (Semaine 3-4)
**Objectif:** Fonctionnalités essentielles utilisateur

- [ ] Authentification complète
- [ ] Recherche et filtres
- [ ] Détails camping
- [ ] Processus de réservation
- [ ] Profil utilisateur

### Sprint 3: Fonctionnalités Hôte (Semaine 5-6)
**Objectif:** Dashboard hôte fonctionnel

- [ ] Dashboard hôte
- [ ] Création/édition listing
- [ ] Gestion des réservations
- [ ] Statistiques hôte
- [ ] Upload d'images

### Sprint 4: IA & Expérience Utilisateur (Semaine 7-8)
**Objectif:** Intégration complète Gemini et amélioration UX

- [ ] Chatbot contextuel
- [ ] Suggestions intelligentes
- [ ] Traduction FR/EN
- [ ] Résumé d'avis IA
- [ ] Expériences locales

### Sprint 5: Paiements & Notifications (Semaine 9-10)
**Objectif:** Paiements et communication

- [ ] Intégration Stripe
- [ ] Notifications push (Firebase)
- [ ] Emails transactionnels
- [ ] Webhooks paiement
- [ ] Historique transactions

### Sprint 6: Optimisation & Tests (Semaine 11-12)
**Objectif:** Performance, sécurité, tests

- [ ] Tests E2E complets
- [ ] Optimisation performance
- [ ] Audit sécurité
- [ ] Accessibilité complète
- [ ] Documentation utilisateur

---

## Checklists Qualité

### Checklist Code Review

**Avant chaque PR:**
- [ ] Code respecte les conventions du projet
- [ ] Pas de secrets/credentials dans le code
- [ ] Tests unitaires ajoutés/modifiés
- [ ] Documentation mise à jour si nécessaire
- [ ] Pas de warnings du linter
- [ ] Build réussit sans erreurs
- [ ] Screens respectent le design system
- [ ] Accessibilité vérifiée

### Checklist Sécurité

**À vérifier régulièrement:**
- [ ] Row Level Security (RLS) activé sur toutes les tables
- [ ] Validation des entrées utilisateur (frontend + backend)
- [ ] Sanitization des données
- [ ] HTTPS uniquement en production
- [ ] Secrets dans variables d'environnement
- [ ] Pas de données sensibles dans les logs
- [ ] Authentification requise pour actions sensibles
- [ ] Permissions vérifiées (RBAC)

### Checklist Performance

**À optimiser:**
- [ ] Lazy loading des images
- [ ] Pagination des listes
- [ ] Cache des données fréquentes
- [ ] Optimisation des requêtes DB (éviter N+1)
- [ ] Code splitting Flutter
- [ ] Minification assets production
- [ ] Monitoring performance (APM)

### Checklist UI/UX

**À valider:**
- [ ] Design system cohérent
- [ ] Responsive/mobile-first
- [ ] Mode dark/light fonctionnel
- [ ] Accessibilité (contraste, labels, navigation clavier)
- [ ] Feedback utilisateur (loading, erreurs, succès)
- [ ] Animations fluides
- [ ] Cohérence avec screens Stitch

---

## Gestion des Risques

### Risques Techniques Identifiés

| Risque | Impact | Probabilité | Mitigation | Statut |
|--------|--------|-------------|------------|--------|
| **Limites API Gemini** | Élevé | Moyenne | Monitoring + cache + fallback | En cours |
| **Performance Mapbox** | Moyen | Faible | Clustering + lazy loading | Mitigé |
| **Coûts Supabase** | Moyen | Faible | Monitoring usage + optimisations | En cours |
| **Complexité réservations** | Élevé | Élevée | Tests E2E + validation stricte | En cours |
| **Intégration Stripe** | Élevé | Moyenne | Tests sandbox + webhooks | ️ À faire |
| **Synchronisation Stitch** | Faible | Faible | Scripts automatisés | Mitigé |

### Actions Correctives

1. **Limites API Gemini**
- Monitoring en place
- Implémenter cache agressif
- ️ Prévoir fallback sans IA

2. **Performance Mapbox**
- Clustering implémenté
- Lazy loading des marqueurs
- Optimiser requêtes géospatiales

3. **Coûts Supabase**
- Monitoring des requêtes
- ️ Optimiser les Edge Functions
- ️ Cache côté client

---

## Métriques de Succès

### KPIs Techniques

- **Couverture de tests**: Objectif 80%+
- **Temps de build**: < 5 minutes
- **Temps de réponse API**: < 200ms (p95)
- **Taux d'erreur**: < 0.1%
- **Performance Lighthouse**: 90+ (mobile)

### KPIs Fonctionnels

- **Screens implémentés**: 23/51 (45%)
- **Fonctionnalités IA**: 9/9 (100%)
- **Endpoints API**: 30+ implémentés
- **Documentation**: 95% complète

---

## Points de Synchronisation

### Réunions Techniques Hebdomadaires

**Chaque lundi 10h:**
- Revue des objectifs de la semaine
- Blocages et risques
- Priorisation des tâches
- Validation des choix techniques

### Reviews Code

**Tous les jours:**
- Review des PRs ouvertes
- Validation des merges
- Feedback technique

### Documentation

**Chaque vendredi:**
- Mise à jour de la documentation
- Changelog
- Rapport d'avancement

---

## Documentation Centralisée

### Documents de Supervision (Overseer)

- **[OVERSEER.md](OVERSEER.md)** - Ce document (vue d'ensemble supervision)
- **[docs/OVERSEER_TASKS.md](docs/OVERSEER_TASKS.md)** - Suivi détaillé des tâches par agent
- **[docs/OVERSEER_CHECKLISTS.md](docs/OVERSEER_CHECKLISTS.md)** - Checklists qualité complètes
- **[docs/OVERSEER_ROADMAP.md](docs/OVERSEER_ROADMAP.md)** - Roadmap technique et planification
- **[docs/OVERSEER_RISKS.md](docs/OVERSEER_RISKS.md)** - Gestion des risques techniques
- **[docs/OVERSEER_SYNC.md](docs/OVERSEER_SYNC.md)** - Synchronisation et communication inter-agents
- **[docs/OVERSEER_ACTIONS_IMMEDIATES.md](docs/OVERSEER_ACTIONS_IMMEDIATES.md)** - Actions immédiates et blocages critiques
- **[docs/OVERSEER_REUNIONS.md](docs/OVERSEER_REUNIONS.md)** - Calendrier et procédures des réunions
- **[docs/OVERSEER_INDEX.md](docs/OVERSEER_INDEX.md)** - Index centralisé de la documentation

### Documents Techniques Principaux

- **[README.md](README.md)** - Vue d'ensemble du projet
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Architecture technique
- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - Documentation API complète
- **[GEMINI_INTEGRATION.md](GEMINI_INTEGRATION.md)** - Intégration IA
- **[docs/MAPBOX_INTEGRATION.md](docs/MAPBOX_INTEGRATION.md)** - Intégration cartes
- **[docs/STITCH_SCREENS.md](docs/STITCH_SCREENS.md)** - Synchronisation screens
- **[SETUP.md](SETUP.md)** - Guide d'installation

### Documentation par Agent

- **Flutter**: `ARCHITECTURE.md` + code comments
- **Backend**: `API_DOCUMENTATION.md` + `supabase/README.md`
- **IA Gemini**: `GEMINI_INTEGRATION.md` + `README_GEMINI.md`
- **UI/UX**: `design-system/README.md` + screens Stitch
- **Mapbox**: `docs/MAPBOX_INTEGRATION.md`
- **GitHub**: `docs/GIT_WORKFLOW.md` + `.github/`

### Outils de Supervision

- **[scripts/overseer_status_check.py](scripts/overseer_status_check.py)** - Script de vérification automatique du statut
- **[scripts/check_stitch_screens_coverage.py](scripts/check_stitch_screens_coverage.py)** - Vérification couverture screens Stitch

---

## Prochaines Actions Prioritaires

### Cette Semaine

1. **Agent Backend**: Finaliser Edge Functions réservations
2. **Agent Flutter**: Compléter processus de réservation
3. **Agent UI/UX**: Valider flux réservation avec screens Stitch
4. **Agent IA**: Optimiser prompts chatbot réservation
5. **Agent GitHub**: Configurer tests automatisés CI/CD

### Ce Mois

1. Intégration Stripe (paiements)
2. Notifications push Firebase
3. Tests E2E complets
4. Optimisation performance
5. Documentation utilisateur

---

## Communication

### Canaux de Communication

- **GitHub Issues**: Bugs, features, questions techniques
- **GitHub Discussions**: Discussions générales
- **PRs**: Code review et validation
- **Documentation**: Spécifications et guides

### Contacts par Agent

- **Agent Flutter**: Issues labelées `flutter`
- **Agent Backend**: Issues labelées `backend`
- **Agent IA**: Issues labelées `ai` ou `gemini`
- **Agent UI/UX**: Issues labelées `ui/ux` ou `design`
- **Agent Mapbox**: Issues labelées `mapbox` ou `maps`
- **Agent GitHub**: Issues labelées `github` ou `ci/cd`

---

## Audits Réguliers

### Audit Quotidien (Automatique)

Le script `scripts/overseer_status_check.py` génère un rapport quotidien:
```bash
python scripts/overseer_status_check.py --output docs/STATUS_REPORT.md
```

**Métriques surveillées**:
- Couverture screens Stitch
- État des intégrations (Supabase, Gemini, Mapbox, Stripe, Firebase)
- Couverture tests
- Complétude documentation

### Audit Hebdomadaire

- [ ] Revue des métriques de performance
- [ ] Vérification des tests
- [ ] Audit sécurité (dépendances, secrets)
- [ ] Validation documentation
- [ ] Mise à jour OVERSEER_TASKS.md
- [ ] Revue risques dans OVERSEER_RISKS.md

### Audit Mensuel

- [ ] Revue complète de l'architecture
- [ ] Audit sécurité approfondi
- [ ] Optimisation performance
- [ ] Planification roadmap (OVERSEER_ROADMAP.md)
- [ ] Revue synchronisation agents (OVERSEER_SYNC.md)

---

**Dernière mise à jour**: 2024
**Prochaine révision**: Semaine prochaine
**Statut global**: Sur la bonne voie


