import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_event_model.freezed.dart';
part 'analytics_event_model.g.dart';

/// Modèle pour un événement analytics
@freezed
class AnalyticsEventModel with _$AnalyticsEventModel {
  const factory AnalyticsEventModel({
    String? id,
    String? userId,
    required String sessionId,
    String? anonymousId,
    required String eventName,
    required String
    eventCategory, // 'navigation', 'interaction', 'conversion', 'error', 'performance'
    required String eventType, // 'screen_view', 'button_click', 'search', etc.
    String? screenName,
    String? screenClass,
    String? previousScreen,
    @JsonKey(name: 'event_properties') Map<String, dynamic>? eventProperties,
    String? appVersion,
    String? platform,
    String? osVersion,
    String? deviceModel,
    String? deviceId,
    String? city,
    String? province,
    String? country,
    int? loadTimeMs,
    int? responseTimeMs,
    DateTime? createdAt,
  }) = _AnalyticsEventModel;

  factory AnalyticsEventModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsEventModelFromJson(json);
}

/// Modèle pour une session analytics
@freezed
class AnalyticsSessionModel with _$AnalyticsSessionModel {
  const factory AnalyticsSessionModel({
    String? id,
    String? userId,
    required String anonymousId,
    required DateTime startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    @Default(true) bool isActive,
    String? entryScreen,
    String? exitScreen,
    @Default(0) int screensViewed,
    @Default(0) int eventsCount,
    String? appVersion,
    String? platform,
    String? osVersion,
    String? deviceModel,
    String? deviceId,
    String? city,
    String? province,
    String? country,
    @Default(0) int interactionsCount,
    @Default(0) int searchesCount,
    @Default(0) int listingsViewed,
    String? conversionType,
    double? conversionValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AnalyticsSessionModel;

  factory AnalyticsSessionModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsSessionModelFromJson(json);
}

/// Modèle pour une conversion
@freezed
class AnalyticsConversionModel with _$AnalyticsConversionModel {
  const factory AnalyticsConversionModel({
    String? id,
    String? userId,
    String? sessionId,
    String? anonymousId,
    required String conversionType, // 'signup', 'reservation_confirmed', etc.
    double? conversionValue,
    @Default('CAD') String currency,
    String? listingId,
    String? reservationId,
    String? funnelStep,
    int? funnelPosition,
    String? source,
    String? campaign,
    String? referrer,
    @JsonKey(name: 'event_properties') Map<String, dynamic>? eventProperties,
    DateTime? createdAt,
  }) = _AnalyticsConversionModel;

  factory AnalyticsConversionModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsConversionModelFromJson(json);
}

/// Modèle pour la satisfaction utilisateur
@freezed
class AnalyticsSatisfactionModel with _$AnalyticsSatisfactionModel {
  const factory AnalyticsSatisfactionModel({
    String? id,
    String? userId,
    String? anonymousId,
    required String feedbackType, // 'nps', 'csat', 'ces', 'rating', etc.
    int? npsScore,
    int? csatScore,
    int? cesScore,
    int? rating,
    String? comment,
    String? sentiment, // 'positive', 'neutral', 'negative'
    double? sentimentScore,
    String? screenName,
    String? listingId,
    String? reservationId,
    List<String>? categories,
    String? appVersion,
    String? platform,
    DateTime? createdAt,
  }) = _AnalyticsSatisfactionModel;

  factory AnalyticsSatisfactionModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsSatisfactionModelFromJson(json);
}

/// Modèle pour les comportements utilisateur analysés par Gemini
@freezed
class AnalyticsUserBehaviorModel with _$AnalyticsUserBehaviorModel {
  const factory AnalyticsUserBehaviorModel({
    String? id,
    String? userId,
    required String anonymousId,
    required DateTime analysisDate,
    required String analysisPeriod, // 'daily', 'weekly', 'monthly'
    required Map<String, dynamic>
    behaviors, // Patterns, insights, recommendations
    @Default(0) int sessionsCount,
    @Default(0) int totalTimeMinutes,
    @Default(0) int screensViewed,
    @Default(0) int interactionsCount,
    @Default(0) int searchesCount,
    @Default(0) int conversionsCount,
    List<String>? preferredPropertyTypes,
    List<String>? preferredLocations,
    Map<String, dynamic>? preferredPriceRange,
    List<String>? preferredAmenities,
    double? personalizationScore,
    double? engagementScore,
    double? retentionProbability,
    @JsonKey(name: 'ai_recommendations')
    List<Map<String, dynamic>>? aiRecommendations,
    String? aiInsights,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AnalyticsUserBehaviorModel;

  factory AnalyticsUserBehaviorModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsUserBehaviorModelFromJson(json);
}

/// Modèle pour les consentements privacy
@freezed
class AnalyticsPrivacyConsentModel with _$AnalyticsPrivacyConsentModel {
  const factory AnalyticsPrivacyConsentModel({
    String? id,
    String? userId,
    required String anonymousId,
    @Default(true) bool analyticsEnabled,
    @Default(true) bool personalizationEnabled,
    @Default(false) bool dataSharingEnabled,
    @Default(365) int dataRetentionDays,
    @Default('standard') String anonymizationLevel,
    required String consentVersion,
    required DateTime consentGivenAt,
    DateTime? consentUpdatedAt,
  }) = _AnalyticsPrivacyConsentModel;

  factory AnalyticsPrivacyConsentModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsPrivacyConsentModelFromJson(json);
}
