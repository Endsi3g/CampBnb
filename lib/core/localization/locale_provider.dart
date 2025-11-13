/// Provider Riverpod pour gérer la locale actuelle
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_locale.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(AppLocale.defaultLocale.locale) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code');
      final countryCode = prefs.getString('country_code');

      if (languageCode != null) {
        final locale = Locale(languageCode, countryCode);
        final appLocale = AppLocale.fromLocale(locale);
        if (appLocale != null) {
          state = appLocale.locale;
        }
      }
    } catch (e) {
      // Utiliser la locale par défaut en cas d'erreur
    }
  }

  Future<void> setLocale(Locale locale) async {
    final appLocale = AppLocale.fromLocale(locale);
    if (appLocale == null) return;

    state = appLocale.locale;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
      if (locale.countryCode != null) {
        await prefs.setString('country_code', locale.countryCode!);
      } else {
        await prefs.remove('country_code');
      }
    } catch (e) {
      // Erreur silencieuse
    }
  }

  AppLocale? get currentAppLocale => AppLocale.fromLocale(state);
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
