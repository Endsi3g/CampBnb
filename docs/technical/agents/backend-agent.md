# 🔧 Agent Backend - Campbnb Québec

Documentation pour l'agent responsable du backend Supabase.

## 🎯 Responsabilités

- Développement des Edge Functions Supabase
- Configuration de la base de données PostgreSQL
- Mise en place des politiques RLS (Row Level Security)
- Gestion des migrations
- API REST complète

## 🏗️ Architecture

### Stack Backend

- **Base de données** : PostgreSQL (Supabase)
- **API** : Supabase Edge Functions (Deno)
- **Authentification** : Supabase Auth
- **Storage** : Supabase Storage
- **Real-time** : Supabase Realtime (optionnel)

### Structure

```
supabase/
├── functions/                # Edge Functions
│   ├── listings/
│   ├── reservations/
│   ├── profiles/
│   ├── messages/
│   ├── reviews/
│   ├── mapbox/
│   └── gemini/
├── migrations/               # Migrations SQL
│   ├── 001_initial_schema.sql
│   └── 002_row_level_security.sql
└── storage/                  # Politiques de storage
    └── policies.sql
```

## 🔐 Sécurité

### Row Level Security (RLS)

Toutes les tables ont des politiques RLS :

**Exemple - Listings**
```sql
-- Les utilisateurs peuvent voir les listings actifs
CREATE POLICY "Anyone can view active listings" ON listings
  FOR SELECT USING (status = 'active');

-- Les hôtes peuvent gérer leurs propres listings
CREATE POLICY "Hosts can manage own listings" ON listings
  FOR ALL USING (auth.uid() = host_id);
```

### Validation

- Validation des entrées côté serveur
- Sanitization des données
- Protection contre les injections SQL
- Rate limiting

## 📡 Edge Functions

### Structure d'une Function

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  // Authentification
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
    })
  }

  // Logique métier
  // ...

  return new Response(JSON.stringify({ data: result }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

### Functions Disponibles

- `listings` : Gestion des annonces
- `reservations` : Gestion des réservations
- `profiles` : Gestion des profils
- `messages` : Messagerie
- `reviews` : Avis et évaluations
- `mapbox` : Intégration Mapbox
- `gemini` : Intégration Gemini AI

## 🗄️ Base de Données

### Tables Principales

- `profiles` : Profils utilisateurs
- `listings` : Annonces de camping
- `reservations` : Réservations
- `messages` : Messages
- `reviews` : Avis

### Migrations

**Créer une migration**
```bash
supabase migration new nom_de_la_migration
```

**Appliquer les migrations**
```bash
supabase db push
```

## ✅ Checklist Qualité

### Sécurité

- [ ] RLS activé sur toutes les tables
- [ ] Validation des entrées
- [ ] Sanitization des données
- [ ] Authentification requise pour actions sensibles

### Performance

- [ ] Index sur les colonnes fréquemment requêtées
- [ ] Pagination pour les listes
- [ ] Optimisation des requêtes (éviter N+1)
- [ ] Cache quand approprié

### Tests

- [ ] Tests d'intégration pour chaque endpoint
- [ ] Tests de sécurité
- [ ] Tests de performance

## 📚 Ressources

- [API Documentation](../../API_DOCUMENTATION.md)
- [Supabase Documentation](https://supabase.com/docs)
- [Edge Functions Guide](https://supabase.com/docs/guides/functions)

---

**Dernière mise à jour :** 2024

