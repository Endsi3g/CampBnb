# Interactions & Micro-animations

## Principes d'animation

### Durées

- **Rapide**: 150ms - Interactions immédiates (hover, press)
- **Standard**: 200-300ms - Transitions courantes
- **Longue**: 400-500ms - Transitions complexes, navigation

### Courbes d'animation

```dart
// Standard
Curves.easeInOut

// Entrée
Curves.easeOut

// Sortie
Curves.easeIn

// Élastique (pour feedback)
Curves.elasticOut
```

### Transitions

- **Fade**: Opacity 0 → 1
- **Slide**: TranslateY/X
- **Scale**: Scale 0.95 → 1.0
- **Combinaison**: Fade + Slide

---

## Interactions par composant

### Boutons

#### Press

```dart
AnimatedScale(
scale: isPressed ? 0.98: 1.0,
duration: Duration(milliseconds: 100),
child: GestureDetector(
onTapDown: (_) => setState(() => isPressed = true),
onTapUp: (_) => setState(() => isPressed = false),
onTapCancel: () => setState(() => isPressed = false),
child: _Button(),
),
)
```

#### Ripple Effect

```dart
InkWell(
onTap: onPressed,
borderRadius: BorderRadius.circular(9999),
child: Container(...),
)
```

### Cards

#### Hover (tablette/desktop)

```dart
MouseRegion(
onEnter: (_) => setState(() => isHovered = true),
onExit: (_) => setState(() => isHovered = false),
child: AnimatedContainer(
duration: Duration(milliseconds: 200),
transform: Matrix4.identity()..scale(isHovered ? 1.02: 1.0),
child: Card(...),
),
)
```

#### Tap Feedback

```dart
GestureDetector(
onTapDown: (_) => setState(() => isPressed = true),
onTapUp: (_) {
setState(() => isPressed = false);
onTap();
},
child: AnimatedScale(
scale: isPressed ? 0.97: 1.0,
duration: Duration(milliseconds: 100),
child: Card(...),
),
)
```

### Navigation

#### Bottom Nav Transition

```dart
AnimatedContainer(
duration: Duration(milliseconds: 300),
curve: Curves.easeInOut,
child: BottomNavigationBar(
currentIndex: currentIndex,
onTap: (index) {
setState(() => currentIndex = index);
},
type: BottomNavigationBarType.fixed,
),
)
```

#### Page Transitions

```dart
// Slide depuis la droite
PageRouteBuilder(
pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
transitionsBuilder: (context, animation, secondaryAnimation, child) {
const begin = Offset(1.0, 0.0);
const end = Offset.zero;
const curve = Curves.easeInOut;

var tween = Tween(begin: begin, end: end).chain(
CurveTween(curve: curve),
);

return SlideTransition(
position: animation.drive(tween),
child: child,
);
},
transitionDuration: Duration(milliseconds: 300),
)
```

### Inputs

#### Focus Animation

```dart
AnimatedContainer(
duration: Duration(milliseconds: 200),
decoration: BoxDecoration(
border: Border.all(
color: isFocused ? AppColors.primary: Colors.grey.shade200,
width: isFocused ? 2: 1,
),
borderRadius: BorderRadius.circular(9999),
),
child: TextField(
onTap: () => setState(() => isFocused = true),
onSubmitted: (_) => setState(() => isFocused = false),
...
),
)
```

#### Validation Feedback

```dart
AnimatedSwitcher(
duration: Duration(milliseconds: 200),
child: hasError
? Text(
errorMessage,
key: ValueKey('error'),
style: TextStyle(color: AppColors.error),
)
: SizedBox.shrink(key: ValueKey('empty')),
)
```

### Lists

#### Pull to Refresh

```dart
RefreshIndicator(
onRefresh: () async {
await loadData();
},
color: AppColors.primary,
child: ListView(...),
)
```

#### Infinite Scroll

```dart
NotificationListener<ScrollNotification>(
onNotification: (notification) {
if (notification is ScrollEndNotification) {
if (scrollController.position.pixels >=
scrollController.position.maxScrollExtent - 200) {
loadMore();
}
}
return false;
},
child: ListView(...),
)
```

### Modals

#### Bottom Sheet Animation

```dart
showModalBottomSheet(
context: context,
isScrollControlled: true,
backgroundColor: Colors.transparent,
builder: (context) => DraggableScrollableSheet(
initialChildSize: 0.5,
minChildSize: 0.3,
maxChildSize: 0.9,
builder: (context, scrollController) => Container(
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
),
child: ListView(controller: scrollController, ...),
),
),
)
```

#### Dialog Fade

```dart
showDialog(
context: context,
barrierColor: Colors.black.withOpacity(0.5),
builder: (context) => FadeTransition(
opacity: animation,
child: Dialog(...),
),
)
```

---

## Animations de chargement

### Shimmer

