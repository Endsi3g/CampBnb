import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../core/config/mapbox_config.dart';
import '../../../core/monitoring/network_error_interceptor.dart';
import '../../../core/monitoring/observability_service.dart';
import '../../../core/monitoring/error_monitoring_service.dart';
import '../../domain/entities/campsite_location.dart';

/// Service pour les appels API Mapbox
class MapboxService {
  final Dio _dio;
  final Logger _logger = Logger();

  MapboxService({Dio? dio}) : _dio = dio ?? Dio() {
    // Ajouter l'intercepteur de monitoring des erreurs réseau
    _dio.interceptors.add(NetworkErrorInterceptor());
  }

 /// Token d'accès Mapbox
  String? get _accessToken => MapboxConfig.accessToken;

 /// Base URL pour l'API Mapbox
 static const String baseUrl = 'https://api.mapbox.com';

  /// Effectue une recherche géocodique (adresse -> coordonnées)
  Future<Map<String, dynamic>?> geocode(String query, {String? proximity}) async {
    if (_accessToken == null) {
 _logger.e('Token Mapbox manquant');
      return null;
    }

    try {
      return await ObservabilityService().monitorMapboxOperation(
        'geocode',
        () async {
          final response = await _dio.get(
 '$baseUrl/geocoding/v5/mapbox.places/$query.json',
        queryParameters: {
 'access_token': _accessToken,
 'country': 'CA', // Canada uniquement
 'proximity': proximity ?? '-71.2080,46.8139', // Québec par défaut
 'types': 'place,locality,neighborhood,address',
 'language': 'fr', // Français pour le Québec
        },
        options: Options(
          receiveTimeout: MapboxConfig.requestTimeout,
        ),
      );

          if (response.statusCode == 200 && response.data['features'] != null) {
            final features = response.data['features'] as List;
            if (features.isNotEmpty) {
              return features[0] as Map<String, dynamic>;
            }
          }

          return null;
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Erreur lors du géocodage: $e');
      await ErrorMonitoringService().captureException(
        e,
        stackTrace: stackTrace,
        context: {
          'component': 'mapbox_service',
          'operation': 'geocode',
          'query': query,
        },
      );
      return null;
    }
  }

  /// Effectue un géocodage inverse (coordonnées -> adresse)
  Future<Map<String, dynamic>?> reverseGeocode(double lat, double lon) async {
    if (_accessToken == null) {
 _logger.e('Token Mapbox manquant');
      return null;
    }

    try {
      return await ObservabilityService().monitorMapboxOperation(
        'reverse_geocode',
        () async {
          final response = await _dio.get(
 '$baseUrl/geocoding/v5/mapbox.places/$lon,$lat.json',
        queryParameters: {
 'access_token': _accessToken,
 'language': 'fr',
 'types': 'place,locality,neighborhood,address',
        },
        options: Options(
          receiveTimeout: MapboxConfig.requestTimeout,
        ),
      );

          if (response.statusCode == 200 && response.data['features'] != null) {
            final features = response.data['features'] as List;
            if (features.isNotEmpty) {
              return features[0] as Map<String, dynamic>;
            }
          }

          return null;
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Erreur lors du géocodage inverse: $e');
      await ErrorMonitoringService().captureException(
        e,
        stackTrace: stackTrace,
        context: {
          'component': 'mapbox_service',
          'operation': 'reverse_geocode',
          'lat': lat,
          'lon': lon,
        },
      );
      return null;
    }
  }

  /// Récupère les directions entre deux points
  Future<Map<String, dynamic>?> getDirections({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
 String profile = 'driving', // driving, walking, cycling
  }) async {
    if (_accessToken == null) {
 _logger.e('Token Mapbox manquant');
      return null;
    }

    try {
 final coordinates = '$startLon,$startLat;$endLon,$endLat';
      final response = await _dio.get(
 '$baseUrl/directions/v5/mapbox/$profile/$coordinates',
        queryParameters: {
 'access_token': _accessToken,
 'geometries': 'geojson',
 'overview': 'full',
 'steps': 'true',
 'language': 'fr',
        },
        options: Options(
          receiveTimeout: MapboxConfig.requestTimeout,
        ),
      );

 if (response.statusCode == 200 && response.data['routes'] != null) {
 final routes = response.data['routes'] as List;
        if (routes.isNotEmpty) {
          return routes[0] as Map<String, dynamic>;
        }
      }

      return null;
    } catch (e) {
 _logger.e('Erreur lors de la récupération des directions: $e');
      return null;
    }
  }

  /// Recherche des POI (Points of Interest) à proximité
  Future<List<Map<String, dynamic>>> searchPOI({
    required double lat,
    required double lon,
    required String category, // camping, restaurant, gas_station, etc.
    double radius = 5000, // en mètres
  }) async {
    if (_accessToken == null) {
 _logger.e('Token Mapbox manquant');
      return [];
    }

    try {
      final response = await _dio.get(
 '$baseUrl/geocoding/v5/mapbox.places/$category.json',
        queryParameters: {
 'access_token': _accessToken,
 'proximity': '$lon,$lat',
 'radius': radius,
 'types': 'poi',
 'limit': 10,
        },
        options: Options(
          receiveTimeout: MapboxConfig.requestTimeout,
        ),
      );

 if (response.statusCode == 200 && response.data['features'] != null) {
 final features = response.data['features'] as List;
        return features.cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e) {
 _logger.e('Erreur lors de la recherche de POI: $e');
      return [];
    }
  }
}

