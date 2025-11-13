/// Service de cache pour optimiser les performances
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class CacheService {
  static final Logger _logger = Logger();
  static CacheService? _instance;
  
  factory CacheService() => _instance ??= CacheService._internal();
  CacheService._internal();

 static const String _cachePrefix = 'campbnb_cache_';
  static const Duration _defaultTtl = Duration(hours: 24);

  /// Met en cache une valeur avec une durée de vie
  Future<void> setCache({
    required String key,
    required dynamic value,
    Duration? ttl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
 'value': value,
 'expires_at': DateTime.now().add(ttl ?? _defaultTtl).toIso8601String(),
      };
      await prefs.setString(
 '$_cachePrefix$key',
        jsonEncode(cacheData),
      );
    } catch (e) {
 _logger.e('Erreur lors de la mise en cache: $e');
    }
  }

  /// Récupère une valeur du cache
  Future<T?> getCache<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
 final cacheString = prefs.getString('$_cachePrefix$key');
      
      if (cacheString == null) return null;

      final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
 final expiresAt = DateTime.parse(cacheData['expires_at'] as String);

      if (DateTime.now().isAfter(expiresAt)) {
        // Cache expiré, supprimer
 await prefs.remove('$_cachePrefix$key');
        return null;
      }

 return cacheData['value'] as T?;
    } catch (e) {
 _logger.e('Erreur lors de la récupération du cache: $e');
      return null;
    }
  }

  /// Supprime une clé du cache
  Future<void> removeCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
 await prefs.remove('$_cachePrefix$key');
    } catch (e) {
 _logger.e('Erreur lors de la suppression du cache: $e');
    }
  }

  /// Vide tout le cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
 _logger.e('Erreur lors du vidage du cache: $e');
    }
  }

  /// Vérifie si une clé existe dans le cache
  Future<bool> hasCache(String key) async {
    final value = await getCache(key);
    return value != null;
  }
}


