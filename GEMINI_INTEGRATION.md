# Intégration Gemini 2.5 dans Campbnb Québec

## Vue d'ensemble

Ce document décrit l'intégration complète de l'IA Gemini 2.5 dans l'application Campbnb Québec. L'intégration permet d'ajouter des fonctionnalités intelligentes pour améliorer l'expérience utilisateur.

## Fonctionnalités implémentées

### 1. Suggestions intelligentes de destinations
- Analyse les préférences utilisateur
- Suggère des campings adaptés selon la région, période, type de groupe
- **Widget**: `DestinationSuggestionsWidget`

### 2. Analyse automatique des recherches
- Extrait l'intention, localisation, dates, préférences
- Améliore les résultats de recherche
- **Provider**: `searchAnalysisProvider`

### 3. Génération d'itinéraires
- Crée des itinéraires personnalisés pour les séjours
- Inclut activités, horaires, conseils
- **Provider**: `itineraryProvider`

### 4. Réponses FAQ intelligentes
- Répond aux questions fréquentes avec contexte
- Intégré dans l'écran d'aide et support
- **Widget**: `FAQAIWidget`

### 5. Résumé d'avis
- Analyse et résume les avis des utilisateurs
- Extrait points positifs/négatifs, sentiment global
- **Widget**: `ReviewSummaryWidget`

### 6. Traduction FR/EN instantanée
- Traduction naturelle et contextuelle
- Disponible sur les écrans de détails
- **Widget**: `TranslationWidget`

### 7. Analyse d'images
- Analyse les images de campings
- Extrait équipements, environnement, suggestions
- **Provider**: `imageAnalysisProvider`

### 8. Expériences locales
- Suggère des expériences authentiques près des campings
- Catégorise par type (gastronomie, nature, culture)
- **Widget**: `LocalExperiencesWidget`

### 9. Chatbot IA contextuel
- Assistant conversationnel intégré
- Disponible dans plusieurs écrans
- **Widget**: `GeminiChatWidget`, `GeminiChatFloatingButton`

## Structure du projet

```
lib/
├── core/
│ ├── config/
│ │ └── gemini_config.dart # Configuration centralisée
│ ├── models/
│ │ └── gemini_models.dart # Modèles de données
│ ├── prompts/
│ │ └── gemini_prompts.dart # Prompts prédéfinis
│ ├── providers/
│ │ └── gemini_providers.dart # Providers Riverpod
│ ├── services/
│ │ └── gemini_service.dart # Service centralisé
│ └── monitoring/
│ └── gemini_monitoring.dart # Surveillance et logs
├── features/
│ ├── ai_chat/
│ │ ├── screens/
│ │ │ └── ai_chat_screen.dart
│ │ └── widgets/
│ │ └── gemini_chat_widget.dart
│ └── ai_features/
│ └── widgets/
│ ├── destination_suggestions_widget.dart
│ ├── review_summary_widget.dart
│ ├── translation_widget.dart
│ ├── local_experiences_widget.dart
│ └── faq_ai_widget.dart
└── main.dart
```

## ️ Configuration

### 1. Créer le fichier `.env`

Copiez `.env.example` vers `.env` et ajoutez votre clé API Gemini:

```bash
cp .env.example .env
```

Puis éditez `.env`:
```
GEMINI_API_KEY=votre_cle_api_ici
```

### 2. Obtenir une clé API Gemini

1. Allez sur https://makersuite.google.com/app/apikey
2. Créez une nouvelle clé API
3. Copiez-la dans votre fichier `.env`

### 3. Configuration avancée

Vous pouvez ajuster les paramètres dans `.env`:

- `GEMINI_MODEL`: Modèle à utiliser (par défaut: `gemini-2.0-flash-exp`)
- `GEMINI_RATE_LIMIT`: Limite de requêtes par minute (par défaut: 60)
- `GEMINI_DAILY_LIMIT`: Limite quotidienne (par défaut: 1000)
- `GEMINI_TIMEOUT`: Timeout en secondes (par défaut: 30)
- `GEMINI_TEMPERATURE`: Température de génération 0.0-1.0 (par défaut: 0.7)
- `GEMINI_MAX_TOKENS`: Nombre max de tokens en sortie (par défaut: 2048)

## Utilisation

### Initialisation

L'application initialise automatiquement Gemini au démarrage (voir `main.dart`):

```dart
await GeminiConfig.initialize();
await GeminiService().initialize();
```

### Exemple: Suggestions de destinations

