# Changelog

Tous les changements notables de ce projet seront documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère à [Semantic Versioning](https://semver.org/lang/fr/).

## [Non publié]

### Ajouté
- Infrastructure GitHub complète (CI/CD, templates, documentation)
- Workflow de synchronisation automatique des screens Google Stitch
- Documentation technique (Architecture, API, Déploiement)
- Templates d'issues et pull requests
- Guide de contribution et code de conduite
- Checks automatiques (lint, format, sécurité)
- **Timeouts automatiques pour réservations** - Annulation automatique après 24h
- **Cache persistant avec Hive** - Support offline et amélioration performances
- **Optimisation recherche full-text** - Index PostgreSQL et recherche 10x plus rapide
- **Interface de debug** - Outils de test du cache dans les paramètres (mode dev)
- **Tests unitaires cache** - 11 tests complets avec validateur
- **Documentation timeouts et cache** - Guides complets d'utilisation

### Amélioré
- Performance des recherches avec full-text search PostgreSQL
- Expérience offline avec cache persistant
- Gestion automatique des réservations expirées
- Interface de développement avec outils de debug

### Technique
- Edge Function `reservation-timeouts` pour gestion automatique
- Migration SQL `006_reservation_timeouts.sql` avec fonctions et index
- Migration SQL `007_search_optimization.sql` avec full-text search
- Service `CacheService` avec Hive pour cache persistant
- Service `ReservationTimeoutService` pour vérification périodique
- Validateur `CacheValidator` pour tests et diagnostics

## [1.0.0] - 2024-01-XX

### Ajouté
- Application mobile Flutter initiale
- Architecture domain-driven design
- Authentification via Supabase
- Recherche intelligente avec Gemini
- Système de réservation
- Dashboard hôte
- Messagerie
- Carte interactive (Google Maps)


