/// Providers Riverpod pour toutes les fonctionnalités Gemini
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gemini_models.dart';
import '../services/gemini_service.dart';

/// Provider pour le service Gemini (singleton)
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

/// Provider pour les statistiques API
final geminiStatsProvider = StreamProvider<GeminiApiStats>((ref) async* {
  final service = ref.watch(geminiServiceProvider);
  yield service.getStats();

  // Émettre des mises à jour périodiques
  await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
    yield service.getStats();
  }
});

/// Provider pour les suggestions de destinations
final destinationSuggestionsProvider =
    FutureProvider.family<
      List<DestinationSuggestion>,
      DestinationSuggestionParams
    >((ref, params) async {
      final service = ref.watch(geminiServiceProvider);
      return await service.suggestDestinations(
        region: params.region,
        month: params.month,
        preferences: params.preferences,
        groupType: params.groupType,
      );
    });

/// Paramètres pour les suggestions de destinations
class DestinationSuggestionParams {
  final String region;
  final String? month;
  final String? preferences;
  final String? groupType;

  DestinationSuggestionParams({
    required this.region,
    this.month,
    this.preferences,
    this.groupType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DestinationSuggestionParams &&
          runtimeType == other.runtimeType &&
          region == other.region &&
          month == other.month &&
          preferences == other.preferences &&
          groupType == other.groupType;

  @override
  int get hashCode =>
      region.hashCode ^
      month.hashCode ^
      preferences.hashCode ^
      groupType.hashCode;
}

/// Provider pour l'analyse de recherche
final searchAnalysisProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, query) async {
      final service = ref.watch(geminiServiceProvider);
      return await service.analyzeSearch(query);
    });

/// Provider pour la génération d'itinéraire
final itineraryProvider =
    FutureProvider.family<GeneratedItinerary, ItineraryParams>((
      ref,
      params,
    ) async {
      final service = ref.watch(geminiServiceProvider);
      return await service.generateItinerary(
        destination: params.destination,
        days: params.days,
        preferences: params.preferences,
        budget: params.budget,
      );
    });

/// Paramètres pour la génération d'itinéraire
class ItineraryParams {
  final String destination;
  final int days;
  final String? preferences;
  final String? budget;

  ItineraryParams({
    required this.destination,
    required this.days,
    this.preferences,
    this.budget,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItineraryParams &&
          runtimeType == other.runtimeType &&
          destination == other.destination &&
          days == other.days &&
          preferences == other.preferences &&
          budget == other.budget;

  @override
  int get hashCode =>
      destination.hashCode ^
      days.hashCode ^
      preferences.hashCode ^
      budget.hashCode;
}

/// Provider pour les réponses FAQ
final faqResponseProvider = FutureProvider.family<String, FAQParams>((
  ref,
  params,
) async {
  final service = ref.watch(geminiServiceProvider);
  return await service.answerFAQ(params.question, context: params.context);
});

/// Paramètres pour FAQ
class FAQParams {
  final String question;
  final String? context;

  FAQParams({required this.question, this.context});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FAQParams &&
          runtimeType == other.runtimeType &&
          question == other.question &&
          context == other.context;

  @override
  int get hashCode => question.hashCode ^ context.hashCode;
}

/// Provider pour le résumé d'avis
final reviewSummaryProvider =
    FutureProvider.family<ReviewSummary, List<String>>((ref, reviews) async {
      final service = ref.watch(geminiServiceProvider);
      return await service.summarizeReviews(reviews);
    });

/// Provider pour la traduction
final translationProvider = FutureProvider.family<String, TranslationParams>((
  ref,
  params,
) async {
  final service = ref.watch(geminiServiceProvider);
  return await service.translate(
    params.text,
    targetLanguage: params.targetLanguage,
  );
});

/// Paramètres pour la traduction
class TranslationParams {
  final String text;
  final String targetLanguage;

  TranslationParams({required this.text, required this.targetLanguage});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationParams &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          targetLanguage == other.targetLanguage;

  @override
  int get hashCode => text.hashCode ^ targetLanguage.hashCode;
}

/// Provider pour l'analyse d'image
final imageAnalysisProvider =
    FutureProvider.family<Map<String, dynamic>, String>((
      ref,
      imageDescription,
    ) async {
      final service = ref.watch(geminiServiceProvider);
      return await service.analyzeImage(imageDescription);
    });

/// Provider pour les expériences locales
final localExperiencesProvider =
    FutureProvider.family<List<LocalExperience>, LocalExperienceParams>((
      ref,
      params,
    ) async {
      final service = ref.watch(geminiServiceProvider);
      return await service.suggestLocalExperiences(
        location: params.location,
        preferences: params.preferences,
      );
    });

/// Paramètres pour les expériences locales
class LocalExperienceParams {
  final String location;
  final String? preferences;

  LocalExperienceParams({required this.location, this.preferences});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalExperienceParams &&
          runtimeType == other.runtimeType &&
          location == other.location &&
          preferences == other.preferences;

  @override
  int get hashCode => location.hashCode ^ preferences.hashCode;
}

/// Provider pour le chat conversationnel
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(ref.watch(geminiServiceProvider)),
);

/// État du chat
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({this.messages = const [], this.isLoading = false, this.error});

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier pour le chat
class ChatNotifier extends StateNotifier<ChatState> {
  final GeminiService _service;
  String? _userContext;

  ChatNotifier(this._service) : super(ChatState());

  /// Envoie un message et obtient une réponse
  Future<void> sendMessage(String message) async {
    // Ajouter le message utilisateur
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final response = await _service.chat(
        message: message,
        history: state.messages,
        userContext: _userContext,
      );

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Définit le contexte utilisateur
  void setUserContext(String? context) {
    _userContext = context;
  }

  /// Efface l'historique du chat
  void clearHistory() {
    state = ChatState();
  }
}
