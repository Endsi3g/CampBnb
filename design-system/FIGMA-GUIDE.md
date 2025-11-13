# Guide de création des maquettes Figma

Instructions pour créer les maquettes Figma du design system Campbnb Québec.

## Configuration Figma

### 1. Créer un nouveau fichier Figma

1. Ouvrir Figma
2. Créer un nouveau fichier: "Campbnb Québec - Design System"
3. Organiser en pages:
- **Design System**: Composants de base
- **Screens**: Écrans complets
- **IA Screens**: Écrans avec IA
- **Dark Mode**: Variantes dark

### 2. Configurer les styles

#### Couleurs

Créer des styles de couleur pour chaque couleur du design system:

**Primary**
- `Primary/Base`: #2D572C
- `Primary/Light`: #4A7A4A
- `Primary/Dark`: #1A3A1A

**Secondary**
- `Secondary/Base`: #3B8EA5
- `Secondary/Light`: #5BA8C0
- `Secondary/Dark`: #2A6B7F

**Accent**
- `Accent/Base`: #F5E5D5
- `Accent/Light`: #FFF5EB
- `Accent/Dark`: #E8D4C0

**Text**
- `Text/Primary/Light`: #333333
- `Text/Secondary/Light`: #5C5C5C
- `Text/Primary/Dark`: #E0E0E0
- `Text/Secondary/Dark`: #B0B0B0

**Backgrounds**
- `Background/Light`: #FFFFFF
- `Background/Dark`: #152210
- `Surface/Light`: #FFFFFF
- `Surface/Dark`: #2A3F29

#### Typographie

Créer des styles de texte:

**Display**
- `Display/Large`: Plus Jakarta Sans, 32px, Bold (800), -0.5 letter-spacing
- `Display/Medium`: Plus Jakarta Sans, 28px, Bold (800), -0.3 letter-spacing
- `Display/Small`: Plus Jakarta Sans, 24px, Bold (700), -0.2 letter-spacing

**Headline**
- `Headline/Large`: Plus Jakarta Sans, 22px, Bold (700), -0.1 letter-spacing
- `Headline/Medium`: Plus Jakarta Sans, 20px, Bold (700), 0 letter-spacing
- `Headline/Small`: Plus Jakarta Sans, 18px, Bold (700), 0 letter-spacing

**Body**
- `Body/Large`: Plus Jakarta Sans, 16px, Regular (400), 0.15 letter-spacing
- `Body/Medium`: Plus Jakarta Sans, 14px, Regular (400), 0.25 letter-spacing
- `Body/Small`: Plus Jakarta Sans, 12px, Regular (400), 0.4 letter-spacing

**Label**
- `Label/Large`: Plus Jakarta Sans, 14px, Medium (500), 0.1 letter-spacing
- `Label/Medium`: Plus Jakarta Sans, 12px, Medium (500), 0.5 letter-spacing
- `Label/Small`: Plus Jakarta Sans, 11px, Medium (500), 0.5 letter-spacing

#### Effets

Créer des styles d'effets:

**Shadows**
- `Shadow/Small`: 0px 2px 4px rgba(0,0,0,0.05)
- `Shadow/Medium`: 0px 4px 8px rgba(0,0,0,0.08)
- `Shadow/Large`: 0px 8px 16px rgba(0,0,0,0.12)

**Blur**
- `Blur/Backdrop`: Background blur 10px

---

## Créer les composants

### 1. Boutons

#### Primary Button

- **Frame**: 48px height, auto width, padding 24px horizontal
- **Fill**: Primary/Base
- **Corner Radius**: 9999px (full)
- **Text**: Label/Large, blanc, bold
- **États**:
- Default
- Hover (opacity 90%)
- Pressed (scale 98%)
- Disabled (opacity 50%)

#### Secondary Button

- **Frame**: 48px height, auto width, padding 24px horizontal
- **Fill**: Transparent
- **Stroke**: Primary/Base, 20% opacity, 1px
- **Corner Radius**: 9999px
- **Text**: Label/Large, Primary/Base

### 2. Cards

#### Camping Card

- **Frame**: 360px width (mobile), auto height
- **Corner Radius**: 16px
- **Shadow**: Shadow/Medium
- **Structure**:
1. Image: 192px height, cover
2. Badge (optionnel): Position absolue, top-left, 12px padding
3. Content: 16px padding
- Titre: Display/Small
- Localisation: Body/Medium, Secondary
- Type: Body/Small, Secondary
- Prix: Display/Small, Primary, aligné droite

### 3. Inputs

#### Search Bar

- **Frame**: 56px height, auto width
- **Fill**: Surface/Light
- **Corner Radius**: 9999px
- **Stroke**: Gray-200, 1px
- **Padding**: 20px horizontal, 16px vertical
- **Icon**: Search, 24px, Secondary/Base, left
- **Text**: Body/Large, placeholder Secondary

### 4. Navigation

#### Bottom Navigation Bar

- **Frame**: 80px height, full width
- **Fill**: Surface/Light, 80% opacity
- **Blur**: Backdrop blur 10px
- **Stroke**: Top, Primary/Base, 10% opacity, 1px
- **Items**: 4, espacement égal
- Icon: 32px
- Text: Label/Small
- Active: Primary/Base
- Inactive: Text/Secondary

---

## Créer les écrans

### 1. Welcome Screen

**Frame**: 428px × 926px (iPhone 14 Pro Max)

**Structure**:
- Background image: Lac québécois, overlay gradient
- Logo: Icône feu de camp, 48px, Accent/Base
- Titre: Display/Large, Accent/Base, centré
- Sous-titre: Body/Large, Accent/Base, 90% opacity
- Boutons:
- Primary: "Inscription"
- Secondary: "Connexion" (outlined, blanc)

