/// Modèle pour représenter une locale supportée
class AppLocale {
  final String languageCode;
  final String? countryCode;
  final String name;
  final String nativeName;
  final String flag;
  final String currencyCode;
  final bool isRTL;

  const AppLocale({
    required this.languageCode,
    this.countryCode,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.currencyCode,
    this.isRTL = false,
  });

  Locale get locale => Locale(languageCode, countryCode);

  static const List<AppLocale> supportedLocales = [
    // Amérique du Nord
    AppLocale(
      languageCode: 'fr',
      countryCode: 'CA',
      name: 'French (Canada)',
      nativeName: 'Français (Canada)',
      flag: '',
      currencyCode: 'CAD',
    ),
    AppLocale(
      languageCode: 'en',
      countryCode: 'US',
      name: 'English (US)',
      nativeName: 'English (US)',
      flag: '',
      currencyCode: 'USD',
    ),
    AppLocale(
      languageCode: 'en',
      countryCode: 'CA',
      name: 'English (Canada)',
      nativeName: 'English (Canada)',
      flag: '',
      currencyCode: 'CAD',
    ),
    AppLocale(
      languageCode: 'es',
      countryCode: 'MX',
      name: 'Spanish (Mexico)',
      nativeName: 'Español (México)',
      flag: '',
      currencyCode: 'MXN',
    ),
    // Europe
    AppLocale(
      languageCode: 'fr',
      countryCode: 'FR',
      name: 'French (France)',
      nativeName: 'Français (France)',
      flag: '',
      currencyCode: 'EUR',
    ),
    AppLocale(
      languageCode: 'en',
      countryCode: 'GB',
      name: 'English (UK)',
      nativeName: 'English (UK)',
      flag: '',
      currencyCode: 'GBP',
    ),
    AppLocale(
      languageCode: 'es',
      countryCode: 'ES',
      name: 'Spanish (Spain)',
      nativeName: 'Español (España)',
      flag: '',
      currencyCode: 'EUR',
    ),
    AppLocale(
      languageCode: 'de',
      countryCode: 'DE',
      name: 'German',
      nativeName: 'Deutsch',
      flag: '',
      currencyCode: 'EUR',
    ),
    AppLocale(
      languageCode: 'it',
      countryCode: 'IT',
      name: 'Italian',
      nativeName: 'Italiano',
      flag: '',
      currencyCode: 'EUR',
    ),
    // Amérique du Sud
    AppLocale(
      languageCode: 'pt',
      countryCode: 'BR',
      name: 'Portuguese (Brazil)',
      nativeName: 'Português (Brasil)',
      flag: '',
      currencyCode: 'BRL',
    ),
    AppLocale(
      languageCode: 'es',
      countryCode: 'AR',
      name: 'Spanish (Argentina)',
      nativeName: 'Español (Argentina)',
      flag: '',
      currencyCode: 'ARS',
    ),
    AppLocale(
      languageCode: 'es',
      countryCode: 'CL',
      name: 'Spanish (Chile)',
      nativeName: 'Español (Chile)',
      flag: '',
      currencyCode: 'CLP',
    ),
    AppLocale(
      languageCode: 'es',
      countryCode: 'CO',
      name: 'Spanish (Colombia)',
      nativeName: 'Español (Colombia)',
      flag: '',
      currencyCode: 'COP',
    ),
    // Asie-Pacifique
    AppLocale(
      languageCode: 'ja',
      countryCode: 'JP',
      name: 'Japanese',
      nativeName: '日本語',
      flag: '',
      currencyCode: 'JPY',
    ),
    AppLocale(
      languageCode: 'zh',
      countryCode: 'CN',
      name: 'Chinese (Simplified)',
      nativeName: '简体中文',
      flag: '',
      currencyCode: 'CNY',
    ),
    AppLocale(
      languageCode: 'ko',
      countryCode: 'KR',
      name: 'Korean',
      nativeName: '한국어',
      flag: '',
      currencyCode: 'KRW',
    ),
    AppLocale(
      languageCode: 'hi',
      countryCode: 'IN',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '',
      currencyCode: 'INR',
    ),
    AppLocale(
      languageCode: 'en',
      countryCode: 'AU',
      name: 'English (Australia)',
      nativeName: 'English (Australia)',
      flag: '',
      currencyCode: 'AUD',
    ),
    AppLocale(
      languageCode: 'en',
      countryCode: 'NZ',
      name: 'English (New Zealand)',
      nativeName: 'English (New Zealand)',
      flag: '',
      currencyCode: 'NZD',
    ),
  ];

  static AppLocale? fromLocale(Locale locale) {
    try {
      return supportedLocales.firstWhere(
        (appLocale) =>
            appLocale.languageCode == locale.languageCode &&
            (appLocale.countryCode == locale.countryCode ||
                appLocale.countryCode == null),
      );
    } catch (e) {
      return null;
    }
  }

  static AppLocale get defaultLocale => supportedLocales.first;

  static List<Locale> get locales =>
      supportedLocales.map((e) => e.locale).toList();
}
