import 'package:flutter_test/flutter_test.dart';
import 'package:campbnb_quebec/core/localization/currency_exchange_service.dart';

void main() {
  group('CurrencyExchangeService', () {
    late CurrencyExchangeService service;

    setUp(() {
      service = CurrencyExchangeService();
    });

    test('convertCurrency - même devise retourne le même montant', () async {
      final result = await service.convertCurrency(
        amount: 100.0,
        fromCurrency: 'USD',
        toCurrency: 'USD',
      );
      expect(result, equals(100.0));
    });

    test('getExchangeRate - retourne null pour devises inconnues', () {
      // Note: Ce test nécessite que le service soit initialisé avec des taux
      // En pratique, on devrait mock l'API
      final rate = service.getExchangeRate('XXX', 'YYY');
      expect(rate, isNull);
    });

    test('lastUpdate - initialement null', () {
      expect(service.lastUpdate, isNull);
    });
  });
}