### 2. Home Screen

**Frame**: 428px × 926px

**Structure**:
- App Bar: 56px height
- Logo: 32px, Primary/Base
- Titre: Headline/Medium, Primary/Base, centré
- Search Bar: 56px height, 16px padding
- Filter Chips: 40px height, 3 chips, 12px gap
- Cards: Liste verticale, 16px gap
- Bottom Nav: 80px height, fixed bottom

### 3. Detail Screen

**Frame**: 428px × 926px

**Structure**:
- App Bar: Sticky, backdrop blur
- Image Carousel: 320px height, indicators
- Content: 16px padding
- Titre: Display/Medium
- Localisation: Body/Medium, Secondary
- Description: Body/Large
- Grid 2×2: Type, Capacité, Arrhes, Règlement
- Équipements: Liste avec icônes
- Bottom Bar: Fixed, 80px height
- Prix: Display/Medium, Primary
- Bouton: Primary Button

### 4. Reservation Screen

**Frame**: 428px × 926px

**Structure**:
- App Bar: 56px height
- Calendrier: 2 mois, grille 7 colonnes
- Compteurs: Adultes/Enfants avec steppers
- Résumé: Prix détaillé
- Bottom Bar: Fixed, bouton "Confirmer"

---

## Écrans IA

### 1. Chat Gemini Screen

**Frame**: 428px × 926px

**Structure**:
- App Bar: "Chat Gemini" avec icône IA
- Messages: Liste verticale
- Message IA: Aligné gauche, Accent background
- Message User: Aligné droite, Primary background
- Input: 56px height, microphone button

### 2. Suggestions Screen

**Frame**: 428px × 926px

**Structure**:
- Header: "Suggestions pour vous" avec icône IA
- Cards: Horizontal scroll, badge "Suggéré pour vous"
- Reason: Overlay sur card avec raison

### 3. Review Screen (IA)

**Frame**: 428px × 926px

**Structure**:
- Rating: 5 étoiles
- Badge: "Généré par IA"
- Text Area: 8 lignes, éditable
- Button: "Générer avec IA"
- Photos: Grille
- CTA: "Publier l'avis"

---

## Dark Mode

### Créer des variantes

Pour chaque écran, créer une variante dark:

1. Dupliquer le frame
2. Renommer: "[Screen Name] - Dark"
3. Appliquer les couleurs dark:
- Background: Background/Dark
- Surface: Surface/Dark
- Text: Text/Primary/Dark
- Primary: Primary/Dark (adapté)

### Variables Figma

Utiliser les variables Figma pour gérer les thèmes:

1. Créer des variables de couleur
2. Créer des modes: "Light" et "Dark"
3. Appliquer les variables aux composants
4. Basculer entre les modes facilement

---

## Grille et espacements

### Grille de base

- **Columns**: 4 colonnes
- **Gutter**: 16px
- **Margin**: 16px (mobile), 24px (tablette)

### Espacements

Créer des composants d'espacement réutilisables:
- Spacer/4: 4px
- Spacer/8: 8px
- Spacer/16: 16px
- Spacer/24: 24px
- Spacer/32: 32px

---

## Prototypage

### Interactions

Configurer les interactions dans Figma:

1. **Navigation**: On click → Navigate to screen
2. **Hover**: Change opacity/scale
3. **Press**: Change scale to 98%
4. **Input**: Open keyboard overlay

### Animations

- **Page transitions**: Slide from right, 300ms
- **Modal**: Fade + scale, 400ms
- **Bottom sheet**: Slide from bottom, 300ms

---

## Organisation

### Structure recommandée

```
Campbnb Québec Design System
├── Design System
│ ├── Colors
│ ├── Typography
│ ├── Components
│ │ ├── Buttons
│ │ ├── Cards
│ │ ├── Inputs
│ │ └── Navigation
│ └── Icons
├── Screens
│ ├── Authentication
│ ├── Home
│ ├── Search
│ ├── Details
│ └── Reservation
├── IA Screens
│ ├── Chat Gemini
│ ├── Suggestions
│ └── Review
└── Dark Mode
└── [Variantes dark de tous les écrans]
```

---

## Checklist

### Design System
- [ ] Styles de couleur créés
- [ ] Styles de texte créés
- [ ] Styles d'effets créés
- [ ] Composants de base créés
- [ ] Variantes (états) créées

### Screens
- [ ] Welcome Screen
- [ ] Onboarding (3 écrans)
- [ ] Home Screen
- [ ] Search Screen
- [ ] Detail Screen
- [ ] Reservation Screen
- [ ] Profile Screen
- [ ] Settings Screen

### IA Screens
- [ ] Chat Gemini Screen
- [ ] Suggestions Screen
- [ ] Review Screen (IA)
- [ ] Voice Search Screen

### Dark Mode
- [ ] Variantes dark de tous les écrans
- [ ] Variables Figma configurées

### Prototypage
- [ ] Interactions configurées
- [ ] Animations définies
- [ ] Flow complet testé

---

## Export

### Pour développement

1. **Inspect Mode**: Activer pour les développeurs
2. **Export assets**: Préparer les assets nécessaires
3. **Spécifications**: Vérifier que tout est documenté

### Pour présentation

1. **Prototype**: Créer un prototype cliquable
2. **Présentation**: Organiser en slides si nécessaire
3. **Documentation**: Ajouter des notes explicatives

---

## Ressources

- [Figma Documentation](https://help.figma.com/)
- [Figma Variables](https://help.figma.com/hc/en-us/articles/15339657135383)
- [Material Design 3 in Figma](https://m3.material.io/)

---

**Note**: Ce guide fournit les instructions pour créer les maquettes. Les maquettes elles-mêmes doivent être créées dans Figma par un designer.


