# Index du Design System Campbnb Québec

Index complet pour naviguer facilement dans toute la documentation du design system.

## Démarrage rapide

### Pour les développeurs
1. Lire [INTEGRATION.md](INTEGRATION.md) pour intégrer le design system
2. Consulter [flutter-specs/theme.dart](flutter-specs/theme.dart) pour le thème
3. Utiliser les composants dans [flutter-specs/components/](flutter-specs/components/)

### Pour les designers
1. Lire [FIGMA-GUIDE.md](FIGMA-GUIDE.md) pour créer les maquettes
2. Consulter [moodboards/README.md](moodboards/README.md) pour l'inspiration
3. Voir [SUMMARY.md](SUMMARY.md) pour un résumé complet

---

## Documentation principale

### Vue d'ensemble
- **[README.md](README.md)**: Documentation principale du design system
- Philosophie du design
- Palette de couleurs
- Typographie
- Espacements & Layout
- Composants UI
- Responsive & Breakpoints
- Dark Mode
- Écrans IA

- **[SUMMARY.md](SUMMARY.md)**: Résumé exécutif
- Livrables
- Identité visuelle
- Composants principaux
- Prochaines étapes

---

## Design & Style

### Couleurs & Typographie
- **Couleurs**: Voir [README.md#palette-de-couleurs](README.md#palette-de-couleurs)
- **Typographie**: Voir [README.md#typographie](README.md#typographie)
- **Dark Mode**: Voir [dark-mode.md](dark-mode.md)

### Références visuelles
- **[moodboards/README.md](moodboards/README.md)**: Moodboards et inspiration
- Identité visuelle
- Références design
- Palette complète
- Animations de référence

---

## Composants

### Documentation
- **[components/base-components.md](components/base-components.md)**: Composants de base
- Boutons (Primary, Secondary, Text)
- Cards (Camping Card, Badge)
- Inputs (Search Bar, Form Fields)
- Navigation (Bottom Nav, App Bar)
- Filtres (Chips)
- Calendrier
- Compteurs
- Loading States
- Empty States
- Modals

### Spécifications Flutter
- **[flutter-specs/theme.dart](flutter-specs/theme.dart)**: Configuration thème complète
- **[flutter-specs/components/camping_card.dart](flutter-specs/components/camping_card.dart)**: Card de camping
- **[flutter-specs/components/search_bar.dart](flutter-specs/components/search_bar.dart)**: Barre de recherche
- **[flutter-specs/components/filter_chip.dart](flutter-specs/components/filter_chip.dart)**: Chip de filtre

---

## Interactions & Animations

- **[interactions.md](interactions.md)**: Guide complet des interactions
- Principes d'animation
- Interactions par composant
- Animations de chargement
- Animations de feedback
- Animations de page
- Animations de liste
- Performance
- Accessibilité

---

## Dark Mode

- **[dark-mode.md](dark-mode.md)**: Spécifications dark mode
- Stratégie
- Palette dark mode
- Implémentation Flutter
- Adaptations spécifiques
- Tests de contraste
- Bonnes pratiques

---

## Écrans IA

- **[ai-screens.md](ai-screens.md)**: Documentation des écrans IA
- Chat Gemini contextuel
- Suggestions intelligentes
- Avis automatisés
- Recherche vocale
- Principes d'intégration
- Spécifications techniques
- Roadmap

---

## Intégration

- **[INTEGRATION.md](INTEGRATION.md)**: Guide d'intégration Flutter
- Installation
- Configuration
- Utilisation des couleurs
- Utilisation de la typographie
- Utilisation des espacements
- Utilisation des animations
- Créer de nouveaux composants
- Responsive
- Tests
- Dépannage

---

## Maquettes Figma

- **[FIGMA-GUIDE.md](FIGMA-GUIDE.md)**: Guide de création des maquettes
- Configuration Figma
- Créer les composants
- Créer les écrans
- Écrans IA
- Dark Mode
- Prototypage
- Organisation
- Checklist

---

## Écrans documentés

### Écrans de base (basés sur les 33 screens Stitch)
- Welcome Screen
- Onboarding (3 écrans)
- Login/Signup
- Home Screen
- Search & Results
- Detail Screen
- Reservation Process
- Profile Screen
- Settings
- Host Dashboard
- Add Listing
- Messaging
- Map

### Écrans IA (anticipés)
- Chat Gemini
- Suggestions intelligentes
- Avis automatisés
- Recherche vocale

---

## Recherche rapide

### Par besoin

**Je veux...**
- **Intégrer le design system** → [INTEGRATION.md](INTEGRATION.md)
- **Créer des maquettes Figma** → [FIGMA-GUIDE.md](FIGMA-GUIDE.md)
- **Comprendre les couleurs** → [README.md#palette-de-couleurs](README.md#palette-de-couleurs)
- **Implémenter dark mode** → [dark-mode.md](dark-mode.md)
- **Créer des animations** → [interactions.md](interactions.md)
- **Intégrer l'IA** → [ai-screens.md](ai-screens.md)
- **Voir des exemples de code** → [flutter-specs/](flutter-specs/)
- **Trouver de l'inspiration** → [moodboards/README.md](moodboards/README.md)

### Par rôle

**Développeur Flutter**
1. [INTEGRATION.md](INTEGRATION.md)
2. [flutter-specs/theme.dart](flutter-specs/theme.dart)
3. [flutter-specs/components/](flutter-specs/components/)
4. [interactions.md](interactions.md)

**Designer UI/UX**
1. [FIGMA-GUIDE.md](FIGMA-GUIDE.md)
2. [moodboards/README.md](moodboards/README.md)
3. [components/base-components.md](components/base-components.md)
4. [dark-mode.md](dark-mode.md)

**Product Manager**
1. [SUMMARY.md](SUMMARY.md)
2. [README.md](README.md)
3. [ai-screens.md](ai-screens.md)

---

## Structure des fichiers

```
design-system/
├── INDEX.md # Ce fichier
├── README.md # Documentation principale
├── SUMMARY.md # Résumé exécutif
├── INTEGRATION.md # Guide d'intégration Flutter
├── FIGMA-GUIDE.md # Guide maquettes Figma
├── interactions.md # Animations et interactions
├── dark-mode.md # Spécifications dark mode
├── ai-screens.md # Écrans IA
├── components/
│ └── base-components.md # Composants de base
├── flutter-specs/
│ ├── theme.dart # Configuration thème
│ └── components/
│ ├── camping_card.dart # Card de camping
│ ├── search_bar.dart # Barre de recherche
│ └── filter_chip.dart # Chip de filtre
└── moodboards/
└── README.md # Références visuelles
```

---

## Prochaines étapes

### Immédiat
1. Design system documenté
2. Spécifications Flutter créées
3. Écrans IA documentés

### Court terme
- [ ] Créer les maquettes Figma
- [ ] Ajouter plus de composants Flutter
- [ ] Créer les illustrations québécoises

### Long terme
- [ ] Tests d'accessibilité complets
- [ ] Composants avancés
- [ ] Localisation (français/anglais)

---

## Support

Pour toute question:
1. Consulter cet index
2. Lire la documentation correspondante
3. Voir les exemples de code dans `flutter-specs/`

---

**Version**: 1.0.0
**Dernière mise à jour**: 2024


