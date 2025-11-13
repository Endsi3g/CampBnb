/// Service de cache persistant utilisant Hive
/// Permet de mettre en cache les données pour améliorer les performances et le support offline
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../../core/monitoring/error_monitoring_service.dart';

class CacheService {
  static final Logger _logger = Logger();
  static CacheService? _instance;
  static const String _listingsBox = 'listings_cache';
  static const String _reservationsBox = 'reservations_cache';
  static const String _userDataBox = 'user_data_cache';
  static const String _searchResultsBox = 'search_results_cache';
  
  // Durée de vie du cache (en heures)
  static const int _cacheExpirationHours = 24;
  
  bool _initialized = false;

  factory CacheService() => _instance ??= CacheService._internal();
  CacheService._internal();

  /// Initialise le service de cache
  Future<void> initialize() async {
    if (_initialized) {
      _logger.d('CacheService déjà initialisé');
      return;
    }

    try {
      // Initialiser Hive (peut être appelé plusieurs fois sans problème)
      try {
        await Hive.initFlutter();
      } catch (e) {
        // Hive peut déjà être initialisé par un autre service (ex: OfflineService)
        // C'est OK, on continue
        _logger.d('Hive déjà initialisé, continuation...');
      }
      
      // Ouvrir les boxes de cache (avec gestion des erreurs si déjà ouvertes)
      try {
        if (!Hive.isBoxOpen(_listingsBox)) {
          await Hive.openBox(_listingsBox);
        }
      } catch (e) {
        _logger.w('Box $_listingsBox déjà ouverte ou erreur: $e');
      }

      try {
        if (!Hive.isBoxOpen(_reservationsBox)) {
          await Hive.openBox(_reservationsBox);
        }
      } catch (e) {
        _logger.w('Box $_reservationsBox déjà ouverte ou erreur: $e');
      }

      try {
        if (!Hive.isBoxOpen(_userDataBox)) {
          await Hive.openBox(_userDataBox);
        }
      } catch (e) {
        _logger.w('Box $_userDataBox déjà ouverte ou erreur: $e');
      }

      try {
        if (!Hive.isBoxOpen(_searchResultsBox)) {
          await Hive.openBox(_searchResultsBox);
        }
      } catch (e) {
        _logger.w('Box $_searchResultsBox déjà ouverte ou erreur: $e');
      }
      
      _initialized = true;
      _logger.i('CacheService initialisé avec succès');
      
      // Nettoyer le cache expiré au démarrage
      await _cleanExpiredCache();
    } catch (e, stackTrace) {
      _logger.e('Erreur lors de l\'initialisation du cache', error: e, stackTrace: stackTrace);
      ErrorMonitoringService().captureException(
        e,
        stackTrace: stackTrace,
        context: {'component': 'cache_service', 'action': 'initialize'},
      );
    }
  }

  /// Met en cache un listing
  Future<void> cacheListing(String listingId, Map<String, dynamic> data) async {
    if (!_initialized) await initialize();
    
    try {
      final box = Hive.box(_listingsBox);
      final cacheEntry = {
        'data': data,
        'cached_at': DateTime.now().toIso8601String(),
      };
      await box.put(listingId, cacheEntry);
      _logger.d('Listing $listingId mis en cache');
    } catch (e) {
      _logger.e('Erreur lors de la mise en cache du listing', error: e);
    }
  }

  /// Récupère un listing depuis le cache
  Map<String, dynamic>? getCachedListing(String listingId) {
    if (!_initialized) return null;
    
    try {
      final box = Hive.box(_listingsBox);
      final cacheEntry = box.get(listingId) as Map<String, dynamic>?;
      
      if (cacheEntry == null) return null;
      
      // Vérifier si le cache est expiré
      final cachedAt = DateTime.parse(cacheEntry['cached_at'] as String);
      final now = DateTime.now();
      final hoursSinceCache = now.difference(cachedAt).inHours;
      
      if (hoursSinceCache > _cacheExpirationHours) {
        _logger.d('Cache expiré pour listing $listingId');
        box.delete(listingId);
        return null;
      }
      
      return cacheEntry['data'] as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Erreur lors de la récupération du cache', error: e);
      return null;
    }
  }

