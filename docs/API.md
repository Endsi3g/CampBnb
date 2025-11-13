# Documentation API - Campbnb Québec

## Vue d'ensemble

Campbnb Québec utilise **Supabase** comme backend, fournissant une API REST et GraphQL pour toutes les opérations backend.

## Base URL

```
Production: https://YOUR_PROJECT_ID.supabase.co
Staging: https://YOUR_STAGING_PROJECT_ID.supabase.co
```

## Authentification

### Headers Requis

```http
Authorization: Bearer YOUR_ACCESS_TOKEN
apikey: YOUR_ANON_KEY
Content-Type: application/json
```

### Obtenir un Token

```dart
final response = await supabase.auth.signInWithPassword(
email: email,
password: password,
);
final accessToken = response.session?.accessToken;
```

## Endpoints Principaux

### Authentification

#### Inscription

```http
POST /auth/v1/signup
Content-Type: application/json

{
"email": "user@example.com",
"password": "securepassword"
}
```

#### Connexion

```http
POST /auth/v1/token?grant_type=password
Content-Type: application/json

{
"email": "user@example.com",
"password": "securepassword"
}
```

#### Déconnexion

```http
POST /auth/v1/logout
Authorization: Bearer YOUR_ACCESS_TOKEN
```

### Campings (Listings)

#### Lister les campings

```http
GET /rest/v1/listings?select=*
```

#### Détails d'un camping

```http
GET /rest/v1/listings?id=eq.{listing_id}&select=*
```

#### Recherche

```http
GET /rest/v1/listings?location=ilike.*{query}*
```

### Réservations

#### Créer une réservation

```http
POST /rest/v1/reservations
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: application/json

{
"listing_id": "uuid",
"check_in": "2024-07-01",
"check_out": "2024-07-05",
"guests": 2
}
```

#### Mes réservations

```http
GET /rest/v1/reservations?user_id=eq.{user_id}&select=*
```

### Profil Utilisateur

#### Obtenir le profil

```http
GET /rest/v1/profiles?id=eq.{user_id}&select=*
```

#### Mettre à jour le profil

```http
PATCH /rest/v1/profiles?id=eq.{user_id}
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: application/json

{
"first_name": "John",
"last_name": "Doe"
}
```

## Row Level Security (RLS)

Toutes les tables utilisent RLS pour la sécurité:

- Les utilisateurs ne peuvent voir que leurs propres données
- Les hôtes peuvent gérer leurs propres listings
- Les réservations sont privées par utilisateur

## Storage

### Upload d'image

```dart
final file = File('path/to/image.jpg');
await supabase.storage
.from('listings')
.upload('${listingId}/image.jpg', file);
```

### URL publique

```dart
final url = supabase.storage
.from('listings')
.getPublicUrl('${listingId}/image.jpg');
```

## Realtime

### S'abonner aux changements

```dart
supabase
.from('reservations')
.stream(primaryKey: ['id'])
.listen((data) {
// Gérer les changements
});
```

## ️ Utilisation dans Flutter

### Client Supabase

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
```

### Exemple: Récupérer les campings

```dart
final response = await supabase
.from('listings')
.select()
.limit(10);

final listings = response as List<Map<String, dynamic>>;
```

## Documentation Complète

- [Supabase REST API](https://supabase.com/docs/reference/javascript/introduction)
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)
- [Supabase Storage](https://supabase.com/docs/guides/storage)

## Sécurité

- Toutes les requêtes nécessitent un token valide (sauf endpoints publics)
- RLS appliqué sur toutes les tables
- Validation des données côté serveur
- Rate limiting configuré


