import 'package:flutter_test/flutter_test.dart';
import 'package:campbnb_quebec/core/localization/currency_service.dart';

void main() {
  group('CurrencyService', () {
    test('convertCurrency - même devise retourne le même montant', () {
      final result = CurrencyService.convertCurrency(
        amount: 100.0,
        fromCurrency: 'USD',
        toCurrency: 'USD',
      );
      expect(result, equals(100.0));
    });

    test('convertCurrency - conversion USD vers CAD', () {
      final result = CurrencyService.convertCurrency(
        amount: 100.0,
        fromCurrency: 'USD',
        toCurrency: 'CAD',
      );
      // Vérifier que le résultat est approximatif (taux ~1.35)
      expect(result, greaterThan(130.0));
      expect(result, lessThan(140.0));
    });

    test('formatAmount - formatage USD', () {
      final result = CurrencyService.formatAmount(
        amount: 100.50,
        currencyCode: 'USD',
        locale: const Locale('en', 'US'),
      );
      expect(result, contains('\$'));
      expect(result, contains('100'));
    });

    test('formatAmount - formatage EUR', () {
      final result = CurrencyService.formatAmount(
        amount: 100.50,
        currencyCode: 'EUR',
        locale: const Locale('fr', 'FR'),
      );
      expect(result, contains('€'));
    });

    test('getCurrencyForCountry - retourne la bonne devise', () {
      expect(CurrencyService.getCurrencyForCountry('CA'), equals('CAD'));
      expect(CurrencyService.getCurrencyForCountry('US'), equals('USD'));
      expect(CurrencyService.getCurrencyForCountry('FR'), equals('EUR'));
    });
  });
}