  /// Met en cache une liste de listings
  Future<void> cacheListings(List<Map<String, dynamic>> listings, {String? searchKey}) async {
    if (!_initialized) await initialize();
    
    try {
      final box = Hive.box(_listingsBox);
      
      for (final listing in listings) {
        final listingId = listing['id'] as String;
        final cacheEntry = {
          'data': listing,
          'cached_at': DateTime.now().toIso8601String(),
        };
        await box.put(listingId, cacheEntry);
      }
      
      // Si une clé de recherche est fournie, la mettre en cache aussi
      if (searchKey != null) {
        final searchBox = Hive.box(_searchResultsBox);
        await searchBox.put(searchKey, {
          'listing_ids': listings.map((l) => l['id'] as String).toList(),
          'cached_at': DateTime.now().toIso8601String(),
        });
      }
      
      _logger.d('${listings.length} listing(s) mis(s) en cache');
    } catch (e) {
      _logger.e('Erreur lors de la mise en cache des listings', error: e);
    }
  }

  /// Récupère les listings depuis le cache
  List<Map<String, dynamic>>? getCachedListings({String? searchKey}) {
    if (!_initialized) return null;
    
    try {
      if (searchKey != null) {
        // Récupérer depuis la clé de recherche
        final searchBox = Hive.box(_searchResultsBox);
        final searchCache = searchBox.get(searchKey) as Map<String, dynamic>?;
        
        if (searchCache == null) return null;
        
        // Vérifier expiration
        final cachedAt = DateTime.parse(searchCache['cached_at'] as String);
        if (DateTime.now().difference(cachedAt).inHours > _cacheExpirationHours) {
          searchBox.delete(searchKey);
          return null;
        }
        
        final listingIds = searchCache['listing_ids'] as List<dynamic>;
        final box = Hive.box(_listingsBox);
        final listings = <Map<String, dynamic>>[];
        
        for (final id in listingIds) {
          final cacheEntry = box.get(id) as Map<String, dynamic>?;
          if (cacheEntry != null) {
            listings.add(cacheEntry['data'] as Map<String, dynamic>);
          }
        }
        
        return listings.isNotEmpty ? listings : null;
      } else {
        // Récupérer tous les listings du cache
        final box = Hive.box(_listingsBox);
        final listings = <Map<String, dynamic>>[];
        
        for (final key in box.keys) {
          final cacheEntry = box.get(key) as Map<String, dynamic>?;
          if (cacheEntry != null) {
            final cachedAt = DateTime.parse(cacheEntry['cached_at'] as String);
            if (DateTime.now().difference(cachedAt).inHours <= _cacheExpirationHours) {
              listings.add(cacheEntry['data'] as Map<String, dynamic>);
            }
          }
        }
        
        return listings.isNotEmpty ? listings : null;
      }
    } catch (e) {
      _logger.e('Erreur lors de la récupération des listings en cache', error: e);
      return null;
    }
  }

  /// Met en cache une réservation
  Future<void> cacheReservation(String reservationId, Map<String, dynamic> data) async {
    if (!_initialized) await initialize();
    
    try {
      final box = Hive.box(_reservationsBox);
      final cacheEntry = {
        'data': data,
        'cached_at': DateTime.now().toIso8601String(),
      };
      await box.put(reservationId, cacheEntry);
      _logger.d('Réservation $reservationId mise en cache');
    } catch (e) {
      _logger.e('Erreur lors de la mise en cache de la réservation', error: e);
    }
  }

  /// Récupère une réservation depuis le cache
  Map<String, dynamic>? getCachedReservation(String reservationId) {
    if (!_initialized) return null;
    
    try {
      final box = Hive.box(_reservationsBox);
      final cacheEntry = box.get(reservationId) as Map<String, dynamic>?;
      
      if (cacheEntry == null) return null;
      
      // Vérifier expiration (cache plus court pour les réservations - 1 heure)
      final cachedAt = DateTime.parse(cacheEntry['cached_at'] as String);
      if (DateTime.now().difference(cachedAt).inHours > 1) {
        box.delete(reservationId);
        return null;
      }
      
      return cacheEntry['data'] as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Erreur lors de la récupération de la réservation en cache', error: e);
      return null;
    }
  }

  /// Met en cache les données utilisateur
  Future<void> cacheUserData(String userId, Map<String, dynamic> data) async {
    if (!_initialized) await initialize();
    
    try {
      final box = Hive.box(_userDataBox);
      final cacheEntry = {
        'data': data,
        'cached_at': DateTime.now().toIso8601String(),
      };
      await box.put(userId, cacheEntry);
      _logger.d('Données utilisateur $userId mises en cache');
    } catch (e) {
      _logger.e('Erreur lors de la mise en cache des données utilisateur', error: e);
    }
  }

