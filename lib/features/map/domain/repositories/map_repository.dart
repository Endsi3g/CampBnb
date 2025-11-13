import '../entities/campsite_location.dart';

/// Repository pour les opérations cartographiques
abstract class MapRepository {
  /// Récupère les emplacements de camping dans une zone donnée
  Future<List<CampsiteLocation>> getCampsitesInBounds({
    required double north,
    required double south,
    required double east,
    required double west,
  });

  /// Récupère les emplacements de camping à proximité d'un point
  Future<List<CampsiteLocation>> getCampsitesNearby({
    required double latitude,
    required double longitude,
    required double radiusInMeters,
  });

  /// Recherche des emplacements par région
  Future<List<CampsiteLocation>> searchCampsitesByRegion(String region);

  /// Recherche des emplacements par texte (nom, description, etc.)
  Future<List<CampsiteLocation>> searchCampsitesByText(String query);

  /// Filtre les emplacements selon des critères
  Future<List<CampsiteLocation>> filterCampsites({
    List<CampsiteType>? types,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? isAvailable,
  });

  /// Récupère un emplacement par son ID
  Future<CampsiteLocation?> getCampsiteById(String id);

  /// Crée un nouvel emplacement (pour les hôtes)
  Future<CampsiteLocation> createCampsite(CampsiteLocation campsite);

  /// Met à jour un emplacement existant
  Future<CampsiteLocation> updateCampsite(CampsiteLocation campsite);

  /// Supprime un emplacement
  Future<void> deleteCampsite(String id);
}
