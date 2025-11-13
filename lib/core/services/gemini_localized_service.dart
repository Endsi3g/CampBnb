/// Service Gemini adapté pour différents marchés et langues
import 'package:logger/logger.dart';
import '../services/gemini_service.dart';
import '../prompts/gemini_prompts.dart';
import '../localization/app_locale.dart';

class GeminiLocalizedService {
  static final Logger _logger = Logger();
  final GeminiService _geminiService = GeminiService();

  /// Obtient le prompt localisé selon la région
  String _getLocalizedSystemPrompt(AppLocale locale) {
    final language = locale.languageCode;
    final country = locale.countryCode ?? '';

    switch ('$language-$country') {
      case 'fr-CA':
        return '''
Tu es l'assistant IA de Campbnb, une plateforme de réservation de campings au Canada.
Tu es spécialisé dans les campings québécois et canadiens.
Réponds toujours en français québécois, de manière amicale et chaleureuse.
Utilise des références culturelles canadiennes et québécoises.
''';
      case 'en-US':
        return '''
You are the AI assistant for Campbnb, a camping reservation platform in the United States.
You specialize in US camping experiences and national parks.
Always respond in American English, in a friendly and helpful manner.
Use US cultural references and camping terminology.
''';
      case 'es-MX':
        return '''
Eres el asistente de IA de Campbnb, una plataforma de reservas de campamentos en México.
Te especializas en experiencias de campamento mexicanas.
Responde siempre en español mexicano, de manera amigable y entusiasta.
Usa referencias culturales mexicanas.
''';
      case 'pt-BR':
        return '''
Você é o assistente de IA do Campbnb, uma plataforma de reservas de acampamentos no Brasil.
Você se especializa em experiências de acampamento brasileiras.
Sempre responda em português brasileiro, de forma amigável e entusiasmada.
Use referências culturais brasileiras.
''';
      case 'fr-FR':
        return '''
Tu es l'assistant IA de Campbnb, une plateforme de réservation de campings en France.
Tu es spécialisé dans les campings français et européens.
Réponds toujours en français de France, de manière professionnelle et courtoise.
Utilise des références culturelles françaises.
''';
      default:
        return '''
You are the AI assistant for Campbnb, a global camping reservation platform.
Always respond in ${locale.nativeName}, in a friendly and helpful manner.
Adapt your responses to the local culture and preferences.
''';
    }
  }

  /// Suggère des destinations avec contexte culturel
  Future<List<Map<String, dynamic>>> suggestDestinationsLocalized({
    required AppLocale locale,
    required String region,
    String? month,
    String? preferences,
  }) async {
    try {
      final systemPrompt = _getLocalizedSystemPrompt(locale);
      final userPrompt = _buildLocalizedDestinationPrompt(
        locale: locale,
        region: region,
        month: month,
        preferences: preferences,
      );

      final response = await _geminiService.chat(
        message: userPrompt,
        history: [],
        userContext: systemPrompt,
      );

      // Parser la réponse JSON
      // En production, utiliser un parser robuste
      return [];
    } catch (e) {
      _logger.e('Erreur lors de la suggestion de destinations localisées: $e');
      rethrow;
    }
  }

  String _buildLocalizedDestinationPrompt({
    required AppLocale locale,
    required String region,
    String? month,
    String? preferences,
  }) {
    final language = locale.languageCode;

    if (language == 'fr') {
      return '''
Suggère-moi des destinations de camping exceptionnelles dans la région: $region
${month != null ? 'Période: $month' : ''}
${preferences != null ? 'Préférences: $preferences' : ''}

Réponds en format JSON avec des suggestions adaptées à la culture locale.
''';
    } else if (language == 'es') {
      return '''
Sugiéreme destinos de campamento excepcionales en la región: $region
${month != null ? 'Período: $month' : ''}
${preferences != null ? 'Preferencias: $preferences' : ''}

Responde en formato JSON con sugerencias adaptadas a la cultura local.
''';
    } else {
      return '''
Suggest exceptional camping destinations in the region: $region
${month != null ? 'Period: $month' : ''}
${preferences != null ? 'Preferences: $preferences' : ''}

Respond in JSON format with suggestions adapted to local culture.
''';
    }
  }

  /// Génère une description de listing localisée
  Future<String> generateListingDescriptionLocalized({
    required AppLocale locale,
    required Map<String, dynamic> listingData,
  }) async {
    try {
      final systemPrompt = _getLocalizedSystemPrompt(locale);
      final userPrompt = _buildListingDescriptionPrompt(
        locale: locale,
        listingData: listingData,
      );

      return await _geminiService.chat(
        message: userPrompt,
        history: [],
        userContext: systemPrompt,
      );
    } catch (e) {
      _logger.e('Erreur lors de la génération de description localisée: $e');
      rethrow;
    }
  }

  String _buildListingDescriptionPrompt({
    required AppLocale locale,
    required Map<String, dynamic> listingData,
  }) {
    final language = locale.languageCode;
    final title = listingData['title'] ?? '';
    final location = listingData['location'] ?? '';
    final amenities = listingData['amenities'] ?? [];

    if (language == 'fr') {
      return '''
Génère une description attrayante pour ce camping:
Titre: $title
Emplacement: $location
Équipements: ${amenities.join(', ')}

La description doit être en français, engageante et mettre en valeur les aspects uniques de ce camping.
''';
    } else if (language == 'es') {
      return '''
Genera una descripción atractiva para este campamento:
Título: $title
Ubicación: $location
Comodidades: ${amenities.join(', ')}

La descripción debe estar en español, atractiva y destacar los aspectos únicos de este campamento.
''';
    } else {
      return '''
Generate an attractive description for this campsite:
Title: $title
Location: $location
Amenities: ${amenities.join(', ')}

The description should be in ${locale.nativeName}, engaging, and highlight the unique aspects of this campsite.
''';
    }
  }

  /// Répond à une FAQ avec contexte culturel
  Future<String> answerFAQLocalized({
    required AppLocale locale,
    required String question,
    String? context,
  }) async {
    try {
      final systemPrompt = _getLocalizedSystemPrompt(locale);
      final userPrompt =
          '''
Question: $question
${context != null ? 'Contexte: $context' : ''}

Réponds de manière claire et adaptée à la culture locale.
''';

      return await _geminiService.chat(
        message: userPrompt,
        history: [],
        userContext: systemPrompt,
      );
    } catch (e) {
      _logger.e('Erreur lors de la réponse FAQ localisée: $e');
      rethrow;
    }
  }

  /// Traduit du contenu avec préservation du contexte culturel
  Future<String> translateWithCulturalContext({
    required String text,
    required AppLocale sourceLocale,
    required AppLocale targetLocale,
  }) async {
    try {
      final prompt =
          '''
Traduis ce texte de ${sourceLocale.nativeName} vers ${targetLocale.nativeName}, 
en préservant le contexte culturel et les nuances locales:

"$text"

Réponds uniquement avec la traduction, sans texte supplémentaire.
''';

      return await _geminiService.translate(
        text: text,
        targetLanguage: targetLocale.languageCode,
      );
    } catch (e) {
      _logger.e('Erreur lors de la traduction avec contexte culturel: $e');
      rethrow;
    }
  }
}
