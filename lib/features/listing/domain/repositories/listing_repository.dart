import '../../../../shared/models/listing_model.dart';

/// Interface du repository pour les listings
abstract class ListingRepository {
  /// Récupérer un listing par ID
  Future<ListingModel> getListingById(String id);

  /// Récupérer tous les listings actifs
  Future<List<ListingModel>> getListings({
    String? city,
    String? province,
    ListingType? type,
    double? minPrice,
    double? maxPrice,
    int? minGuests,
    int? page,
    int? limit,
  });

  /// Rechercher des listings par texte
  Future<List<ListingModel>> searchListings(String query);

  /// Créer un nouveau listing
  Future<ListingModel> createListing(ListingModel listing);

  /// Mettre à jour un listing
  Future<ListingModel> updateListing(ListingModel listing);

  /// Supprimer un listing
  Future<void> deleteListing(String id);

  /// Récupérer les listings d'un hôte
  Future<List<ListingModel>> getHostListings(String hostId);
}
