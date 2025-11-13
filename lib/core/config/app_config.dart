import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class AppConfig {
  AppConfig._();

  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Supabase
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://kniaisdkzeflauawmyka.supabase.co';

  // Supporte SUPABASE_KEY ou SUPABASE_ANON_KEY pour flexibilité
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_KEY'] ?? dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Mapbox
  static String get mapboxAccessToken =>
      dotenv.env['MAPBOX_ACCESS_TOKEN'] ??
      'pk.eyJ1IjoiY2FtcGJuYiIsImEiOiJjbWh3N21wZjAwNDhuMm9weXFwMmt1c2VqIn0.r6bKsNWgKmIb0FzWOcZh8g';

  // Gemini
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // Stripe
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  // Environment
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  static bool get isDevelopment => !isProduction;

  // Validation
  static bool validateConfig() {
    final errors = <String>[];

    if (supabaseUrl.isEmpty) {
      errors.add('SUPABASE_URL is missing');
    }
    if (supabaseAnonKey.isEmpty) {
      errors.add('SUPABASE_ANON_KEY is missing');
    }
    if (mapboxAccessToken.isEmpty) {
      errors.add('MAPBOX_ACCESS_TOKEN is missing');
    }
    if (geminiApiKey.isEmpty) {
      errors.add('GEMINI_API_KEY is missing');
    }

    if (errors.isNotEmpty) {
      logger.e('Configuration errors: ${errors.join(', ')}');
      return false;
    }

    return true;
  }
}
