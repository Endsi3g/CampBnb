import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:logger/logger.dart';
import '../../../core/config/mapbox_config.dart';
import '../../domain/entities/campsite_location.dart';
import 'campsite_marker.dart';
import 'map_cluster_manager.dart';

/// Widget principal de la carte Mapbox
class MapboxMapWidget extends StatefulWidget {
  final List<CampsiteLocation> campsites;
  final Function(CampsiteLocation)? onCampsiteTap;
  final Function(double lat, double lon)? onMapTap;
  final Function(double lat, double lon)? onMapLongPress;
  final bool showClusters;
  final bool showUserLocation;
  final String? initialStyle;
  final double? initialZoom;
  final double? initialLatitude;
  final double? initialLongitude;

  const MapboxMapWidget({
    super.key,
    required this.campsites,
    this.onCampsiteTap,
    this.onMapTap,
    this.onMapLongPress,
    this.showClusters = true,
    this.showUserLocation = true,
    this.initialStyle,
    this.initialZoom,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<MapboxMapWidget> createState() => _MapboxMapWidgetState();
}

class _MapboxMapWidgetState extends State<MapboxMapWidget> {
  MapboxMap? _mapboxMap;
  final Logger _logger = Logger();
  final MapClusterManager _clusterManager = MapClusterManager();
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    if (!MapboxConfig.isValid) {
      _logger.e('Configuration Mapbox invalide');
      return;
    }

    try {
      // Initialise Mapbox avec le token
      // Note: L'initialisation peut varier selon la version de mapbox_maps_flutter
      // Vérifiez la documentation pour la méthode exacte
      // await MapboxOptions.setAccessToken(MapboxConfig.accessToken!);
    } catch (e) {
      _logger.e('Erreur lors de l\'initialisation de Mapbox: $e');
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _isMapReady = true;

    // Configure la carte
    _configureMap();

    // Charge les marqueurs
    _loadMarkers();
  }

  Future<void> _configureMap() async {
    if (_mapboxMap == null) return;

    try {
      // Style de carte
      final style = widget.initialStyle ?? MapboxConfig.natureStyle;
      await _mapboxMap!.style.setStyleURI(style);

      // Position initiale
      final cameraOptions = CameraOptions(
        center: Point(
          coordinates: Position(
            widget.initialLongitude ?? MapboxConfig.defaultLongitude,
            widget.initialLatitude ?? MapboxConfig.defaultLatitude,
          ),
        ),
        zoom: widget.initialZoom ?? MapboxConfig.defaultZoom,
      );
      await _mapboxMap!.camera.easeTo(cameraOptions);

      // Active la localisation de l'utilisateur si demandé
      // Note: L'API peut varier selon la version de mapbox_maps_flutter
      // if (widget.showUserLocation) {
      //   await _mapboxMap!.location.updateSettings(...);
      // }
    } catch (e) {
      _logger.e('Erreur lors de la configuration de la carte: $e');
    }
  }

  Future<void> _loadMarkers() async {
    if (_mapboxMap == null || !_isMapReady) return;

    try {
      if (widget.showClusters) {
        await _clusterManager.loadClusters(
          _mapboxMap!,
          widget.campsites,
          onClusterTap: (cluster) {
            // Zoom sur le cluster
            _zoomToCluster(cluster);
          },
          onCampsiteTap: widget.onCampsiteTap,
        );
      } else {
        // Charge les marqueurs individuels sans clustering
        for (final campsite in widget.campsites) {
          await _addMarker(campsite);
        }
      }
    } catch (e) {
      _logger.e('Erreur lors du chargement des marqueurs: $e');
    }
  }

  Future<void> _addMarker(CampsiteLocation campsite) async {
    if (_mapboxMap == null) return;

    try {
      final marker = CampsiteMarker(
        campsite: campsite,
        onTap: () => widget.onCampsiteTap?.call(campsite),
      );
      await marker.addToMap(_mapboxMap!);
    } catch (e) {
      _logger.e('Erreur lors de l\'ajout du marqueur: $e');
    }
  }

  Future<void> _zoomToCluster(CampsiteCluster cluster) async {
    if (_mapboxMap == null) return;

    try {
      final cameraOptions = CameraOptions(
        center: Point(
          coordinates: Position(cluster.longitude, cluster.latitude),
        ),
        zoom: await _getCurrentZoom() + 2,
      );
      await _mapboxMap!.camera.easeTo(cameraOptions);
    } catch (e) {
      _logger.e('Erreur lors du zoom sur le cluster: $e');
    }
  }

  Future<double> _getCurrentZoom() async {
    if (_mapboxMap == null) return MapboxConfig.defaultZoom;
    try {
      final cameraState = await _mapboxMap!.camera.getCameraState();
      return cameraState.zoom;
    } catch (e) {
      return MapboxConfig.defaultZoom;
    }
  }

  void _onMapClick(Point point) {
    if (widget.onMapTap != null) {
      widget.onMapTap!(point.coordinates.lat, point.coordinates.lng);
    }
  }

  void _onMapLongClick(Point point) {
    if (widget.onMapLongPress != null) {
      widget.onMapLongPress!(point.coordinates.lat, point.coordinates.lng);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!MapboxConfig.isValid) {
      return const Center(child: Text('Configuration Mapbox invalide'));
    }

    return MapWidget(
      key: const ValueKey('mapbox_map'),
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(
            widget.initialLongitude ?? MapboxConfig.defaultLongitude,
            widget.initialLatitude ?? MapboxConfig.defaultLatitude,
          ),
        ),
        zoom: widget.initialZoom ?? MapboxConfig.defaultZoom,
      ),
      styleUri: widget.initialStyle ?? MapboxConfig.natureStyle,
      textureView: true,
      onMapCreated: _onMapCreated,
      onMapClick: _onMapClick,
      onMapLongClick: _onMapLongClick,
    );
  }

  @override
  void didUpdateWidget(MapboxMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.campsites != widget.campsites && _isMapReady) {
      _loadMarkers();
    }
  }

  @override
  void dispose() {
    _clusterManager.dispose();
    super.dispose();
  }
}
