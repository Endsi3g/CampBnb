import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/services/mapbox_service.dart';

class MapboxMapScreen extends StatefulWidget {
  final List<ListingModel> listings;
  final ListingModel? selectedListing;

  const MapboxMapScreen({
    super.key,
    required this.listings,
    this.selectedListing,
  });

  @override
  State<MapboxMapScreen> createState() => _MapboxMapScreenState();
}

class _MapboxMapScreenState extends State<MapboxMapScreen> {
  MapboxMap? mapboxMap;
  final List<PointAnnotation> _annotations = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await MapboxService.initialize();
    _createMarkers();
  }

  void _createMarkers() {
    for (final listing in widget.listings) {
      final marker = PointAnnotation(
        id: listing.id,
        geometry: Point(
          coordinates: Position(
            listing.longitude,
            listing.latitude,
          ),
        ),
        textField: listing.title,
        textSize: 12.0,
        iconColor: 0xFF2D572C, // Vert forêt
      );
      _annotations.add(marker);
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.annotations.createPointAnnotationManager().then((manager) {
      manager.createMulti(_annotations);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
 key: const ValueKey('mapbox'),
        cameraOptions: CameraOptions(
          center: widget.selectedListing != null
              ? Point(
                  coordinates: Position(
                    widget.selectedListing!.longitude,
                    widget.selectedListing!.latitude,
                  ),
                )
              : const Point(
                  coordinates: Position(-71.2089, 46.8139), // Québec
                ),
          zoom: 10.0,
        ),
        styleUri: MapboxService.getCustomStyle(),
        onMapCreated: _onMapCreated,
      ),
    );
  }
}

