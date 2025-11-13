/// Service de notifications et prioritisation des erreurs
/// Gère les alertes, filtres et notifications pour l'équipe de développement
import 'dart:async';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'error_monitoring_service.dart';
import '../config/app_config.dart';

/// Service de notifications d'erreurs
class ErrorNotificationService {
  static final ErrorNotificationService _instance = ErrorNotificationService._internal();
  factory ErrorNotificationService() => _instance;
  ErrorNotificationService._internal();

  final List<ErrorAlert> _activeAlerts = [];
  final StreamController<ErrorAlert> _alertController = StreamController<ErrorAlert>.broadcast();

 /// Stream des alertes d'erreurs
  Stream<ErrorAlert> get alerts => _alertController.stream;

 /// Détermine la priorité d'une erreur
  ErrorPriority determinePriority({
    required ErrorSeverity severity,
    required String errorType,
    int? affectedUsers,
    bool isRecurring = false,
    bool isBlocking = false,
  }) {
    // Erreurs fatales = priorité critique
    if (severity == ErrorSeverity.fatal) {
      return ErrorPriority.critical;
    }

    // Erreurs récurrentes = priorité élevée
    if (isRecurring) {
      return ErrorPriority.high;
    }

    // Erreurs bloquantes = priorité élevée
    if (isBlocking) {
      return ErrorPriority.high;
    }

 // Erreurs affectant beaucoup d'utilisateurs = priorité élevée
    if (affectedUsers != null && affectedUsers > 100) {
      return ErrorPriority.high;
    }

    // Erreurs réseau = priorité moyenne
 if (errorType == 'network_error') {
      return ErrorPriority.medium;
    }

    // Erreurs de performance = priorité moyenne
 if (errorType == 'performance') {
      return ErrorPriority.medium;
    }

    // Par défaut, utiliser la sévérité
    switch (severity) {
      case ErrorSeverity.fatal:
        return ErrorPriority.critical;
      case ErrorSeverity.error:
        return ErrorPriority.high;
      case ErrorSeverity.warning:
        return ErrorPriority.medium;
      case ErrorSeverity.info:
        return ErrorPriority.low;
    }
  }

 /// Crée une alerte d'erreur
  Future<void> createAlert({
    required String errorId,
    required String title,
    required String description,
    required ErrorSeverity severity,
    required ErrorPriority priority,
    String? errorType,
    Map<String, dynamic>? context,
    List<String>? affectedVersions,
    List<String>? affectedUsers,
  }) async {
    final alert = ErrorAlert(
      id: errorId,
      title: title,
      description: description,
      severity: severity,
      priority: priority,
      errorType: errorType,
      context: context ?? {},
      affectedVersions: affectedVersions ?? [],
      affectedUsers: affectedUsers ?? [],
      createdAt: DateTime.now(),
      status: AlertStatus.active,
    );

    _activeAlerts.add(alert);
    _alertController.add(alert);

 // Logger l'alerte
    AppConfig.logger.w(
 ' Alerte créée: $title (Priorité: ${priority.name})',
    );

    // Envoyer une notification si priorité critique ou élevée
    if (priority == ErrorPriority.critical || priority == ErrorPriority.high) {
      await _sendNotification(alert);
    }
  }

  /// Envoie une notification pour une alerte
  Future<void> _sendNotification(ErrorAlert alert) async {
    // Ici, vous pouvez intégrer avec :
    // - Slack webhook
    // - Email
    // - Push notifications
    // - Discord
    // - PagerDuty pour les alertes critiques

    AppConfig.logger.i(
 ' Notification envoyée pour: ${alert.title}',
    );

 // Exemple d'intégration avec un webhook Slack (à configurer)
    // await _sendSlackNotification(alert);
  }

  /// Filtre les erreurs par critères
  List<ErrorAlert> filterAlerts({
    ErrorPriority? priority,
    ErrorSeverity? severity,
    String? errorType,
    DateTime? since,
    List<String>? versions,
  }) {
    return _activeAlerts.where((alert) {
      if (priority != null && alert.priority != priority) return false;
      if (severity != null && alert.severity != severity) return false;
      if (errorType != null && alert.errorType != errorType) return false;
      if (since != null && alert.createdAt.isBefore(since)) return false;
      if (versions != null && !versions.any((v) => alert.affectedVersions.contains(v))) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Résout une alerte
  void resolveAlert(String alertId, {String? resolution}) {
    final alert = _activeAlerts.firstWhere(
      (a) => a.id == alertId,
 orElse: () => throw Exception('Alert not found'),
    );

    alert.status = AlertStatus.resolved;
    alert.resolvedAt = DateTime.now();
    alert.resolution = resolution;

 AppConfig.logger.i(' Alerte résolue: ${alert.title}');
  }

 /// Obtient les statistiques d'alertes
  AlertStats getStats() {
    final now = DateTime.now();
    final last24h = now.subtract(const Duration(hours: 24));

    final recentAlerts = _activeAlerts.where(
      (a) => a.createdAt.isAfter(last24h),
    ).toList();

    return AlertStats(
      totalAlerts: _activeAlerts.length,
      activeAlerts: _activeAlerts.where((a) => a.status == AlertStatus.active).length,
      resolvedAlerts: _activeAlerts.where((a) => a.status == AlertStatus.resolved).length,
      criticalAlerts: _activeAlerts.where((a) => a.priority == ErrorPriority.critical).length,
      alertsLast24h: recentAlerts.length,
    );
  }
}

/// Priorité d'une erreur
enum ErrorPriority {
  low,
  medium,
  high,
  critical,
}

/// Statut d'une alerte
enum AlertStatus {
  active,
  investigating,
  resolved,
  ignored,
}

/// Alerte d'erreur
class ErrorAlert {
  final String id;
  final String title;
  final String description;
  final ErrorSeverity severity;
  final ErrorPriority priority;
  final String? errorType;
  final Map<String, dynamic> context;
  final List<String> affectedVersions;
  final List<String> affectedUsers;
  final DateTime createdAt;
  AlertStatus status;
  DateTime? resolvedAt;
  String? resolution;

  ErrorAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.priority,
    this.errorType,
    required this.context,
    required this.affectedVersions,
    required this.affectedUsers,
    required this.createdAt,
    this.status = AlertStatus.active,
    this.resolvedAt,
    this.resolution,
  });
}

/// Statistiques d'alertes
class AlertStats {
  final int totalAlerts;
  final int activeAlerts;
  final int resolvedAlerts;
  final int criticalAlerts;
  final int alertsLast24h;

  AlertStats({
    required this.totalAlerts,
    required this.activeAlerts,
    required this.resolvedAlerts,
    required this.criticalAlerts,
    required this.alertsLast24h,
  });
}

