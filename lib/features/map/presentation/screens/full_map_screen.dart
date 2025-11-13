import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/mapbox_map_widget.dart';
import '../widgets/map_filters_sheet.dart';
import '../widgets/map_search_bar.dart';
import '../widgets/map_controls.dart';
import '../widgets/add_location_button.dart';
import '../../domain/entities/campsite_location.dart';
import '../../../core/theme/app_colors.dart';
import 'add_campsite_screen.dart';

/// Écran de carte plein écran avec toutes les fonctionnalités
class FullMapScreen extends ConsumerStatefulWidget {
  const FullMapScreen({super.key});

  @override
  ConsumerState<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends ConsumerState<FullMapScreen> {
  final List<CampsiteLocation> _campsites = [];
  final List<CampsiteType> _selectedTypes = [];
  double? _minPrice;
  double? _maxPrice;
  String? _selectedRegion;
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Carte Mapbox
          MapboxMapWidget(
            campsites: _campsites,
            showClusters: true,
            showUserLocation: true,
            onCampsiteTap: _onCampsiteTap,
            onMapTap: _onMapTap,
            onMapLongPress: _onMapLongPress,
          ),

          // Barre de recherche en haut
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: MapSearchBar(
              onSearch: _onSearch,
              onRegionSelected: _onRegionSelected,
            ),
          ),

          // Contrôles de la carte (zoom, localisation, filtres)
          Positioned(
            bottom: _showFilters ? 300 : 16,
            right: 16,
            child: MapControls(
              onMyLocationTap: _onMyLocationTap,
              onFiltersTap: _onFiltersTap,
            ),
          ),

          // Panneau de filtres
          if (_showFilters)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MapFiltersSheet(
                selectedTypes: _selectedTypes,
                minPrice: _minPrice,
                maxPrice: _maxPrice,
                selectedRegion: _selectedRegion,
                onTypesChanged: (types) {
                  setState(() => _selectedTypes = types);
                  _applyFilters();
                },
                onPriceChanged: (min, max) {
                  setState(() {
                    _minPrice = min;
                    _maxPrice = max;
                  });
                  _applyFilters();
                },
                onRegionChanged: (region) {
                  setState(() => _selectedRegion = region);
                  _applyFilters();
                },
                onClose: () {
                  setState(() => _showFilters = false);
                },
              ),
            ),

          // Bouton pour ajouter un emplacement
          Positioned(
            bottom: _showFilters ? 320 : 80,
            left: 16,
            child: AddLocationButton(),
          ),
        ],
      ),
    );
  }

  void _onCampsiteTap(CampsiteLocation campsite) {
    // Navigue vers les détails du camping
    // TODO: Implémenter la navigation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(campsite.name),
        content: Text(campsite.description ?? 'Aucune description'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _onMapTap(double lat, double lon) {
    // Affiche les informations du point cliqué
  }

  void _onMapLongPress(double lat, double lon) {
    // Permet aux hôtes de créer un nouvel emplacement
    _showAddCampsiteDialog(lat, lon);
  }

  void _showAddCampsiteDialog(double lat, double lon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un emplacement'),
        content: Text(
          'Voulez-vous créer un nouvel emplacement à cet endroit ?\n\n'
          'Coordonnées: $lat, $lon',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCampsiteScreen(
                    initialLatitude: lat,
                    initialLongitude: lon,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _onSearch(String query) {
    // Recherche textuelle
    // TODO: Implémenter la recherche
  }

  void _onRegionSelected(String region) {
    setState(() => _selectedRegion = region);
    _applyFilters();
  }

  void _onMyLocationTap() {
    // Centre la carte sur la position de l'utilisateur
    // TODO: Implémenter le centrage
  }

  void _onFiltersTap() {
    setState(() => _showFilters = !_showFilters);
  }

  void _applyFilters() {
    // Applique les filtres et recharge les campsites
    // TODO: Implémenter le filtrage
  }
}
