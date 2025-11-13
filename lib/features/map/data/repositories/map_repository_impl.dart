import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/campsite_location.dart';
import '../../domain/repositories/map_repository.dart';

/// Implémentation du repository utilisant Supabase
class MapRepositoryImpl implements MapRepository {
  final SupabaseClient _supabase;
  final Logger _logger = Logger();

  MapRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<List<CampsiteLocation>> getCampsitesInBounds({
    required double north,
    required double south,
    required double east,
    required double west,
  }) async {
    try {
      final response = await _supabase
          .from('campsites')
          .select()
          .gte('latitude', south)
          .lte('latitude', north)
          .gte('longitude', west)
          .lte('longitude', east)
          .eq('is_available', true);

      return _parseCampsites(response);
    } catch (e) {
      _logger.e('Erreur lors de la récupération des emplacements: $e');
      return [];
    }
  }

  @override
  Future<List<CampsiteLocation>> getCampsitesNearby({
    required double latitude,
    required double longitude,
    required double radiusInMeters,
  }) async {
    try {
      // Utilise la fonction PostGIS de Supabase pour la recherche par distance
      // Note: Nécessite l'extension PostGIS activée dans Supabase
      final response = await _supabase.rpc(
        'get_campsites_nearby',
        params: {
          'lat': latitude,
          'lon': longitude,
          'radius_meters': radiusInMeters,
        },
      );

      return _parseCampsites(response);
    } catch (e) {
      _logger.e('Erreur lors de la recherche à proximité: $e');
      // Fallback: recherche simple par bounds approximatifs
      final radiusDegrees = radiusInMeters / 111000.0; // Approximation
      return getCampsitesInBounds(
        north: latitude + radiusDegrees,
        south: latitude - radiusDegrees,
        east: longitude + radiusDegrees,
        west: longitude - radiusDegrees,
      );
    }
  }

  @override
  Future<List<CampsiteLocation>> searchCampsitesByRegion(String region) async {
    try {
      final response = await _supabase
          .from('campsites')
          .select()
          .ilike('region', '%$region%')
          .eq('is_available', true);

      return _parseCampsites(response);
    } catch (e) {
      _logger.e('Erreur lors de la recherche par région: $e');
      return [];
    }
  }

  @override
  Future<List<CampsiteLocation>> searchCampsitesByText(String query) async {
    try {
      final response = await _supabase
          .from('campsites')
          .select()
          .or(
            'name.ilike.%$query%,description.ilike.%$query%,region.ilike.%$query%',
          )
          .eq('is_available', true)
          .limit(50);

      return _parseCampsites(response);
    } catch (e) {
      _logger.e('Erreur lors de la recherche textuelle: $e');
      return [];
    }
  }

  @override
  Future<List<CampsiteLocation>> filterCampsites({
    List<CampsiteType>? types,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? isAvailable,
  }) async {
    try {
      var query = _supabase.from('campsites').select();

      if (types != null && types.isNotEmpty) {
        final typeStrings = types.map((t) => t.name).toList();
        query = query.in_('type', typeStrings);
      }

      if (minPrice != null) {
        query = query.gte('price_per_night', minPrice);
      }

      if (maxPrice != null) {
        query = query.lte('price_per_night', maxPrice);
      }

      if (minRating != null) {
        query = query.gte('rating', minRating);
      }

      if (isAvailable != null) {
        query = query.eq('is_available', isAvailable);
      }

      final response = await query;
      return _parseCampsites(response);
    } catch (e) {
      _logger.e('Erreur lors du filtrage: $e');
      return [];
    }
  }

  @override
  Future<CampsiteLocation?> getCampsiteById(String id) async {
    try {
      final response = await _supabase
          .from('campsites')
          .select()
          .eq('id', id)
          .single();

      return _parseCampsite(response);
    } catch (e) {
      _logger.e('Erreur lors de la récupération de l\'emplacement: $e');
      return null;
    }
  }

  @override
  Future<CampsiteLocation> createCampsite(CampsiteLocation campsite) async {
    try {
      final data = _campsiteToJson(campsite);
      final response = await _supabase
          .from('campsites')
          .insert(data)
          .select()
          .single();

      return _parseCampsite(response)!;
    } catch (e) {
      _logger.e('Erreur lors de la création de l\'emplacement: $e');
      rethrow;
    }
  }

  @override
  Future<CampsiteLocation> updateCampsite(CampsiteLocation campsite) async {
    try {
      final data = _campsiteToJson(campsite);
      final response = await _supabase
          .from('campsites')
          .update(data)
          .eq('id', campsite.id)
          .select()
          .single();

      return _parseCampsite(response)!;
    } catch (e) {
      _logger.e('Erreur lors de la mise à jour de l\'emplacement: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCampsite(String id) async {
    try {
      await _supabase.from('campsites').delete().eq('id', id);
    } catch (e) {
      _logger.e('Erreur lors de la suppression de l\'emplacement: $e');
      rethrow;
    }
  }

  /// Parse une liste de campsites depuis la réponse Supabase
  List<CampsiteLocation> _parseCampsites(dynamic response) {
    if (response == null) return [];
    if (response is! List) return [];

    return response
        .map((json) => _parseCampsite(json))
        .whereType<CampsiteLocation>()
        .toList();
  }

  /// Parse un campsite depuis JSON
  CampsiteLocation? _parseCampsite(Map<String, dynamic> json) {
    try {
      return CampsiteLocation(
        id: json['id'] as String,
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        type: CampsiteType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => CampsiteType.tent,
        ),
        description: json['description'] as String?,
        pricePerNight: json['price_per_night'] != null
            ? (json['price_per_night'] as num).toDouble()
            : null,
        hostId: json['host_id'] as String?,
        imageUrl: json['image_url'] as String?,
        rating: json['rating'] != null
            ? (json['rating'] as num).toDouble()
            : null,
        reviewCount: json['review_count'] as int?,
        isAvailable: json['is_available'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );
    } catch (e) {
      _logger.e('Erreur lors du parsing du campsite: $e');
      return null;
    }
  }

  /// Convertit un CampsiteLocation en JSON pour Supabase
  Map<String, dynamic> _campsiteToJson(CampsiteLocation campsite) {
    return {
      'id': campsite.id,
      'name': campsite.name,
      'latitude': campsite.latitude,
      'longitude': campsite.longitude,
      'type': campsite.type.name,
      'description': campsite.description,
      'price_per_night': campsite.pricePerNight,
      'host_id': campsite.hostId,
      'image_url': campsite.imageUrl,
      'rating': campsite.rating,
      'review_count': campsite.reviewCount,
      'is_available': campsite.isAvailable,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
