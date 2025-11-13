import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../core/config/app_config.dart';

class MapboxService {
  MapboxService._();

  static bool _initialized = false;

  /// Initialiser Mapbox
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await MapboxMapsFlutter.install();
      _initialized = true;
    } catch (e) {
 throw Exception('Erreur lors de l\'initialisation de Mapbox: $e');
    }
  }

 /// Obtenir le token d'accès Mapbox
  static String get accessToken => AppConfig.mapboxAccessToken;

  /// Créer un style de carte personnalisé
  static String getCustomStyle() {
    // Style personnalisé inspiré du Québec
 return 'mapbox://styles/mapbox/outdoors-v12';
  }

  /// Créer un marqueur personnalisé pour un camping
  static Future<PointAnnotationOptions> createCampingMarker({
    required double latitude,
    required double longitude,
    required String title,
    String? imageUrl,
  }) async {
    return PointAnnotationOptions(
      geometry: Point(coordinates: Position(latitude, longitude)),
      textField: title,
      textSize: 12.0,
      iconColor: 0xFF2D572C, // Vert forêt
      iconSize: 1.0,
    );
  }
}

