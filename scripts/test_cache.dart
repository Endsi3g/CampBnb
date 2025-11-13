/// Script de test manuel pour valider le fonctionnement du cache
/// Usage: flutter run scripts/test_cache.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../lib/core/cache/cache_service.dart';
import '../lib/core/cache/cache_validator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('\n🧪 Test du Cache Service\n');
  print('=' * 60);
  
  // Exécuter la validation
  await CacheValidator.printValidationReport();
  
  // Tests supplémentaires
  print('\n📝 Tests supplémentaires:\n');
  
  final cacheService = CacheService();
  await cacheService.initialize();
  
  // Test 1: Performance
  print('1. Test de performance...');
  final stopwatch = Stopwatch()..start();
  
  for (int i = 0; i < 100; i++) {
    await cacheService.cacheListing('perf-test-$i', {
      'id': 'perf-test-$i',
      'title': 'Performance Test $i',
    });
  }
  
  stopwatch.stop();
  print('   ✅ 100 listings mis en cache en ${stopwatch.elapsedMilliseconds}ms');
  print('   📊 Moyenne: ${stopwatch.elapsedMilliseconds / 100}ms par listing\n');
  
  // Test 2: Récupération
  print('2. Test de récupération...');
  stopwatch.reset();
  stopwatch.start();
  
  int hits = 0;
  for (int i = 0; i < 100; i++) {
    final cached = cacheService.getCachedListing('perf-test-$i');
    if (cached != null) hits++;
  }
  
  stopwatch.stop();
  print('   ✅ 100 listings récupérés en ${stopwatch.elapsedMilliseconds}ms');
  print('   📊 Cache hits: $hits/100');
  print('   📊 Moyenne: ${stopwatch.elapsedMilliseconds / 100}ms par récupération\n');
  
  // Test 3: Taille du cache
  print('3. Taille du cache...');
  final size = await cacheService.getCacheSize();
  print('   📊 Taille: ${(size / 1024).toStringAsFixed(2)} KB');
  print('   📊 Taille: ${(size / 1024 / 1024).toStringAsFixed(2)} MB\n');
  
  // Test 4: Nettoyage
  print('4. Test de nettoyage...');
  await cacheService.clearCache();
  final sizeAfterClear = await cacheService.getCacheSize();
  print('   ✅ Cache vidé');
  print('   📊 Taille après nettoyage: ${(sizeAfterClear / 1024).toStringAsFixed(2)} KB\n');
  
  print('=' * 60);
  print('\n✅ Tous les tests terminés!\n');
}

