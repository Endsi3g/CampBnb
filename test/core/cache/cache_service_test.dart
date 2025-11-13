import 'package:flutter_test/flutter_test.dart';
import 'package:campbnb_quebec/core/cache/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService();
    });

    tearDown(() async {
      await cacheService.clearCache();
    });

    test('setCache et getCache - fonctionne correctement', () async {
      await cacheService.setCache(
        key: 'test_key',
        value: 'test_value',
      );

      final value = await cacheService.getCache<String>('test_key');
      expect(value, equals('test_value'));
    });

    test('getCache - retourne null pour clé inexistante', () async {
      final value = await cacheService.getCache<String>('non_existent');
      expect(value, isNull);
    });

    test('hasCache - retourne true si la clé existe', () async {
      await cacheService.setCache(
        key: 'test_key',
        value: 'test_value',
      );

      expect(await cacheService.hasCache('test_key'), isTrue);
      expect(await cacheService.hasCache('non_existent'), isFalse);
    });

    test('removeCache - supprime la clé', () async {
      await cacheService.setCache(
        key: 'test_key',
        value: 'test_value',
      );

      await cacheService.removeCache('test_key');
      final value = await cacheService.getCache<String>('test_key');
      expect(value, isNull);
    });

    test('clearCache - vide tout le cache', () async {
      await cacheService.setCache(key: 'key1', value: 'value1');
      await cacheService.setCache(key: 'key2', value: 'value2');

      await cacheService.clearCache();

      expect(await cacheService.getCache('key1'), isNull);
      expect(await cacheService.getCache('key2'), isNull);
    });
  });
}