```dart
Shimmer.fromColors(
baseColor: Colors.grey.shade300,
highlightColor: Colors.grey.shade100,
child: Container(
width: double.infinity,
height: 200,
color: Colors.white,
),
)
```

### Skeleton Loader

```dart
SkeletonLoader(
builder: Container(
padding: EdgeInsets.all(16),
child: Column(
children: [
SkeletonItem(
child: Container(
height: 200,
decoration: BoxDecoration(
color: Colors.grey.shade300,
borderRadius: BorderRadius.circular(16),
),
),
),
SizedBox(height: 16),
SkeletonItem(
child: Container(
height: 20,
width: double.infinity,
decoration: BoxDecoration(
color: Colors.grey.shade300,
borderRadius: BorderRadius.circular(4),
),
),
),
],
),
),
)
```

### Progress Indicator

```dart
CircularProgressIndicator(
valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
strokeWidth: 3,
)
```

---

## Animations de feedback

### Success Toast

```dart
AnimatedPositioned(
duration: Duration(milliseconds: 300),
curve: Curves.easeOut,
top: isVisible ? 0: -100,
child: Container(
padding: EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppColors.success,
borderRadius: BorderRadius.circular(12),
),
child: Row(
children: [
Icon(Icons.check_circle, color: Colors.white),
SizedBox(width: 12),
Text('Réservation confirmée!', style: TextStyle(color: Colors.white)),
],
),
),
)
```

### Error Shake

```dart
AnimatedBuilder(
animation: shakeAnimation,
builder: (context, child) {
return Transform.translate(
offset: Offset(shakeAnimation.value * 10, 0),
child: child,
);
},
child: TextField(...),
)
```

### Confirmation Pulse

```dart
AnimatedContainer(
duration: Duration(milliseconds: 300),
curve: Curves.easeInOut,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: isConfirmed
? AppColors.success.withOpacity(0.2)
: Colors.transparent,
),
child: Icon(
Icons.check_circle,
color: isConfirmed ? AppColors.success: Colors.grey,
size: isConfirmed ? 48: 40,
),
)
```

---

## Animations de page

### Page Transitions

#### Slide Right

```dart
PageRouteBuilder(
pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
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
)
```

#### Fade

```dart
PageRouteBuilder(
pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
transitionsBuilder: (context, animation, secondaryAnimation, child) {
return FadeTransition(
opacity: animation,
child: child,
);
},
)
```

#### Scale

```dart
PageRouteBuilder(
pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
transitionsBuilder: (context, animation, secondaryAnimation, child) {
return ScaleTransition(
scale: Tween<double>(begin: 0.8, end: 1.0).animate(
CurvedAnimation(parent: animation, curve: Curves.easeOut),
),
child: FadeTransition(
opacity: animation,
child: child,
),
);
},
)
```

---

## Animations de liste

### Staggered List

```dart
ListView.builder(
itemCount: items.length,
itemBuilder: (context, index) {
return TweenAnimationBuilder<double>(
tween: Tween(begin: 0.0, end: 1.0),
duration: Duration(milliseconds: 300 + (index * 50)),
builder: (context, value, child) {
return Opacity(
opacity: value,
child: Transform.translate(
offset: Offset(0, 20 * (1 - value)),
child: child,
),
);
},
child: ListItem(item: items[index]),
);
},
)
```

### Swipe to Delete

```dart
Dismissible(
key: Key(item.id),
direction: DismissDirection.endToStart,
background: Container(
alignment: Alignment.centerRight,
padding: EdgeInsets.only(right: 20),
color: AppColors.error,
child: Icon(Icons.delete, color: Colors.white),
),
onDismissed: (direction) {
deleteItem(item);
},
child: ListItem(item: item),
)
```

---

## Performance

### Best Practices

1. **Utiliser `AnimatedContainer`** pour les animations simples
2. **Éviter les rebuilds inutiles** avec `const` widgets
3. **Utiliser `RepaintBoundary`** pour isoler les animations
4. **Limiter les animations simultanées** (max 2-3)
5. **Désactiver les animations** si `MediaQuery.of(context).disableAnimations`

### Optimisation

```dart
// Utiliser AnimatedBuilder pour éviter les rebuilds
AnimatedBuilder(
animation: animationController,
builder: (context, child) {
return Transform.scale(
scale: animationController.value,
child: child,
);
},
child: ExpensiveWidget(), // Ne sera pas reconstruit
)
```

---

## Accessibilité

### Respecter les préférences

```dart
// Désactiver les animations si demandé
final disableAnimations = MediaQuery.of(context).disableAnimations;

if (disableAnimations) {
return StaticWidget();
} else {
return AnimatedWidget();
}
```

### Feedback haptique

```dart
import 'package:flutter/services.dart';

// Vibration légère pour feedback
HapticFeedback.lightImpact();

// Vibration moyenne pour confirmation
HapticFeedback.mediumImpact();

// Vibration forte pour erreur
HapticFeedback.heavyImpact();
```


