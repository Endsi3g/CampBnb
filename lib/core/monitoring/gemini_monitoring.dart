/// Système de surveillance et monitoring pour l'API Gemini
/// Gère les logs, métriques, alertes et limites
import 'dart:async';
import 'package:logger/logger.dart';
import '../config/gemini_config.dart';
import '../models/gemini_models.dart';
import '../services/gemini_service.dart';

class GeminiMonitoring {
  static final GeminiMonitoring _instance = GeminiMonitoring._internal();
  factory GeminiMonitoring() => _instance;
  GeminiMonitoring._internal();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
    ),
  );

  final List<MonitoringEvent> _events = [];
  final StreamController<MonitoringEvent> _eventController =
      StreamController<MonitoringEvent>.broadcast();

  /// Stream des événements de monitoring
  Stream<MonitoringEvent> get events => _eventController.stream;

  /// Enregistre un événement
  void logEvent({
    required MonitoringEventType type,
    required String message,
    Map<String, dynamic>? metadata,
    Object? error,
  }) {
    final event = MonitoringEvent(
      type: type,
      message: message,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
      error: error?.toString(),
    );

    _events.add(event);
    _eventController.add(event);

    // Limiter la taille de l'historique
    if (_events.length > 1000) {
      _events.removeAt(0);
    }

    // Logger selon le type
    switch (type) {
      case MonitoringEventType.error:
        _logger.e(message, error: error, stackTrace: StackTrace.current);
        break;
      case MonitoringEventType.warning:
        _logger.w(message);
        break;
      case MonitoringEventType.info:
        _logger.i(message);
        break;
      case MonitoringEventType.success:
        _logger.d(message);
        break;
    }
  }

  /// Enregistre une requête API
  void logRequest({
    required GeminiRequestType requestType,
    required Duration duration,
    required bool success,
    String? error,
  }) {
    logEvent(
      type: success ? MonitoringEventType.success : MonitoringEventType.error,
      message: 'Requête ${requestType.name} ${success ? "réussie" : "échouée"}',
      metadata: {
        'requestType': requestType.name,
        'duration': duration.inMilliseconds,
        'success': success,
        if (error != null) 'error': error,
      },
    );

    // Alerte si le temps de réponse est trop long
    if (duration.inSeconds > 10) {
      logEvent(
        type: MonitoringEventType.warning,
        message: 'Temps de réponse élevé: ${duration.inSeconds}s',
        metadata: {'requestType': requestType.name},
      );
    }
  }

  /// Enregistre une limite de taux atteinte
  void logRateLimit(GeminiRequestType requestType) {
    logEvent(
      type: MonitoringEventType.warning,
      message: 'Limite de taux atteinte pour ${requestType.name}',
      metadata: {'requestType': requestType.name},
    );
  }

  /// Enregistre une erreur API
  void logApiError({
    required String error,
    required GeminiRequestType requestType,
    Object? exception,
  }) {
    logEvent(
      type: MonitoringEventType.error,
      message: 'Erreur API Gemini: $error',
      metadata: {'requestType': requestType.name},
      error: exception,
    );
  }

  /// Obtient les statistiques de monitoring
  MonitoringStats getStats() {
    final now = DateTime.now();
    final last24h = now.subtract(const Duration(hours: 24));

    final recentEvents = _events
        .where((e) => e.timestamp.isAfter(last24h))
        .toList();

    return MonitoringStats(
      totalEvents: _events.length,
      eventsLast24h: recentEvents.length,
      errors: recentEvents
          .where((e) => e.type == MonitoringEventType.error)
          .length,
      warnings: recentEvents
          .where((e) => e.type == MonitoringEventType.warning)
          .length,
      apiStats: GeminiService().getStats(),
    );
  }

  /// Obtient l'historique des événements
  List<MonitoringEvent> getEventHistory({int? limit}) {
    if (limit != null) {
      return _events.reversed.take(limit).toList();
    }
    return List.unmodifiable(_events.reversed);
  }

  /// Vérifie la santé du système
  SystemHealth checkHealth() {
    final stats = getStats();
    final apiStats = stats.apiStats;

    // Vérifier les limites
    final rateLimitReached =
        apiStats.requestsThisMinute >= GeminiConfig.rateLimitPerMinute;
    final dailyLimitReached =
        apiStats.requestsToday >= GeminiConfig.rateLimitPerDay;

    // Calculer le taux d'erreur
    final errorRate = apiStats.totalRequests > 0
        ? apiStats.failedRequests / apiStats.totalRequests
        : 0.0;

    HealthStatus status;
    if (dailyLimitReached || rateLimitReached) {
      status = HealthStatus.degraded;
    } else if (errorRate > 0.1) {
      status = HealthStatus.degraded;
    } else if (errorRate > 0.05) {
      status = HealthStatus.warning;
    } else {
      status = HealthStatus.healthy;
    }

    return SystemHealth(
      status: status,
      rateLimitReached: rateLimitReached,
      dailyLimitReached: dailyLimitReached,
      errorRate: errorRate,
      stats: stats,
    );
  }

  /// Réinitialise le monitoring (pour les tests)
  void reset() {
    _events.clear();
  }
}

/// Type d'événement de monitoring
enum MonitoringEventType { info, success, warning, error }

/// Événement de monitoring
class MonitoringEvent {
  final MonitoringEventType type;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final String? error;

  MonitoringEvent({
    required this.type,
    required this.message,
    required this.timestamp,
    required this.metadata,
    this.error,
  });
}

/// Statistiques de monitoring
class MonitoringStats {
  final int totalEvents;
  final int eventsLast24h;
  final int errors;
  final int warnings;
  final GeminiApiStats apiStats;

  MonitoringStats({
    required this.totalEvents,
    required this.eventsLast24h,
    required this.errors,
    required this.warnings,
    required this.apiStats,
  });
}

/// Santé du système
enum HealthStatus { healthy, warning, degraded }

class SystemHealth {
  final HealthStatus status;
  final bool rateLimitReached;
  final bool dailyLimitReached;
  final double errorRate;
  final MonitoringStats stats;

  SystemHealth({
    required this.status,
    required this.rateLimitReached,
    required this.dailyLimitReached,
    required this.errorRate,
    required this.stats,
  });
}
