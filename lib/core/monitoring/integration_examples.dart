/// Exemples d'intégration des outils de monitoring
/// Ce fichier montre comment intégrer Sentry, Talker, etc.
/// avec le système de monitoring Gemini existant
/// Note: Campbnb utilise uniquement Supabase (pas Firebase)

// Exemple 1: Intégration Sentry avec GeminiMonitoring
/*
import 'package:sentry_flutter/sentry_flutter.dart';
import 'gemini_monitoring.dart';

class GeminiMonitoringWithSentry extends GeminiMonitoring {
  @override
  void logEvent({
    required MonitoringEventType type,
    required String message,
    Map<String, dynamic>? metadata,
    Object? error,
  }) {
    // Appeler la méthode parente
    super.logEvent(
      type: type,
      message: message,
      metadata: metadata,
      error: error,
    );

    // Envoyer à Sentry pour les erreurs critiques
    if (type == MonitoringEventType.error && error != null) {
      Sentry.captureException(
        error is Exception ? error : Exception(error.toString()),
        stackTrace: StackTrace.current,
        hint: Hint.withMap(metadata ?? {}),
      );
    }

    // Envoyer les warnings importants
    if (type == MonitoringEventType.warning) {
      Sentry.captureMessage(
        message,
        level: SentryLevel.warning,
        hint: Hint.withMap(metadata ?? {}),
      );
    }
  }

  @override
  void logApiError({
    required String error,
    required GeminiRequestType requestType,
    Object? exception,
  }) {
    super.logApiError(
      error: error,
      requestType: requestType,
      exception: exception,
    );

    // Envoyer à Sentry avec contexte
    Sentry.captureException(
      exception is Exception ? exception : Exception(error),
      stackTrace: StackTrace.current,
      hint: Hint.withMap({
 'requestType': requestType.name,
 'error': error,
      }),
    );
  }
}
*/

// Exemple 2: Intégration Supabase avec GeminiMonitoring
/*
// Note: Supabase est déjà intégré dans le projet
// Pour le monitoring backend, utilisez le Supabase Dashboard
// Pour les erreurs côté client, utilisez Sentry (voir Exemple 1)
*/

// Exemple 3: Intégration Talker pour le développement
/*
import 'package:talker_flutter/talker_flutter.dart';
import 'gemini_monitoring.dart';

class GeminiMonitoringWithTalker extends GeminiMonitoring {
  late final Talker _talker;

  GeminiMonitoringWithTalker() {
    _talker = TalkerFlutter.init();
  }

  @override
  void logEvent({
    required MonitoringEventType type,
    required String message,
    Map<String, dynamic>? metadata,
    Object? error,
  }) {
    super.logEvent(
      type: type,
      message: message,
      metadata: metadata,
      error: error,
    );

    // Logger avec Talker pour visualisation en dev
    switch (type) {
      case MonitoringEventType.error:
        _talker.error(message, error: error);
        break;
      case MonitoringEventType.warning:
        _talker.warning(message);
        break;
      case MonitoringEventType.info:
        _talker.info(message);
        break;
      case MonitoringEventType.success:
        _talker.good(message);
        break;
    }

    if (metadata != null) {
 _talker.debug('Metadata: $metadata');
    }
  }
}
*/

// Exemple 4: Intégration Catcher pour la capture d'erreurs
/*
import 'package:catcher/catcher.dart';
import 'gemini_monitoring.dart';

void setupCatcher() {
  final debugOptions = CatcherOptions(
    DialogReportMode(),
    [
      ConsoleHandler(),
      // Intégrer avec Sentry
      SentryHandler(
        SentryClient(
 SentryOptions(dsn: 'YOUR_SENTRY_DSN'),
        ),
      ),
    ],
    customParameters: {
 'app': 'Campbnb Québec',
 'version': '1.0.0',
    },
  );

  final releaseOptions = CatcherOptions(
    SilentReportMode(),
    [
 EmailManualHandler(['support@campbnb.quebec']),
      SentryHandler(
        SentryClient(
 SentryOptions(dsn: 'YOUR_SENTRY_DSN'),
        ),
      ),
    ],
  );

  Catcher(
    rootWidget: const MyApp(),
    debugConfig: debugOptions,
    releaseConfig: releaseOptions,
  );
}

// Intégrer avec GeminiMonitoring
class GeminiMonitoringWithCatcher extends GeminiMonitoring {
  @override
  void logEvent({
    required MonitoringEventType type,
    required String message,
    Map<String, dynamic>? metadata,
    Object? error,
  }) {
    super.logEvent(
      type: type,
      message: message,
      metadata: metadata,
      error: error,
    );

    // Utiliser Catcher pour les erreurs non gérées
    if (type == MonitoringEventType.error && error != null) {
      Catcher.sendTestException(
        error is Exception ? error : Exception(error.toString()),
        StackTrace.current,
      );
    }
  }
}
*/

// Exemple 5: Configuration complète dans main.dart (Supabase uniquement)
/*
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/monitoring/gemini_monitoring.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Supabase
  await Supabase.initialize(
 url: 'YOUR_SUPABASE_URL',
 anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Initialiser Sentry
  await SentryFlutter.init(
    (options) {
 options.dsn = 'YOUR_SENTRY_DSN';
      options.tracesSampleRate = 1.0;
 options.environment = 'production';
      options.beforeSend = (event, {hint}) {
        // Filtrer les erreurs si nécessaire
        return event;
      };
    },
    appRunner: () {
      // Initialiser le monitoring Gemini
      GeminiMonitoring().logEvent(
        type: MonitoringEventType.info,
 message: 'Application démarrée',
      );

      runApp(const MyApp());
    },
  );
}
*/

// Exemple 6: Wrapper pour utiliser plusieurs outils de monitoring (Supabase uniquement)
/*
class MultiMonitoringService {
  final GeminiMonitoring _geminiMonitoring = GeminiMonitoring();
  final bool _useSentry;
  final bool _useTalker;

  MultiMonitoringService({
    this._useSentry = false,
    this._useTalker = false,
  });

  void logError({
    required String message,
    required Object error,
    Map<String, dynamic>? metadata,
  }) {
    // Toujours utiliser GeminiMonitoring
    _geminiMonitoring.logEvent(
      type: MonitoringEventType.error,
      message: message,
      metadata: metadata,
      error: error,
    );

    // Envoyer à Sentry si activé
    if (_useSentry) {
 // import 'package:sentry_flutter/sentry_flutter.dart';
      // Sentry.captureException(...);
    }

    // Logger avec Talker si activé (dev seulement)
    if (_useTalker && kDebugMode) {
 // import 'package:talker_flutter/talker_flutter.dart';
      // _talker.error(...);
    }

    // Note: Supabase monitoring se fait via le Dashboard Supabase
 // Pas besoin d'intégration côté client pour le monitoring backend
  }
}
*/
