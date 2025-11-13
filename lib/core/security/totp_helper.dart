import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Helper pour la génération et vérification de codes TOTP
/// Basé sur RFC 6238 (TOTP: Time-Based One-Time Password Algorithm)
class TOTPHelper {
  /// Génère un secret aléatoire de 32 caractères (base32)
  static String generateSecret() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Génère un code TOTP à 6 chiffres
  static String generateCode(String secret, {int timeStep = 30}) {
    final time = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final counter = time ~/ timeStep;
    return _generateHOTP(secret, counter);
  }

  /// Vérifie un code TOTP
  static bool verifyCode(
    String code,
    String secret, {
    int timeStep = 30,
    int window = 1,
  }) {
    final time = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final counter = time ~/ timeStep;

    // Vérifier le code pour le compteur actuel et les fenêtres adjacentes
    for (int i = -window; i <= window; i++) {
      final testCounter = counter + i;
      final testCode = _generateHOTP(secret, testCounter);
      if (testCode == code) {
        return true;
      }
    }
    return false;
  }

  /// Génère un code HOTP (HMAC-Based One-Time Password)
  static String _generateHOTP(String secret, int counter) {
    // Décoder le secret base32
    final key = _base32Decode(secret);

    // Convertir le compteur en bytes (8 bytes, big-endian)
    final counterBytes = List<int>.generate(
      8,
      (i) => (counter >> (56 - i * 8)) & 0xFF,
    );

    // Calculer HMAC-SHA256
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(counterBytes);
    final hash = digest.bytes;

    // Dynamic Truncation (RFC 4226)
    final offset = hash[hash.length - 1] & 0x0F;
    final binary =
        ((hash[offset] & 0x7F) << 24) |
        ((hash[offset + 1] & 0xFF) << 16) |
        ((hash[offset + 2] & 0xFF) << 8) |
        (hash[offset + 3] & 0xFF);

    final otp = binary % 1000000;
    return otp.toString().padLeft(6, '0');
  }

  /// Décode une chaîne base32
  static List<int> _base32Decode(String input) {
    const base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    input = input.toUpperCase();

    int bits = 0;
    int value = 0;
    final output = <int>[];

    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == '=') break;

      final index = base32Chars.indexOf(char);
      if (index == -1) continue;

      value = (value << 5) | index;
      bits += 5;

      if (bits >= 8) {
        output.add((value >> (bits - 8)) & 0xFF);
        bits -= 8;
      }
    }

    return output;
  }

  /// Génère l'URL pour le QR code TOTP
  static String generateOTPAuthUrl({
    required String secret,
    required String accountName,
    required String issuer,
    int digits = 6,
    int period = 30,
    String algorithm = 'SHA256',
  }) {
    final encodedIssuer = Uri.encodeComponent(issuer);
    final encodedAccountName = Uri.encodeComponent(accountName);

    return 'otpauth://totp/$encodedIssuer:$encodedAccountName?'
        'secret=$secret&'
        'issuer=$encodedIssuer&'
        'algorithm=$algorithm&'
        'digits=$digits&'
        'period=$period';
  }
}
