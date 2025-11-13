/// Service centralisé pour toutes les interactions avec l'API Gemini
/// Gère les requêtes, limites de taux, logs et erreurs
import 'dart:async';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/gemini_config.dart';
import '../models/gemini_models.dart';
import '../prompts/gemini_prompts.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
    ),
  );

  GenerativeModel? _model;
  final List<GeminiRequest> _requestHistory = [];
  GeminiApiStats _stats = const GeminiApiStats();
  final List<DateTime> _requestTimestamps = [];
  DateTime? _lastRequestTime;

  /// Initialise le service Gemini
  Future<void> initialize() async {
    if (!GeminiConfig.isValid) {
      _logger.e('Impossible d\'initialiser GeminiService: API key manquante');
      return;
    }

    try {
      _model = GenerativeModel(
        model: GeminiConfig.modelName,
        apiKey: GeminiConfig.apiKey!,
        generationConfig: GenerationConfig(
          temperature: GeminiConfig.temperature,
          maxOutputTokens: GeminiConfig.maxOutputTokens,
        ),
      );

      await _loadStats();
      _logger.i('GeminiService initialise avec succes');
    } catch (e) {
      _logger.e('Erreur lors de l\'initialisation de GeminiService: $e');
      rethrow;
    }
  }

  /// Vérifie si une nouvelle requête peut être effectuée (rate limiting)
  Future<bool> _canMakeRequest() async {
    final now = DateTime.now();
    
    // Vérifier limite par minute
    _requestTimestamps.removeWhere((timestamp) => 
        now.difference(timestamp).inMinutes >= 1);
    
    if (_requestTimestamps.length >= GeminiConfig.rateLimitPerMinute) {
      _logger.w('Limite de requetes par minute atteinte');
      return false;
    }

    // Vérifier limite par jour
    if (_stats.requestsToday >= GeminiConfig.rateLimitPerDay) {
      _logger.w('Limite de requetes quotidienne atteinte');
      return false;
    }

    return true;
  }

 /// Enregistre une requête dans l'historique
  void _recordRequest({required bool success, required Duration duration}) {
    final now = DateTime.now();
    _requestTimestamps.add(now);
    _lastRequestTime = now;

    _stats = _stats.copyWith(
      requestsToday: _stats.requestsToday + 1,
      requestsThisMinute: _requestTimestamps.length,
      totalRequests: _stats.totalRequests + 1,
      failedRequests: success ? _stats.failedRequests : _stats.failedRequests + 1,
      lastRequestTime: now,
      averageResponseTime: _calculateAverageResponseTime(duration),
    );

    _saveStats();
  }

  /// Calcule le temps de réponse moyen
  double _calculateAverageResponseTime(Duration newDuration) {
    final currentAvg = _stats.averageResponseTime;
    final totalRequests = _stats.totalRequests;
    if (totalRequests == 0) return newDuration.inMilliseconds.toDouble();
    
    return ((currentAvg * (totalRequests - 1)) + newDuration.inMilliseconds) / totalRequests;
  }

  /// Sauvegarde les statistiques
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
 await prefs.setString('gemini_stats', jsonEncode(_stats.toJson()));
 await prefs.setString('gemini_last_reset', DateTime.now().toIso8601String());
    } catch (e) {
 _logger.e('Erreur lors de la sauvegarde des stats: $e');
    }
  }

  /// Charge les statistiques
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
 final statsJson = prefs.getString('gemini_stats');
 final lastResetStr = prefs.getString('gemini_last_reset');
      
      if (statsJson != null) {
        final lastReset = lastResetStr != null ? DateTime.parse(lastResetStr) : null;
        final now = DateTime.now();
        
        // Réinitialiser le compteur quotidien si nécessaire
        if (lastReset == null || now.difference(lastReset).inDays >= 1) {
          _stats = const GeminiApiStats();
          await _saveStats();
        } else {
          _stats = GeminiApiStats.fromJson(jsonDecode(statsJson));
        }
      }
    } catch (e) {
 _logger.e('Erreur lors du chargement des stats: $e');
    }
  }

  /// Méthode générique pour effectuer une requête Gemini
  Future<String> _makeRequest({
    required String prompt,
    String? systemInstruction,
    List<Content>? history,
  }) async {
    if (_model == null) {
 throw Exception('GeminiService non initialisé');
    }

    if (!await _canMakeRequest()) {
 throw Exception('Limite de requêtes atteinte. Réessayez plus tard.');
    }

    final stopwatch = Stopwatch()..start();
    try {
 _logger.d(' Envoi requête Gemini: ${prompt.substring(0, prompt.length > 100 ? 100 : prompt.length)}...');

      final content = [
        if (systemInstruction != null)
          Content.system(systemInstruction),
        ...?history,
        Content.text(prompt),
      ];

      final response = await _model!
          .generateContent(content)
          .timeout(GeminiConfig.requestTimeout);

      stopwatch.stop();
      final duration = stopwatch.elapsed;

      if (response.text == null || response.text!.isEmpty) {
 throw Exception('Réponse vide de Gemini');
      }

      _recordRequest(success: true, duration: duration);
 _logger.d(' Réponse reçue en ${duration.inMilliseconds}ms');

      return response.text!;
    } catch (e) {
      stopwatch.stop();
      _recordRequest(success: false, duration: stopwatch.elapsed);
 _logger.e(' Erreur requête Gemini: $e');
      rethrow;
    }
  }

  /// Suggère des destinations de camping
  Future<List<DestinationSuggestion>> suggestDestinations({
    required String region,
    String? month,
    String? preferences,
    String? groupType,
  }) async {
    try {
      final prompt = GeminiPrompts.destinationSuggestion(
        region: region,
        month: month,
        preferences: preferences,
        groupType: groupType,
      );

      final response = await _makeRequest(prompt: prompt);
      final json = jsonDecode(response) as Map<String, dynamic>;
 final suggestions = (json['suggestions'] as List)
          .map((s) => DestinationSuggestion.fromJson(s as Map<String, dynamic>))
          .toList();

      return suggestions;
    } catch (e) {
 _logger.e('Erreur lors de la suggestion de destinations: $e');
      rethrow;
    }
  }

  /// Analyse une recherche utilisateur
  Future<Map<String, dynamic>> analyzeSearch(String searchQuery) async {
    try {
      final prompt = GeminiPrompts.searchAnalysis(searchQuery);
      final response = await _makeRequest(prompt: prompt);
      return jsonDecode(response) as Map<String, dynamic>;
    } catch (e) {
 _logger.e('Erreur lors de l\'analyse de recherche: $e');
      rethrow;
    }
  }

  /// Génère un itinéraire
  Future<GeneratedItinerary> generateItinerary({
    required String destination,
    required int days,
    String? preferences,
    String? budget,
  }) async {
    try {
      final prompt = GeminiPrompts.itineraryGeneration(
        destination: destination,
        days: days,
        preferences: preferences,
        budget: budget,
      );

      final response = await _makeRequest(prompt: prompt);
      final json = jsonDecode(response) as Map<String, dynamic>;
      return GeneratedItinerary.fromJson(json);
    } catch (e) {
 _logger.e('Erreur lors de la génération d\'itinéraire: $e');
      rethrow;
    }
  }

  /// Répond à une question FAQ
  Future<String> answerFAQ(String question, {String? context}) async {
    try {
      final prompt = GeminiPrompts.faqResponse(question, context: context);
      return await _makeRequest(prompt: prompt);
    } catch (e) {
 _logger.e('Erreur lors de la réponse FAQ: $e');
      rethrow;
    }
  }

  /// Résume des avis
  Future<ReviewSummary> summarizeReviews(List<String> reviews) async {
    try {
      final prompt = GeminiPrompts.reviewSummary(reviews);
      final response = await _makeRequest(prompt: prompt);
      final json = jsonDecode(response) as Map<String, dynamic>;
      return ReviewSummary.fromJson(json);
    } catch (e) {
 _logger.e('Erreur lors du résumé d\'avis: $e');
      rethrow;
    }
  }

  /// Traduit du texte
  Future<String> translate(String text, {required String targetLanguage}) async {
    try {
      final prompt = GeminiPrompts.translation(text, targetLanguage: targetLanguage);
      return await _makeRequest(prompt: prompt);
    } catch (e) {
 _logger.e('Erreur lors de la traduction: $e');
      rethrow;
    }
  }

  /// Analyse une image
  Future<Map<String, dynamic>> analyzeImage(String imageDescription) async {
    try {
      final prompt = GeminiPrompts.imageAnalysis(imageDescription);
      final response = await _makeRequest(prompt: prompt);
      return jsonDecode(response) as Map<String, dynamic>;
    } catch (e) {
 _logger.e('Erreur lors de l\'analyse d\'image: $e');
      rethrow;
    }
  }

  /// Suggère des expériences locales
  Future<List<LocalExperience>> suggestLocalExperiences({
    required String location,
    String? preferences,
  }) async {
    try {
      final prompt = GeminiPrompts.localExperience(
        location: location,
        preferences: preferences,
      );

      final response = await _makeRequest(prompt: prompt);
      final json = jsonDecode(response) as Map<String, dynamic>;
 final experiences = (json['experiences'] as List)
          .map((e) => LocalExperience.fromJson(e as Map<String, dynamic>))
          .toList();

      return experiences;
    } catch (e) {
 _logger.e('Erreur lors de la suggestion d\'expériences locales: $e');
      rethrow;
    }
  }

  /// Chat conversationnel avec contexte
  Future<String> chat({
    required String message,
    required List<ChatMessage> history,
    String? userContext,
  }) async {
    try {
      final systemPrompt = GeminiPrompts.chatSystemPrompt;
      final chatPrompt = GeminiPrompts.chatPrompt(message, userContext: userContext);

 // Convertir l'historique en Content
      final contentHistory = history
          .where((msg) => !msg.isProcessing && msg.error == null)
          .map((msg) => Content.text(msg.content))
          .toList();

      return await _makeRequest(
        prompt: chatPrompt,
        systemInstruction: systemPrompt,
        history: contentHistory,
      );
    } catch (e) {
 _logger.e('Erreur lors du chat: $e');
      rethrow;
    }
  }

 /// Obtient les statistiques d'utilisation
  GeminiApiStats getStats() => _stats;

 /// Obtient l'historique des requêtes
  List<GeminiRequest> getRequestHistory() => List.unmodifiable(_requestHistory);

  /// Réinitialise les statistiques (pour les tests)
  Future<void> resetStats() async {
    _stats = const GeminiApiStats();
    _requestTimestamps.clear();
    await _saveStats();
  }
}


