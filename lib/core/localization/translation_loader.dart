/// Chargeur de traductions depuis les fichiers JSON
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class TranslationLoader {
  static final Logger _logger = Logger();

  static Future<Map<String, String>> loadTranslations(
    String languageCode,
    String? countryCode,
  ) async {
    try {
      // Essayer d'abord avec le code pays spécifique
      if (countryCode != null) {
        try {
          final path = 'assets/translations/$languageCode-$countryCode.json';
          final jsonString = await rootBundle.loadString(path);
          final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
          return jsonMap.map((key, value) => MapEntry(key, value.toString()));
        } catch (e) {
          _logger.d(
            'Fichier de traduction $languageCode-$countryCode.json non trouvé, utilisation de $languageCode.json',
          );
        }
      }

      // Fallback sur le code langue seul
      final path = 'assets/translations/$languageCode.json';
      final jsonString = await rootBundle.loadString(path);
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      _logger.w('Erreur lors du chargement des traductions: $e');
      // Fallback sur l'anglais
      try {
        final path = 'assets/translations/en.json';
        final jsonString = await rootBundle.loadString(path);
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return jsonMap.map((key, value) => MapEntry(key, value.toString()));
      } catch (e2) {
        _logger.e('Impossible de charger les traductions de fallback: $e2');
        return {};
      }
    }
  }
}
