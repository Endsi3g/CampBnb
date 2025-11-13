import 'package:flutter_test/flutter_test.dart';
import 'package:campbnb_quebec/core/localization/app_localizations.dart';
import 'package:campbnb_quebec/core/localization/app_locale.dart';

void main() {
  group('AppLocalizations', () {
    test('translate - retourne la traduction correcte', () {
      final translations = {
        'welcome': 'Bienvenue',
        'search': 'Rechercher',
      };
      final localizations = AppLocalizations(
        const Locale('fr', 'CA'),
        translations,
      );

      expect(localizations.translate('welcome'), equals('Bienvenue'));
      expect(localizations.translate('search'), equals('Rechercher'));
    });

    test('translate - retourne la clé si traduction absente', () {
      final translations = <String, String>{};
      final localizations = AppLocalizations(
        const Locale('fr', 'CA'),
        translations,
      );

      expect(localizations.translate('missing_key'), equals('missing_key'));
    });

    test('translate - remplace les paramètres', () {
      final translations = {
        'greeting': 'Bonjour {{name}}',
      };
      final localizations = AppLocalizations(
        const Locale('fr', 'CA'),
        translations,
      );

      final result = localizations.translate(
        'greeting',
        {'name': 'Jean'},
      );
      expect(result, equals('Bonjour Jean'));
    });

    test('formatCurrency - formate correctement', () {
      final translations = <String, String>{};
      final localizations = AppLocalizations(
        const Locale('fr', 'CA'),
        translations,
      );

      final result = localizations.formatCurrency(100.50, currencyCode: 'CAD');
      expect(result, contains('100'));
      expect(result, contains('50'));
    });

    test('formatDistance - système métrique', () {
      final translations = <String, String>{};
      final localizations = AppLocalizations(
        const Locale('fr', 'CA'),
        translations,
      );

      final result = localizations.formatDistance(10.5, useImperial: false);
      expect(result, contains('km'));
    });

    test('formatDistance - système impérial', () {
      final translations = <String, String>{};
      final localizations = AppLocalizations(
        const Locale('en', 'US'),
        translations,
      );

      final result = localizations.formatDistance(10.0, useImperial: true);
      expect(result, contains('mi'));
    });
  });
}

