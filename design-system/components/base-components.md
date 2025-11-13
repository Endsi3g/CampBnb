# Composants de base

## Boutons

### Bouton primaire

**Usage**: Actions principales (réserver, confirmer, sauvegarder)

**Spécifications**:
- Hauteur: `48px` (12.0)
- Padding horizontal: `24px` (6.0)
- Border radius: `9999px` (full)
- Font: Plus Jakarta Sans, 16px, Bold
- Couleur: Primary (#2D572C)
- Texte: Blanc

**États**:
- Default: Background primary, texte blanc
- Pressed: Opacity 0.9, scale 0.98
- Disabled: Opacity 0.5, non cliquable
- Loading: Spinner + texte

**Flutter**:
```dart
ElevatedButton(
onPressed: onPressed,
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.primary,
foregroundColor: Colors.white,
minimumSize: Size(double.infinity, 48),
padding: EdgeInsets.symmetric(horizontal: 24),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(9999),
),
elevation: 0,
),
child: Text(
label,
style: AppTextStyles.labelLarge.copyWith(
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
)
```

### Bouton secondaire

**Usage**: Actions secondaires (annuler, voir plus)

**Spécifications**:
- Même dimensions que primaire
- Background: Transparent ou surface
- Border: 1px solid primary/20
- Texte: Primary

**Flutter**:
```dart
OutlinedButton(
onPressed: onPressed,
style: OutlinedButton.styleFrom(
backgroundColor: Colors.transparent,
foregroundColor: AppColors.primary,
minimumSize: Size(double.infinity, 48),
padding: EdgeInsets.symmetric(horizontal: 24),
side: BorderSide(
color: AppColors.primary.withOpacity(0.2),
width: 1,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(9999),
),
),
child: Text(label, style: AppTextStyles.labelLarge),
)
```

### Bouton texte

**Usage**: Actions tertiaires (lien, annuler)

**Spécifications**:
- Pas de background
- Texte: Primary ou Secondary
- Padding réduit

---

## Cards

### Card de camping

**Usage**: Affichage des campings dans les listes

**Spécifications**:
- Border radius: `16px` (4.0)
- Shadow: shadowMD
- Image: 192px de hauteur (48.0)
- Padding: `16px` (4.0)
- Espacement entre éléments: `12px` (3.0)

**Structure**:
1. Badge (optionnel): Position absolue top-left
2. Image: Cover, aspect ratio 16:9
3. Titre: Display Small, Bold
4. Localisation: Body Medium, Secondary
5. Type: Body Small, Secondary
6. Prix: Display Small, Primary, aligné à droite

**Flutter**:
```dart
Card(
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Stack(
children: [
ClipRRect(
borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
child: Image.network(
imageUrl,
height: 192,
width: double.infinity,
fit: BoxFit.cover,
),
),
if (badge != null)
Positioned(
top: 12,
left: 12,
child: _Badge(label: badge),
),
],
),
Padding(
padding: EdgeInsets.all(16),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(title, style: AppTextStyles.displaySmall),
SizedBox(height: 4),
Text(location, style: AppTextStyles.bodyMedium),
SizedBox(height: 4),
Text(type, style: AppTextStyles.bodySmall),
],
),
),
Text(
'\$$price / nuit',
style: AppTextStyles.displaySmall.copyWith(
color: AppColors.primary,
),
),
],
),
),
],
),
)
```

### Badge

**Usage**: Indicateurs (Populaire, Nouveau, Bord de l'eau)

**Spécifications**:
- Height: `24px` (6.0)
- Padding horizontal: `12px` (3.0)
- Border radius: `9999px`
- Font: 12px, Bold
- Couleurs:
- Populaire: Secondary
- Nouveau: Primary
- Bord de l'eau: Secondary/80

---

## Inputs

### Champ de recherche

**Usage**: Barre de recherche principale

**Spécifications**:
- Height: `56px` (14.0)
- Border radius: `9999px`
- Background: Surface
- Border: 1px gray-200
- Padding: `20px` horizontal (5.0)
- Icône search: 24px, Secondary

**Flutter**:
```dart
TextField(
decoration: InputDecoration(
hintText: 'Lieu, hébergement, dates',
prefixIcon: Icon(Icons.search, color: AppColors.secondary),
filled: true,
fillColor: AppColors.surface,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(9999),
borderSide: BorderSide(color: Colors.grey.shade200),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(9999),
borderSide: BorderSide(color: Colors.grey.shade200),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(9999),
borderSide: BorderSide(color: AppColors.primary, width: 2),
),
contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
),
)
```

### Champ de formulaire

**Usage**: Formulaires (inscription, connexion, ajout listing)

**Spécifications**:
- Height: `56px`
- Border radius: `12px` (3.0)
- Background: Surface
- Label: 14px, Medium, au-dessus
- Placeholder: 16px, Secondary
- Error: Border rouge, message en dessous

---

## Navigation

### Bottom Navigation Bar

**Usage**: Navigation principale

**Spécifications**:
- Height: `80px` (20.0)
- Background: Surface/80 avec backdrop blur
- Border top: 1px primary/10
- Items: 4 (Accueil, Favoris, Réservations, Profil)
- Icônes: 32px (Material Symbols)
- Texte: 12px, Bold si actif
- Couleur active: Primary
- Couleur inactive: Secondary

**Flutter**:
```dart
Container(
height: 80,
decoration: BoxDecoration(
color: AppColors.surface.withOpacity(0.8),
border: Border(
top: BorderSide(
color: AppColors.primary.withOpacity(0.1),
width: 1,
),
),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceAround,
children: navItems.map((item) => _NavItem(item: item)).toList(),
),
)
```

### App Bar

**Usage**: En-tête des écrans

**Spécifications**:
- Height: `56px` (14.0)
- Background: Surface/80 avec backdrop blur
- Sticky: Oui
- Padding: `16px` horizontal (4.0)
- Titre: Centré, 18px, Bold
- Actions: Icônes 24px, droite

---

## Filtres

### Chip de filtre

**Usage**: Filtres rapides (Prix, Type, Région)

**Spécifications**:
- Height: `40px` (10.0)
- Padding horizontal: `16px` (4.0)
- Border radius: `9999px`
- Border: 1px primary/20
- Background: Surface ou Primary si actif
- Texte: 14px, Medium
- Icône expand: 20px

---

## Calendrier

### Date Picker

**Usage**: Sélection de dates pour réservation

**Spécifications**:
- Grille 7 colonnes
- Jours de la semaine: 13px, Bold, Secondary
- Jours: 14px, Medium
- Jours sélectionnés: Background Primary, texte blanc
- Jours dans la plage: Background Accent
- Border radius: `9999px` pour jours individuels

---

## Compteurs

### Stepper (Adultes/Enfants)

**Usage**: Sélection du nombre de personnes

**Spécifications**:
- Layout: Horizontal, espacement entre
- Icône: 40px, Accent background
- Labels: 16px Medium, 14px Secondary
- Boutons +/-: 32px, border Secondary
- Valeur: 16px Medium, centré

---

## Loading States

### Shimmer

**Usage**: Placeholder pendant le chargement

**Spécifications**:
- Animation: Shimmer effect
- Durée: 1.5s, loop
- Couleur: Gray-200 → Gray-100

### Skeleton

**Usage**: Structure de chargement pour cards

---

## Empty States

### État vide

**Usage**: Aucun résultat, liste vide

**Spécifications**:
- Illustration: 200px
- Titre: Headline Medium
- Description: Body Medium, Secondary
- CTA: Bouton primaire

---

## Modals

### Bottom Sheet

**Usage**: Actions contextuelles, filtres

**Spécifications**:
- Border radius top: `24px` (6.0)
- Max height: 90% de l'écran
- Handle: Barre grise, 4px height, 40px width
- Padding: `24px` (6.0)

### Dialog

**Usage**: Confirmations, alertes

**Spécifications**:
- Width: 90% max, 400px max
- Border radius: `24px`
- Padding: `24px`
- Shadow: shadowLG


