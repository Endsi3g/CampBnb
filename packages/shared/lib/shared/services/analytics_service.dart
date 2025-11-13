import 'dart:convert';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/config/app_config.dart';
import '../models/analytics_event_model.dart';
import 'supabase_service.dart';
import 'gemini_service.dart';

/// Service Analytics intégrant Supabase et Gemini
/// Note: Utilise uniquement Supabase (pas Firebase)
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  bool _isInitialized = false;
  String? _currentSessionId;
  String? _anonymousId;
  AnalyticsPrivacyConsentModel? _privacyConsent;

  /// Initialiser le service analytics
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
 // Générer ou récupérer l'ID anonyme
      _anonymousId = await _getOrCreateAnonymousId();

      // Récupérer les consentements privacy
      await _loadPrivacyConsent();

      // Démarrer une nouvelle session si pas déjà démarrée
      if (_currentSessionId == null) {
        await startSession();
      }

      _isInitialized = true;
 AppConfig.logger.i(' Analytics Service initialisé');
    } catch (e) {
 AppConfig.logger.e(' Erreur initialisation Analytics: $e');
    }
  }

  /// Obtenir ou créer un ID anonyme
  Future<String> _getOrCreateAnonymousId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
 String? storedId = prefs.getString('analytics_anonymous_id');

      if (storedId == null || storedId.isEmpty) {
        storedId = const Uuid().v4();
 await prefs.setString('analytics_anonymous_id', storedId);
      }

      return storedId;
    } catch (e) {
 AppConfig.logger.e('Erreur récupération anonymous_id: $e');
      return const Uuid().v4();
    }
  }

  /// Charger les consentements privacy
  Future<void> _loadPrivacyConsent() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      final anonymousId = _anonymousId ?? await _getOrCreateAnonymousId();

 final response = await SupabaseService.from('analytics_privacy_consents')
          .select()
 .or('user_id.eq.$userId,anonymous_id.eq.$anonymousId')
          .maybeSingle();

      if (response != null) {
        _privacyConsent = AnalyticsPrivacyConsentModel.fromJson(response);
      } else {
        // Créer un consentement par défaut
        _privacyConsent = AnalyticsPrivacyConsentModel(
          anonymousId: anonymousId,
          userId: userId,
 consentVersion: '1.0',
          consentGivenAt: DateTime.now(),
        );
        await _savePrivacyConsent(_privacyConsent!);
      }
    } catch (e) {
 AppConfig.logger.e('Erreur chargement consentement: $e');
      // Consentement par défaut si erreur
      _privacyConsent = AnalyticsPrivacyConsentModel(
        anonymousId: _anonymousId ?? const Uuid().v4(),
 consentVersion: '1.0',
        consentGivenAt: DateTime.now(),
      );
    }
  }

  /// Sauvegarder les consentements privacy
  Future<void> _savePrivacyConsent(AnalyticsPrivacyConsentModel consent) async {
    try {
 await SupabaseService.from('analytics_privacy_consents')
          .upsert(consent.toJson());
    } catch (e) {
 AppConfig.logger.e('Erreur sauvegarde consentement: $e');
    }
  }

 /// Vérifier si l'analytics est activé
  bool get isAnalyticsEnabled {
    return _privacyConsent?.analyticsEnabled ?? true;
  }

  /// Démarrer une nouvelle session
  Future<void> startSession() async {
    if (!isAnalyticsEnabled) return;

    try {
      _currentSessionId = const Uuid().v4();
      final userId = SupabaseService.currentUser?.id;
      final anonymousId = _anonymousId ?? await _getOrCreateAnonymousId();

 // Récupérer les infos de l'app
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = await _getDeviceInfo();

      final session = AnalyticsSessionModel(
        id: _currentSessionId,
        userId: userId,
        anonymousId: anonymousId,
        startedAt: DateTime.now(),
        isActive: true,
        appVersion: packageInfo.version,
 platform: Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'web',
 osVersion: deviceInfo['osVersion'],
 deviceModel: deviceInfo['deviceModel'],
 deviceId: await _hashDeviceId(deviceInfo['deviceId'] ?? ''),
        entryScreen: null, // Sera mis à jour au premier screen_view
      );

 await SupabaseService.from('analytics_sessions').insert(session.toJson());

 AppConfig.logger.d(' Session démarrée: $_currentSessionId');
    } catch (e) {
 AppConfig.logger.e('Erreur démarrage session: $e');
    }
  }

  /// Terminer la session actuelle
  Future<void> endSession() async {
    if (!isAnalyticsEnabled || _currentSessionId == null) return;

    try {
 await SupabaseService.from('analytics_sessions')
          .update({
 'ended_at': DateTime.now().toIso8601String(),
 'is_active': false,
          })
 .eq('id', _currentSessionId!);

      _currentSessionId = null;
 AppConfig.logger.d(' Session terminée');
    } catch (e) {
 AppConfig.logger.e('Erreur fin session: $e');
    }
  }

  /// Logger un événement
  Future<void> logEvent({
    required String eventName,
    required String eventCategory,
    required String eventType,
    String? screenName,
    String? screenClass,
    String? previousScreen,
    Map<String, dynamic>? properties,
    int? loadTimeMs,
    int? responseTimeMs,
  }) async {
    if (!isAnalyticsEnabled) return;

    try {
      final userId = SupabaseService.currentUser?.id;
      final anonymousId = _anonymousId ?? await _getOrCreateAnonymousId();
      if (_currentSessionId == null) {
        await startSession();
      }
      final sessionId = _currentSessionId!;

      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = await _getDeviceInfo();

      final event = AnalyticsEventModel(
        sessionId: sessionId,
        userId: userId,
        anonymousId: anonymousId,
        eventName: eventName,
        eventCategory: eventCategory,
        eventType: eventType,
        screenName: screenName,
        screenClass: screenClass,
        previousScreen: previousScreen,
        eventProperties: properties,
        appVersion: packageInfo.version,
 platform: Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'web',
 osVersion: deviceInfo['osVersion'],
 deviceModel: deviceInfo['deviceModel'],
 deviceId: await _hashDeviceId(deviceInfo['deviceId'] ?? ''),
        loadTimeMs: loadTimeMs,
        responseTimeMs: responseTimeMs,
        createdAt: DateTime.now(),
      );

      // Supabase
 await SupabaseService.from('analytics_events').insert(event.toJson());

 AppConfig.logger.d(' Événement: $eventName');
    } catch (e) {
 AppConfig.logger.e('Erreur log événement: $e');
    }
  }

  /// Logger une conversion
  Future<void> logConversion({
    required String conversionType,
    double? conversionValue,
    String? listingId,
    String? reservationId,
    String? funnelStep,
    int? funnelPosition,
    String? source,
    String? campaign,
    Map<String, dynamic>? properties,
  }) async {
    if (!isAnalyticsEnabled) return;

    try {
      final userId = SupabaseService.currentUser?.id;
      final anonymousId = _anonymousId ?? await _getOrCreateAnonymousId();
      final sessionId = _currentSessionId;

      final conversion = AnalyticsConversionModel(
        userId: userId,
        sessionId: sessionId,
        anonymousId: anonymousId,
        conversionType: conversionType,
        conversionValue: conversionValue,
        listingId: listingId,
        reservationId: reservationId,
        funnelStep: funnelStep,
        funnelPosition: funnelPosition,
        source: source,
        campaign: campaign,
        eventProperties: properties,
        createdAt: DateTime.now(),
      );

 await SupabaseService.from('analytics_conversions').insert(conversion.toJson());

      // Mettre à jour la session avec la conversion
      if (sessionId != null) {
 await SupabaseService.from('analytics_sessions')
            .update({
 'conversion_type': conversionType,
 'conversion_value': conversionValue,
            })
 .eq('id', sessionId);
      }

 AppConfig.logger.i(' Conversion: $conversionType');
    } catch (e) {
 AppConfig.logger.e('Erreur log conversion: $e');
    }
  }

  /// Logger la satisfaction utilisateur
  Future<void> logSatisfaction({
    required String feedbackType,
    int? npsScore,
    int? csatScore,
    int? cesScore,
    int? rating,
    String? comment,
    String? screenName,
    String? listingId,
    String? reservationId,
    List<String>? categories,
  }) async {
    if (!isAnalyticsEnabled) return;

    try {
      final userId = SupabaseService.currentUser?.id;
      final anonymousId = _anonymousId ?? await _getOrCreateAnonymousId();

      // Analyser le sentiment avec Gemini si commentaire présent
      String? sentiment;
      double? sentimentScore;
      if (comment != null && comment.isNotEmpty) {
        final sentimentAnalysis = await _analyzeSentiment(comment);
 sentiment = sentimentAnalysis['sentiment'];
 sentimentScore = sentimentAnalysis['score'];
      }

      final packageInfo = await PackageInfo.fromPlatform();

      final satisfaction = AnalyticsSatisfactionModel(
        userId: userId,
        anonymousId: anonymousId,
        feedbackType: feedbackType,
        npsScore: npsScore,
        csatScore: csatScore,
        cesScore: cesScore,
        rating: rating,
        comment: comment,
        sentiment: sentiment,
        sentimentScore: sentimentScore,
        screenName: screenName,
        listingId: listingId,
        reservationId: reservationId,
        categories: categories,
        appVersion: packageInfo.version,
 platform: Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'web',
        createdAt: DateTime.now(),
      );

 await SupabaseService.from('analytics_satisfaction').insert(satisfaction.toJson());

 AppConfig.logger.i(' Satisfaction: $feedbackType');
    } catch (e) {
 AppConfig.logger.e('Erreur log satisfaction: $e');
    }
  }

 /// Analyser le sentiment d'un commentaire avec Gemini
  Future<Map<String, dynamic>> _analyzeSentiment(String comment) async {
    try {
 final prompt = '''
Analyse le sentiment de ce commentaire utilisateur et retourne uniquement un JSON avec:
- "sentiment": "positive", "neutral" ou "negative"
- "score": un nombre entre -1.0 (très négatif) et 1.0 (très positif)

Commentaire: "$comment"
''';

      final response = await GeminiService.model.generateContent([Content.text(prompt)]);
 final responseText = response.text ?? '';
 final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(responseText);
      
      if (jsonMatch != null) {
        final json = jsonDecode(jsonMatch.group(0)!);
        return {
 'sentiment': json['sentiment'] ?? 'neutral',
 'score': (json['score'] ?? 0.0).toDouble(),
        };
      }
    } catch (e) {
 AppConfig.logger.e('Erreur analyse sentiment: $e');
    }

 return {'sentiment': 'neutral', 'score': 0.0};
  }

  /// Obtenir les infos du device
  Future<Map<String, String?>> _getDeviceInfo() async {
    try {
      // Utiliser device_info_plus si disponible, sinon valeurs par défaut
      return {
 'deviceModel': Platform.isIOS ? 'iOS Device' : 'Android Device',
 'osVersion': Platform.operatingSystemVersion,
 'deviceId': _anonymousId,
      };
    } catch (e) {
      return {
 'deviceModel': null,
 'osVersion': null,
 'deviceId': _anonymousId,
      };
    }
  }

  /// Hasher un device ID pour privacy
  Future<String> _hashDeviceId(String deviceId) async {
 if (deviceId.isEmpty) return '';
    // Utiliser un hash simple (en production, utiliser crypto)
 return deviceId.substring(0, 16); // Simplifié pour l'exemple
  }

  /// Mettre à jour les consentements privacy
  Future<void> updatePrivacyConsent({
    bool? analyticsEnabled,
    bool? personalizationEnabled,
    bool? dataSharingEnabled,
    int? dataRetentionDays,
    String? anonymizationLevel,
  }) async {
    try {
      final updatedConsent = _privacyConsent!.copyWith(
        analyticsEnabled: analyticsEnabled ?? _privacyConsent!.analyticsEnabled,
        personalizationEnabled: personalizationEnabled ?? _privacyConsent!.personalizationEnabled,
        dataSharingEnabled: dataSharingEnabled ?? _privacyConsent!.dataSharingEnabled,
        dataRetentionDays: dataRetentionDays ?? _privacyConsent!.dataRetentionDays,
        anonymizationLevel: anonymizationLevel ?? _privacyConsent!.anonymizationLevel,
        consentUpdatedAt: DateTime.now(),
      );

      _privacyConsent = updatedConsent;
      await _savePrivacyConsent(updatedConsent);
    } catch (e) {
 AppConfig.logger.e('Erreur mise à jour consentement: $e');
    }
  }
}

