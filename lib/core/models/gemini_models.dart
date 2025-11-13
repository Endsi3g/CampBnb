/// Modèles de données pour les interactions avec Gemini
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gemini_models.freezed.dart';
part 'gemini_models.g.dart';

/// Type de requête Gemini
enum GeminiRequestType {
  destinationSuggestion,
  searchAnalysis,
  itineraryGeneration,
  faqResponse,
  reviewSummary,
  translation,
  imageAnalysis,
  localExperience,
  chatConversation,
}

/// Statut d'une requête Gemini
enum GeminiRequestStatus { pending, processing, completed, failed, rateLimited }

/// Modèle pour une requête Gemini
@freezed
class GeminiRequest with _$GeminiRequest {
  const factory GeminiRequest({
    required String id,
    required GeminiRequestType type,
    required String prompt,
    @Default(GeminiRequestStatus.pending) GeminiRequestStatus status,
    String? response,
    String? error,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
    List<String>? imageUrls,
  }) = _GeminiRequest;

  factory GeminiRequest.fromJson(Map<String, dynamic> json) =>
      _$GeminiRequestFromJson(json);
}

/// Modèle pour une suggestion de destination
@freezed
class DestinationSuggestion with _$DestinationSuggestion {
  const factory DestinationSuggestion({
    required String name,
    required String region,
    required String description,
    required List<String> highlights,
    required String bestSeason,
    required double rating,
    String? imageUrl,
    Map<String, dynamic>? additionalInfo,
  }) = _DestinationSuggestion;

  factory DestinationSuggestion.fromJson(Map<String, dynamic> json) =>
      _$DestinationSuggestionFromJson(json);
}

/// Modèle pour un itinéraire généré
@freezed
class GeneratedItinerary with _$GeneratedItinerary {
  const factory GeneratedItinerary({
    required String title,
    required List<ItineraryDay> days,
    required String summary,
    required List<String> tips,
  }) = _GeneratedItinerary;

  factory GeneratedItinerary.fromJson(Map<String, dynamic> json) =>
      _$GeneratedItineraryFromJson(json);
}

/// Modèle pour un jour d'itinéraire
@freezed
class ItineraryDay with _$ItineraryDay {
  const factory ItineraryDay({
    required int dayNumber,
    required String title,
    required List<ItineraryActivity> activities,
    required String description,
  }) = _ItineraryDay;

  factory ItineraryDay.fromJson(Map<String, dynamic> json) =>
      _$ItineraryDayFromJson(json);
}

/// Modèle pour une activité d'itinéraire
@freezed
class ItineraryActivity with _$ItineraryActivity {
  const factory ItineraryActivity({
    required String name,
    required String time,
    required String description,
    String? location,
    String? duration,
  }) = _ItineraryActivity;

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) =>
      _$ItineraryActivityFromJson(json);
}

/// Modèle pour un résumé d'avis
@freezed
class ReviewSummary with _$ReviewSummary {
  const factory ReviewSummary({
    required double averageRating,
    required Map<String, int> ratingDistribution,
    required List<String> positiveAspects,
    required List<String> negativeAspects,
    required String overallSentiment,
    required int totalReviews,
  }) = _ReviewSummary;

  factory ReviewSummary.fromJson(Map<String, dynamic> json) =>
      _$ReviewSummaryFromJson(json);
}

/// Modèle pour une expérience locale
@freezed
class LocalExperience with _$LocalExperience {
  const factory LocalExperience({
    required String title,
    required String description,
    required String category,
    required String location,
    String? imageUrl,
    List<String>? tags,
    Map<String, dynamic>? details,
  }) = _LocalExperience;

  factory LocalExperience.fromJson(Map<String, dynamic> json) =>
      _$LocalExperienceFromJson(json);
}

/// Modèle pour un message de chat
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String content,
    required bool isUser,
    required DateTime timestamp,
    @Default(false) bool isProcessing,
    String? error,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

/// Modèle pour les statistiques d'utilisation API
@freezed
class GeminiApiStats with _$GeminiApiStats {
  const factory GeminiApiStats({
    @Default(0) int requestsToday,
    @Default(0) int requestsThisMinute,
    @Default(0) int totalRequests,
    @Default(0) int failedRequests,
    DateTime? lastRequestTime,
    @Default(0) double averageResponseTime,
  }) = _GeminiApiStats;

  factory GeminiApiStats.fromJson(Map<String, dynamic> json) =>
      _$GeminiApiStatsFromJson(json);
}
