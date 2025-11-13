# 🤖 Agent Flutter - Campbnb Québec

Documentation pour l'agent responsable du développement Flutter.

## 🎯 Responsabilités

- Développement des screens Flutter (51 screens Google Stitch)
- Implémentation de l'architecture domain-driven
- Intégration des widgets UI/UX
- Gestion d'état avec Riverpod
- Navigation avec GoRouter

## 🏗️ Architecture

### Structure Domain-Driven

```
lib/
├── core/                    # Configuration globale
│   ├── config/              # Configuration
│   ├── routing/             # Navigation (GoRouter)
│   ├── theme/               # Design system
│   └── constants/           # Constantes
├── features/                # Features métier
│   ├── auth/
│   ├── listing/
│   ├── reservation/
│   └── ...
└── shared/                  # Code partagé
    ├── models/              # Modèles de données
    ├── services/            # Services (Supabase, Gemini, Maps)
    └── widgets/             # Widgets réutilisables
```

### Pattern par Feature

Chaque feature suit le pattern :

```
feature/
├── domain/                  # Couche domaine
│   ├── entities/           # Entités métier
│   └── repositories/        # Interfaces
├── data/                    # Couche données
│   └── repositories/        # Implémentations
└── presentation/            # Couche présentation
    ├── providers/           # Riverpod providers
    ├── screens/             # Écrans
    └── widgets/             # Widgets spécifiques
```

## 🎨 Design System

### Thème

- **Couleurs** : Palette inspirée du Québec
- **Typographie** : Plus Jakarta Sans
- **Thèmes** : Light et Dark
- **Composants** : Réutilisables et cohérents

### Widgets Réutilisables

- `CustomButton` : Boutons standardisés
- `CustomTextField` : Champs de texte
- `ListingCard` : Carte de camping
- Et plus...

## 🔄 Gestion d'État

### Riverpod

**Providers**
- `authRepositoryProvider` : Repository d'authentification
- `listingProvider` : Gestion des listings
- `reservationProvider` : Gestion des réservations

**Notifiers**
- `AuthNotifier` : État d'authentification
- `ListingNotifier` : État des listings

## 🗺️ Navigation

### GoRouter

**Routes principales**
- `/welcome` : Écran de bienvenue
- `/home` : Accueil
- `/search` : Recherche
- `/listing/:id` : Détails d'un camping
- Et plus...

**Protection des routes**
- Redirection si non authentifié
- Guards pour les routes protégées

## ✅ Checklist Qualité

### Code

- [ ] Respect des conventions Flutter
- [ ] Architecture domain-driven respectée
- [ ] Séparation des responsabilités
- [ ] Code commenté et documenté

### Tests

- [ ] Tests unitaires pour les repositories
- [ ] Tests de widgets pour les composants
- [ ] Tests d'intégration pour les flows
- [ ] Couverture de tests > 80%

### Performance

- [ ] Lazy loading des images
- [ ] Pagination des listes
- [ ] Cache des données
- [ ] Optimisation des builds

### Accessibilité

- [ ] Labels pour les lecteurs d'écran
- [ ] Contraste des couleurs
- [ ] Navigation au clavier
- [ ] Support des tailles de texte

## 📚 Ressources

- [Architecture](../ARCHITECTURE.md)
- [Design System](../../design-system/README.md)
- [Flutter Documentation](https://flutter.dev/docs)

---

**Dernière mise à jour :** 2024

