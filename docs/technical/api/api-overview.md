# 🔌 Vue d'Ensemble API - Campbnb Québec

Introduction à l'API REST de Campbnb Québec.

## 📋 Base URL

```
https://your-project-ref.supabase.co/functions/v1
```

## 🔐 Authentification

Toutes les requêtes (sauf publiques) nécessitent un token JWT :

```http
Authorization: Bearer <token>
```

Le token est obtenu via Supabase Auth lors de la connexion.

## 📡 Endpoints Principaux

### Authentification

- `POST /auth/v1/signup` - Inscription
- `POST /auth/v1/token` - Connexion
- `GET /auth/v1/user` - Utilisateur actuel

### Listings

- `GET /listings` - Liste des listings
- `GET /listings/:id` - Détails d'un listing
- `POST /listings` - Créer un listing
- `PUT /listings/:id` - Mettre à jour
- `DELETE /listings/:id` - Supprimer

### Réservations

- `GET /reservations` - Liste des réservations
- `GET /reservations/:id` - Détails
- `POST /reservations` - Créer une réservation
- `PUT /reservations/:id` - Mettre à jour

### Profils

- `GET /profiles/:id` - Récupérer un profil
- `PUT /profiles/:id` - Mettre à jour
- `GET /profiles/:id/stats` - Statistiques

### Messages

- `GET /messages/conversations` - Conversations
- `GET /messages/:conversation_id` - Messages
- `POST /messages` - Envoyer un message

### Avis

- `GET /reviews` - Liste des avis
- `POST /reviews` - Créer un avis
- `PUT /reviews/:id` - Répondre à un avis

### MapBox

- `GET /mapbox/config` - Configuration
- `GET /mapbox/listings` - Listings pour la carte
- `POST /mapbox/geocode` - Géocodage inverse
- `POST /mapbox/search` - Recherche d'adresses

### Gemini AI

- `POST /gemini/suggest` - Suggestions intelligentes
- `POST /gemini/describe-listing` - Générer description
- `POST /gemini/recommend` - Recommandations

## 📝 Format des Réponses

### Succès

```json
{
  "data": { ... }
}
```

### Erreur

```json
{
  "error": "Message d'erreur descriptif"
}
```

## 🔒 Codes d'Erreur

- `200` : Succès
- `201` : Créé
- `400` : Requête invalide
- `401` : Non authentifié
- `403` : Non autorisé
- `404` : Ressource introuvable
- `500` : Erreur serveur

## 📚 Documentation Complète

- [API Authentification](authentication-api.md)
- [API Listings](listings-api.md)
- [API Réservations](reservations-api.md)
- [Référence API](api-reference.md)

---

**Dernière mise à jour :** 2024

