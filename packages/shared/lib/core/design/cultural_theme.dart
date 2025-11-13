/// Système de design adapté par culture/région
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../localization/app_locale.dart';

class CulturalTheme {
  final AppLocale locale;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final String fontFamily;

  CulturalTheme({
    required this.locale,
    required this.colorScheme,
    required this.textTheme,
    required this.fontFamily,
  });

  /// Obtient le thème culturel pour une locale
  static CulturalTheme getThemeForLocale(AppLocale locale) {
    switch (locale.countryCode) {
 case 'CA':
        return _canadianTheme(locale);
 case 'US':
        return _americanTheme(locale);
 case 'FR':
        return _frenchTheme(locale);
 case 'ES':
        return _spanishTheme(locale);
 case 'MX':
        return _mexicanTheme(locale);
 case 'BR':
        return _brazilianTheme(locale);
 case 'JP':
        return _japaneseTheme(locale);
 case 'CN':
        return _chineseTheme(locale);
 case 'KR':
        return _koreanTheme(locale);
 case 'IN':
        return _indianTheme(locale);
      default:
        return _defaultTheme(locale);
    }
  }

  static CulturalTheme _canadianTheme(AppLocale locale) {
    return CulturalTheme(
      locale: locale,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2D572C), // Vert forêt québécois
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
 fontFamily: 'PlusJakartaSans',
    );
  }

  static CulturalTheme _americanTheme(AppLocale locale) {
    return CulturalTheme(
      locale: locale,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E88E5), // Bleu américain
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(),
 fontFamily: 'Inter',
    );
  }

  static CulturalTheme _frenchTheme(AppLocale locale) {
    return CulturalTheme(
      locale: locale,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0055A4), // Bleu français
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.robotoTextTheme(),
 fontFamily: 'Roboto',
    );
  }

  static CulturalTheme _spanishTheme(AppLocale locale) {
    return CulturalTheme(
      locale: locale,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFC60B1E), // Rouge espagnol
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.robotoTextTheme(),
 fontFamily: 'Roboto',
    );
  }

  static CulturalTheme _mexicanTheme(AppLocale locale) {
    return CulturalTheme(
      locale: locale,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF006847), // Vert mexicain
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.robotoTextTheme(),
 fontFamily: 'Roboto',
    );
  }

  static CulturalTheme _brazilianTheme(AppLocale locale) {
    return CulturalTheme(
      locale: locale,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF009739), // Vert brésilien
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.robotoTextTheme(),
 fontFamily: 'Roboto',
    );
  }

  static CulturalTheme _japaneseTheme(AppLocale locale) {
    return CulturalTheme(
      locale: locale,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFBC002D), // Rouge japonais
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.notoSansJpTextTheme(),
 fontFamily: 'NotoSansJP',
    );
  }

  static CulturalTheme _chineseTheme(AppLocale locale) {
    return CulturalTheme(
      locale: locale,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFDE2910), // Rouge chinois
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.notoSansScTextTheme(),
 fontFamily: 'NotoSansSC',
    );
  }

  static CulturalTheme _koreanTheme(AppLocale locale) {
    return CulturalTheme(
      locale: locale,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFCE1126), // Rouge coréen
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.notoSansKrTextTheme(),
 fontFamily: 'NotoSansKR',
    );
  }

  static CulturalTheme _indianTheme(AppLocale locale) {
    return CulturalTheme(
      locale: locale,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF9933), // Orange indien
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.notoSansTextTheme(),
 fontFamily: 'NotoSans',
    );
  }

  static CulturalTheme _defaultTheme(AppLocale locale) {
    return CulturalTheme(
      locale: locale,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.robotoTextTheme(),
 fontFamily: 'Roboto',
    );
  }

  /// Crée un ThemeData Flutter à partir du thème culturel
  ThemeData toThemeData({bool isDark = false}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: isDark ? colorScheme.dark() : colorScheme,
      textTheme: textTheme,
      fontFamily: fontFamily,
    );
  }
}


