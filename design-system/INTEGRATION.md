# Guide d'intégration Flutter

Guide complet pour intégrer le design system Campbnb Québec dans votre application Flutter.

## Installation

### 1. Copier les fichiers de thème

Copiez le fichier `design-system/flutter-specs/theme.dart` dans votre projet:

```bash
cp design-system/flutter-specs/theme.dart lib/core/theme/app_theme.dart
```

### 2. Configurer le thème dans main.dart

```dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
runApp(MyApp());
}

class MyApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Campbnb Québec',
theme: AppTheme.lightTheme,
darkTheme: AppTheme.darkTheme,
themeMode: ThemeMode.system, // Suit les préférences système
home: HomeScreen(),
);
}
}
```

### 3. Utiliser les composants

Copiez les composants depuis `design-system/flutter-specs/components/` dans votre projet:

```bash
mkdir -p lib/shared/widgets
cp design-system/flutter-specs/components/*.dart lib/shared/widgets/
```

### 4. Importer dans vos écrans

```dart
import 'package:campbnb_quebec/shared/widgets/camping_card.dart';
import 'package:campbnb_quebec/shared/widgets/search_bar.dart';
import 'package:campbnb_quebec/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
@override
Widget build(BuildContext context) {
return Scaffold(
body: Column(
children: [
SearchBar(
hintText: 'Lieu, hébergement, dates',
onChanged: (value) {
// Gérer la recherche
},
),
Expanded(
child: ListView.builder(
itemCount: campings.length,
itemBuilder: (context, index) {
return CampingCard(
imageUrl: campings[index].imageUrl,
title: campings[index].title,
location: campings[index].location,
type: campings[index].type,
price: campings[index].price,
badge: campings[index].badge,
onTap: () {
// Navigation vers détails
},
);
},
),
),
],
),
);
}
}
```

---

## Utilisation des couleurs

### Accès direct

```dart
Container(
color: AppColors.primary,
child: Text(
'Texte',
style: TextStyle(color: AppColors.textInverseLight),
),
)
```

### Via Theme

```dart
Container(
color: Theme.of(context).primaryColor,
child: Text(
'Texte',
style: Theme.of(context).textTheme.bodyLarge,
),
)
```

### Adaptation Dark Mode

```dart
final isDarkMode = Theme.of(context).brightness == Brightness.dark;
Container(
color: isDarkMode ? AppColors.surfaceDark: AppColors.surfaceLight,
)
```

---

## Utilisation de la typographie

### Styles prédéfinis

```dart
Text(
'Titre principal',
style: AppTextStyles.displayLarge,
)

Text(
'Sous-titre',
style: AppTextStyles.headlineMedium,
)

Text(
'Corps de texte',
style: AppTextStyles.bodyLarge,
)
```

### Via Theme

```dart
Text(
'Titre',
style: Theme.of(context).textTheme.displayLarge,
)
```

---

## Utilisation des espacements

```dart
Padding(
padding: EdgeInsets.all(AppSpacing.md), // 16px
child: Column(
children: [
Widget1(),
SizedBox(height: AppSpacing.lg), // 24px
Widget2(),
],
),
)
```

---

## Utilisation des animations

### Transitions de page

```dart
Navigator.push(
context,
PageRouteBuilder(
pageBuilder: (context, animation, secondaryAnimation) => NextScreen(),
transitionsBuilder: (context, animation, secondaryAnimation, child) {
return SlideTransition(
position: Tween<Offset>(
begin: Offset(1.0, 0.0),
end: Offset.zero,
).animate(CurvedAnimation(
parent: animation,
curve: Curves.easeInOut,
)),
child: child,
);
},
transitionDuration: Duration(milliseconds: 300),
),
);
```

### Animations de bouton

```dart
AnimatedScale(
scale: isPressed ? 0.98: 1.0,
duration: Duration(milliseconds: 100),
child: ElevatedButton(
onPressed: () {},
child: Text('Bouton'),
),
)
```

---

## Créer de nouveaux composants

### Structure recommandée

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MyCustomComponent extends StatelessWidget {
final String title;
final VoidCallback? onTap;

const MyCustomComponent({
Key? key,
required this.title,
this.onTap,
}): super(key: key);

@override
Widget build(BuildContext context) {
final isDarkMode = Theme.of(context).brightness == Brightness.dark;

return Container(
padding: EdgeInsets.all(AppSpacing.md),
decoration: BoxDecoration(
color: isDarkMode ? AppColors.surfaceDark: AppColors.surfaceLight,
borderRadius: BorderRadius.circular(AppRadius.lg),
),
child: Text(
title,
style: AppTextStyles.headlineMedium.copyWith(
color: isDarkMode
? AppColors.textPrimaryDark
: AppColors.textPrimaryLight,
),
),
);
}
}
```

### Bonnes pratiques

1. **Toujours supporter le dark mode**
2. **Utiliser les constantes du design system**
3. **Respecter les espacements (8px base)**
4. **Utiliser les styles de texte prédéfinis**
5. **Tester sur différentes tailles d'écran**

---

## Responsive

### Breakpoints

```dart
class AppBreakpoints {
static const double mobile = 428.0;
static const double tablet = 768.0;
static const double desktop = 1024.0;
}

// Utilisation
final width = MediaQuery.of(context).size.width;
if (width < AppBreakpoints.mobile) {
// Layout mobile
} else if (width < AppBreakpoints.tablet) {
// Layout tablette
} else {
// Layout desktop
}
```

### Layout adaptatif

```dart
LayoutBuilder(
builder: (context, constraints) {
if (constraints.maxWidth < 428) {
return MobileLayout();
} else {
return TabletLayout();
}
},
)
```

---

## Tests

### Tests de composants

```dart
testWidgets('CampingCard affiche les informations correctement', (tester) async {
await tester.pumpWidget(
MaterialApp(
theme: AppTheme.lightTheme,
home: Scaffold(
body: CampingCard(
imageUrl: 'https://example.com/image.jpg',
title: 'Test Camping',
location: 'Test Location',
type: 'Tente',
price: 50.0,
),
),
),
);

expect(find.text('Test Camping'), findsOneWidget);
expect(find.text('Test Location'), findsOneWidget);
expect(find.text('\$50'), findsOneWidget);
});
```

### Tests de thème

```dart
test('Light theme utilise les bonnes couleurs', () {
final theme = AppTheme.lightTheme;
expect(theme.primaryColor, AppColors.primary);
expect(theme.scaffoldBackgroundColor, AppColors.backgroundLight);
});
```

---

## Dépannage

### Problèmes courants

#### Les couleurs ne s'appliquent pas

Vérifiez que vous utilisez `Theme.of(context)` ou les constantes `AppColors` directement.

#### Le dark mode ne fonctionne pas

Assurez-vous d'avoir configuré `themeMode: ThemeMode.system` ou `ThemeMode.dark` dans `MaterialApp`.

#### Les polices ne s'affichent pas

Vérifiez que la police Plus Jakarta Sans est bien configurée dans `pubspec.yaml` et que les fichiers de police sont présents dans `assets/fonts/`.

---

## Ressources supplémentaires

- [Documentation Flutter](https://flutter.dev/docs)
- [Material Design 3](https://m3.material.io/)
- [Design System Documentation](./README.md)

---

## Mises à jour

Ce guide sera mis à jour avec chaque nouvelle version du design system.

**Version actuelle**: 1.0.0


