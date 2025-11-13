import 'package:geolocator/geolocator.dart';

/// Service de géolocalisation en temps réel
abstract class LocationService {
  /// Vérifie si les permissions de localisation sont accordées
  Future<bool> checkLocationPermission();

  /// Demande les permissions de localisation
  Future<bool> requestLocationPermission();

  /// Récupère la position actuelle de l'utilisateur
  Future<Position?> getCurrentPosition();

  /// Écoute les changements de position en temps réel
  Stream<Position> watchPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // en mètres
  });

  /// Calcule la distance entre deux points en mètres
  double calculateDistance(double lat1, double lon1, double lat2, double lon2);

  /// Vérifie si le service de localisation est activé
  Future<bool> isLocationServiceEnabled();
}
