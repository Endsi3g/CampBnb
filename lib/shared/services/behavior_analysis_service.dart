import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/config/app_config.dart';
import '../models/analytics_event_model.dart';
import 'supabase_service.dart';
import 'gemini_service.dart';

/// Service d'analyse comportementale utilisateur avec Gemini
class BehaviorAnalysisService {
  BehaviorAnalysisService._();
  static final BehaviorAnalysisService instance = BehaviorAnalysisService._();

  /// Analyser les comportements utilisateur pour une période donnée
  Future<AnalyticsUserBehaviorModel> analyzeUserBehavior({
    required String userIdOrAnonymousId,
    required DateTime analysisDate,
    required String analysisPeriod, // 'daily', 'weekly', 'monthly'
  }) async {
    try {
      // Récupérer les données de la période
      final events = await _getEventsForPeriod(
        userIdOrAnonymousId,
        analysisDate,
        analysisPeriod,
      );
      final sessions = await _getSessionsForPeriod(
        userIdOrAnonymousId,
        analysisDate,
        analysisPeriod,
      );
      final conversions = await _getConversionsForPeriod(
        userIdOrAnonymousId,
        analysisDate,
        analysisPeriod,
      );

      // Préparer les données pour Gemini
      final analysisData = _prepareAnalysisData(events, sessions, conversions);

      // Analyser avec Gemini
      final behaviors = await _analyzeWithGemini(analysisData);

      // Calculer les métriques
      final metrics = _calculateMetrics(events, sessions, conversions);

      // Détecter les préférences
      final preferences = _detectPreferences(events, conversions);

      // Calculer les scores
      final scores = _calculateScores(metrics, behaviors);

      // Générer des recommandations IA
      final recommendations = await _generateRecommendations(
        behaviors,
        preferences,
        scores,
      );

      return AnalyticsUserBehaviorModel(
        userId: events.isNotEmpty && events.first.userId != null
            ? events.first.userId
            : null,
        anonymousId: userIdOrAnonymousId,
        analysisDate: analysisDate,
        analysisPeriod: analysisPeriod,
        behaviors: behaviors,
        sessionsCount: sessions.length,
        totalTimeMinutes: metrics['totalTimeMinutes'] ?? 0,
        screensViewed: metrics['screensViewed'] ?? 0,
        interactionsCount: metrics['interactionsCount'] ?? 0,
        searchesCount: metrics['searchesCount'] ?? 0,
        conversionsCount: conversions.length,
        preferredPropertyTypes: preferences['propertyTypes'] as List<String>?,
        preferredLocations: preferences['locations'] as List<String>?,
        preferredPriceRange: preferences['priceRange'] as Map<String, dynamic>?,
        preferredAmenities: preferences['amenities'] as List<String>?,
        personalizationScore: scores['personalization'] as double?,
        engagementScore: scores['engagement'] as double?,
        retentionProbability: scores['retention'] as double?,
        aiRecommendations: recommendations,
        aiInsights: behaviors['insights']?.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      AppConfig.logger.e('Erreur analyse comportement: $e');
      rethrow;
    }
  }

  /// Récupérer les événements pour une période
  Future<List<AnalyticsEventModel>> _getEventsForPeriod(
    String userIdOrAnonymousId,
    DateTime date,
    String period,
  ) async {
    try {
      DateTime startDate;
      DateTime endDate = date.add(const Duration(days: 1));

      switch (period) {
        case 'daily':
          startDate = DateTime(date.year, date.month, date.day);
          break;
        case 'weekly':
          startDate = date.subtract(Duration(days: date.weekday - 1));
          break;
        case 'monthly':
          startDate = DateTime(date.year, date.month, 1);
          break;
        default:
          startDate = date;
      }

      final response = await SupabaseService.from('analytics_events')
          .select()
          .or(
            'user_id.eq.$userIdOrAnonymousId,anonymous_id.eq.$userIdOrAnonymousId',
          )
          .gte('created_at', startDate.toIso8601String())
          .lt('created_at', endDate.toIso8601String())
          .order('created_at', ascending: true);

      return (response as List)
          .map((e) => AnalyticsEventModel.fromJson(e))
          .toList();
    } catch (e) {
      AppConfig.logger.e('Erreur récupération événements: $e');
      return [];
    }
  }

  /// Récupérer les sessions pour une période
  Future<List<AnalyticsSessionModel>> _getSessionsForPeriod(
    String userIdOrAnonymousId,
    DateTime date,
    String period,
  ) async {
    try {
      DateTime startDate;
      DateTime endDate = date.add(const Duration(days: 1));

      switch (period) {
        case 'daily':
          startDate = DateTime(date.year, date.month, date.day);
          break;
        case 'weekly':
          startDate = date.subtract(Duration(days: date.weekday - 1));
          break;
        case 'monthly':
          startDate = DateTime(date.year, date.month, 1);
          break;
        default:
          startDate = date;
      }

      final response = await SupabaseService.from('analytics_sessions')
          .select()
          .or(
            'user_id.eq.$userIdOrAnonymousId,anonymous_id.eq.$userIdOrAnonymousId',
          )
          .gte('started_at', startDate.toIso8601String())
          .lt('started_at', endDate.toIso8601String());

      return (response as List)
          .map((e) => AnalyticsSessionModel.fromJson(e))
          .toList();
    } catch (e) {
      AppConfig.logger.e('Erreur récupération sessions: $e');
      return [];
    }
  }

  /// Récupérer les conversions pour une période
  Future<List<AnalyticsConversionModel>> _getConversionsForPeriod(
    String userIdOrAnonymousId,
    DateTime date,
    String period,
  ) async {
    try {
      DateTime startDate;
      DateTime endDate = date.add(const Duration(days: 1));

      switch (period) {
        case 'daily':
          startDate = DateTime(date.year, date.month, date.day);
          break;
        case 'weekly':
          startDate = date.subtract(Duration(days: date.weekday - 1));
          break;
        case 'monthly':
          startDate = DateTime(date.year, date.month, 1);
          break;
        default:
          startDate = date;
      }

      final response = await SupabaseService.from('analytics_conversions')
          .select()
          .or(
            'user_id.eq.$userIdOrAnonymousId,anonymous_id.eq.$userIdOrAnonymousId',
          )
          .gte('created_at', startDate.toIso8601String())
          .lt('created_at', endDate.toIso8601String());

      return (response as List)
          .map((e) => AnalyticsConversionModel.fromJson(e))
          .toList();
    } catch (e) {
      AppConfig.logger.e('Erreur récupération conversions: $e');
      return [];
    }
  }

  /// Préparer les données pour l'analyse Gemini
  Map<String, dynamic> _prepareAnalysisData(
    List<AnalyticsEventModel> events,
    List<AnalyticsSessionModel> sessions,
    List<AnalyticsConversionModel> conversions,
  ) {
    return {
      'events': events
          .map(
            (e) => {
              'name': e.eventName,
              'category': e.eventCategory,
              'type': e.eventType,
              'screen': e.screenName,
              'properties': e.eventProperties,
              'timestamp': e.createdAt?.toIso8601String(),
            },
          )
          .toList(),
      'sessions': sessions
          .map(
            (s) => {
              'duration': s.durationSeconds,
              'screens_viewed': s.screensViewed,
              'interactions': s.interactionsCount,
              'searches': s.searchesCount,
              'conversion': s.conversionType,
            },
          )
          .toList(),
      'conversions': conversions
          .map(
            (c) => {
              'type': c.conversionType,
              'value': c.conversionValue,
              'funnel_step': c.funnelStep,
            },
          )
          .toList(),
    };
  }

  /// Analyser avec Gemini
  Future<Map<String, dynamic>> _analyzeWithGemini(
    Map<String, dynamic> data,
  ) async {
    try {
      final prompt =
          '''
Analyse les comportements utilisateur suivants et retourne un JSON avec:
- "patterns": Liste des patterns comportementaux détectés
- "insights": Insights clés sur l'engagement et les préférences
- "recommendations": Recommandations pour améliorer l'expérience

Données:
${jsonEncode(data)}

Réponds uniquement en JSON valide.
''';

      final response = await GeminiService.model.generateContent([
        Content.text(prompt),
      ]);
      final responseText = response.text ?? '';

      // Extraire le JSON de la réponse
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(responseText);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      }

      return {
        'patterns': [],
        'insights': 'Analyse en cours...',
        'recommendations': [],
      };
    } catch (e) {
      AppConfig.logger.e('Erreur analyse Gemini: $e');
      return {
        'patterns': [],
        'insights': 'Erreur lors de l\'analyse',
        'recommendations': [],
      };
    }
  }

