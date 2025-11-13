import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class OfflineService {
  OfflineService._();

  static Box? _cacheBox;
  static bool _initialized = false;

  /// Initialiser le service de cache
  static Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();
    _cacheBox = await Hive.openBox('campbnb_cache');
    _initialized = true;
  }

  /// Sauvegarder des données en cache
  static Future<void> saveToCache<T>({
    required String key,
    required T data,
    Duration? expiry,
  }) async {
    if (_cacheBox == null) await initialize();

    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };

    await _cacheBox!.put(key, jsonEncode(cacheData));
  }

  /// Récupérer des données du cache
  static T? getFromCache<T>(String key) {
    if (_cacheBox == null) return null;

    final cached = _cacheBox!.get(key);
    if (cached == null) return null;

    try {
      final cacheData = jsonDecode(cached as String) as Map<String, dynamic>;

      // Vérifier l'expiration
      if (cacheData['expiry'] != null) {
        final timestamp = cacheData['timestamp'] as int;
        final expiry = cacheData['expiry'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;

        if (now - timestamp > expiry) {
          _cacheBox!.delete(key);
          return null;
        }
      }

      return cacheData['data'] as T;
    } catch (e) {
      return null;
    }
  }

  /// Supprimer une clé du cache
  static Future<void> removeFromCache(String key) async {
    if (_cacheBox == null) await initialize();
    await _cacheBox!.delete(key);
  }

  /// Vider tout le cache
  static Future<void> clearCache() async {
    if (_cacheBox == null) await initialize();
    await _cacheBox!.clear();
  }

  /// Vérifier si une clé existe dans le cache
  static bool hasCache(String key) {
    if (_cacheBox == null) return false;
    return _cacheBox!.containsKey(key);
  }

  /// Obtenir toutes les clés du cache
  static List<String> getAllKeys() {
    if (_cacheBox == null) return [];
    return _cacheBox!.keys.map((key) => key.toString()).toList();
  }
}
