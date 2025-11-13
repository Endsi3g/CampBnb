import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/services/location_service.dart';

/// Implémentation du service de géolocalisation
class LocationServiceImpl implements LocationService {
  final Logger _logger = Logger();

  @override
  Future<bool> checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      _logger.e('Erreur lors de la vérification des permissions: $e');
      return false;
    }
  }

  @override
  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        _logger.i('Permission de localisation accordée');
        return true;
      } else if (status.isPermanentlyDenied) {
        _logger.w('Permission de localisation refusée définitivement');
        // Optionnel: ouvrir les paramètres de l'app
        // await openAppSettings();
      }
      return false;
    } catch (e) {
      _logger.e('Erreur lors de la demande de permission: $e');
      return false;
    }
  }

  @override
  Future<Position?> getCurrentPosition() async {
    try {
      // Vérifie d'abord si le service est activé
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('Service de localisation désactivé');
        return null;
      }

      // Vérifie les permissions
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        final granted = await requestLocationPermission();
        if (!granted) {
          _logger.w('Permission de localisation refusée');
          return null;
        }
      }

      // Récupère la position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _logger.i(
        'Position récupérée: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      _logger.e('Erreur lors de la récupération de la position: $e');
      return null;
    }
  }

  @override
  Stream<Position> watchPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  @override
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      _logger.e('Erreur lors de la vérification du service: $e');
      return false;
    }
  }
}
