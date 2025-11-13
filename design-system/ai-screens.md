# Écrans IA - Campbnb Québec

Documentation des écrans intégrant l'intelligence artificielle (Gemini 2.5) dans l'expérience Campbnb.

## Vue d'ensemble

L'IA est intégrée de manière contextuelle pour améliorer l'expérience utilisateur sans être intrusive. Les fonctionnalités IA sont clairement identifiées et l'utilisateur garde toujours le contrôle.

---

## 1. Chat Gemini Contextuel

### Description

Assistant conversationnel intégré pour aider les utilisateurs dans leur recherche et réservation de campings.

### Cas d'usage

- Recherche vocale ou textuelle de campings
- Suggestions personnalisées basées sur les préférences
- Réponses aux questions sur les équipements, règles, disponibilités
- Aide à la réservation (dates alternatives, prix, etc.)

### Design

#### Layout

```
┌─────────────────────────────┐
│ [←] Chat Gemini [×] │ ← App Bar
├─────────────────────────────┤
│ │
│ Bonjour ! Comment puis- │ ← Message IA
│ je vous aider ? │
│ │
│ Je cherche un camping │ ← Message utilisateur
│ près d'un lac pour │
│ 4 personnes en juillet │
│ │
│ Voici 3 suggestions... │ ← Message IA avec cards
│ [Card 1] [Card 2] [Card 3]│
│ │
│ Quel est le prix moyen ?│
│ │
│ Le prix moyen est de... │
│ │
├─────────────────────────────┤
│ [] [Tapez votre message] │ ← Input avec bouton vocal
└─────────────────────────────┘
```

#### Composants