  /// Calculer les métriques
  Map<String, int> _calculateMetrics(
    List<AnalyticsEventModel> events,
    List<AnalyticsSessionModel> sessions,
    List<AnalyticsConversionModel> conversions,
  ) {
    int totalTimeMinutes = 0;
    int screensViewed = 0;
    int interactionsCount = 0;
    int searchesCount = 0;

    for (final session in sessions) {
      totalTimeMinutes += (session.durationSeconds ?? 0) ~/ 60;
      screensViewed += session.screensViewed;
      interactionsCount += session.interactionsCount;
      searchesCount += session.searchesCount;
    }

    return {
      'totalTimeMinutes': totalTimeMinutes,
      'screensViewed': screensViewed,
      'interactionsCount': interactionsCount,
      'searchesCount': searchesCount,
    };
  }

  /// Détecter les préférences utilisateur
  Map<String, dynamic> _detectPreferences(
    List<AnalyticsEventModel> events,
    List<AnalyticsConversionModel> conversions,
  ) {
    final propertyTypes = <String, int>{};
    final locations = <String, int>{};
    final amenities = <String, int>{};
    final prices = <double>[];

    // Analyser les événements
    for (final event in events) {
      if (event.eventProperties != null) {
        if (event.eventProperties!['property_type'] != null) {
          final type = event.eventProperties!['property_type'].toString();
          propertyTypes[type] = (propertyTypes[type] ?? 0) + 1;
        }
        if (event.eventProperties!['city'] != null) {
          final city = event.eventProperties!['city'].toString();
          locations[city] = (locations[city] ?? 0) + 1;
        }
        if (event.eventProperties!['amenities'] != null) {
          final amenitiesList = event.eventProperties!['amenities'] as List?;
          if (amenitiesList != null) {
            for (final amenity in amenitiesList) {
              amenities[amenity.toString()] =
                  (amenities[amenity.toString()] ?? 0) + 1;
            }
          }
        }
        if (event.eventProperties!['price'] != null) {
          final price = double.tryParse(
            event.eventProperties!['price'].toString(),
          );
          if (price != null) prices.add(price);
        }
      }
    }

    // Analyser les conversions
    for (final conversion in conversions) {
      if (conversion.eventProperties != null) {
        if (conversion.eventProperties!['property_type'] != null) {
          final type = conversion.eventProperties!['property_type'].toString();
          propertyTypes[type] =
              (propertyTypes[type] ?? 0) +
              2; // Plus de poids pour les conversions
        }
      }
      if (conversion.conversionValue != null) {
        prices.add(conversion.conversionValue!);
      }
    }

    // Trier et prendre les plus fréquents
    final topPropertyTypes = propertyTypes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topLocations = locations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topAmenities = amenities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    double? minPrice, maxPrice;
    if (prices.isNotEmpty) {
      prices.sort();
      minPrice = prices.first;
      maxPrice = prices.last;
    }

    return {
      'propertyTypes': topPropertyTypes.take(3).map((e) => e.key).toList(),
      'locations': topLocations.take(3).map((e) => e.key).toList(),
      'amenities': topAmenities.take(5).map((e) => e.key).toList(),
      'priceRange': minPrice != null && maxPrice != null
          ? {'min': minPrice, 'max': maxPrice}
          : null,
    };
  }

