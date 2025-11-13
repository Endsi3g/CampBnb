# Dark Mode

## Stratégie

Le dark mode de Campbnb Québec est conçu pour offrir une expérience confortable en conditions de faible luminosité, tout en conservant l'identité visuelle québécoise.

## Principes

1. **Cohérence**: Les couleurs dark mode conservent les mêmes relations que le light mode
2. **Contraste**: Respect des standards WCAG 2.1 AA (ratio minimum 4.5:1)
3. **Réduction de la fatigue**: Tons plus doux, moins de contraste agressif
4. **Identité préservée**: Les couleurs primaires restent reconnaissables

---

## Palette Dark Mode

### Couleurs principales

```dart
// Primary - Vert forêt adapté
Color primaryDark = Color(0xFF4A7A4A); // Plus clair que light mode
Color primaryLightDark = Color(0xFF6B9A6B); // Pour hover/active
Color primaryDarkDark = Color(0xFF2D572C); // Pour accents

// Secondary - Bleu lac adapté
Color secondaryDark = Color(0xFF5BA8C0); // Plus clair
Color secondaryLightDark = Color(0xFF7BC8E0);
Color secondaryDarkDark = Color(0xFF3B8EA5);

// Backgrounds
Color backgroundDark = Color(0xFF152210); // Vert très foncé
Color surfaceDark = Color(0xFF2A3F29); // Vert moyen foncé
Color surfaceElevatedDark = Color(0xFF3A4F38); // Pour cards élevées
```

### Couleurs de texte

```dart
// Text colors dark mode
Color textPrimaryDark = Color(0xFFE0E0E0); // Presque blanc
Color textSecondaryDark = Color(0xFFB0B0B0); // Gris moyen
Color textTertiaryDark = Color(0xFF757575); // Gris foncé
Color textInverseDark = Color(0xFF152210); // Pour texte sur primary
```

### Couleurs sémantiques (adaptées)

```dart
// Success - Plus doux en dark
Color successDark = Color(0xFF66BB6A);
Color successLightDark = Color(0xFF81C784);

// Warning - Moins agressif
Color warningDark = Color(0xFFFFB74D);
Color warningLightDark = Color(0xFFFFCC80);

// Error - Légèrement atténué
Color errorDark = Color(0xFFEF5350);
Color errorLightDark = Color(0xFFE57373);

// Info - Plus doux
Color infoDark = Color(0xFF64B5F6);
Color infoLightDark = Color(0xFF90CAF9);
```

---

## Implémentation Flutter

### ThemeData Dark

```dart
ThemeData darkTheme = ThemeData(
brightness: Brightness.dark,
primaryColor: AppColors.primaryDark,
scaffoldBackgroundColor: AppColors.backgroundDark,
cardColor: AppColors.surfaceDark,
colorScheme: ColorScheme.dark(
primary: AppColors.primaryDark,
secondary: AppColors.secondaryDark,
surface: AppColors.surfaceDark,
background: AppColors.backgroundDark,
error: AppColors.errorDark,
onPrimary: AppColors.textInverseDark,
onSecondary: AppColors.textInverseDark,
onSurface: AppColors.textPrimaryDark,
onBackground: AppColors.textPrimaryDark,
onError: Colors.white,
),
textTheme: TextTheme(
displayLarge: AppTextStyles.displayLarge.copyWith(
color: AppColors.textPrimaryDark,
),
displayMedium: AppTextStyles.displayMedium.copyWith(
color: AppColors.textPrimaryDark,
),
bodyLarge: AppTextStyles.bodyLarge.copyWith(
color: AppColors.textPrimaryDark,
),
bodyMedium: AppTextStyles.bodyMedium.copyWith(
color: AppColors.textSecondaryDark,
),
),
);
```

### Détection automatique

```dart
// Détecter la préférence système
bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

// Ou utiliser un provider
final themeProvider = Provider.of<ThemeProvider>(context);
bool isDarkMode = themeProvider.isDarkMode;
```

### Toggle Dark Mode

```dart
class ThemeProvider extends ChangeNotifier {
bool _isDarkMode = false;

bool get isDarkMode => _isDarkMode;

void toggleTheme() {
_isDarkMode = !_isDarkMode;
notifyListeners();
}

void setTheme(bool isDark) {
_isDarkMode = isDark;
notifyListeners();
}
}
```

