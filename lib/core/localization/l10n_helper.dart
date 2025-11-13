/// Helper pour faciliter l'utilisation des traductions
import 'package:flutter/material.dart';
import 'app_localizations.dart';

extension LocalizationExtension on BuildContext {
  /// Obtient les localisations
  AppLocalizations? get l10n => AppLocalizations.of(this);

  /// Traduit une clé
  String t(String key, [Map<String, String>? params]) {
    return l10n?.translate(key, params) ?? key;
  }

  /// Formate une date
  String formatDate(DateTime date, {String? format}) {
    return l10n?.formatDate(date, format: format) ?? date.toString();
  }

  /// Formate une monnaie
  String formatCurrency(double amount, {String? currencyCode}) {
    return l10n?.formatCurrency(amount, currencyCode: currencyCode) ??
        amount.toStringAsFixed(2);
  }

  /// Formate une distance
  String formatDistance(double distanceInKm, {bool? useImperial}) {
    final locale = Localizations.localeOf(this);
    final shouldUseImperial =
        useImperial ??
        (locale.countryCode == 'US' ||
            locale.countryCode == 'LR' ||
            locale.countryCode == 'MM');
    return l10n?.formatDistance(distanceInKm, useImperial: shouldUseImperial) ??
        '${distanceInKm.toStringAsFixed(1)} km';
  }

  /// Formate une température
  String formatTemperature(double celsius, {bool? useFahrenheit}) {
    final locale = Localizations.localeOf(this);
    final shouldUseFahrenheit =
        useFahrenheit ??
        (locale.countryCode == 'US' ||
            locale.countryCode == 'BS' ||
            locale.countryCode == 'BZ' ||
            locale.countryCode == 'KY' ||
            locale.countryCode == 'PW');
    return l10n?.formatTemperature(
          celsius,
          useFahrenheit: shouldUseFahrenheit,
        ) ??
        '${celsius.toStringAsFixed(0)}°C';
  }
}
