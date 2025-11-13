import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../../../shared/services/behavior_analysis_service.dart';
import '../../../../shared/models/analytics_event_model.dart';

part 'analytics_provider.g.dart';

/// Provider pour le service Analytics
@riverpod
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  return AnalyticsService.instance;
}

/// Provider pour le service d'analyse comportementale
@riverpod
BehaviorAnalysisService behaviorAnalysisService(BehaviorAnalysisServiceRef ref) {
  return BehaviorAnalysisService.instance;
}

/// Provider pour la session analytics actuelle
@riverpod
Future<String?> currentSessionId(CurrentSessionIdRef ref) async {
  final analytics = ref.watch(analyticsServiceProvider);
 // Retourner l'ID de session actuel (simplifié)
  return null; // Sera géré par le service
}

/// Provider pour les consentements privacy
@riverpod
Future<AnalyticsPrivacyConsentModel?> privacyConsent(PrivacyConsentRef ref) async {
  final analytics = ref.watch(analyticsServiceProvider);
  // Le consentement est géré en interne par le service
  return null;
}

/// Provider pour analyser les comportements utilisateur
@riverpod
Future<AnalyticsUserBehaviorModel?> userBehaviorAnalysis(
  UserBehaviorAnalysisRef ref, {
  required String userIdOrAnonymousId,
  required DateTime analysisDate,
  required String analysisPeriod,
}) async {
  final behaviorService = ref.watch(behaviorAnalysisServiceProvider);
  
  try {
    final analysis = await behaviorService.analyzeUserBehavior(
      userIdOrAnonymousId: userIdOrAnonymousId,
      analysisDate: analysisDate,
      analysisPeriod: analysisPeriod,
    );
    
 // Sauvegarder l'analyse
    await behaviorService.saveBehaviorAnalysis(analysis);
    
    return analysis;
  } catch (e) {
    return null;
  }
}



