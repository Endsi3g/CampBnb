/// Point d'entrée principal de l'application mobile
/// Initialise le monitoring d'erreurs, Gemini et configure l'application
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:campbnb_shared/core/config/app_config.dart';
import 'package:campbnb_shared/core/config/gemini_config.dart';
import 'package:campbnb_shared/core/config/mapbox_config.dart';
import 'package:campbnb_shared/core/services/gemini_service.dart';
import 'package:campbnb_shared/core/monitoring/gemini_monitoring.dart' show GeminiMonitoring, MonitoringEventType;
import 'package:campbnb_shared/core/monitoring/error_monitoring_service.dart';
import 'package:campbnb_shared/core/localization/app_localizations.dart';
import 'package:campbnb_shared/core/localization/app_localizations_delegate.dart';
import 'package:campbnb_shared/core/localization/locale_provider.dart';
import 'package:campbnb_shared/core/localization/timezone_service.dart';
import 'package:campbnb_shared/core/localization/currency_exchange_service.dart';
import 'package:campbnb_shared/core/cdn/cdn_config.dart';
import 'package:campbnb_shared/core/design/cultural_theme.dart';
import 'package:campbnb_shared/core/localization/app_locale.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campbnb_shared/core/routing/app_router.dart';
import 'package:campbnb_shared/shared/services/supabase_service.dart';

void main() async {
  // Initialiser les bindings Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('WARNING: Fichier .env non trouvé. Assurez-vous de le créer.');
  }

  // Démarrer l'application avec Sentry
  final sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';
  
  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.environment = AppConfig.isProduction ? 'production' : 'development';
        options.tracesSampleRate = AppConfig.isProduction ? 0.1 : 1.0;
        options.profilesSampleRate = AppConfig.isProduction ? 0.1 : 1.0;
      },
      appRunner: () async {
        await _initializeApp();
      },
    );
  } else {
    // Si Sentry n'est pas configuré, démarrer l'app normalement
    await _initializeApp();
  }
}

/// Initialise l'application après la configuration de Sentry
Future<void> _initializeApp() async {
  // Initialiser Supabase en premier (avant ErrorMonitoringService)
  try {
    // Supporte SUPABASE_KEY ou SUPABASE_ANON_KEY
    final supabaseKey = dotenv.env['SUPABASE_KEY'] ?? 
                       dotenv.env['SUPABASE_ANON_KEY'] ?? 
                       '';
    
    if (supabaseKey.isEmpty) {
      print('⚠️  ATTENTION: SUPABASE_KEY ou SUPABASE_ANON_KEY non trouvée dans .env.');
      print('   Pour mobile/desktop, utilisez la clé publishable au lieu de anon key.');
      print('   Vous pouvez la trouver dans Supabase Dashboard > Settings > API');
      print('   Ajoutez SUPABASE_KEY=votre_cle dans le fichier .env');
    }
    
    await Supabase.initialize(
      url: 'https://kniaisdkzeflauawmyka.supabase.co',
      anonKey: supabaseKey.isNotEmpty 
          ? supabaseKey 
          : '<prefer publishable key instead of anon key for mobile and desktop apps>',
      debug: AppConfig.isDevelopment,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    
    // Initialiser le service Supabase (récupère l'instance déjà créée)
    await SupabaseService.initialize();
    
    print('✅ Supabase initialisé avec succès');
  } catch (e, stackTrace) {
    print('❌ ERREUR: Échec de l\'initialisation Supabase: $e');
    print('   Stack trace: $stackTrace');
    // L'application peut continuer même si Supabase échoue
  }

  // Initialiser le monitoring d'erreurs (après Supabase)
  final sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';
  await ErrorMonitoringService.initialize(
    sentryDsn: sentryDsn,
    enableSentry: sentryDsn.isNotEmpty,
    enableTalker: AppConfig.isDevelopment,
  );
  
  // Maintenant on peut capturer l'erreur Supabase si elle s'est produite
  // (mais on ne le fait pas car c'est déjà géré)

  // Configurer les handlers d'erreurs Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    // Envoyer à Sentry
    ErrorMonitoringService().captureException(
      details.exception,
      stackTrace: details.stack,
      context: {
        'library': details.library,
        'informationCollector': details.informationCollector?.call().toString(),
      },
    );

    // Logger localement
    FlutterError.presentError(details);
  };

  // Configurer les handlers d'erreurs Dart (non-Flutter)
  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorMonitoringService().captureException(
      error,
      stackTrace: stack,
      severity: ErrorSeverity.fatal,
    );

    return true;
  };

  // Initialiser les services de localisation
  try {
    await TimezoneService.initialize();
  } catch (e) {
    ErrorMonitoringService().captureException(
      e,
      context: {'component': 'timezone_initialization'},
    );
  }

  // Initialiser le service de conversion de devises
  try {
    await CurrencyExchangeService().initialize();
  } catch (e) {
    ErrorMonitoringService().captureException(
      e,
      context: {'component': 'currency_exchange_initialization'},
    );
  }

  // Initialiser et valider la configuration CDN
  try {
    await CDNConfig.initialize();
  } catch (e) {
    ErrorMonitoringService().captureException(
      e,
      context: {'component': 'cdn_config_initialization'},
    );
  }

  // Initialiser Gemini
  try {
    await GeminiConfig.initialize();
    if (GeminiConfig.isValid) {
      await GeminiService().initialize();
      GeminiMonitoring().logEvent(
        type: MonitoringEventType.success,
        message: 'Application mobile démarrée avec succès',
      );
      
      // Ajouter un breadcrumb pour Sentry
      ErrorMonitoringService().addBreadcrumb(
        message: 'Gemini initialisé avec succès',
        category: 'initialization',
      );
    }
  } catch (e, stackTrace) {
    GeminiMonitoring().logEvent(
      type: MonitoringEventType.error,
      message: 'Erreur lors de l\'initialisation de Gemini',
      error: e,
    );
    
    // Capturer l'erreur dans Sentry
    await ErrorMonitoringService().captureException(
      e,
      stackTrace: stackTrace,
      context: {
        'component': 'gemini_initialization',
      },
    );
  }

  // Initialiser Mapbox
  try {
    await MapboxConfig.initialize();
    if (MapboxConfig.isValid) {
      ErrorMonitoringService().addBreadcrumb(
        message: 'Mapbox initialisé avec succès',
        category: 'initialization',
      );
    }
  } catch (e, stackTrace) {
    await ErrorMonitoringService().captureException(
      e,
      stackTrace: stackTrace,
      context: {
        'component': 'mapbox_initialization',
      },
    );
  }

  // Démarrer l'application
  runApp(
    const ProviderScope(
      child: CampbnbMobileApp(),
    ),
  );
}

class CampbnbMobileApp extends ConsumerWidget {
  const CampbnbMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final appLocale = AppLocale.fromLocale(locale) ?? AppLocale.defaultLocale;
    final culturalTheme = CulturalTheme.getThemeForLocale(appLocale);

    return MaterialApp.router(
      title: 'Campbnb Québec',
      debugShowCheckedModeBanner: false,
      
      // Localisation
      locale: locale,
      supportedLocales: AppLocale.locales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Thème culturel (adapté pour mobile)
      theme: culturalTheme.toThemeData(isDark: false),
      darkTheme: culturalTheme.toThemeData(isDark: true),
      themeMode: ThemeMode.system,
      
      // Router
      routerConfig: ref.watch(routerProvider),
    );
  }
}