**App Bar**
- Titre: "Chat Gemini" avec icône IA
- Bouton fermer (×)
- Indicateur de statut (en ligne, en train d'écrire...)

**Messages**
- Messages IA: Alignés à gauche, background Accent
- Messages utilisateur: Alignés à droite, background Primary
- Timestamp: 12px, Secondary, sous chaque message
- Typing indicator: Animation de points

**Input**
- Champ texte avec placeholder "Tapez votre message..."
- Bouton microphone (recherche vocale)
- Bouton envoyer (apparaît quand texte saisi)
- Suggestions rapides (chips cliquables)

**Cards de suggestions**
- Intégrées dans les messages IA
- Format similaire aux cards de camping
- Bouton "Voir détails" ou "Réserver"

#### Spécifications Flutter

```dart
class GeminiChatScreen extends StatelessWidget {
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Row(
children: [
Icon(Icons.auto_awesome, color: AppColors.secondary),
SizedBox(width: 8),
Text('Chat Gemini'),
],
),
actions: [
IconButton(
icon: Icon(Icons.close),
onPressed: () => Navigator.pop(context),
),
],
),
body: Column(
children: [
Expanded(
child: ListView.builder(
itemCount: messages.length,
itemBuilder: (context, index) {
return _MessageBubble(message: messages[index]);
},
),
),
_ChatInput(),
],
),
);
}
}

class _MessageBubble extends StatelessWidget {
final Message message;

@override
Widget build(BuildContext context) {
final isAI = message.isFromAI;

return Align(
alignment: isAI ? Alignment.centerLeft: Alignment.centerRight,
child: Container(
margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
padding: EdgeInsets.all(12),
constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
decoration: BoxDecoration(
color: isAI ? AppColors.accent: AppColors.primary,
borderRadius: BorderRadius.circular(16),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
message.text,
style: TextStyle(
color: isAI ? AppColors.textPrimaryLight: Colors.white,
),
),
if (message.suggestions != null)
...message.suggestions!.map((suggestion) => _SuggestionCard(suggestion)),
],
),
),
);
}
}
```

### États

- **Idle**: En attente de message
- **Typing**: IA en train de répondre (animation)
- **Streaming**: Réponse en cours de génération (texte qui apparaît progressivement)
- **Error**: Erreur de connexion ou de traitement

### Micro-animations

- **Typing indicator**: 3 points animés (bounce)
- **Message apparition**: Fade + slide depuis le bas
- **Streaming text**: Texte qui apparaît progressivement
- **Suggestion cards**: Slide depuis la droite avec stagger

---

## 2. Suggestions Intelligentes

### Description

Section dédiée aux recommandations personnalisées basées sur l'historique, les préférences et le contexte.

### Cas d'usage

- Suggestions sur l'écran d'accueil
- Recommandations après une recherche
- Alternatives si dates non disponibles
- Suggestions basées sur la localisation

### Design

#### Layout

```
┌─────────────────────────────┐
│ Suggestions pour vous │ ← Section header
│ [Basé sur vos préférences] │
├─────────────────────────────┤
│ │
│ [Card 1] │
│ [Card 2] │
│ [Card 3] │
│ │
│ [Voir plus de suggestions] │ ← CTA
│ │
└─────────────────────────────┘
```

#### Composants

**Section Header**
- Titre: "Suggestions pour vous"
- Sous-titre: "Basé sur vos préférences" ou raison de la suggestion
- Badge IA: Petite icône indiquant que c'est une suggestion IA

**Cards de suggestion**
- Format standard de card de camping
- Badge "Suggéré pour vous" ou "Parfait pour vous"
- Indicateur de correspondance (score de pertinence)
- Raison de la suggestion: "Parce que vous aimez les lacs"

**CTA**
- Bouton "Voir plus de suggestions"
- Lien vers écran dédié aux suggestions

#### Spécifications Flutter

```dart
class SuggestionsSection extends StatelessWidget {
@override
Widget build(BuildContext context) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Padding(
padding: EdgeInsets.symmetric(horizontal: 16),
child: Row(
children: [
Icon(Icons.auto_awesome, size: 20, color: AppColors.secondary),
SizedBox(width: 8),
Text(
'Suggestions pour vous',
style: AppTextStyles.headlineMedium,
),
],
),
),
SizedBox(height: 8),
Padding(
padding: EdgeInsets.symmetric(horizontal: 16),
child: Text(
'Basé sur vos préférences',
style: AppTextStyles.bodySmall.copyWith(
color: AppColors.textSecondaryLight,
),
),
),
SizedBox(height: 16),
SizedBox(
height: 300,
child: ListView.builder(
scrollDirection: Axis.horizontal,
padding: EdgeInsets.symmetric(horizontal: 16),
itemCount: suggestions.length,
itemBuilder: (context, index) {
return _SuggestionCard(suggestion: suggestions[index]);
},
),
),
],
);
}
}

class _SuggestionCard extends StatelessWidget {
final Suggestion suggestion;

@override
Widget build(BuildContext context) {
return Container(
width: 280,
margin: EdgeInsets.only(right: 16),
child: Stack(
children: [
CampingCard(camping: suggestion.camping),
Positioned(
top: 12,
left: 12,
child: Container(
padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
decoration: BoxDecoration(
color: AppColors.secondary,
borderRadius: BorderRadius.circular(12),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(Icons.auto_awesome, size: 12, color: Colors.white),
SizedBox(width: 4),
Text(
'Suggéré pour vous',
style: TextStyle(
color: Colors.white,
fontSize: 10,
fontWeight: FontWeight.bold,
),
),
],
),
),
),
Positioned(
bottom: 16,
left: 16,
right: 16,
child: Container(
padding: EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.black.withOpacity(0.6),
borderRadius: BorderRadius.circular(8),
),
child: Text(
suggestion.reason,
style: TextStyle(
color: Colors.white,
fontSize: 12,
),
),
),
),
],
),
);
}
}
```

### États

- **Loading**: Skeleton loaders
- **Empty**: Message "Aucune suggestion pour le moment"
- **Error**: Message d'erreur avec bouton réessayer

---

## 3. Avis Automatisés

### Description

Génération automatique d'avis basés sur les données de réservation, avec possibilité de personnalisation.

### Cas d'usage

- Génération d'avis après un séjour
- Suggestions de texte pour l'avis
- Complétion automatique basée sur les photos
- Traduction automatique

### Design

#### Layout

```
┌─────────────────────────────┐
│ [←] Rédiger un avis │
├─────────────────────────────┤
│ │
│ ⭐⭐⭐⭐⭐ (5.0) │ ← Note
│ │
│ [Avis généré par IA] │ ← Badge
│ │
│ ┌───────────────────────┐ │
│ │ Notre séjour au │ │ ← Texte généré
│ │ Camping du Lac... │ │
│ │ │ │
│ │ [Éditer] │ │ ← Bouton éditer
│ └───────────────────────┘ │
│ │
│ Photos │
│ [Photo 1] [Photo 2] ... │
│ │
│ [Publier l'avis] │ ← CTA
│ │
└─────────────────────────────┘
```

#### Composants

**Header**
- Titre: "Rédiger un avis"
- Badge "Généré par IA" (optionnel, si généré automatiquement)

**Note**
- Étoiles interactives (1-5)
- Affichage de la note sélectionnée

**Texte généré**
- Zone de texte éditable
- Placeholder si vide: "L'IA peut vous aider à rédiger votre avis..."
- Bouton "Générer avec IA" si vide
- Bouton "Éditer" si généré
- Compteur de caractères

**Photos**
- Grille de photos sélectionnées
- Bouton "Ajouter des photos"

**CTA**
- Bouton "Publier l'avis" (primary)
- Bouton "Enregistrer comme brouillon" (secondary)

#### Spécifications Flutter

```dart
class ReviewScreen extends StatefulWidget {
@override
_ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
int rating = 5;
String reviewText = '';
bool isAIGenerated = false;

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text('Rédiger un avis'),
),
body: SingleChildScrollView(
padding: EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_RatingSection(
rating: rating,
onRatingChanged: (value) => setState(() => rating = value),
),
SizedBox(height: 24),
if (isAIGenerated)
Container(
padding: EdgeInsets.all(8),
decoration: BoxDecoration(
color: AppColors.accent,
borderRadius: BorderRadius.circular(8),
),
child: Row(
children: [
Icon(Icons.auto_awesome, size: 16, color: AppColors.secondary),
SizedBox(width: 8),
Text(
'Avis généré par IA',
style: TextStyle(
color: AppColors.secondary,
fontSize: 12,
fontWeight: FontWeight.bold,
),
),
],
),
),
SizedBox(height: 16),
TextField(
maxLines: 8,
decoration: InputDecoration(
hintText: reviewText.isEmpty
? 'L\'IA peut vous aider à rédiger votre avis...'
: null,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
),
controller: TextEditingController(text: reviewText),
onChanged: (value) => setState(() => reviewText = value),
),
if (reviewText.isEmpty)
Padding(
padding: EdgeInsets.only(top: 8),
child: TextButton.icon(
onPressed: _generateReview,
icon: Icon(Icons.auto_awesome),
label: Text('Générer avec IA'),
),
),
SizedBox(height: 24),
_PhotoSection(),
SizedBox(height: 32),
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: _publishReview,
child: Text('Publier l\'avis'),
),
),
],
),
),
);
}

Future<void> _generateReview() async {
// Appel à l'API Gemini
final generatedText = await geminiService.generateReview(
campingId: widget.campingId,
rating: rating,
);

setState(() {
reviewText = generatedText;
isAIGenerated = true;
});
}
}
```

### États

- **Empty**: Champ vide, bouton "Générer avec IA"
- **Generating**: Loading indicator
- **Generated**: Texte affiché, badge "Généré par IA", bouton "Éditer"
- **Editing**: Texte éditable, badge disparaît
- **Published**: Confirmation, retour à l'écran précédent

---

## 4. Recherche Vocale

### Description

Recherche de campings par commande vocale, avec transcription et suggestions en temps réel.

### Design

#### Layout

```
┌─────────────────────────────┐
│ [←] Recherche vocale │
├─────────────────────────────┤
│ │
│ │ ← Grand bouton microphone
│ │
│ "Je cherche un camping │ ← Transcription en temps réel
│ près d'un lac..." │
│ │
│ [Arrêter] [Annuler] │ ← Actions
│ │
└─────────────────────────────┘
```

#### Composants

**Bouton microphone**
- Grand cercle (120px)
- Animation pulse quand actif
- Couleur: Primary ou Secondary
- Icône microphone au centre

**Transcription**
- Texte affiché en temps réel
- Style: Body Large, centré
- Animation de frappe (typing effect)

**Actions**
- Bouton "Arrêter": Arrête l'enregistrement
- Bouton "Annuler": Annule et ferme

**Résultats**
- Apparaissent après la transcription
- Format similaire à la recherche textuelle

---

## Principes d'intégration IA

### 1. Transparence

- Toujours indiquer quand l'IA est utilisée
- Badge "IA" ou "Généré par IA" visible
- Explication claire de ce que fait l'IA

### 2. Contrôle utilisateur

- L'utilisateur peut toujours modifier/éditer
- Possibilité de désactiver les suggestions IA
- Option de revenir à une version manuelle

### 3. Performance

- Chargement rapide (< 2s)
- Feedback visuel pendant le traitement
- Gestion des erreurs gracieuse

### 4. Accessibilité

- Alternatives textuelles pour toutes les fonctionnalités IA
- Support du clavier
- Messages d'erreur clairs

---

## Spécifications techniques

### API Gemini 2.5

```dart
class GeminiService {
final GenerativeModel model;

GeminiService(): model = GenerativeModel(
model: 'gemini-2.5',
apiKey: dotenv.env['GEMINI_API_KEY']!,
);

Future<String> generateChatResponse(String prompt, BuildContext context) async {
final content = [Content.text(prompt)];
final response = await model.generateContent(content);
return response.text ?? '';
}

Future<List<Camping>> getSuggestions(String userId) async {
// Récupérer préférences utilisateur
final preferences = await getUserPreferences(userId);

// Construire prompt contextuel
final prompt = 'Suggest camping sites in Quebec based on: $preferences';

// Appel à Gemini
final response = await generateChatResponse(prompt, context);

// Parser et retourner les résultats
return parseCampingSuggestions(response);
}
}
```

### Gestion d'état

```dart
@riverpod
class GeminiChatNotifier extends _$GeminiChatNotifier {
@override
List<Message> build() => [];

Future<void> sendMessage(String text) async {
// Ajouter message utilisateur
state = [...state, Message(text: text, isFromAI: false)];

// Appeler IA
final response = await ref.read(geminiServiceProvider).generateChatResponse(text);

// Ajouter réponse IA
state = [...state, Message(text: response, isFromAI: true)];
}
}
```

---

## Tests

### Scénarios de test

1. **Chat Gemini**
- Envoi de message
- Réception de réponse
- Gestion d'erreur réseau
- Suggestions de campings

2. **Suggestions**
- Affichage des suggestions
- Clic sur une suggestion
- Refresh des suggestions
- État vide

3. **Avis automatisés**
- Génération d'avis
- Édition d'avis généré
- Publication
- Gestion d'erreur

---

## Roadmap

### Phase 1 (Actuel)
- Chat Gemini contextuel
- Suggestions intelligentes
- Avis automatisés

### Phase 2 (Futur)
- Recherche vocale
- Traduction automatique
- Recommandations basées sur photos
- Prédiction de prix

### Phase 3 (Futur)
- Assistant virtuel complet
- Planification de voyage IA
- Optimisation d'itinéraires


