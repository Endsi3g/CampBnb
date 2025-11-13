import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../shared/models/listing_model.dart';
import '../../domain/repositories/listing_repository.dart';
import '../../data/repositories/listing_repository_impl.dart';

part 'listing_provider.g.dart';

/// Provider pour le repository de listings
@riverpod
ListingRepository listingRepository(ListingRepositoryRef ref) {
  return ListingRepositoryImpl();
}

/// Provider pour récupérer un listing par ID
@riverpod
Future<ListingModel> listingById(
  ListingByIdRef ref,
  String id,
) async {
  final repository = ref.watch(listingRepositoryProvider);
  return await repository.getListingById(id);
}

/// Provider pour récupérer tous les listings actifs
@riverpod
Future<List<ListingModel>> listings(
  ListingsRef ref, {
  String? city,
  String? province,
  ListingType? type,
  double? minPrice,
  double? maxPrice,
  int? minGuests,
  int? page,
  int? limit,
}) async {
  final repository = ref.watch(listingRepositoryProvider);
  return await repository.getListings(
    city: city,
    province: province,
    type: type,
    minPrice: minPrice,
    maxPrice: maxPrice,
    minGuests: minGuests,
    page: page,
    limit: limit,
  );
}

/// Provider pour rechercher des listings
@riverpod
Future<List<ListingModel>> searchListings(
  SearchListingsRef ref,
  String query,
) async {
  final repository = ref.watch(listingRepositoryProvider);
  return await repository.searchListings(query);
}

/// Provider pour récupérer les listings d'un hôte
@riverpod
Future<List<ListingModel>> hostListings(
  HostListingsRef ref,
  String hostId,
) async {
  final repository = ref.watch(listingRepositoryProvider);
  return await repository.getHostListings(hostId);
}

/// Notifier pour gérer les actions sur les listings
@riverpod
class ListingNotifier extends _$ListingNotifier {
  @override
  FutureOr<void> build() {
    // État initial vide
  }

  /// Créer un listing
  Future<ListingModel> createListing(ListingModel listing) async {
    final repository = ref.read(listingRepositoryProvider);
    final created = await repository.createListing(listing);
    
    // Invalider les providers pour rafraîchir les listes
    ref.invalidate(listingsProvider);
    ref.invalidate(hostListingsProvider(listing.hostId));
    
    return created;
  }

  /// Mettre à jour un listing
  Future<ListingModel> updateListing(ListingModel listing) async {
    final repository = ref.read(listingRepositoryProvider);
    final updated = await repository.updateListing(listing);
    
    // Invalider les providers
    ref.invalidate(listingByIdProvider(listing.id));
    ref.invalidate(listingsProvider);
    ref.invalidate(hostListingsProvider(listing.hostId));
    
    return updated;
  }

  /// Supprimer un listing
  Future<void> deleteListing(String id, String hostId) async {
    final repository = ref.read(listingRepositoryProvider);
    await repository.deleteListing(id);
    
    // Invalider les providers
    ref.invalidate(listingByIdProvider(id));
    ref.invalidate(listingsProvider);
    ref.invalidate(hostListingsProvider(hostId));
  }
}

