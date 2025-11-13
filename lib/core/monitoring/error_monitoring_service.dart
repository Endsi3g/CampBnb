/// Service centralisé de gestion des erreurs et monitoring
/// Intègre Sentry et Talker pour une surveillance complète
/// Compatible avec Supabase uniquement (pas de Firebase)
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/app_config.dart';
import '../../shared/models/user_model.dart';

/// Service de monitoring d'erreurs centralisé
class ErrorMonitoringService {
  static final ErrorMonitoringService _instance =
      ErrorMonitoringService._internal();
  factory ErrorMonitoringService() => _instance;
  ErrorMonitoringService._internal();

  static Talker? _talker;
  static bool _initialized = false;
  static UserModel? _currentUser;
  static String? _appVersion;
  static String? _buildNumber;

  /// Initialise le service de monitoring
  static Future<void> initialize({
    required String sentryDsn,
    bool enableSentry = true,
    bool enableTalker = true,
  }) async {
    if (_initialized) return;

    try {
      // Récupérer les informations de version
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;

      // Initialiser Sentry
      if (enableSentry && sentryDsn.isNotEmpty) {
        await SentryFlutter.init(
          (options) {
            options.dsn = sentryDsn;
            options.environment = AppConfig.isProduction
                ? 'production'
                : 'development';
            options.release =
                '${packageInfo.packageName}@${packageInfo.version}+${packageInfo.buildNumber}';
            options.tracesSampleRate = AppConfig.isProduction ? 0.1 : 1.0;
            options.profilesSampleRate = AppConfig.isProduction ? 0.1 : 1.0;

            // Configuration des filtres
            options.beforeSend = (event, {hint}) {
              // Filtrer les données sensibles (RGPD)
              return _sanitizeEvent(event);
            };

            // Tags par défaut
            options.tags = {
              'platform': Platform.operatingSystem,
              'platform_version': Platform.operatingSystemVersion,
              'app_version': _appVersion ?? 'unknown',
              'build_number': _buildNumber ?? 'unknown',
            };
          },
          appRunner: () {}, // Sera remplacé dans main.dart
        );
      }

      // Initialiser Talker (pour les logs locaux)
      if (enableTalker) {
        _talker = TalkerFlutter.init();
      }

      _initialized = true;
      AppConfig.logger.i(' ErrorMonitoringService initialisé avec succès');
    } catch (e, stackTrace) {
      AppConfig.logger.e(
        ' Erreur lors de l\'initialisation du monitoring',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Capture une exception
  Future<String?> captureException(
    Object exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    ErrorSeverity severity = ErrorSeverity.error,
    String? userId,
    String? userEmail,
  }) async {
    try {
      // Context enrichi
      final enrichedContext = <String, dynamic>{
        ...?context,
        'app_version': _appVersion,
        'build_number': _buildNumber,
        'platform': Platform.operatingSystem,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Ajouter les informations utilisateur si disponibles
      if (userId != null || userEmail != null || _currentUser != null) {
        final user = _currentUser;
        enrichedContext['user'] = {
          'id': userId ?? user?.id,
          'email': userEmail ?? user?.email,
          'is_host': user?.isHost ?? false,
        };
      }

      // Envoyer à Sentry
      final sentryId = await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: Hint.withMap(enrichedContext),
      );

      // Logger localement avec Talker
      _talker?.handle(exception, stackTrace ?? StackTrace.current);

      // Logger avec le logger standard
      AppConfig.logger.e(
        'Exception capturée: ${exception.toString()}',
        error: exception,
        stackTrace: stackTrace,
      );

      return sentryId.toString();
    } catch (e) {
      AppConfig.logger.e('Erreur lors de la capture d\'exception', error: e);
      return null;
    }
  }

  /// Capture un message d'erreur
  Future<String?> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.error,
    Map<String, dynamic>? context,
  }) async {
    try {
      final enrichedContext = <String, dynamic>{
        ...?context,
        'app_version': _appVersion,
        'build_number': _buildNumber,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final sentryId = await Sentry.captureMessage(
        message,
        level: level,
        hint: Hint.withMap(enrichedContext),
      );

      _talker?.error(message);
      AppConfig.logger.e(message);

      return sentryId.toString();
    } catch (e) {
      AppConfig.logger.e('Erreur lors de la capture de message', error: e);
      return null;
    }
  }

  /// Capture une erreur réseau
  Future<String?> captureNetworkError({
    required String url,
    required int statusCode,
    String? method,
    Map<String, dynamic>? requestData,
    String? responseBody,
    Object? exception,
    StackTrace? stackTrace,
  }) async {
    return await captureException(
      exception ?? 'Network Error: $statusCode',
      stackTrace: stackTrace,
      context: {
        'type': 'network_error',
        'url': url,
        'method': method ?? 'GET',
        'status_code': statusCode,
        'request_data': requestData,
        'response_body': responseBody?.substring(0, 500), // Limiter la taille
      },
      severity: _getSeverityFromStatusCode(statusCode),
    );
  }

  /// Capture une erreur de performance
  Future<void> capturePerformanceIssue({
    required String operation,
    required Duration duration,
    String? context,
  }) async {
    if (duration.inMilliseconds > 3000) {
      await captureMessage(
        'Performance issue: $operation took ${duration.inMilliseconds}ms',
        level: SentryLevel.warning,
        context: {
          'type': 'performance',
          'operation': operation,
          'duration_ms': duration.inMilliseconds,
          'context': context,
        },
      );
    }
  }

  /// Définit l'utilisateur actuel pour le contexte
  void setUser(UserModel? user) {
    _currentUser = user;
    if (user != null) {
      Sentry.configureScope((scope) {
        scope.setUser(
          SentryUser(
            id: user.id,
            email: user.email,
            username: user.fullName,
            data: {
              'is_host': user.isHost,
              'created_at': user.createdAt?.toIso8601String(),
            },
          ),
        );
      });
    } else {
      Sentry.configureScope((scope) {
        scope.setUser(null);
      });
    }
  }

  /// Ajoute un tag personnalisé
  void addTag(String key, String value) {
    Sentry.configureScope((scope) {
      scope.setTag(key, value);
    });
  }

  /// Ajoute du contexte personnalisé
  void addContext(String key, Map<String, dynamic> context) {
    Sentry.configureScope((scope) {
      scope.setContexts(key, context);
    });
  }

  /// Crée un breadcrumb (trace d'action)
  void addBreadcrumb({
    required String message,
    String? category,
    SentryLevel level = SentryLevel.info,
    Map<String, String>? data,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category ?? 'navigation',
        level: level,
        data: data,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Démarre une transaction de performance
  ISentryTransaction startTransaction(
    String name,
    String operation, {
    Map<String, dynamic>? data,
  }) {
    return Sentry.startTransaction(name, operation, bindToScope: true);
  }

  /// Obtient les statistiques d'erreurs
  Future<ErrorStats> getErrorStats() async {
    // Cette méthode pourrait interroger l'API Sentry ou une base locale
    return ErrorStats(
      totalErrors: 0, // À implémenter avec l'API Sentry
      errorsLast24h: 0,
      crashesLast24h: 0,
      networkErrors: 0,
    );
  }

  /// Nettoie les données sensibles pour la conformité RGPD
  static SentryEvent? _sanitizeEvent(SentryEvent event) {
    // Vérifier le consentement RGPD avant d'envoyer
    // (à implémenter avec GDPRService)

    // Supprimer les données sensibles
    final sanitizedEvent = event.copyWith(
      request: event.request?.copyWith(
        data: _sanitizeData(event.request?.data),
        headers: _sanitizeHeaders(event.request?.headers),
      ),
      contexts: event.contexts.copyWith(
        device: event.contexts.device?.copyWith(
          name: null, // Ne pas envoyer le nom du device
        ),
      ),
      user: event.user?.copyWith(
        email: _anonymizeEmail(event.user?.email),
        ipAddress: null, // Ne pas envoyer l'IP
      ),
    );

    return sanitizedEvent;
  }

  /// Anonymise l'email pour la conformité RGPD
  static String? _anonymizeEmail(String? email) {
    if (email == null) return null;
    // Remplacer par un hash ou supprimer complètement
    // Exemple: user@example.com -> user_***@example.com
    final parts = email.split('@');
    if (parts.length != 2) return null;
    return '${parts[0].substring(0, 2)}***@${parts[1]}';
  }

  static dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      final sanitized = <String, dynamic>{};
      data.forEach((key, value) {
        // Ne pas envoyer les mots de passe, tokens, etc.
        if (_isSensitiveKey(key)) {
          sanitized[key] = '[REDACTED]';
        } else if (value is Map) {
          sanitized[key] = _sanitizeData(value);
        } else {
          sanitized[key] = value;
        }
      });
      return sanitized;
    }
    return data;
  }

  static Map<String, String>? _sanitizeHeaders(Map<String, String>? headers) {
    if (headers == null) return null;
    final sanitized = <String, String>{};
    headers.forEach((key, value) {
      if (_isSensitiveKey(key)) {
        sanitized[key] = '[REDACTED]';
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  static bool _isSensitiveKey(String key) {
    final sensitiveKeys = [
      'password',
      'token',
      'secret',
      'key',
      'authorization',
      'cookie',
      'credit_card',
      'cvv',
      'ssn',
      'api_key',
    ];
    return sensitiveKeys.any(
      (sensitive) => key.toLowerCase().contains(sensitive),
    );
  }

  static ErrorSeverity _getSeverityFromStatusCode(int statusCode) {
    if (statusCode >= 500) return ErrorSeverity.fatal;
    if (statusCode >= 400) return ErrorSeverity.error;
    return ErrorSeverity.warning;
  }
}

/// Niveaux de sévérité d'erreur
enum ErrorSeverity { info, warning, error, fatal }

/// Statistiques d'erreurs
class ErrorStats {
  final int totalErrors;
  final int errorsLast24h;
  final int crashesLast24h;
  final int networkErrors;

  ErrorStats({
    required this.totalErrors,
    required this.errorsLast24h,
    required this.crashesLast24h,
    required this.networkErrors,
  });
}
