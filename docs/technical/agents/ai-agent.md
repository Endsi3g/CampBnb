# 🤖 Agent IA Gemini - Campbnb Québec

Documentation pour l'agent responsable de l'intégration Gemini AI.

## 🎯 Responsabilités

- Intégration Google Gemini 2.5
- Développement des fonctionnalités IA
- Optimisation des prompts
- Monitoring de l'utilisation API
- Gestion des limites de taux

## 🏗️ Architecture

### Structure

```
lib/
├── core/
│   ├── config/
│   │   └── gemini_config.dart        # Configuration Gemini
│   ├── prompts/
│   │   └── gemini_prompts.dart       # Prompts prédéfinis
│   ├── providers/
│   │   └── gemini_providers.dart     # Providers Riverpod
│   ├── services/
│   │   └── gemini_service.dart       # Service centralisé
│   └── monitoring/
│       └── gemini_monitoring.dart     # Surveillance
└── features/
    ├── ai_chat/                      # Chatbot IA
    └── ai_features/                  # Widgets IA
        ├── destination_suggestions_widget.dart
        ├── faq_ai_widget.dart
        ├── review_summary_widget.dart
        └── translation_widget.dart
```

## ✨ Fonctionnalités IA

### 1. Chatbot Contextuel

**Widget** : `GeminiChatWidget`

- Assistant conversationnel
- Réponses contextuelles
- Intégré dans les écrans de réservation, support, recherche

### 2. Suggestions Intelligentes

**Widget** : `DestinationSuggestionsWidget`

- Analyse des préférences utilisateur
- Suggestions personnalisées
- Basé sur région, période, type de groupe

### 3. Recherche Intelligente

**Service** : `GeminiService.intelligentSearch`

- Analyse du langage naturel
- Extraction d'intentions
- Amélioration des résultats

### 4. Résumé d'Avis

**Widget** : `ReviewSummaryWidget`

- Analyse automatique des avis
- Extraction des points positifs/négatifs
- Sentiment global

### 5. Traduction

**Widget** : `TranslationWidget`

- Traduction FR/EN instantanée
- Préservation du contexte
- Disponible sur les écrans de détails

## 🔧 Configuration

### Clé API

```dart
// lib/core/config/gemini_config.dart
class GeminiConfig {
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String model = 'gemini-2.5-pro';
}
```

### Variables d'Environnement

```env
GEMINI_API_KEY=votre_cle_api_ici
```

## 📊 Monitoring

### GeminiMonitoring

Surveille :
- Nombre de requêtes
- Temps de réponse
- Erreurs
- Limites de taux

```dart
final monitoring = GeminiMonitoring();
final stats = monitoring.getStats();
final health = monitoring.checkHealth();
```

## 🛡️ Gestion des Erreurs

### Limites de Taux

- Détection automatique des limites
- Retry avec backoff exponentiel
- Fallback gracieux

### Erreurs API

- Gestion des erreurs réseau
- Gestion des erreurs API
- Messages d'erreur utilisateur-friendly

## ✅ Checklist Qualité

- [ ] Tous les widgets IA fonctionnent
- [ ] Gestion des erreurs API
- [ ] Monitoring et logs en place
- [ ] Prompts optimisés et testés
- [ ] Documentation des fonctionnalités IA
- [ ] Tests unitaires pour le service
- [ ] Tests d'intégration pour les widgets

## 📚 Ressources

- [GEMINI_INTEGRATION.md](../../GEMINI_INTEGRATION.md)
- [README_GEMINI.md](../../README_GEMINI.md)
- [Google Gemini Documentation](https://ai.google.dev/docs)

---

**Dernière mise à jour :** 2024

