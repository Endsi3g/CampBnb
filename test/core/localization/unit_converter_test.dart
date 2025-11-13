import 'package:flutter_test/flutter_test.dart';
import 'package:campbnb_quebec/core/localization/unit_converter.dart';

void main() {
  group('UnitConverter', () {
    test('kmToMiles - conversion correcte', () {
      final miles = UnitConverter.kmToMiles(10.0);
      expect(miles, closeTo(6.21371, 0.01));
    });

    test('milesToKm - conversion correcte', () {
      final km = UnitConverter.milesToKm(10.0);
      expect(km, closeTo(16.0934, 0.01));
    });

    test('celsiusToFahrenheit - conversion correcte', () {
      final fahrenheit = UnitConverter.celsiusToFahrenheit(25.0);
      expect(fahrenheit, equals(77.0));
    });

    test('fahrenheitToCelsius - conversion correcte', () {
      final celsius = UnitConverter.fahrenheitToCelsius(77.0);
      expect(celsius, equals(25.0));
    });

    test('formatDistance - système métrique', () {
      final formatted = UnitConverter.formatDistance(
        distanceInKm: 10.5,
        useImperial: false,
      );
      expect(formatted, contains('km'));
      expect(formatted, contains('10.5'));
    });

    test('formatDistance - système impérial', () {
      final formatted = UnitConverter.formatDistance(
        distanceInKm: 10.0,
        useImperial: true,
      );
      expect(formatted, contains('mi'));
    });

    test('formatTemperature - Celsius', () {
      final formatted = UnitConverter.formatTemperature(
        celsius: 25.0,
        useFahrenheit: false,
      );
      expect(formatted, contains('°C'));
      expect(formatted, contains('25'));
    });

    test('formatTemperature - Fahrenheit', () {
      final formatted = UnitConverter.formatTemperature(
        celsius: 25.0,
        useFahrenheit: true,
      );
      expect(formatted, contains('°F'));
      expect(formatted, contains('77'));
    });

    test('usesImperialSystem - retourne true pour US', () {
      expect(UnitConverter.usesImperialSystem('US'), isTrue);
      expect(UnitConverter.usesImperialSystem('CA'), isFalse);
    });

    test('usesFahrenheit - retourne true pour US', () {
      expect(UnitConverter.usesFahrenheit('US'), isTrue);
      expect(UnitConverter.usesFahrenheit('CA'), isFalse);
    });
  });
}

