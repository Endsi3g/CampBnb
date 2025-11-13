import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/campsite_location.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/services/location_service.dart';
import '../../data/repositories/map_repository_impl.dart';
import '../../data/services/location_service_impl.dart';
import '../../data/services/mapbox_service.dart';

/// Provider pour le repository de carte
final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepositoryImpl();
});

/// Provider pour le service de localisation
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationServiceImpl();
});

/// Provider pour le service Mapbox
final mapboxServiceProvider = Provider<MapboxService>((ref) {
  return MapboxService();
});

/// Provider pour les campsites chargés
final campsitesProvider = FutureProvider<List<CampsiteLocation>>((ref) async {
  final repository = ref.read(mapRepositoryProvider);
  // Charge les campsites par défaut (tous disponibles)
  return repository.filterCampsites(isAvailable: true);
});

/// Provider pour les campsites filtrés
final filteredCampsitesProvider = Provider.family<List<CampsiteLocation>, MapFilters>((ref, filters) {
  final allCampsites = ref.watch(campsitesProvider);
  
  return allCampsites.when(
    data: (campsites) {
      var filtered = campsites;

      // Filtre par type
      if (filters.types != null && filters.types!.isNotEmpty) {
        filtered = filtered.where((c) => filters.types!.contains(c.type)).toList();
      }

      // Filtre par prix
      if (filters.minPrice != null) {
        filtered = filtered.where((c) => 
          c.pricePerNight != null && c.pricePerNight! >= filters.minPrice!
        ).toList();
      }
      if (filters.maxPrice != null) {
        filtered = filtered.where((c) => 
          c.pricePerNight != null && c.pricePerNight! <= filters.maxPrice!
        ).toList();
      }

      // Filtre par région (nécessite un champ région dans CampsiteLocation)
 // TODO: Ajouter le champ région à l'entité

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Modèle pour les filtres de carte
class MapFilters {
  final List<CampsiteType>? types;
  final double? minPrice;
  final double? maxPrice;
  final String? region;
  final double? minRating;

  const MapFilters({
    this.types,
    this.minPrice,
    this.maxPrice,
    this.region,
    this.minRating,
  });

  MapFilters copyWith({
    List<CampsiteType>? types,
    double? minPrice,
    double? maxPrice,
    String? region,
    double? minRating,
  }) {
    return MapFilters(
      types: types ?? this.types,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      region: region ?? this.region,
      minRating: minRating ?? this.minRating,
    );
  }
}

/// Provider pour les filtres actuels
final mapFiltersProvider = StateProvider<MapFilters>((ref) {
  return const MapFilters();
});
