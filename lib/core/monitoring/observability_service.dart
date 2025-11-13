/// Service d'observabilité pour Supabase et Mapbox
/// Surveille les performances et la santé des services externes
/// Note: Utilise uniquement Supabase (pas Firebase)
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'error_monitoring_service.dart';
import '../config/app_config.dart';
import '../../shared/services/supabase_service.dart';
import '../../shared/services/mapbox_service.dart';

/// Service d'observabilité
class ObservabilityService {
  static final ObservabilityService _instance = ObservabilityService._internal();
  factory ObservabilityService() => _instance;
  ObservabilityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _healthCheckTimer;

 /// Initialise le service d'observabilité
  Future<void> initialize() async {
    // Surveiller la connectivité
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Vérification de santé périodique (toutes les 5 minutes)
    _healthCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performHealthCheck(),
    );

    // Vérification initiale
    await _performHealthCheck();
  }

  /// Gère les changements de connectivité
  Future<void> _onConnectivityChanged(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      await ErrorMonitoringService().captureMessage(
 'Connexion internet perdue',
        level: SentryLevel.warning,
        context: {
 'type': 'connectivity',
 'status': 'disconnected',
        },
      );
    } else {
      await ErrorMonitoringService().addBreadcrumb(
 message: 'Connexion internet rétablie',
 category: 'connectivity',
 data: {'type': result.toString()},
      );
    }
  }

  /// Effectue une vérification de santé
  Future<void> _performHealthCheck() async {
    final checks = <Future<HealthCheckResult>>[
      _checkSupabaseHealth(),
      _checkMapboxHealth(),
      _checkConnectivity(),
    ];

    final results = await Future.wait(checks);
    final failedChecks = results.where((r) => !r.isHealthy).toList();

    if (failedChecks.isNotEmpty) {
      await ErrorMonitoringService().captureMessage(
 '${failedChecks.length} service(s) en panne',
        level: SentryLevel.warning,
        context: {
 'type': 'health_check',
 'failed_services': failedChecks.map((r) => r.serviceName).toList(),
        },
      );
    }
  }

  /// Vérifie la santé de Supabase
  Future<HealthCheckResult> _checkSupabaseHealth() async {
    try {
      final stopwatch = Stopwatch()..start();
      
 // Test simple : vérifier l'authentification
      final client = SupabaseService.client;
      final response = await client.auth.getSession();
      
      stopwatch.stop();

      if (stopwatch.elapsedMilliseconds > 5000) {
        await ErrorMonitoringService().capturePerformanceIssue(
 operation: 'supabase_health_check',
          duration: stopwatch.elapsed,
 context: 'Supabase response time is high',
        );
      }

      return HealthCheckResult(
 serviceName: 'Supabase',
        isHealthy: true,
        responseTime: stopwatch.elapsed,
      );
    } catch (e, stackTrace) {
      await ErrorMonitoringService().captureException(
        e,
        stackTrace: stackTrace,
        context: {
 'type': 'health_check',
 'service': 'supabase',
        },
      );

      return HealthCheckResult(
 serviceName: 'Supabase',
        isHealthy: false,
        error: e.toString(),
      );
    }
  }

  /// Vérifie la santé de Mapbox
  Future<HealthCheckResult> _checkMapboxHealth() async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // Test simple : vérifier que le token est valide
      final token = AppConfig.mapboxAccessToken;
      if (token.isEmpty) {
        return HealthCheckResult(
 serviceName: 'Mapbox',
          isHealthy: false,
 error: 'Token not configured',
        );
      }

 // Vérifier la connectivité à l'API Mapbox
      // (test simplifié - en production, faire une vraie requête)
      stopwatch.stop();

      return HealthCheckResult(
 serviceName: 'Mapbox',
        isHealthy: true,
        responseTime: stopwatch.elapsed,
      );
    } catch (e, stackTrace) {
      await ErrorMonitoringService().captureException(
        e,
        stackTrace: stackTrace,
        context: {
 'type': 'health_check',
 'service': 'mapbox',
        },
      );

      return HealthCheckResult(
 serviceName: 'Mapbox',
        isHealthy: false,
        error: e.toString(),
      );
    }
  }

  /// Vérifie la connectivité
  Future<HealthCheckResult> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final isConnected = result != ConnectivityResult.none;

      return HealthCheckResult(
 serviceName: 'Connectivity',
        isHealthy: isConnected,
 metadata: {'type': result.toString()},
      );
    } catch (e) {
      return HealthCheckResult(
 serviceName: 'Connectivity',
        isHealthy: false,
        error: e.toString(),
      );
    }
  }

  /// Surveille une opération Supabase
  Future<T> monitorSupabaseOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final transaction = ErrorMonitoringService().startTransaction(
 'supabase_$operationName',
 'database',
    );

    try {
      final stopwatch = Stopwatch()..start();
      final result = await operation();
      stopwatch.stop();

      if (stopwatch.elapsedMilliseconds > 2000) {
        await ErrorMonitoringService().capturePerformanceIssue(
 operation: 'supabase_$operationName',
          duration: stopwatch.elapsed,
        );
      }

      await transaction.finish(status: const SentrySpanStatus.ok());
      return result;
    } catch (e, stackTrace) {
      await transaction.finish(status: const SentrySpanStatus.internalError());
      await ErrorMonitoringService().captureException(
        e,
        stackTrace: stackTrace,
        context: {
 'type': 'supabase_operation',
 'operation': operationName,
        },
      );
      rethrow;
    }
  }

  /// Surveille une opération Mapbox
  Future<T> monitorMapboxOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final transaction = ErrorMonitoringService().startTransaction(
 'mapbox_$operationName',
 'map_service',
    );

    try {
      final stopwatch = Stopwatch()..start();
      final result = await operation();
      stopwatch.stop();

      if (stopwatch.elapsedMilliseconds > 3000) {
        await ErrorMonitoringService().capturePerformanceIssue(
 operation: 'mapbox_$operationName',
          duration: stopwatch.elapsed,
        );
      }

      await transaction.finish(status: const SentrySpanStatus.ok());
      return result;
    } catch (e, stackTrace) {
      await transaction.finish(status: const SentrySpanStatus.internalError());
      await ErrorMonitoringService().captureException(
        e,
        stackTrace: stackTrace,
        context: {
 'type': 'mapbox_operation',
 'operation': operationName,
        },
      );
      rethrow;
    }
  }

  /// Nettoie les ressources
  void dispose() {
    _connectivitySubscription?.cancel();
    _healthCheckTimer?.cancel();
  }
}

/// Résultat d'une vérification de santé
class HealthCheckResult {
  final String serviceName;
  final bool isHealthy;
  final Duration? responseTime;
  final String? error;
  final Map<String, dynamic>? metadata;

  HealthCheckResult({
    required this.serviceName,
    required this.isHealthy,
    this.responseTime,
    this.error,
    this.metadata,
  });
}

