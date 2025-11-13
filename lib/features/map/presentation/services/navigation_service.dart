import 'package:logger/logger.dart';
import '../../../core/config/mapbox_config.dart';
import '../../data/services/mapbox_service.dart';
import '../../domain/entities/campsite_location.dart';

/// Service pour la navigation et les directions
class NavigationService {
  final MapboxService _mapboxService;
  final Logger _logger = Logger();

  NavigationService({MapboxService? mapboxService})
      : _mapboxService = mapboxService ?? MapboxService();

  /// Récupère les directions vers un emplacement de camping
  Future<NavigationRoute?> getDirectionsToCampsite({
    required double startLat,
    required double startLon,
    required CampsiteLocation destination,
 String profile = 'driving', // driving, walking, cycling
  }) async {
    try {
      final routeData = await _mapboxService.getDirections(
        startLat: startLat,
        startLon: startLon,
        endLat: destination.latitude,
        endLon: destination.longitude,
        profile: profile,
      );

      if (routeData == null) return null;

      return NavigationRoute.fromMapboxResponse(routeData);
    } catch (e) {
 _logger.e('Erreur lors de la récupération des directions: $e');
      return null;
    }
  }

 /// Récupère les POI à proximité d'un emplacement
  Future<List<PointOfInterest>> getNearbyPOI({
    required double lat,
    required double lon,
    double radius = 5000, // 5km par défaut
  }) async {
    try {
      final poiData = await _mapboxService.searchPOI(
        lat: lat,
        lon: lon,
 category: 'camping,restaurant,gas_station,pharmacy',
        radius: radius,
      );

      return poiData.map((data) => PointOfInterest.fromMapboxData(data)).toList();
    } catch (e) {
 _logger.e('Erreur lors de la récupération des POI: $e');
      return [];
    }
  }
}

/// Modèle pour une route de navigation
class NavigationRoute {
  final double distance; // en mètres
  final double duration; // en secondes
  final List<RouteStep> steps;
  final String geometry; // GeoJSON LineString

  NavigationRoute({
    required this.distance,
    required this.duration,
    required this.steps,
    required this.geometry,
  });

  factory NavigationRoute.fromMapboxResponse(Map<String, dynamic> data) {
 final distance = (data['distance'] as num).toDouble();
 final duration = (data['duration'] as num).toDouble();
 final geometry = data['geometry'] as Map<String, dynamic>;
 final legs = data['legs'] as List?;
    
    final steps = <RouteStep>[];
    if (legs != null && legs.isNotEmpty) {
      final firstLeg = legs[0] as Map<String, dynamic>;
 final legSteps = firstLeg['steps'] as List?;
      if (legSteps != null) {
        steps.addAll(legSteps.map((s) => RouteStep.fromMapboxData(s as Map<String, dynamic>)));
      }
    }

    return NavigationRoute(
      distance: distance,
      duration: duration,
      steps: steps,
      geometry: geometry.toString(),
    );
  }

  String get formattedDistance {
    if (distance < 1000) {
 return '${distance.toInt()} m';
    }
 return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    final hours = (duration / 3600).floor();
    final minutes = ((duration % 3600) / 60).floor();
    
    if (hours > 0) {
 return '${hours}h ${minutes}min';
    }
 return '${minutes}min';
  }
}

/// Étape d'une route
class RouteStep {
  final double distance;
  final double duration;
  final String instruction;
  final String? maneuver;

  RouteStep({
    required this.distance,
    required this.duration,
    required this.instruction,
    this.maneuver,
  });

  factory RouteStep.fromMapboxData(Map<String, dynamic> data) {
    return RouteStep(
 distance: (data['distance'] as num).toDouble(),
 duration: (data['duration'] as num).toDouble(),
 instruction: data['maneuver']?['instruction'] as String? ?? '',
 maneuver: data['maneuver']?['type'] as String?,
    );
  }
}

/// Point d'intérêt (POI)
class PointOfInterest {
  final String id;
  final String name;
  final String category;
  final double latitude;
  final double longitude;
  final double? distance; // en mètres depuis le point de référence

  PointOfInterest({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.distance,
  });

  factory PointOfInterest.fromMapboxData(Map<String, dynamic> data) {
 final geometry = data['geometry'] as Map<String, dynamic>;
 final coordinates = geometry['coordinates'] as List;
 final properties = data['properties'] as Map<String, dynamic>?;

    return PointOfInterest(
 id: data['id'] as String,
 name: properties?['name'] as String? ?? 'POI',
 category: properties?['category'] as String? ?? 'unknown',
      latitude: (coordinates[1] as num).toDouble(),
      longitude: (coordinates[0] as num).toDouble(),
    );
  }
}


