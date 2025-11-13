import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:logger/logger.dart';
import '../../../core/config/mapbox_config.dart';
import '../../domain/entities/campsite_location.dart';
import 'campsite_marker.dart';

/// Gestionnaire de clustering pour les marqueurs sur la carte
class MapClusterManager {
  final Logger _logger = Logger();
  final Map<String, CampsiteMarker> _markers = {};
  PointAnnotationManager? _pointManager;
  CircleAnnotationManager? _clusterManager;

  /// Charge les clusters sur la carte
  Future<void> loadClusters(
    MapboxMap mapboxMap,
    List<CampsiteLocation> campsites, {
    Function(CampsiteCluster)? onClusterTap,
    Function(CampsiteLocation)? onCampsiteTap,
  }) async {
    try {
 // Crée les managers d'annotations
 // Note: L'API peut varier selon la version de mapbox_maps_flutter
      // _pointManager = await mapboxMap.annotations.createPointAnnotationManager();
      // _clusterManager = await mapboxMap.annotations.createCircleAnnotationManager();
      
 _logger.w('Cluster manager - API Mapbox à adapter selon la version');

      // Nettoie les anciens marqueurs
      await _clearMarkers();

      // Groupe les campsites par proximité (clustering simple)
      final clusters = _createClusters(campsites);

      // Affiche les clusters ou les marqueurs individuels selon le zoom
      final currentZoom = await _getCurrentZoom(mapboxMap);
      
      if (currentZoom >= MapboxConfig.clusterMinZoom) {
        // Affiche les marqueurs individuels
        for (final campsite in campsites) {
          await _addMarker(campsite, onCampsiteTap);
        }
      } else {
        // Affiche les clusters
        for (final cluster in clusters) {
          if (cluster.pointCount > 1) {
            await _addCluster(cluster, onClusterTap);
          } else if (cluster.campsiteIds.isNotEmpty) {
            // Cluster avec un seul point = marqueur individuel
            final campsite = campsites.firstWhere(
              (c) => c.id == cluster.campsiteIds.first,
            );
            await _addMarker(campsite, onCampsiteTap);
          }
        }
      }
    } catch (e) {
 _logger.e('Erreur lors du chargement des clusters: $e');
    }
  }

  /// Crée des clusters à partir des campsites
  List<CampsiteCluster> _createClusters(List<CampsiteLocation> campsites) {
    if (campsites.isEmpty) return [];

    final clusters = <CampsiteCluster>[];
    final processed = <String>{};

    for (final campsite in campsites) {
      if (processed.contains(campsite.id)) continue;

      // Trouve les campsites proches
      final nearby = campsites.where((c) {
        if (c.id == campsite.id || processed.contains(c.id)) return false;
        final distance = _calculateDistance(
          campsite.latitude,
          campsite.longitude,
          c.latitude,
          c.longitude,
        );
        // Distance maximale pour un cluster (environ 1km)
        return distance < 1000;
      }).toList();

      if (nearby.isNotEmpty) {
        // Crée un cluster
        final allIds = [campsite.id, ...nearby.map((c) => c.id)];
        final avgLat = (campsite.latitude +
                nearby.map((c) => c.latitude).reduce((a, b) => a + b)) /
            (nearby.length + 1);
        final avgLon = (campsite.longitude +
                nearby.map((c) => c.longitude).reduce((a, b) => a + b)) /
            (nearby.length + 1);

        clusters.add(CampsiteCluster(
 id: 'cluster_${campsite.id}',
          latitude: avgLat,
          longitude: avgLon,
          pointCount: allIds.length,
          campsiteIds: allIds,
        ));

        processed.addAll(allIds);
      } else {
        // Marqueur individuel
        clusters.add(CampsiteCluster(
 id: 'single_${campsite.id}',
          latitude: campsite.latitude,
          longitude: campsite.longitude,
          pointCount: 1,
          campsiteIds: [campsite.id],
        ));
        processed.add(campsite.id);
      }
    }

    return clusters;
  }

  /// Ajoute un marqueur individuel
  Future<void> _addMarker(
    CampsiteLocation campsite,
    Function(CampsiteLocation)? onTap,
  ) async {
    if (_pointManager == null) return;

    try {
      final marker = CampsiteMarker(
        campsite: campsite,
        onTap: () => onTap?.call(campsite),
      );
      await marker.addToMap(_pointManager!);
      _markers[campsite.id] = marker;
    } catch (e) {
 _logger.e('Erreur lors de l\'ajout du marqueur: $e');
    }
  }

  /// Ajoute un cluster sur la carte
  Future<void> _addCluster(
    CampsiteCluster cluster,
    Function(CampsiteCluster)? onTap,
  ) async {
    if (_clusterManager == null) return;

    try {
      final circleOptions = CircleAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            cluster.longitude,
            cluster.latitude,
          ),
        ),
        circleRadius: 20.0 + (cluster.pointCount * 2.0),
        circleColor: 0xFF2D572C, // AppColors.primary
        circleStrokeColor: 0xFFFFFFFF,
        circleStrokeWidth: 2.0,
      );

      final annotation = await _clusterManager!.create(circleOptions);

      // Gère le tap sur le cluster
      _clusterManager!.onCircleAnnotationClick.listen((event) {
        if (event.annotation.id == annotation.id) {
          onTap?.call(cluster);
        }
      });
    } catch (e) {
 _logger.e('Erreur lors de l\'ajout du cluster: $e');
    }
  }

  /// Nettoie tous les marqueurs
  Future<void> _clearMarkers() async {
    try {
      if (_pointManager != null) {
        await _pointManager!.delete(_markers.keys.toList());
      }
      if (_clusterManager != null) {
        // Supprime tous les clusters (nécessite de garder une référence)
      }
      _markers.clear();
    } catch (e) {
 _logger.e('Erreur lors du nettoyage des marqueurs: $e');
    }
  }

  /// Calcule la distance entre deux points en mètres
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Rayon de la Terre en mètres
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = (dLat / 2).sin() * (dLat / 2).sin() +
        _toRadians(lat1).cos() *
            _toRadians(lat2).cos() *
            (dLon / 2).sin() *
            (dLon / 2).sin();
    final c = 2 * a.sqrt().atan2((1 - a).sqrt());

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (3.14159265359 / 180.0);

  Future<double> _getCurrentZoom(MapboxMap mapboxMap) async {
    try {
      final cameraState = await mapboxMap.camera.getCameraState();
      return cameraState.zoom;
    } catch (e) {
      return MapboxConfig.defaultZoom;
    }
  }

  void dispose() {
    _markers.clear();
    _pointManager = null;
    _clusterManager = null;
  }
}

