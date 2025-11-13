/// Service pour convertir les unités (distance, température, poids, etc.)
class UnitConverter {
  /// Convertit les kilomètres en miles
  static double kmToMiles(double km) => km * 0.621371;

  /// Convertit les miles en kilomètres
  static double milesToKm(double miles) => miles * 1.60934;

  /// Convertit Celsius en Fahrenheit
  static double celsiusToFahrenheit(double celsius) => (celsius * 9 / 5) + 32;

  /// Convertit Fahrenheit en Celsius
  static double fahrenheitToCelsius(double fahrenheit) => (fahrenheit - 32) * 5 / 9;

  /// Convertit les mètres en pieds
  static double metersToFeet(double meters) => meters * 3.28084;

  /// Convertit les pieds en mètres
  static double feetToMeters(double feet) => feet * 0.3048;

  /// Convertit les kilogrammes en livres
  static double kgToLbs(double kg) => kg * 2.20462;

  /// Convertit les livres en kilogrammes
  static double lbsToKg(double lbs) => lbs * 0.453592;

 /// Formate une distance selon le système d'unités
  static String formatDistance({
    required double distanceInKm,
    required bool useImperial,
  }) {
    if (useImperial) {
      final miles = kmToMiles(distanceInKm);
 return '${miles.toStringAsFixed(1)} mi';
    }
 return '${distanceInKm.toStringAsFixed(1)} km';
  }

 /// Formate une température selon le système d'unités
  static String formatTemperature({
    required double celsius,
    required bool useFahrenheit,
  }) {
    if (useFahrenheit) {
      final fahrenheit = celsiusToFahrenheit(celsius);
 return '${fahrenheit.toStringAsFixed(0)}°F';
    }
 return '${celsius.toStringAsFixed(0)}°C';
  }

 /// Formate une altitude selon le système d'unités
  static String formatElevation({
    required double meters,
    required bool useImperial,
  }) {
    if (useImperial) {
      final feet = metersToFeet(meters);
 return '${feet.toStringAsFixed(0)} ft';
    }
 return '${meters.toStringAsFixed(0)} m';
  }

  /// Détermine si un pays utilise le système impérial
  static bool usesImperialSystem(String countryCode) {
 return ['US', 'LR', 'MM'].contains(countryCode);
  }

  /// Détermine si un pays utilise Fahrenheit
  static bool usesFahrenheit(String countryCode) {
 return ['US', 'BS', 'BZ', 'KY', 'PW'].contains(countryCode);
  }
}


