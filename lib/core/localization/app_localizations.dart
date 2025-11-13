/// Service de localisation principal pour l'application
/// Gère les traductions, formats de dates, monnaies, etc.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_locale.dart';
import 'app_localizations_delegate.dart';

class AppLocalizations {
  final Locale locale;
  final Map<String, String> _localizedStrings;

  AppLocalizations(this.locale, this._localizedStrings);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String translate(String key, [Map<String, String>? params]) {
    String translation = _localizedStrings[key] ?? key;

    if (params != null) {
      params.forEach((key, value) {
        translation = translation.replaceAll('{{$key}}', value);
      });
    }

    return translation;
  }

  // Formatage des dates
  String formatDate(DateTime date, {String? format}) {
    final dateFormat = format != null
        ? DateFormat(format, locale.languageCode)
        : DateFormat.yMMMd(locale.languageCode);
    return dateFormat.format(date);
  }

  String formatTime(DateTime time, {String? format}) {
    final timeFormat = format != null
        ? DateFormat(format, locale.languageCode)
        : DateFormat.Hm(locale.languageCode);
    return timeFormat.format(time);
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMd().add_Hm().format(dateTime);
  }

  // Formatage des monnaies
  String formatCurrency(double amount, {String? currencyCode}) {
    final currency = currencyCode ?? _getCurrencyForLocale(locale);
    final formatter = NumberFormat.currency(
      locale: locale.toString(),
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Formatage des nombres
  String formatNumber(double number, {int? decimals}) {
    return NumberFormat.decimalPattern(locale.toString()).format(number);
  }

  // Formatage des distances
  String formatDistance(double distanceInKm, {bool useImperial = false}) {
    if (useImperial || _shouldUseImperial(locale)) {
      final miles = distanceInKm * 0.621371;
      return '${miles.toStringAsFixed(1)} mi';
    }
    return '${distanceInKm.toStringAsFixed(1)} km';
  }

  // Formatage des températures
  String formatTemperature(double celsius, {bool useFahrenheit = false}) {
    if (useFahrenheit || _shouldUseFahrenheit(locale)) {
      final fahrenheit = (celsius * 9 / 5) + 32;
      return '${fahrenheit.toStringAsFixed(0)}°F';
    }
    return '${celsius.toStringAsFixed(0)}°C';
  }

  // Helpers privés
  String _getCurrencyForLocale(Locale locale) {
    final countryCode = locale.countryCode ?? 'US';
    return _currencyMap[countryCode] ?? 'USD';
  }

  String _getCurrencySymbol(String currencyCode) {
    return _currencySymbols[currencyCode] ?? currencyCode;
  }

  bool _shouldUseImperial(Locale locale) {
    return ['US', 'LR', 'MM'].contains(locale.countryCode);
  }

  bool _shouldUseFahrenheit(Locale locale) {
    return ['US', 'BS', 'BZ', 'KY', 'PW'].contains(locale.countryCode);
  }

  static const Map<String, String> _currencyMap = {
    'US': 'USD',
    'CA': 'CAD',
    'FR': 'EUR',
    'ES': 'EUR',
    'IT': 'EUR',
    'DE': 'EUR',
    'GB': 'GBP',
    'MX': 'MXN',
    'BR': 'BRL',
    'AR': 'ARS',
    'CL': 'CLP',
    'CO': 'COP',
    'PE': 'PEN',
    'AU': 'AUD',
    'NZ': 'NZD',
    'JP': 'JPY',
    'CN': 'CNY',
    'IN': 'INR',
    'KR': 'KRW',
    'SG': 'SGD',
    'CH': 'CHF',
    'SE': 'SEK',
    'NO': 'NOK',
    'DK': 'DKK',
  };

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'CAD': 'C\$',
    'EUR': '€',
    'GBP': '£',
    'MXN': '\$',
    'BRL': 'R\$',
    'ARS': '\$',
    'CLP': '\$',
    'COP': '\$',
    'PEN': 'S/',
    'AUD': 'A\$',
    'NZD': 'NZ\$',
    'JPY': '¥',
    'CNY': '¥',
    'INR': '₹',
    'KRW': '₩',
    'SGD': 'S\$',
    'CHF': 'CHF',
    'SEK': 'kr',
    'NOK': 'kr',
    'DKK': 'kr',
  };
}
