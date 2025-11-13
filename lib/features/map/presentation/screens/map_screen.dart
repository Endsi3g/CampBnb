import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/services/maps_service.dart';

class MapScreen extends StatefulWidget {
  final List<ListingModel> listings;
  final ListingModel? selectedListing;

  const MapScreen({
    super.key,
    required this.listings,
    this.selectedListing,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(46.8139, -71.2080); // Québec par défaut
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // Obtenir la position actuelle
    final position = await MapsService.getCurrentPosition();
    if (position != null) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }

    // Créer les marqueurs pour les listings
    _createMarkers();
  }

  void _createMarkers() {
    final markers = widget.listings.map((listing) {
      return Marker(
        markerId: MarkerId(listing.id),
        position: LatLng(listing.latitude, listing.longitude),
        infoWindow: InfoWindow(
          title: listing.title,
 snippet: '\$${listing.pricePerNight.toStringAsFixed(0)}/nuit',
        ),
        onTap: () {
          // TODO: Naviguer vers les détails du listing
        },
      );
    }).toSet();

    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.selectedListing != null
                  ? LatLng(
                      widget.selectedListing!.latitude,
                      widget.selectedListing!.longitude,
                    )
                  : _currentPosition,
              zoom: 10,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                decoration: const InputDecoration(
 hintText: 'Rechercher par région, parc ou ville...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
                onTap: () {
                  // TODO: Ouvrir la recherche
                },
              ),
            ),
          ),
          // Filter Button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                // TODO: Ouvrir les filtres
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.filter_alt, color: Colors.white),
            ),
          ),
          // My Location Button
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    final position = await MapsService.getCurrentPosition();
                    if (position != null && _mapController != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(position.latitude, position.longitude),
                        ),
                      );
                    }
                  },
                  backgroundColor: AppColors.secondary,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    // TODO: Ouvrir les filtres
                  },
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.filter_alt, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

