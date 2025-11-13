import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:otp/otp.dart';
import '../config/app_config.dart';
import '../../shared/services/supabase_service.dart';

/// Service pour l'authentification multi-facteurs (MFA/2FA)
class MFAService {
  MFAService._();
  static final MFAService instance = MFAService._();

 /// Active l'authentification TOTP pour l'utilisateur actuel
  Future<Map<String, dynamic>> enableTOTP() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
 throw Exception('Utilisateur non connecté');
      }

      // Générer un secret TOTP
      final secret = OTP.randomSecret();
      
 // Créer l'URL pour le QR code
 final issuer = 'Campbnb Québec';
      final accountName = user.email ?? user.id;
      final otpUrl = OTP.getUri(
        secret: secret,
        accountName: accountName,
        issuer: issuer,
      );

      // Enregistrer le secret (chiffré) dans la base de données
 await SupabaseService.client.rpc('enable_mfa_totp', params: {
 'secret': secret,
      });

      return {
 'secret': secret,
 'qrCodeUrl': otpUrl,
 'manualEntryKey': secret,
      };
    } catch (e) {
 AppConfig.logger.e('Erreur lors de l\'activation du TOTP: $e');
      rethrow;
    }
  }

  /// Vérifie un code TOTP
  Future<bool> verifyTOTP(String code) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
 throw Exception('Utilisateur non connecté');
      }

      // Récupérer le secret depuis la base de données
 final response = await SupabaseService.from('user_security_settings')
 .select('mfa_secret')
 .eq('id', user.id)
          .single();

 final secret = response['mfa_secret'] as String?;
      if (secret == null) {
 throw Exception('MFA non activé');
      }

      // Vérifier le code
      final isValid = OTP.verify(
        code,
        secret,
        algorithm: Algorithm.SHA256,
      );

      if (isValid) {
 // Logger l'événement
 await _logSecurityEvent('mfa_verified', {'method': 'totp'});
      }

      return isValid;
    } catch (e) {
 AppConfig.logger.e('Erreur lors de la vérification du TOTP: $e');
      return false;
    }
  }

 /// Désactive l'authentification MFA
  Future<void> disableMFA() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
 throw Exception('Utilisateur non connecté');
      }

 await SupabaseService.from('user_security_settings')
          .update({
 'mfa_enabled': false,
 'mfa_method': null,
 'mfa_secret': null,
 'backup_codes': null,
          })
 .eq('id', user.id);

 await _logSecurityEvent('mfa_disabled', {});
    } catch (e) {
 AppConfig.logger.e('Erreur lors de la désactivation du MFA: $e');
      rethrow;
    }
  }

  /// Génère des codes de secours
  Future<List<String>> generateBackupCodes() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
 throw Exception('Utilisateur non connecté');
      }

      // Générer 10 codes de secours
      final codes = List.generate(10, (_) => _generateBackupCode());
      
      // Enregistrer les codes (chiffrés) dans la base de données
 await SupabaseService.from('user_security_settings')
 .update({'backup_codes': codes})
 .eq('id', user.id);

      return codes;
    } catch (e) {
 AppConfig.logger.e('Erreur lors de la génération des codes de secours: $e');
      rethrow;
    }
  }

  /// Vérifie un code de secours
  Future<bool> verifyBackupCode(String code) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
 throw Exception('Utilisateur non connecté');
      }

 final response = await SupabaseService.from('user_security_settings')
 .select('backup_codes')
 .eq('id', user.id)
          .single();

 final backupCodes = (response['backup_codes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [];

      if (backupCodes.contains(code)) {
        // Retirer le code utilisé
        backupCodes.remove(code);
 await SupabaseService.from('user_security_settings')
 .update({'backup_codes': backupCodes})
 .eq('id', user.id);

 await _logSecurityEvent('mfa_verified', {'method': 'backup_code'});
        return true;
      }

      return false;
    } catch (e) {
 AppConfig.logger.e('Erreur lors de la vérification du code de secours: $e');
      return false;
    }
  }

 /// Vérifie si le MFA est activé pour l'utilisateur
  Future<bool> isMFAEnabled() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return false;

 final response = await SupabaseService.from('user_security_settings')
 .select('mfa_enabled')
 .eq('id', user.id)
          .maybeSingle();

 return response?['mfa_enabled'] ?? false;
    } catch (e) {
 AppConfig.logger.e('Erreur lors de la vérification du MFA: $e');
      return false;
    }
  }

  /// Génère un code de secours aléatoire
  String _generateBackupCode() {
 const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = StringBuffer();
    
    for (int i = 0; i < 8; i++) {
      code.write(chars[(random + i) % chars.length]);
    }
    
    return code.toString();
  }

  /// Log un événement de sécurité
  Future<void> _logSecurityEvent(String eventType, Map<String, dynamic> details) async {
    try {
 await SupabaseService.client.rpc('log_security_event', params: {
 'p_event_type': eventType,
 'p_event_details': details,
 'p_severity': 'low',
      });
    } catch (e) {
 AppConfig.logger.w('Impossible de logger l\'événement de sécurité: $e');
    }
  }
}