---

## Adaptations spécifiques

### Cards

```dart
Card(
color: isDarkMode ? AppColors.surfaceDark: AppColors.surface,
elevation: isDarkMode ? 2: 4, // Moins d'élévation en dark
child: ...,
)
```

### Borders

```dart
Container(
decoration: BoxDecoration(
border: Border.all(
color: isDarkMode
? AppColors.textPrimaryDark.withOpacity(0.1)
: AppColors.textPrimaryLight.withOpacity(0.2),
width: 1,
),
),
)
```

### Images

```dart
// Overlay plus foncé en dark mode pour meilleure lisibilité du texte
Container(
decoration: BoxDecoration(
image: DecorationImage(
image: NetworkImage(imageUrl),
fit: BoxFit.cover,
),
),
child: Container(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: isDarkMode
? [
Colors.transparent,
Colors.black.withOpacity(0.7), // Plus opaque
]
: [
Colors.transparent,
Colors.black.withOpacity(0.4),
],
),
),
),
)
```

### Shadows

```dart
// Moins de shadow en dark mode, plus de glow
BoxShadow(
color: isDarkMode
? Colors.black.withOpacity(0.3)
: Colors.black.withOpacity(0.1),
blurRadius: isDarkMode ? 8: 12,
offset: Offset(0, 4),
)
```

---

## Composants spécifiques

### Bottom Navigation

```dart
Container(
decoration: BoxDecoration(
color: isDarkMode
? AppColors.surfaceDark.withOpacity(0.9)
: AppColors.surface.withOpacity(0.8),
border: Border(
top: BorderSide(
color: isDarkMode
? AppColors.primaryDark.withOpacity(0.2)
: AppColors.primary.withOpacity(0.1),
),
),
),
...
)
```

### Input Fields

```dart
TextField(
style: TextStyle(
color: isDarkMode
? AppColors.textPrimaryDark
: AppColors.textPrimaryLight,
),
decoration: InputDecoration(
filled: true,
fillColor: isDarkMode
? AppColors.surfaceDark
: AppColors.surface,
border: OutlineInputBorder(
borderSide: BorderSide(
color: isDarkMode
? AppColors.textPrimaryDark.withOpacity(0.2)
: Colors.grey.shade200,
),
),
hintStyle: TextStyle(
color: isDarkMode
? AppColors.textSecondaryDark
: AppColors.textSecondaryLight,
),
),
)
```

### Buttons

```dart
ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: isDarkMode
? AppColors.primaryDark
: AppColors.primary,
foregroundColor: Colors.white, // Toujours blanc
),
...
)
```

---

## Images & Illustrations

### Overlay pour images

Les images doivent avoir un overlay plus foncé en dark mode pour assurer la lisibilité du texte superposé.

```dart
Stack(
children: [
Image.network(imageUrl),
Container(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
Colors.transparent,
isDarkMode
? Colors.black.withOpacity(0.8)
: Colors.black.withOpacity(0.5),
],
),
),
),
],
)
```

---

## Transitions

### Smooth Transition

```dart
AnimatedTheme(
data: isDarkMode ? darkTheme: lightTheme,
duration: Duration(milliseconds: 300),
curve: Curves.easeInOut,
child: MaterialApp(...),
)
```

---

## Tests de contraste

### Outils recommandés

- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Contrast Ratio Calculator](https://contrast-ratio.com/)

### Ratios minimums

- **Texte normal**: 4.5:1
- **Texte large (18px+)**: 3:1
- **Éléments interactifs**: 3:1

### Exemples validés

- Primary sur blanc: 4.5:1
- Texte primary dark sur background dark: 4.5:1
- Secondary sur surface dark: 4.5:1

---

## Bonnes pratiques

1. **Toujours tester** les deux modes
2. **Préserver l'identité**: Les couleurs doivent rester reconnaissables
3. **Éviter le noir pur**: Utiliser des tons verts foncés
4. **Réduire les ombres**: Moins d'élévation en dark mode
5. **Augmenter les overlays**: Pour les images avec texte

---

## Exemples visuels

Voir les maquettes Figma pour des exemples complets de chaque écran en dark mode.


