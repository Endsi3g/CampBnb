/// Service pour gérer les conversions de devises et les formats
import 'package:intl/intl.dart';
import 'app_locale.dart';

class CurrencyService {
  /// Convertit un montant d'une devise à une autre
  /// Note: En production, utiliser un service API réel (ex: exchangerate-api.com)
  static double convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return amount;

    // Taux de change approximatifs (à remplacer par un service API en production)
    final exchangeRates = {
      'USD': {
        'CAD': 1.35,
        'EUR': 0.92,
        'GBP': 0.79,
        'MXN': 17.50,
        'BRL': 4.95,
        'ARS': 350.00,
        'CLP': 920.00,
        'COP': 3900.00,
        'PEN': 3.70,
        'AUD': 1.52,
        'NZD': 1.65,
        'JPY': 150.00,
        'CNY': 7.20,
        'INR': 83.00,
        'KRW': 1330.00,
        'SGD': 1.34,
        'CHF': 0.88,
        'SEK': 10.50,
        'NOK': 10.80,
        'DKK': 6.90,
      },
    };

    // Convertir via USD comme devise de référence
    final usdAmount = _convertToUSD(amount, fromCurrency, exchangeRates);
    return _convertFromUSD(usdAmount, toCurrency, exchangeRates);
  }

  static double _convertToUSD(
    double amount,
    String fromCurrency,
    Map<String, Map<String, double>> rates,
  ) {
    if (fromCurrency == 'USD') return amount;
    final rate = rates['USD']?[fromCurrency];
    if (rate == null) return amount; // Fallback: pas de conversion
    return amount / rate;
  }

  static double _convertFromUSD(
    double usdAmount,
    String toCurrency,
    Map<String, Map<String, double>> rates,
  ) {
    if (toCurrency == 'USD') return usdAmount;
    final rate = rates['USD']?[toCurrency];
    if (rate == null) return usdAmount; // Fallback: pas de conversion
    return usdAmount * rate;
  }

  /// Formate un montant selon la locale
  static String formatAmount({
    required double amount,
    required String currencyCode,
    required Locale locale,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale.toString(),
      symbol: _getCurrencySymbol(currencyCode),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Obtient le symbole de devise
  static String _getCurrencySymbol(String currencyCode) {
    const symbols = {
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
    return symbols[currencyCode] ?? currencyCode;
  }

  /// Obtient la devise par défaut pour un pays
  static String getCurrencyForCountry(String countryCode) {
    final appLocale = AppLocale.supportedLocales.firstWhere(
      (locale) => locale.countryCode == countryCode,
      orElse: () => AppLocale.defaultLocale,
    );
    return appLocale.currencyCode;
  }

  /// Liste des devises supportées
  static const List<String> supportedCurrencies = [
    'USD',
    'CAD',
    'EUR',
    'GBP',
    'MXN',
    'BRL',
    'ARS',
    'CLP',
    'COP',
    'PEN',
    'AUD',
    'NZD',
    'JPY',
    'CNY',
    'INR',
    'KRW',
    'SGD',
    'CHF',
    'SEK',
    'NOK',
    'DKK',
  ];
}
