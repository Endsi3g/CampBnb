import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Service de chiffrement pour les données sensibles
class EncryptionService {
  EncryptionService._();
  static final EncryptionService instance = EncryptionService._();

  static const _storage = FlutterSecureStorage();
 static const _keyStorageKey = 'encryption_key';
  
  encrypt.Encrypter? _encrypter;
  encrypt.Key? _key;

  /// Initialise le service de chiffrement
  Future<void> initialize() async {
    try {
      // Récupérer ou générer la clé de chiffrement
      final storedKey = await _storage.read(key: _keyStorageKey);
      
      if (storedKey != null) {
        _key = encrypt.Key.fromBase64(storedKey);
      } else {
        // Générer une nouvelle clé
        final key = encrypt.Key.fromSecureRandom(32);
        _key = key;
        await _storage.write(key: _keyStorageKey, value: key.base64);
      }

      // Utiliser AES-256-CBC
      final iv = encrypt.IV.fromSecureRandom(16);
      _encrypter = encrypt.Encrypter(encrypt.AES(_key!));
    } catch (e) {
 AppConfig.logger.e('Erreur lors de l\'initialisation du chiffrement: $e');
      rethrow;
    }
  }

  /// Chiffre une chaîne de caractères
  String encryptString(String plainText) {
    if (_encrypter == null || _key == null) {
 throw Exception('EncryptionService non initialisé');
    }

    try {
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypted = _encrypter!.encrypt(plainText, iv: iv);
      // Retourner IV + données chiffrées en base64
 return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
 AppConfig.logger.e('Erreur lors du chiffrement: $e');
      rethrow;
    }
  }

  /// Déchiffre une chaîne de caractères
  String decryptString(String encryptedData) {
    if (_encrypter == null || _key == null) {
 throw Exception('EncryptionService non initialisé');
    }

    try {
 final parts = encryptedData.split(':');
      if (parts.length != 2) {
 throw Exception('Format de données chiffrées invalide');
      }

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      return _encrypter!.decrypt(encrypted, iv: iv);
    } catch (e) {
 AppConfig.logger.e('Erreur lors du déchiffrement: $e');
      rethrow;
    }
  }

  /// Chiffre des données binaires
  Uint8List encryptBytes(Uint8List plainBytes) {
    if (_encrypter == null || _key == null) {
 throw Exception('EncryptionService non initialisé');
    }

    try {
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypted = _encrypter!.encryptBytes(plainBytes, iv: iv);
      // Retourner IV + données chiffrées
      final result = Uint8List(16 + encrypted.length);
      result.setRange(0, 16, iv.bytes);
      result.setRange(16, result.length, encrypted);
      return result;
    } catch (e) {
 AppConfig.logger.e('Erreur lors du chiffrement de bytes: $e');
      rethrow;
    }
  }

  /// Déchiffre des données binaires
  Uint8List decryptBytes(Uint8List encryptedBytes) {
    if (_encrypter == null || _key == null) {
 throw Exception('EncryptionService non initialisé');
    }

    try {
      final iv = encrypt.IV(encryptedBytes.sublist(0, 16));
      final encrypted = encryptedBytes.sublist(16);
      return _encrypter!.decryptBytes(encrypt.Encrypted(encrypted), iv: iv);
    } catch (e) {
 AppConfig.logger.e('Erreur lors du déchiffrement de bytes: $e');
      rethrow;
    }
  }

  /// Hash une valeur (pour les mots de passe, etc.)
  String hashValue(String value, {String? salt}) {
 final bytes = utf8.encode(value + (salt ?? ''));
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Génère un salt aléatoire
  String generateSalt() {
    final random = encrypt.Key.fromSecureRandom(16);
    return random.base64;
  }

  /// Supprime la clé de chiffrement (pour déconnexion)
  Future<void> clearKey() async {
    await _storage.delete(key: _keyStorageKey);
    _key = null;
    _encrypter = null;
  }
}


