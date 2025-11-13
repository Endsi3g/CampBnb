/// Configuration centralisée pour l'API Gemini
/// Gère les clés API, limites de taux, et paramètres de modèles
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class GeminiConfig {
  static final Logger _logger = Logger();

  /// Clé API Gemini (à définir dans .env)
  static String? get apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      _logger.w('GEMINI_API_KEY non définie dans .env');
    }
    return key;
  }

  /// Modèle Gemini à utiliser (gemini-2.0-flash-exp ou gemini-1.5-pro)
  static String get modelName =>
      dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.0-flash-exp';

  /// Limite de requêtes par minute (par défaut: 60)
  static int get rateLimitPerMinute =>
      int.tryParse(dotenv.env['GEMINI_RATE_LIMIT'] ?? '60') ?? 60;

  /// Limite de requêtes par jour (par défaut: 1000)
  static int get rateLimitPerDay =>
      int.tryParse(dotenv.env['GEMINI_DAILY_LIMIT'] ?? '1000') ?? 1000;

  /// Timeout des requêtes en secondes (par défaut: 30)
  static Duration get requestTimeout => Duration(
    seconds: int.tryParse(dotenv.env['GEMINI_TIMEOUT'] ?? '30') ?? 30,
  );

  /// Température pour la génération (0.0 à 1.0, par défaut: 0.7)
  static double get temperature =>
      double.tryParse(dotenv.env['GEMINI_TEMPERATURE'] ?? '0.7') ?? 0.7;

  /// Nombre maximum de tokens en sortie
  static int get maxOutputTokens =>
      int.tryParse(dotenv.env['GEMINI_MAX_TOKENS'] ?? '2048') ?? 2048;

  /// Vérifie que la configuration est valide
  static bool get isValid {
    if (apiKey == null || apiKey!.isEmpty) {
      _logger.e('Configuration Gemini invalide: API key manquante');
      return false;
    }
    return true;
  }

  /// Initialise la configuration (appelé au démarrage de l'app)
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
      if (!isValid) {
        _logger.e('Configuration Gemini invalide. Verifiez votre fichier .env');
      } else {
        _logger.i(' Configuration Gemini initialisée avec succès');
      }
    } catch (e) {
      _logger.e('Erreur lors du chargement de la configuration Gemini: $e');
    }
  }
}