```dart
// Dans un widget
final suggestions = ref.watch(
destinationSuggestionsProvider(
DestinationSuggestionParams(
region: 'Mauricie',
month: 'octobre',
groupType: 'familles',
),
),
);
```

### Exemple: Chatbot

```dart
// Bouton flottant
GeminiChatFloatingButton(
userContext: 'Utilisateur recherchant un camping en Mauricie',
)

// Ou widget complet
GeminiChatWidget(
title: 'Assistant Campbnb',
userContext: 'Contexte utilisateur...',
)
```

### Exemple: Traduction

```dart
TranslationWidget(
text: 'Description du camping en français',
targetLanguage: 'en',
)
```

### Exemple: Résumé d'avis

```dart
ReviewSummaryWidget(
reviews: [
'Excellent camping, très propre...',
'Superbe emplacement...',
// ...
],
)
```

## Surveillance et monitoring

Le système de monitoring enregistre automatiquement:
- Toutes les requêtes API
- Temps de réponse
- Erreurs et limites atteintes
- Statistiques d'utilisation

### Accéder aux statistiques

```dart
final monitoring = GeminiMonitoring();
final stats = monitoring.getStats();
final health = monitoring.checkHealth();
```

### Logs

Les logs sont automatiquement enregistrés avec différents niveaux:
- Succès
- ️ Avertissements
- Erreurs
- ℹ️ Informations

## ️ Gestion des limites

Le service gère automatiquement:
- **Limite par minute**: Empêche le dépassement du quota
- **Limite quotidienne**: Suivi des requêtes par jour
- **Retry logic**: Gestion des erreurs temporaires
- **Rate limiting**: Délai automatique entre requêtes

## Intégration dans les écrans

### Écran de recherche
```dart
// Ajouter les suggestions IA
DestinationSuggestionsWidget(
region: selectedRegion,
month: selectedMonth,
onSuggestionTap: (suggestion) {
// Naviguer vers le camping
},
)
```

### Écran de détails de camping
```dart
// Résumé d'avis
ReviewSummaryWidget(reviews: camping.reviews)

// Traduction
TranslationWidget(text: camping.description)

// Expériences locales
LocalExperiencesWidget(location: camping.location)
```

### Écran d'aide et support
```dart
// FAQ avec IA
FAQAIWidget(
question: 'Comment annuler une réservation ?',
context: 'Utilisateur avec réservation active',
)

// Chatbot
GeminiChatWidget(
userContext: 'Utilisateur dans l\'écran d\'aide',
)
```

### Écran de réservation
```dart
// Chatbot d'assistance
GeminiChatFloatingButton(
userContext: 'Processus de réservation en cours',
)
```

## Tests

Pour tester l'intégration:

1. Vérifiez que `.env` contient une clé API valide
2. Lancez l'application
3. Les logs devraient afficher: ` Configuration Gemini initialisée avec succès`

## Prompts personnalisés

Tous les prompts sont définis dans `lib/core/prompts/gemini_prompts.dart`. Vous pouvez les modifier pour ajuster le comportement de l'IA.

Exemple de prompt personnalisé:
```dart
static String customPrompt(String input) {
return '''
Tu es un expert en camping au Québec.
${input}
Réponds en format JSON.
''';
}
```

## Dépannage

### Erreur: "API key manquante"
- Vérifiez que `.env` existe et contient `GEMINI_API_KEY`
- Assurez-vous que le fichier est dans le répertoire racine

### Erreur: "Limite de requêtes atteinte"
- Attendez quelques minutes
- Vérifiez vos quotas sur Google Cloud Console
- Ajustez `GEMINI_RATE_LIMIT` si nécessaire

### Réponses vides ou erreurs
- Vérifiez les logs dans la console
- Consultez `GeminiMonitoring` pour les détails
- Vérifiez que le modèle `GEMINI_MODEL` est valide

## Ressources

- [Documentation Gemini](https://ai.google.dev/docs)
- [SDK Flutter Gemini](https://pub.dev/packages/google_generative_ai)
- [Google AI Studio](https://makersuite.google.com/)

## Sécurité

- ️ **Ne commitez jamais** le fichier `.env` avec votre clé API
- Ajoutez `.env` à `.gitignore`
- Utilisez des variables d'environnement en production
- Surveillez l'utilisation de votre clé API

## Améliorations futures

- Cache des réponses fréquentes
- Support multilingue étendu
- Analyse de sentiment avancée
- Recommandations personnalisées basées sur l'historique
- Intégration avec les données utilisateur (préférences, historique)

---

**Dernière mise à jour**: 2024
**Version**: 1.0.0


