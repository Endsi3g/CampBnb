/// Delegate pour charger les traductions
import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'app_locale.dart';
import 'translation_loader.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocale.supportedLocales.any(
      (appLocale) =>
          appLocale.languageCode == locale.languageCode &&
          (appLocale.countryCode == locale.countryCode ||
              appLocale.countryCode == null),
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final appLocale = AppLocale.fromLocale(locale) ?? AppLocale.defaultLocale;
    final translations = await TranslationLoader.loadTranslations(
      appLocale.languageCode,
      appLocale.countryCode,
    );
    return AppLocalizations(appLocale.locale, translations);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}


