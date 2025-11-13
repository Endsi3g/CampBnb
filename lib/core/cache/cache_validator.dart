/// Utilitaire pour valider le fonctionnement du cache
/// Peut être utilisé pour des tests manuels ou des diagnostics
import 'package:logger/logger.dart';
import 'cache_service.dart';

class CacheValidator {
  static final Logger _logger = Logger();
  static final CacheService _cacheService = CacheService();

  /// Valide que le cache fonctionne correctement
  static Future<Map<String, dynamic>> validateCache() async {
    final results = <String, dynamic>{
      'initialized': false,
      'tests': <String, bool>{},
      'errors': <String>[],
    };

    try {
      // Test 1: Initialisation
      try {
        await _cacheService.initialize();
        results['initialized'] = true;
        results['tests']['initialization'] = true;
        _logger.i('✅ Cache initialisé');
      } catch (e) {
        results['errors'].add('Erreur d\'initialisation: $e');
        results['tests']['initialization'] = false;
        _logger.e('❌ Erreur d\'initialisation: $e');
        return results;
      }

      // Test 2: Mise en cache d'un listing
      try {
        const testListingId = 'cache-test-listing';
        final testListing = {
          'id': testListingId,
          'title': 'Test Cache Listing',
          'description': 'Ceci est un test de cache',
          'city': 'Montreal',
          'base_price_per_night': 100.0,
          'cached_at': DateTime.now().toIso8601String(),
        };

        await _cacheService.cacheListing(testListingId, testListing);
        results['tests']['cache_listing'] = true;
        _logger.i('✅ Listing mis en cache');
      } catch (e) {
        results['errors'].add('Erreur mise en cache listing: $e');
        results['tests']['cache_listing'] = false;
        _logger.e('❌ Erreur mise en cache listing: $e');
      }

      // Test 3: Récupération d'un listing
      try {
        const testListingId = 'cache-test-listing';
        final cached = _cacheService.getCachedListing(testListingId);

        if (cached != null && cached['id'] == testListingId) {
          results['tests']['retrieve_listing'] = true;
          _logger.i('✅ Listing récupéré depuis le cache');
        } else {
          results['errors'].add('Listing non trouvé dans le cache');
          results['tests']['retrieve_listing'] = false;
          _logger.w('⚠️ Listing non trouvé dans le cache');
        }
      } catch (e) {
        results['errors'].add('Erreur récupération listing: $e');
        results['tests']['retrieve_listing'] = false;
        _logger.e('❌ Erreur récupération listing: $e');
      }

      // Test 4: Mise en cache de plusieurs listings
      try {
        final testListings = [
          {'id': 'listing-1', 'title': 'Listing 1', 'city': 'Montreal'},
          {'id': 'listing-2', 'title': 'Listing 2', 'city': 'Quebec'},
        ];

        await _cacheService.cacheListings(
          testListings,
          searchKey: 'test-search',
        );
        results['tests']['cache_multiple_listings'] = true;
        _logger.i('✅ Plusieurs listings mis en cache');
      } catch (e) {
        results['errors'].add('Erreur mise en cache multiple: $e');
        results['tests']['cache_multiple_listings'] = false;
        _logger.e('❌ Erreur mise en cache multiple: $e');
      }

      // Test 5: Récupération avec clé de recherche
      try {
        final cached = _cacheService.getCachedListings(
          searchKey: 'test-search',
        );

        if (cached != null && cached.length == 2) {
          results['tests']['retrieve_with_search_key'] = true;
          _logger.i('✅ Listings récupérés avec clé de recherche');
        } else {
          results['errors'].add('Listings non trouvés avec clé de recherche');
          results['tests']['retrieve_with_search_key'] = false;
          _logger.w('⚠️ Listings non trouvés avec clé de recherche');
        }
      } catch (e) {
        results['errors'].add('Erreur récupération avec clé: $e');
        results['tests']['retrieve_with_search_key'] = false;
        _logger.e('❌ Erreur récupération avec clé: $e');
      }

      // Test 6: Taille du cache
      try {
        final size = await _cacheService.getCacheSize();
        results['cache_size_bytes'] = size;
        results['cache_size_mb'] = (size / 1024 / 1024).toStringAsFixed(2);
        results['tests']['cache_size'] = true;
        _logger.i('✅ Taille du cache: ${results['cache_size_mb']} MB');
      } catch (e) {
        results['errors'].add('Erreur calcul taille cache: $e');
        results['tests']['cache_size'] = false;
        _logger.e('❌ Erreur calcul taille cache: $e');
      }

      // Test 7: Suppression
      try {
        await _cacheService.removeFromCache(
          'cache-test-listing',
          type: CacheType.listing,
        );
        final cached = _cacheService.getCachedListing('cache-test-listing');

        if (cached == null) {
          results['tests']['remove_from_cache'] = true;
          _logger.i('✅ Élément supprimé du cache');
        } else {
          results['errors'].add('Élément non supprimé du cache');
          results['tests']['remove_from_cache'] = false;
          _logger.w('⚠️ Élément non supprimé du cache');
        }
      } catch (e) {
        results['errors'].add('Erreur suppression: $e');
        results['tests']['remove_from_cache'] = false;
        _logger.e('❌ Erreur suppression: $e');
      }

      // Calculer le score global
      final passedTests = results['tests'].values
          .where((v) => v == true)
          .length;
      final totalTests = results['tests'].length;
      results['score'] = '$passedTests/$totalTests';
      results['success_rate'] = (passedTests / totalTests * 100)
          .toStringAsFixed(1);

      if (passedTests == totalTests) {
        _logger.i(
          '✅ Tous les tests du cache ont réussi ($passedTests/$totalTests)',
        );
      } else {
        _logger.w('⚠️ Certains tests ont échoué ($passedTests/$totalTests)');
      }
    } catch (e, stackTrace) {
      results['errors'].add('Erreur générale: $e');
      _logger.e(
        '❌ Erreur générale lors de la validation',
        error: e,
        stackTrace: stackTrace,
      );
    }

    return results;
  }

  /// Affiche un rapport de validation dans la console
  static Future<void> printValidationReport() async {
    print('\n🔍 Validation du Cache Service\n');
    print('=' * 50);

    final results = await validateCache();

    print('\n📊 Résultats:');
    print('  Initialisé: ${results['initialized'] ? '✅' : '❌'}');
    print('  Score: ${results['score']}');
    print('  Taux de réussite: ${results['success_rate']}%');

    if (results['cache_size_mb'] != null) {
      print('  Taille du cache: ${results['cache_size_mb']} MB');
    }

    print('\n🧪 Tests:');
    final tests = results['tests'] as Map<String, bool>;
    tests.forEach((test, passed) {
      print('  ${passed ? '✅' : '❌'} $test');
    });

    if (results['errors'].isNotEmpty) {
      print('\n❌ Erreurs:');
      for (final error in results['errors']) {
        print('  - $error');
      }
    }

    print('\n' + '=' * 50 + '\n');
  }
}