  /// Calculer les scores
  Map<String, double> _calculateScores(
    Map<String, int> metrics,
    Map<String, dynamic> behaviors,
  ) {
    // Score d'engagement (0-1)
    final engagementScore = _calculateEngagementScore(metrics);

    // Score de personnalisation (0-1)
    final personalizationScore = _calculatePersonalizationScore(behaviors);

    // Probabilité de rétention (0-1)
    final retentionProbability = _calculateRetentionProbability(
      metrics,
      behaviors,
    );

    return {
      'engagement': engagementScore,
      'personalization': personalizationScore,
      'retention': retentionProbability,
    };
  }

  double _calculateEngagementScore(Map<String, int> metrics) {
    // Score basé sur le temps, interactions, et conversions
    final timeScore = (metrics['totalTimeMinutes'] ?? 0) / 60.0; // Max 1h = 1.0
    final interactionScore =
        (metrics['interactionsCount'] ?? 0) / 50.0; // Max 50 = 1.0
    final searchScore = (metrics['searchesCount'] ?? 0) / 10.0; // Max 10 = 1.0

    return ((timeScore * 0.4 + interactionScore * 0.4 + searchScore * 0.2)
        .clamp(0.0, 1.0));
  }

  double _calculatePersonalizationScore(Map<String, dynamic> behaviors) {
    // Score basé sur la diversité des patterns détectés
    final patterns = behaviors['patterns'] as List?;
    if (patterns == null || patterns.isEmpty) return 0.5;

    return (patterns.length / 10.0).clamp(0.0, 1.0);
  }

