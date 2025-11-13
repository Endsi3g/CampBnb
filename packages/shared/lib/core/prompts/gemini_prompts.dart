/// Prompts prédéfinis pour chaque fonctionnalité Gemini
/// Chaque prompt est optimisé pour obtenir les meilleurs résultats

class GeminiPrompts {
  /// Prompt pour suggérer des destinations de camping
  static String destinationSuggestion({
    required String region,
    String? month,
    String? preferences,
    String? groupType,
  }) {
 return '''
Tu es un expert en camping au Québec. Propose-moi des spots de camping exceptionnels.

Région: $region
${month != null ? 'Période: $month' : ''}
${groupType != null ? 'Type de groupe: $groupType' : ''}
${preferences != null ? 'Préférences: $preferences' : ''}

Réponds en format JSON avec cette structure:
{
 "suggestions": [
    {
 "name": "Nom du camping",
 "region": "Région",
 "description": "Description détaillée (2-3 phrases)",
 "highlights": ["Point fort 1", "Point fort 2", "Point fort 3"],
 "bestSeason": "Meilleure saison",
 "rating": 4.5,
 "imageUrl": "URL si disponible"
    }
  ]
}

Suggère 3-5 destinations pertinentes. Réponds uniquement en JSON, sans texte supplémentaire.
''';
  }

  /// Prompt pour analyser une recherche utilisateur
  static String searchAnalysis(String searchQuery) {
 return '''
Analyse cette recherche de camping: "$searchQuery"

Extrais et structure les informations suivantes en JSON:
{
 "intent": "intention principale (réservation, recherche, information)",
 "location": "lieu mentionné ou null",
 "dates": "dates mentionnées ou null",
 "preferences": ["préférence1", "préférence2"],
 "groupSize": "taille du groupe mentionnée ou null",
 "keywords": ["mot-clé1", "mot-clé2"],
 "suggestedRefinement": "suggestion pour améliorer la recherche"
}

Réponds uniquement en JSON, sans texte supplémentaire.
''';
  }

  /// Prompt pour générer un itinéraire
  static String itineraryGeneration({
    required String destination,
    required int days,
    String? preferences,
    String? budget,
  }) {
 return '''
Crée un itinéraire de camping détaillé pour $destination sur $days jours.

${preferences != null ? 'Préférences: $preferences' : ''}
${budget != null ? 'Budget: $budget' : ''}

Réponds en format JSON:
{
 "title": "Titre de l'itinéraire",
 "summary": "Résumé général (2-3 phrases)",
 "days": [
    {
 "dayNumber": 1,
 "title": "Titre du jour",
 "description": "Description du jour",
 "activities": [
        {
 "name": "Nom activité",
 "time": "Heure",
 "description": "Description",
 "location": "Lieu",
 "duration": "Durée"
        }
      ]
    }
  ],
 "tips": ["Conseil 1", "Conseil 2", "Conseil 3"]
}

Réponds uniquement en JSON, sans texte supplémentaire.
''';
  }

  /// Prompt pour répondre à une FAQ
  static String faqResponse(String question, {String? context}) {
 return '''
Tu es l'assistant de Campbnb Québec, une plateforme de réservation de campings.

Question: $question
${context != null ? 'Contexte: $context' : ''}

Fournis une réponse claire, concise et utile (3-4 phrases maximum). 
Si la question concerne les réservations, paiements, ou règles, sois précis.
Si tu ne connais pas la réponse, suggère de contacter le support.

Réponds en français, de manière amicale et professionnelle.
''';
  }

  /// Prompt pour résumer des avis
  static String reviewSummary(List<String> reviews) {
 final reviewsText = reviews.join('\n---\n');
 return '''
Analyse ces avis sur un camping et crée un résumé structuré:

$reviewsText

Réponds en format JSON:
{
 "averageRating": 4.5,
 "ratingDistribution": {
 "5": 10,
 "4": 5,
 "3": 2,
 "2": 1,
 "1": 0
  },
 "positiveAspects": ["Aspect positif 1", "Aspect positif 2"],
 "negativeAspects": ["Aspect négatif 1", "Aspect négatif 2"],
 "overallSentiment": "positif/neutre/négatif",
 "totalReviews": ${reviews.length}
}

Réponds uniquement en JSON, sans texte supplémentaire.
''';
  }

  /// Prompt pour traduire du texte
  static String translation(String text, {required String targetLanguage}) {
 final languageName = targetLanguage == 'en' ? 'anglais' : 'français';
 return '''
Traduis ce texte en $languageName de manière naturelle et fluide, en préservant le ton et le contexte:

"$text"

Réponds uniquement avec la traduction, sans texte supplémentaire.
''';
  }

  /// Prompt pour analyser une image de camping
  static String imageAnalysis(String imageDescription) {
 return '''
Analyse cette image de camping: $imageDescription

Extrais les informations suivantes en JSON:
{
 "scene": "description de la scène",
 "amenities": ["équipement visible 1", "équipement visible 2"],
 "environment": "type d'environnement (forêt, lac, montagne, etc.)",
 "quality": "qualité de l'image (excellent/bon/moyen)",
 "suggestions": ["suggestion d'amélioration 1", "suggestion 2"],
 "tags": ["tag1", "tag2", "tag3"]
}

Réponds uniquement en JSON, sans texte supplémentaire.
''';
  }

  /// Prompt pour suggérer des expériences locales
  static String localExperience({
    required String location,
    String? preferences,
  }) {
 return '''
Propose des expériences locales authentiques à découvrir près de $location.

${preferences != null ? 'Préférences: $preferences' : ''}

Réponds en format JSON:
{
 "experiences": [
    {
 "title": "Titre de l'expérience",
 "description": "Description (2-3 phrases)",
 "category": "catégorie (gastronomie, nature, culture, etc.)",
 "location": "lieu précis",
 "tags": ["tag1", "tag2"]
    }
  ]
}

Propose 3-5 expériences variées. Réponds uniquement en JSON, sans texte supplémentaire.
''';
  }

  /// Prompt système pour le chatbot contextuel
 static String get chatSystemPrompt => '''
Tu es l'assistant IA de Campbnb Québec, une plateforme de réservation de campings au Québec.

Ton rôle:
- Aider les utilisateurs à trouver le camping idéal
- Répondre aux questions sur les réservations, paiements, règles
- Donner des conseils personnalisés sur le camping
- Suggérer des destinations et activités
- Assister dans le processus de réservation

Ton style:
- Amical, professionnel et enthousiaste
- Concis mais complet (réponses de 2-4 phrases)
- Utilise un style minimaliste et professionnel
- Toujours en français

Si tu ne connais pas la réponse, suggère de contacter le support ou de consulter la FAQ.
''';

  /// Prompt pour le chatbot avec contexte utilisateur
  static String chatPrompt(String userMessage, {String? userContext}) {
 return '''
${userContext != null ? 'Contexte utilisateur: $userContext\n' : ''}
Message utilisateur: $userMessage

Réponds de manière utile et contextuelle.
''';
  }
}


