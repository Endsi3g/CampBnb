# Adaptation UI Windows - Campbnb Québec

Ce document décrit l'implémentation de l'adaptation UI pour Windows avec `PlatformUtils` et `fluent_ui`.

## ✅ Implémentations réalisées

### 1. Layouts adaptatifs

#### `lib/shared/layouts/adaptive_layout.dart`
Widget principal qui choisit automatiquement entre desktop et mobile selon la plateforme.

**Utilisation** :
```dart
AdaptiveLayout(
  currentIndex: 0,
  onNavigationChanged: (index) { /* ... */ },
  title: 'Campbnb Québec',
  child: YourContent(),
)
```

#### `lib/shared/layouts/desktop_layout.dart`
Layout desktop avec sidebar de navigation :
- **Windows** : Utilise `fluent_ui` avec `NavigationView`
- **macOS/Linux** : Utilise Material Design avec `NavigationRail`

**Fonctionnalités** :
- Sidebar rétractable
- Navigation par onglets
- Footer avec paramètres et aide

#### `lib/shared/layouts/mobile_layout.dart`
Layout mobile avec bottom navigation bar (comportement existant).

### 2. Intégration Fluent UI

#### `lib/core/theme/fluent_theme_adapter.dart`
Adaptateur de thème qui :
- Crée un thème Fluent UI basé sur les couleurs de l'application
- Supporte le mode sombre/clair
- S'applique uniquement sur Windows

**Utilisation** :
```dart
FluentThemeAdapter.buildWithTheme(
  isDark: false,
  child: YourApp(),
)
```

### 3. Écrans adaptés

#### `HomeScreen` adapté
- **Mobile** : Layout vertical avec bottom navigation
- **Desktop** : Layout avec sidebar et grille de listings (3 colonnes)
- Utilise `PlatformUtils.shouldUseDesktopLayout()` pour la détection

**Améliorations desktop** :
- Barre de recherche plus large (600px)
- Grille de listings au lieu d'une liste
- Plus de filtres visibles
- Meilleure utilisation de l'espace

## 📋 Structure des fichiers

```
lib/
├── core/
│   ├── utils/
│   │   └── platform_utils.dart          # Détection de plateforme
│   └── theme/
│       └── fluent_theme_adapter.dart     # Adaptateur Fluent UI
├── shared/
│   └── layouts/
│       ├── adaptive_layout.dart          # Layout adaptatif principal
│       ├── desktop_layout.dart           # Layout desktop (Fluent/Material)
│       └── mobile_layout.dart            # Layout mobile
└── features/
    └── home/
        └── presentation/
            └── screens/
                └── home_screen.dart      # Écran adapté avec layouts
```

## 🎨 Design Fluent UI sur Windows

### NavigationView
- Sidebar avec icônes Fluent
- Navigation par onglets
- Support du mode compact/étendu
- Footer avec aide

### Thème
- Couleurs adaptées depuis `AppColors`
- Support du mode sombre
- Cohérence avec le design system

## 🔧 Utilisation

### Dans un écran

```dart
import 'package:campbnb_quebec/core/utils/platform_utils.dart';
import 'package:campbnb_quebec/shared/layouts/adaptive_layout.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformUtils.shouldUseDesktopLayout(context);
    
    return AdaptiveLayout(
      currentIndex: 0,
      onNavigationChanged: (index) {
        // Gérer la navigation
      },
      child: isDesktop 
        ? _buildDesktopContent() 
        : _buildMobileContent(),
    );
  }
}
```

### Détection de plateforme

```dart
// Vérifier si desktop
if (PlatformUtils.isDesktop) { /* ... */ }

// Vérifier si Windows
if (PlatformUtils.isWindows) { /* ... */ }

// Vérifier si layout desktop devrait être utilisé
if (PlatformUtils.shouldUseDesktopLayout(context)) { /* ... */ }
```

## 📱 Écrans à adapter

### ✅ Adaptés
- [x] `HomeScreen` - Layout adaptatif avec grille desktop

### ⏳ À adapter
- [ ] `SearchScreen` - Layout desktop avec sidebar de filtres
- [ ] `ListingDetailsScreen` - Layout desktop avec colonnes
- [ ] `ProfileScreen` - Layout desktop avec sidebar
- [ ] `HostDashboardScreen` - Layout desktop optimisé
- [ ] `ReservationProcessScreen` - Layout desktop avec étapes côte à côte

## 🎯 Bonnes pratiques

### 1. Toujours utiliser `PlatformUtils.shouldUseDesktopLayout()`

```dart
// ✅ Bon
if (PlatformUtils.shouldUseDesktopLayout(context)) {
  return DesktopLayout();
}

// ❌ Mauvais
if (MediaQuery.of(context).size.width > 1024) {
  return DesktopLayout();
}
```

### 2. Créer des méthodes séparées pour mobile et desktop

```dart
Widget build(BuildContext context) {
  final isDesktop = PlatformUtils.shouldUseDesktopLayout(context);
  return isDesktop 
    ? _buildDesktopContent(context)
    : _buildMobileContent(context);
}
```

### 3. Utiliser `AdaptiveLayout` pour la navigation

```dart
AdaptiveLayout(
  currentIndex: currentIndex,
  onNavigationChanged: handleNavigation,
  child: content,
)
```

### 4. Fluent UI uniquement sur Windows

```dart
if (PlatformUtils.isWindows) {
  // Utiliser Fluent UI
} else {
  // Utiliser Material Design
}
```

## 🚀 Prochaines étapes

1. **Adapter les autres écrans principaux**
   - SearchScreen avec sidebar de filtres
   - ListingDetailsScreen avec layout en colonnes
   - ProfileScreen avec sidebar

2. **Améliorer Fluent UI**
   - Ajouter plus de composants Fluent
   - Personnaliser le thème
   - Implémenter les animations Fluent

3. **Optimisations desktop**
   - Raccourcis clavier
   - Menus contextuels
   - Drag & drop

4. **Tests**
   - Tester sur différentes tailles d'écran
   - Tester le redimensionnement
   - Tester la navigation

## 📚 Ressources

- [Fluent UI Package](https://pub.dev/packages/fluent_ui)
- [PlatformUtils Documentation](lib/core/utils/platform_utils.dart)
- [Windows Setup Guide](WINDOWS_SETUP.md)

---

**Dernière mise à jour** : 2024

