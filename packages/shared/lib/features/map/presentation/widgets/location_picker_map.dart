import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mapbox_map_widget.dart';
import '../../../core/theme/app_colors.dart';

/// Widget de carte pour sélectionner un emplacement
/// Permet de cliquer sur la carte ou de rechercher une adresse
class LocationPickerMap extends ConsumerStatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double lat, double lon) onLocationSelected;
  final Function(String query) onSearchAddress;
  final String? selectedAddress;
  final bool isSearchingAddress;

  const LocationPickerMap({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationSelected,
    required this.onSearchAddress,
    this.selectedAddress,
    this.isSearchingAddress = false,
  });

  @override
  ConsumerState<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends ConsumerState<LocationPickerMap> {
  final TextEditingController _searchController = TextEditingController();
  double? _selectedLat;
  double? _selectedLon;

  @override
  void initState() {
    super.initState();
    _selectedLat = widget.initialLatitude;
    _selectedLon = widget.initialLongitude;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMapTap(double lat, double lon) {
    setState(() {
      _selectedLat = lat;
      _selectedLon = lon;
    });
    widget.onLocationSelected(lat, lon);
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      widget.onSearchAddress(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Carte Mapbox
        MapboxMapWidget(
          campsites: const [],
          initialLatitude: _selectedLat ?? 46.8139,
          initialLongitude: _selectedLon ?? -71.2080,
          initialZoom: _selectedLat != null ? 15.0 : 7.0,
          onMapTap: _onMapTap,
          onMapLongPress: _onMapTap, // Long press aussi pour sélectionner
        ),

        // Indicateur de sélection au centre
        if (_selectedLat != null && _selectedLon != null)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.place,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 2,
                  height: 20,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),

        // Barre de recherche en haut
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.primary,
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
 hintText: 'Rechercher une adresse...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: _onSearch,
                  ),
                ),
                if (widget.isSearchingAddress)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _onSearch(_searchController.text),
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),

        // Instructions en bas
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedLat != null
 ? 'Emplacement sélectionné \nAppuyez sur la carte pour changer'
 : 'Appuyez sur la carte pour sélectionner un emplacement',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

