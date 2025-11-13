import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/cache/cache_service.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../domain/repositories/listing_repository.dart';

class ListingRepositoryImpl implements ListingRepository {
  final Dio _dio = Dio();
  final String _baseUrl;
  final CacheService _cacheService = CacheService();

  ListingRepositoryImpl() : _baseUrl = AppConfig.supabaseUrl {
    _dio.options.baseUrl = '$_baseUrl/functions/v1';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  String? get _authToken {
    return SupabaseService.client.auth.currentSession?.accessToken;
  }

  ListingModel _mapToListingModel(Map<String, dynamic> json) {
    // Mapper property_type vers ListingType
    ListingType type;
    switch (json['property_type'] as String? ?? 'tent') {
      case 'tent':
        type = ListingType.tent;
        break;
      case 'rv':
        type = ListingType.rv;
        break;
      case 'cabin':
      case 'yurt':
      case 'treehouse':
        type = ListingType.readyToCamp;
        break;
      default:
        type = ListingType.tent;
    }

    // Mapper status
    ListingStatus status;
    switch (json['status'] as String? ?? 'active') {
      case 'active':
        status = ListingStatus.active;
        break;
      case 'inactive':
        status = ListingStatus.inactive;
        break;
      case 'pending':
        status = ListingStatus.pending;
        break;
      case 'rejected':
      case 'suspended':
      case 'deleted':
        status = ListingStatus.rejected;
        break;
      default:
        status = ListingStatus.active;
    }

    // Mapper images
    final imagesJson = json['image_urls'] as List<dynamic>? ?? [];
    final images = imagesJson.map((e) => e.toString()).toList();
    if (json['cover_image_url'] != null) {
      images.insert(0, json['cover_image_url'].toString());
    }

    // Mapper amenities
    final amenitiesJson = json['amenities'] as List<dynamic>? ?? [];
    final amenities = amenitiesJson.map((e) => e.toString()).toList();

    return ListingModel(
      id: json['id'] as String,
      hostId: json['host_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: type,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address_line1'] as String? ?? '',
      city: json['city'] as String,
      province: json['province'] as String,
      postalCode: json['postal_code'] as String,
      pricePerNight: (json['base_price_per_night'] as num).toDouble(),
      maxGuests: json['max_guests'] as int,
      bedrooms: json['bedrooms'] as int? ?? 0,
      bathrooms: (json['bathrooms'] as num?)?.toDouble() ?? 0.0,
      images: images,
      amenities: amenities,
      status: status,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      rating: json['average_rating'] != null
          ? (json['average_rating'] as num).toDouble()
          : null,
      reviewCount: json['total_reviews'] as int?,
    );
  }

  @override
  Future<ListingModel> getListingById(String id) async {
    try {
      // Vérifier le cache d'abord
      final cached = _cacheService.getCachedListing(id);
      if (cached != null) {
        return _mapToListingModel(cached);
      }

      final response = await _dio.get(
        '/listings/$id',
        options: Options(
          headers: {
            if (_authToken != null) 'Authorization': 'Bearer $_authToken',
          },
        ),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final listing = _mapToListingModel(data);

      // Mettre en cache
      await _cacheService.cacheListing(id, data);

      return listing;
    } catch (e) {
      // En cas d'erreur réseau, essayer le cache
      final cached = _cacheService.getCachedListing(id);
      if (cached != null) {
        return _mapToListingModel(cached);
      }
      throw Exception('Erreur lors de la récupération du listing: $e');
    }
  }

  @override
  Future<List<ListingModel>> getListings({
    String? city,
    String? province,
    ListingType? type,
    double? minPrice,
    double? maxPrice,
    int? minGuests,
    int? page,
    int? limit,
  }) async {
    try {
      // Générer une clé de cache basée sur les paramètres
      final cacheKey = _generateCacheKey(
        city: city,
        province: province,
        type: type,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minGuests: minGuests,
        page: page,
      );

      // Vérifier le cache d'abord (seulement pour la première page)
      if (page == null || page == 1) {
        final cached = _cacheService.getCachedListings(searchKey: cacheKey);
        if (cached != null) {
          return cached.map((json) => _mapToListingModel(json)).toList();
        }
      }

      final queryParams = <String, dynamic>{};
      if (city != null) queryParams['city'] = city;
      if (province != null) queryParams['province'] = province;
      if (type != null) {
        queryParams['property_type'] = type.name;
      }
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (minGuests != null) queryParams['max_guests'] = minGuests;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dio.get(
        '/listings',
        queryParameters: queryParams,
        options: Options(
          headers: {
            if (_authToken != null) 'Authorization': 'Bearer $_authToken',
          },
        ),
      );

      final data = response.data['data'] as List<dynamic>;
      final listings = data
          .map((json) => _mapToListingModel(json as Map<String, dynamic>))
          .toList();

      // Mettre en cache (seulement pour la première page)
      if (page == null || page == 1) {
        final listingsJson = data.cast<Map<String, dynamic>>();
        await _cacheService.cacheListings(listingsJson, searchKey: cacheKey);
      }

      return listings;
    } catch (e) {
      // En cas d'erreur réseau, essayer le cache
      final cacheKey = _generateCacheKey(
        city: city,
        province: province,
        type: type,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minGuests: minGuests,
        page: 1,
      );
      final cached = _cacheService.getCachedListings(searchKey: cacheKey);
      if (cached != null) {
        return cached.map((json) => _mapToListingModel(json)).toList();
      }
      throw Exception('Erreur lors de la récupération des listings: $e');
    }
  }

  String _generateCacheKey({
    String? city,
    String? province,
    ListingType? type,
    double? minPrice,
    double? maxPrice,
    int? minGuests,
    int? page,
  }) {
    final parts = <String>[];
    if (city != null) parts.add('city:$city');
    if (province != null) parts.add('province:$province');
    if (type != null) parts.add('type:${type.name}');
    if (minPrice != null) parts.add('minPrice:$minPrice');
    if (maxPrice != null) parts.add('maxPrice:$maxPrice');
    if (minGuests != null) parts.add('minGuests:$minGuests');
    if (page != null) parts.add('page:$page');
    return parts.join('|');
  }

  @override
  Future<List<ListingModel>> searchListings(String query) async {
    try {
      // Vérifier le cache d'abord
      final cacheKey = 'search:$query';
      final cached = _cacheService.getCachedListings(searchKey: cacheKey);
      if (cached != null) {
        return cached.map((json) => _mapToListingModel(json)).toList();
      }

      // Utiliser la fonction full-text search optimisée si disponible
      // Sinon, fallback sur l'endpoint standard
      try {
        final response = await SupabaseService.client.rpc(
          'search_listings_fulltext',
          params: {'search_query': query, 'p_limit': 20, 'p_page': 1},
        );

        if (response != null && response is List) {
          final listings = (response as List)
              .map((json) => _mapToListingModel(json as Map<String, dynamic>))
              .toList();

          // Mettre en cache
          final listingsJson = response.cast<Map<String, dynamic>>();
          await _cacheService.cacheListings(listingsJson, searchKey: cacheKey);

          return listings;
        }
      } catch (rpcError) {
        // Fallback sur l'endpoint standard si RPC échoue
      }

      final response = await _dio.get(
        '/listings',
        queryParameters: {'search': query},
        options: Options(
          headers: {
            if (_authToken != null) 'Authorization': 'Bearer $_authToken',
          },
        ),
      );

      final data = response.data['data'] as List<dynamic>;
      final listings = data
          .map((json) => _mapToListingModel(json as Map<String, dynamic>))
          .toList();

      // Mettre en cache
      final listingsJson = data.cast<Map<String, dynamic>>();
      await _cacheService.cacheListings(listingsJson, searchKey: cacheKey);

      return listings;
    } catch (e) {
      // En cas d'erreur réseau, essayer le cache
      final cacheKey = 'search:$query';
      final cached = _cacheService.getCachedListings(searchKey: cacheKey);
      if (cached != null) {
        return cached.map((json) => _mapToListingModel(json)).toList();
      }
      throw Exception('Erreur lors de la recherche de listings: $e');
    }
  }

  @override
  Future<ListingModel> createListing(ListingModel listing) async {
    try {
      // Mapper ListingType vers property_type
      String propertyType;
      switch (listing.type) {
        case ListingType.tent:
          propertyType = 'tent';
          break;
        case ListingType.rv:
          propertyType = 'rv';
          break;
        case ListingType.readyToCamp:
          propertyType = 'cabin';
          break;
        case ListingType.wild:
          propertyType = 'other';
          break;
      }

      final response = await _dio.post(
        '/listings',
        data: {
          'title': listing.title,
          'description': listing.description,
          'property_type': propertyType,
          'latitude': listing.latitude,
          'longitude': listing.longitude,
          'address_line1': listing.address,
          'city': listing.city,
          'province': listing.province,
          'postal_code': listing.postalCode,
          'max_guests': listing.maxGuests,
          'bedrooms': listing.bedrooms,
          'bathrooms': listing.bathrooms,
          'amenities': listing.amenities,
          'base_price_per_night': listing.pricePerNight,
          'cover_image_url': listing.images.isNotEmpty
              ? listing.images.first
              : null,
          'image_urls': listing.images,
        },
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );

      return _mapToListingModel(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erreur lors de la création du listing: $e');
    }
  }

  @override
  Future<ListingModel> updateListing(ListingModel listing) async {
    try {
      String propertyType;
      switch (listing.type) {
        case ListingType.tent:
          propertyType = 'tent';
          break;
        case ListingType.rv:
          propertyType = 'rv';
          break;
        case ListingType.readyToCamp:
          propertyType = 'cabin';
          break;
        case ListingType.wild:
          propertyType = 'other';
          break;
      }

      final response = await _dio.put(
        '/listings/${listing.id}',
        data: {
          'title': listing.title,
          'description': listing.description,
          'property_type': propertyType,
          'latitude': listing.latitude,
          'longitude': listing.longitude,
          'address_line1': listing.address,
          'city': listing.city,
          'province': listing.province,
          'postal_code': listing.postalCode,
          'max_guests': listing.maxGuests,
          'bedrooms': listing.bedrooms,
          'bathrooms': listing.bathrooms,
          'amenities': listing.amenities,
          'base_price_per_night': listing.pricePerNight,
          'cover_image_url': listing.images.isNotEmpty
              ? listing.images.first
              : null,
          'image_urls': listing.images,
        },
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );

      return _mapToListingModel(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du listing: $e');
    }
  }

  @override
  Future<void> deleteListing(String id) async {
    try {
      await _dio.delete(
        '/listings/$id',
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );
    } catch (e) {
      throw Exception('Erreur lors de la suppression du listing: $e');
    }
  }

  @override
  Future<List<ListingModel>> getHostListings(String hostId) async {
    try {
      final response = await _dio.get(
        '/listings',
        queryParameters: {'host_id': hostId},
        options: Options(
          headers: {
            if (_authToken != null) 'Authorization': 'Bearer $_authToken',
          },
        ),
      );

      final data = response.data['data'] as List<dynamic>;
      return data
          .map((json) => _mapToListingModel(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des listings de l\'hôte: $e',
      );
    }
  }
}
