class AppConstants {
  AppConstants._();

  // API
 static const String supabaseUrlKey = 'SUPABASE_URL';
 static const String supabaseAnonKeyKey = 'SUPABASE_ANON_KEY';
 static const String googleMapsApiKeyKey = 'GOOGLE_MAPS_API_KEY';
 static const String geminiApiKeyKey = 'GEMINI_API_KEY';

  // Storage Keys
 static const String themeModeKey = 'theme_mode';
 static const String onboardingCompletedKey = 'onboarding_completed';
 static const String userTokenKey = 'user_token';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Images
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
 static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];

  // Dates
  static const int minBookingDays = 1;
  static const int maxBookingDays = 30;
  static const int maxAdvanceBookingDays = 365;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 2000;

  // Map
  static const double defaultMapZoom = 10.0;
  static const double minMapZoom = 5.0;
  static const double maxMapZoom = 18.0;

  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}

