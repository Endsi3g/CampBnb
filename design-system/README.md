# Design System Campbnb Québec

Design system complet pour l'application mobile Campbnb Québec, adapté à la culture québécoise et optimisé pour Flutter.

## Table des matières

1. [Philosophie du design](#philosophie-du-design)
2. [Palette de couleurs](#palette-de-couleurs)
3. [Typographie](#typographie)
4. [Espacements & Layout](#espacements--layout)
5. [Composants UI](#composants-ui)
6. [États & Interactions](#états--interactions)
7. [Responsive & Breakpoints](#responsive--breakpoints)
8. [Dark Mode](#dark-mode)
9. [Écrans IA](#écrans-ia)
10. [Spécifications Flutter](#spécifications-flutter)

---

## Philosophie du design

### Identité visuelle

Campbnb Québec s'inspire de la beauté naturelle du Québec tout en conservant l'élégance et la simplicité d'Airbnb. L'identité visuelle reflète:

- **Authenticité**: Design chaleureux et accueillant
- **Nature**: Couleurs inspirées des forêts, lacs et paysages québécois
- **Modernité**: Interface épurée et intuitive
- **Accessibilité**: Contraste élevé, navigation claire

### Principes de design

1. **Mobile-first**: Tous les composants sont conçus d'abord pour mobile
2. **Cohérence**: Utilisation systématique du design system
3. **Accessibilité**: Respect des standards WCAG 2.1 AA
4. **Performance**: Animations fluides, chargement optimisé
5. **Responsive**: Adaptation automatique mobile/tablette

---

## Palette de couleurs

### Couleurs principales

#### Light Mode

```dart
// Primary - Vert forêt québécois
Color primary = Color(0xFF2D572C);
Color primaryLight = Color(0xFF4A7A4A);
Color primaryDark = Color(0xFF1A3A1A);

// Secondary - Bleu lac
Color secondary = Color(0xFF3B8EA5);
Color secondaryLight = Color(0xFF5BA8C0);
Color secondaryDark = Color(0xFF2A6B7F);

// Accent - Beige bois
Color accent = Color(0xFFF5E5D5);
Color accentLight = Color(0xFFFFF5EB);
Color accentDark = Color(0xFFE8D4C0);

// Neutral - Beige clair
Color neutral = Color(0xFFF5F5DC);
Color neutralLight = Color(0xFFFFFEF8);
Color neutralDark = Color(0xFFE8E8D0);
```

#### Dark Mode

```dart
// Primary - Vert forêt adapté dark
Color primaryDarkMode = Color(0xFF4A7A4A);
Color primaryLightDarkMode = Color(0xFF6B9A6B);
Color primaryDarkDarkMode = Color(0xFF2D572C);

// Secondary - Bleu lac adapté dark
Color secondaryDarkMode = Color(0xFF5BA8C0);
Color secondaryLightDarkMode = Color(0xFF7BC8E0);
Color secondaryDarkDarkMode = Color(0xFF3B8EA5);

// Backgrounds
Color backgroundDark = Color(0xFF152210);
Color surfaceDark = Color(0xFF2A3F29);
```

### Couleurs sémantiques

```dart
// Success
Color success = Color(0xFF4CAF50);
Color successLight = Color(0xFF81C784);
Color successDark = Color(0xFF388E3C);

// Warning
Color warning = Color(0xFFFF9800);
Color warningLight = Color(0xFFFFB74D);
Color warningDark = Color(0xFFF57C00);

// Error
Color error = Color(0xFFE53935);
Color errorLight = Color(0xFFEF5350);
Color errorDark = Color(0xFFC62828);

// Info
Color info = Color(0xFF2196F3);
Color infoLight = Color(0xFF64B5F6);
Color infoDark = Color(0xFF1976D2);
```

### Couleurs de texte

```dart
// Light Mode
Color textPrimaryLight = Color(0xFF333333);
Color textSecondaryLight = Color(0xFF5C5C5C);
Color textTertiaryLight = Color(0xFF9E9E9E);
Color textInverseLight = Color(0xFFFFFFFF);

// Dark Mode
Color textPrimaryDark = Color(0xFFE0E0E0);
Color textSecondaryDark = Color(0xFFB0B0B0);
Color textTertiaryDark = Color(0xFF757575);
Color textInverseDark = Color(0xFF152210);
```

### Utilisation des couleurs

- **Primary**: Actions principales, CTA, navigation active
- **Secondary**: Actions secondaires, badges, liens
- **Accent**: Surlignage, backgrounds subtils
- **Neutral**: Backgrounds, séparateurs
- **Sémantiques**: Feedback utilisateur (succès, erreur, etc.)

---

## Typographie

### Police principale

**Plus Jakarta Sans** (déjà configurée dans `pubspec.yaml`)

### Hiérarchie typographique

```dart
// Display - Titres principaux
TextStyle displayLarge = TextStyle(
fontFamily: 'PlusJakartaSans',
fontSize: 32,
fontWeight: FontWeight.w800,
letterSpacing: -0.5,
height: 1.2,
);

TextStyle displayMedium = TextStyle(
fontFamily: 'PlusJakartaSans',
fontSize: 28,
fontWeight: FontWeight.w800,
letterSpacing: -0.3,
height: 1.25,
);

TextStyle displaySmall = TextStyle(
fontFamily: 'PlusJakartaSans',
fontSize: 24,
fontWeight: FontWeight.w700,
letterSpacing: -0.2,
height: 1.3,
);

// Headline - Sous-titres
TextStyle headlineLarge = TextStyle(
fontFamily: 'PlusJakartaSans',
fontSize: 22,
fontWeight: FontWeight.w700,
letterSpacing: -0.1,
height: 1.35,
);

TextStyle headlineMedium = TextStyle(
fontFamily: 'PlusJakartaSans',
fontSize: 20,
fontWeight: FontWeight.w700,
letterSpacing: 0,
height: 1.4,
);

TextStyle headlineSmall = TextStyle(
fontFamily: 'PlusJakartaSans',
fontSize: 18,
fontWeight: FontWeight.w700,
letterSpacing: 0,
height: 1.4,
);

// Body - Texte courant
TextStyle bodyLarge = TextStyle(
fontFamily: 'PlusJakartaSans',
fontSize: 16,
fontWeight: FontWeight.w400,
letterSpacing: 0.15,
height: 1.5,
);

TextStyle bodyMedium = TextStyle(
fontFamily: 'PlusJakartaSans',
fontSize: 14,
fontWeight: FontWeight.w400,
letterSpacing: 0.25,
height: 1.5,
);

TextStyle bodySmall = TextStyle(
fontFamily: 'PlusJakartaSans',
fontSize: 12,
fontWeight: FontWeight.w400,
letterSpacing: 0.4,
height: 1.5,
);

// Label - Labels et boutons
TextStyle labelLarge = TextStyle(
fontFamily: 'PlusJakartaSans',
fontSize: 14,
fontWeight: FontWeight.w500,
letterSpacing: 0.1,
height: 1.4,
);

TextStyle labelMedium = TextStyle(
fontFamily: 'PlusJakartaSans',
fontSize: 12,
fontWeight: FontWeight.w500,
letterSpacing: 0.5,
height: 1.4,
);

TextStyle labelSmall = TextStyle(
fontFamily: 'PlusJakartaSans',
fontSize: 11,
fontWeight: FontWeight.w500,
letterSpacing: 0.5,
height: 1.4,
);
```

### Utilisation

- **Display**: Écrans d'accueil, titres de sections principales
- **Headline**: Titres de cartes, sous-sections
- **Body**: Contenu principal, descriptions
- **Label**: Boutons, labels de formulaires, navigation

---

## Espacements & Layout

### Système de grille

- **Mobile**: Padding horizontal `16px` (4.0 en Flutter)
- **Tablette**: Padding horizontal `24px` (6.0 en Flutter)
- **Max width**: `428px` pour mobile (taille iPhone 14 Pro Max)

### Espacements (8px base)

```dart
// Spacing scale
double spacingXS = 4.0; // 0.5 * 8
double spacingSM = 8.0; // 1 * 8
double spacingMD = 16.0; // 2 * 8
double spacingLG = 24.0; // 3 * 8
double spacingXL = 32.0; // 4 * 8
double spacingXXL = 48.0; // 6 * 8
double spacingXXXL = 64.0; // 8 * 8
```

### Border Radius

```dart
// Border radius scale
double radiusXS = 4.0;
double radiusSM = 8.0;
double radiusMD = 12.0;
double radiusLG = 16.0;
double radiusXL = 24.0;
double radiusFull = 9999.0; // Pour les boutons arrondis
```

### Ombres

```dart
// Shadow scale
List<BoxShadow> shadowSM = [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 4,
offset: Offset(0, 2),
),
];

List<BoxShadow> shadowMD = [
BoxShadow(
color: Colors.black.withOpacity(0.08),
blurRadius: 8,
offset: Offset(0, 4),
),
];

List<BoxShadow> shadowLG = [
BoxShadow(
color: Colors.black.withOpacity(0.12),
blurRadius: 16,
offset: Offset(0, 8),
),
];
```

---

## Composants UI

Voir la documentation détaillée dans:
- [Composants de base](components/base-components.md)
- [Composants de formulaire](components/form-components.md)
- [Composants de navigation](components/navigation-components.md)
- [Composants de contenu](components/content-components.md)

---

## États & Interactions

Voir la documentation complète dans [interactions.md](interactions.md)

### États des composants

- **Default**: État initial
- **Hover**: Survol (tablette/desktop)
- **Pressed**: Appui
- **Focused**: Focus clavier
- **Disabled**: Désactivé
- **Loading**: Chargement
- **Error**: Erreur
- **Success**: Succès

### Micro-animations

- **Durée standard**: 200-300ms
- **Durée longue**: 400-500ms
- **Courbe d'animation**: `Curves.easeInOut`
- **Transitions**: Fade, slide, scale

---

## Responsive & Breakpoints

### Breakpoints

```dart
// Breakpoints
double mobileBreakpoint = 428.0; // iPhone 14 Pro Max
double tabletBreakpoint = 768.0; // iPad Mini
double desktopBreakpoint = 1024.0; // iPad Pro
```

### Adaptation

- **Mobile (< 428px)**: Layout vertical, navigation bottom
- **Tablette (428px - 768px)**: Layout adaptatif, navigation hybride
- **Desktop (> 768px)**: Layout horizontal, navigation sidebar

---

## Dark Mode

Le dark mode est entièrement supporté avec des couleurs adaptées pour:
- Meilleure lisibilité
- Réduction de la fatigue oculaire
- Cohérence visuelle

Voir [dark-mode.md](dark-mode.md) pour les spécifications complètes.

---

## Écrans IA

Voir la documentation complète dans [ai-screens.md](ai-screens.md)

### Écrans anticipés

1. **Chat Gemini contextuel**: Assistant IA pour recherche et réservation
2. **Suggestions intelligentes**: Recommandations personnalisées
3. **Avis automatisés**: Génération d'avis avec IA
4. **Recherche vocale**: Recherche par commande vocale

---

## Spécifications Flutter

Toutes les spécifications Flutter sont disponibles dans le dossier `flutter-specs/`:

- [Thème Flutter](flutter-specs/theme.dart)
- [Composants Flutter](flutter-specs/components/)
- [Animations Flutter](flutter-specs/animations.dart)

---

## Ressources

- [Moodboards](moodboards/)
- [Maquettes Figma](https://figma.com) *(lien à ajouter)*
- [Icônes Material Symbols](https://fonts.google.com/icons)
- [Illustrations Québec](assets/illustrations/)

---

## Changelog

### Version 1.0.0
- Design system initial
- Support light/dark mode
- Composants de base
- Spécifications Flutter

---

## Contact

Pour toute question sur le design system, contactez l'équipe design.


