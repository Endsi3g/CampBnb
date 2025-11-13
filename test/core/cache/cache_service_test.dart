import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:campbnb_quebec/core/cache/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUpAll(() async {
      // Initialiser Hive pour les tests
      await Hive.initFlutter();
    });

    setUp(() async {
      cacheService = CacheService();
      await cacheService.initialize();
      // Nettoyer le cache avant chaque test
      await cacheService.clearCache();
    });

    tearDown(() async {
      // Nettoyer après chaque test
      await cacheService.clearCache();
    });

    test('devrait initialiser correctement', () async {
      expect(cacheService, isNotNull);
      // L'initialisation devrait être complète
      await cacheService.initialize();
      // Pas d'exception = succès
    });

    test('devrait mettre en cache et récupérer un listing', () async {
      const listingId = 'test-listing-123';
      final listingData = {
        'id': listingId,
        'title': 'Test Listing',
        'description': 'Description de test',
        'city': 'Montreal',
        'base_price_per_night': 50.0,
      };

      // Mettre en cache
      await cacheService.cacheListing(listingId, listingData);

      // Récupérer depuis le cache
      final cached = cacheService.getCachedListing(listingId);

      expect(cached, isNotNull);
      expect(cached!['id'], equals(listingId));
      expect(cached['title'], equals('Test Listing'));
    });

    test('devrait retourner null pour un listing non mis en cache', () {
      const listingId = 'non-existent-listing';
      final cached = cacheService.getCachedListing(listingId);
      expect(cached, isNull);
    });

    test('devrait mettre en cache plusieurs listings', () async {
      final listings = [
        {
          'id': 'listing-1',
          'title': 'Listing 1',
          'city': 'Montreal',
        },
        {
          'id': 'listing-2',
          'title': 'Listing 2',
          'city': 'Quebec',
        },
      ];

      await cacheService.cacheListings(listings);

      final cached1 = cacheService.getCachedListing('listing-1');
      final cached2 = cacheService.getCachedListing('listing-2');

      expect(cached1, isNotNull);
      expect(cached2, isNotNull);
      expect(cached1!['title'], equals('Listing 1'));
      expect(cached2!['title'], equals('Listing 2'));
    });

    test('devrait mettre en cache avec une clé de recherche', () async {
      final listings = [
        {
          'id': 'listing-1',
          'title': 'Listing 1',
        },
      ];
      const searchKey = 'city:Montreal|type:tent';

      await cacheService.cacheListings(listings, searchKey: searchKey);

      final cached = cacheService.getCachedListings(searchKey: searchKey);
      expect(cached, isNotNull);
      expect(cached!.length, equals(1));
      expect(cached[0]['id'], equals('listing-1'));
    });

    test('devrait mettre en cache et récupérer une réservation', () async {
      const reservationId = 'reservation-123';
      final reservationData = {
        'id': reservationId,
        'status': 'confirmed',
        'total_price': 200.0,
      };

      await cacheService.cacheReservation(reservationId, reservationData);

      final cached = cacheService.getCachedReservation(reservationId);
      expect(cached, isNotNull);
      expect(cached!['id'], equals(reservationId));
      expect(cached['status'], equals('confirmed'));
    });

    test('devrait mettre en cache et récupérer des données utilisateur', () async {
      const userId = 'user-123';
      final userData = {
        'id': userId,
        'first_name': 'John',
        'last_name': 'Doe',
      };

      await cacheService.cacheUserData(userId, userData);

      final cached = cacheService.getCachedUserData(userId);
      expect(cached, isNotNull);
      expect(cached!['id'], equals(userId));
      expect(cached['first_name'], equals('John'));
    });

    test('devrait supprimer un élément du cache', () async {
      const listingId = 'listing-to-delete';
      final listingData = {'id': listingId, 'title': 'To Delete'};

      await cacheService.cacheListing(listingId, listingData);
      expect(cacheService.getCachedListing(listingId), isNotNull);

      await cacheService.removeFromCache(listingId, type: CacheType.listing);
      expect(cacheService.getCachedListing(listingId), isNull);
    });

    test('devrait vider le cache', () async {
      // Ajouter des données
      await cacheService.cacheListing('listing-1', {'id': 'listing-1'});
      await cacheService.cacheReservation('reservation-1', {'id': 'reservation-1'});

      // Vider le cache
      await cacheService.clearCache();

      // Vérifier que tout est supprimé
      expect(cacheService.getCachedListing('listing-1'), isNull);
      expect(cacheService.getCachedReservation('reservation-1'), isNull);
    });

    test('devrait vider un type de cache spécifique', () async {
      await cacheService.cacheListing('listing-1', {'id': 'listing-1'});
      await cacheService.cacheReservation('reservation-1', {'id': 'reservation-1'});

      // Vider seulement les listings
      await cacheService.clearCache(type: CacheType.listing);

      expect(cacheService.getCachedListing('listing-1'), isNull);
      // Les réservations devraient toujours être là
      expect(cacheService.getCachedReservation('reservation-1'), isNotNull);
    });

    test('devrait retourner la taille du cache', () async {
      await cacheService.cacheListing('listing-1', {
        'id': 'listing-1',
        'title': 'Test',
        'description': 'Description de test',
      });

      final size = await cacheService.getCacheSize();
      expect(size, greaterThan(0));
    });

    test('devrait gérer les erreurs gracieusement', () async {
      // Tester avec des données invalides
      await cacheService.cacheListing('test', {'id': 'test'});
      
      // Récupérer devrait fonctionner même si les données sont simples
      final cached = cacheService.getCachedListing('test');
      expect(cached, isNotNull);
    });
  });
}