  double _calculateRetentionProbability(
    Map<String, int> metrics,
    Map<String, dynamic> behaviors,
  ) {
    // Probabilité basée sur l'engagement et les conversions
    final engagement = _calculateEngagementScore(metrics);
    final conversions = metrics['conversionsCount'] ?? 0;
    final conversionScore = (conversions / 3.0).clamp(0.0, 1.0);

    return ((engagement * 0.7 + conversionScore * 0.3).clamp(0.0, 1.0));
  }

  /// Générer des recommandations IA
  Future<List<Map<String, dynamic>>> _generateRecommendations(
    Map<String, dynamic> behaviors,
    Map<String, dynamic> preferences,
    Map<String, double> scores,
  ) async {
    try {
      final prompt =
          '''
Génère des recommandations personnalisées pour améliorer l'expérience utilisateur.

Comportements détectés: ${behaviors['insights']}
Préférences: ${jsonEncode(preferences)}
Scores: ${jsonEncode(scores)}

Génère 3-5 recommandations concrètes en JSON avec:
- "type": Type de recommandation (feature, content, ux)
- "title": Titre de la recommandation
- "description": Description détaillée
- "priority": Priorité (high, medium, low)

Réponds uniquement en JSON valide.
''';

      final response = await GeminiService.model.generateContent([
        Content.text(prompt),
      ]);
      final responseText = response.text ?? '';

      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(responseText);
      if (jsonMatch != null) {
        final list = jsonDecode(jsonMatch.group(0)!) as List;
        return list.map((e) => e as Map<String, dynamic>).toList();
      }

      return [];
    } catch (e) {
      AppConfig.logger.e('Erreur génération recommandations: $e');
      return [];
    }
  }

  /// Sauvegarder l'analyse comportementale
  Future<void> saveBehaviorAnalysis(AnalyticsUserBehaviorModel behavior) async {
    try {
      await SupabaseService.from(
        'analytics_user_behaviors',
      ).upsert(behavior.toJson());
    } catch (e) {
      AppConfig.logger.e('Erreur sauvegarde analyse: $e');
      rethrow;
    }
  }
}
