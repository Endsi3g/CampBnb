// Theme configuration for Campbnb Québec
// This file contains all theme definitions for light and dark mode

import 'package:flutter/material.dart';

class AppColors {
  // Primary - Vert forêt québécois
  static const Color primary = Color(0xFF2D572C);
  static const Color primaryLight = Color(0xFF4A7A4A);
  static const Color primaryDark = Color(0xFF1A3A1A);

  // Secondary - Bleu lac
  static const Color secondary = Color(0xFF3B8EA5);
  static const Color secondaryLight = Color(0xFF5BA8C0);
  static const Color secondaryDark = Color(0xFF2A6B7F);

  // Accent - Beige bois
  static const Color accent = Color(0xFFF5E5D5);
  static const Color accentLight = Color(0xFFFFF5EB);
  static const Color accentDark = Color(0xFFE8D4C0);

  // Neutral - Beige clair
  static const Color neutral = Color(0xFFF5F5DC);
  static const Color neutralLight = Color(0xFFFFFEF8);
  static const Color neutralDark = Color(0xFFE8E8D0);

  // Backgrounds - Light Mode
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF6F8F6);

  // Backgrounds - Dark Mode
  static const Color backgroundDark = Color(0xFF152210);
  static const Color surfaceDark = Color(0xFF2A3F29);
  static const Color surfaceElevatedDark = Color(0xFF3A4F38);

  // Text - Light Mode
  static const Color textPrimaryLight = Color(0xFF333333);
  static const Color textSecondaryLight = Color(0xFF5C5C5C);
  static const Color textTertiaryLight = Color(0xFF9E9E9E);
  static const Color textInverseLight = Color(0xFFFFFFFF);

  // Text - Dark Mode
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textTertiaryDark = Color(0xFF757575);
  static const Color textInverseDark = Color(0xFF152210);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // Dark Mode Adaptations
  static const Color primaryDarkMode = Color(0xFF4A7A4A);
  static const Color secondaryDarkMode = Color(0xFF5BA8C0);
  static const Color successDarkMode = Color(0xFF66BB6A);
  static const Color warningDarkMode = Color(0xFFFFB74D);
  static const Color errorDarkMode = Color(0xFFEF5350);
  static const Color infoDarkMode = Color(0xFF64B5F6);
}

class AppTextStyles {
  // Display - Titres principaux
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
  );

  // Headline - Sous-titres
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.4,
  );

  // Body - Texte courant
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.5,
  );

  // Label - Labels et boutons
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}

class AppShadows {
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardColor: AppColors.surfaceLight,
      fontFamily: 'PlusJakartaSans',
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        background: AppColors.backgroundLight,
        error: AppColors.error,
        onPrimary: AppColors.textInverseLight,
        onSecondary: AppColors.textInverseLight,
        onSurface: AppColors.textPrimaryLight,
        onBackground: AppColors.textPrimaryLight,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        displaySmall: AppTextStyles.displaySmall.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textPrimaryLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 48),
          padding: EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          elevation: 0,
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          minimumSize: Size(double.infinity, 48),
          padding: EdgeInsets.symmetric(horizontal: 24),
          side: BorderSide(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        color: AppColors.surfaceLight,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDarkMode,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDark,
      fontFamily: 'PlusJakartaSans',
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDarkMode,
        secondary: AppColors.secondaryDarkMode,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        error: AppColors.errorDarkMode,
        onPrimary: AppColors.textInverseDark,
        onSecondary: AppColors.textInverseDark,
        onSurface: AppColors.textPrimaryDark,
        onBackground: AppColors.textPrimaryDark,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displaySmall: AppTextStyles.displaySmall.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textPrimaryDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkMode,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 48),
          padding: EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          elevation: 0,
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primaryDarkMode,
          minimumSize: Size(double.infinity, 48),
          padding: EdgeInsets.symmetric(horizontal: 24),
          side: BorderSide(
            color: AppColors.primaryDarkMode.withOpacity(0.5),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide(
            color: AppColors.textPrimaryDark.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide(
            color: AppColors.textPrimaryDark.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide(color: AppColors.primaryDarkMode, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide(color: AppColors.errorDarkMode),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        color: AppColors.surfaceDark,
      ),
    );
  }
}