  /// Récupère les données utilisateur depuis le cache
  Map<String, dynamic>? getCachedUserData(String userId) {
    if (!_initialized) return null;
    
    try {
      final box = Hive.box(_userDataBox);
      final cacheEntry = box.get(userId) as Map<String, dynamic>?;
      
      if (cacheEntry == null) return null;
      
      // Vérifier expiration (12 heures pour les données utilisateur)
      final cachedAt = DateTime.parse(cacheEntry['cached_at'] as String);
      if (DateTime.now().difference(cachedAt).inHours > 12) {
        box.delete(userId);
        return null;
      }
      
      return cacheEntry['data'] as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Erreur lors de la récupération des données utilisateur en cache', error: e);
      return null;
    }
  }

  /// Supprime un élément du cache
  Future<void> removeFromCache(String key, {CacheType type = CacheType.listing}) async {
    if (!_initialized) await initialize();
    
    try {
      final boxName = _getBoxName(type);
      final box = Hive.box(boxName);
      await box.delete(key);
      _logger.d('Élément $key supprimé du cache ($boxName)');
    } catch (e) {
      _logger.e('Erreur lors de la suppression du cache', error: e);
    }
  }

  /// Vide tout le cache
  Future<void> clearCache({CacheType? type}) async {
    if (!_initialized) await initialize();
    
    try {
      if (type != null) {
        final boxName = _getBoxName(type);
        final box = Hive.box(boxName);
        await box.clear();
        _logger.i('Cache $boxName vidé');
      } else {
        // Vider tous les caches
        await Hive.box(_listingsBox).clear();
        await Hive.box(_reservationsBox).clear();
        await Hive.box(_userDataBox).clear();
        await Hive.box(_searchResultsBox).clear();
        _logger.i('Tous les caches vidés');
      }
    } catch (e) {
      _logger.e('Erreur lors du vidage du cache', error: e);
    }
  }

  /// Nettoie le cache expiré
  Future<void> _cleanExpiredCache() async {
    try {
      final boxes = [
        (_listingsBox, _cacheExpirationHours),
        (_reservationsBox, 1), // 1 heure pour les réservations
        (_userDataBox, 12), // 12 heures pour les données utilisateur
        (_searchResultsBox, _cacheExpirationHours),
      ];

      int totalCleaned = 0;

      for (final (boxName, expirationHours) in boxes) {
        final box = Hive.box(boxName);
        final keysToDelete = <dynamic>[];

        for (final key in box.keys) {
          final cacheEntry = box.get(key) as Map<String, dynamic>?;
          if (cacheEntry != null) {
            final cachedAt = DateTime.parse(cacheEntry['cached_at'] as String);
            if (DateTime.now().difference(cachedAt).inHours > expirationHours) {
              keysToDelete.add(key);
            }
          }
        }

        for (final key in keysToDelete) {
          await box.delete(key);
          totalCleaned++;
        }
      }

      if (totalCleaned > 0) {
        _logger.i('$totalCleaned élément(s) expiré(s) supprimé(s) du cache');
      }
    } catch (e) {
      _logger.e('Erreur lors du nettoyage du cache', error: e);
    }
  }

  String _getBoxName(CacheType type) {
    switch (type) {
      case CacheType.listing:
        return _listingsBox;
      case CacheType.reservation:
        return _reservationsBox;
      case CacheType.userData:
        return _userDataBox;
      case CacheType.searchResults:
        return _searchResultsBox;
    }
  }

  /// Obtient la taille du cache en octets
  Future<int> getCacheSize() async {
    if (!_initialized) return 0;
    
    try {
      int totalSize = 0;
      final boxes = [_listingsBox, _reservationsBox, _userDataBox, _searchResultsBox];
      
      for (final boxName in boxes) {
        final box = Hive.box(boxName);
        for (final key in box.keys) {
          final value = box.get(key);
          if (value != null) {
            // Estimation approximative de la taille
            totalSize += value.toString().length;
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      _logger.e('Erreur lors du calcul de la taille du cache', error: e);
      return 0;
    }
  }
}

enum CacheType {
  listing,
  reservation,
  userData,
  searchResults,
}
