import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/config/app_config.dart';

class GeminiService {
  GeminiService._();

  static GenerativeModel? _model;

  static void initialize() {
    _model = GenerativeModel(
 model: 'gemini-2.0-flash-exp',
      apiKey: AppConfig.geminiApiKey,
    );
  }

  static GenerativeModel get model {
    if (_model == null) {
 throw Exception('Gemini not initialized. Call GeminiService.initialize() first.');
    }
    return _model!;
  }

  /// Recherche intelligente de campings
  static Future<String> intelligentSearch(String query) async {
 final prompt = '''
Tu es un assistant spécialisé dans la recherche de campings au Québec.
L'utilisateur recherche: "$query"

Analyse la requête et suggère des critères de recherche pertinents:
- Type de camping (tente, VR, prêt-à-camper, sauvage)
- Région du Québec
- Caractéristiques (bord de l'eau, forêt, montagne)
- Prix approximatif
- Dates suggérées

Réponds de manière concise et structurée en JSON.
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
 return response.text ?? '';
    } catch (e) {
 throw Exception('Erreur lors de la recherche intelligente: $e');
    }
  }

  /// Chat conversationnel
  static Future<String> chat({
    required List<Content> history,
    required String message,
  }) async {
    try {
      final chat = model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(message));
 return response.text ?? '';
    } catch (e) {
 throw Exception('Erreur lors du chat: $e');
    }
  }

  /// Suggestions automatisées basées sur le profil utilisateur
  static Future<String> getSuggestions({
    required Map<String, dynamic> userProfile,
    required List<Map<String, dynamic>> previousBookings,
  }) async {
 final prompt = '''
Analyse le profil utilisateur et l'historique de réservations pour suggérer des campings pertinents.

Profil: $userProfile
Historique: $previousBookings

Suggère 3-5 campings qui correspondent aux préférences de l'utilisateur.
Réponds en JSON avec: nom, région, type, raison de la suggestion.
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
 return response.text ?? '';
    } catch (e) {
 throw Exception('Erreur lors de la génération de suggestions: $e');
    }
  }

  /// Génération de description pour une annonce
  static Future<String> generateListingDescription({
    required String name,
    required String location,
    required String type,
    required List<String> features,
  }) async {
 final prompt = '''
Génère une description attrayante et authentique pour un camping au Québec.

Nom: $name
Localisation: $location
Type: $type
Caractéristiques: ${features.join(', ')}

La description doit être:
- En français québécois
- Inspirante et authentique
- 2-3 paragraphes
- Mettant en valeur les aspects naturels et l'expérience unique
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
 return response.text ?? '';
    } catch (e) {
 throw Exception('Erreur lors de la génération de description: $e');
    }
  }
}

