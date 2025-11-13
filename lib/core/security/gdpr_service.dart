import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/services/supabase_service.dart';
import '../config/app_config.dart';

/// Service pour la gestion de la conformité RGPD
class GDPRService {
  GDPRService._();
  static final GDPRService instance = GDPRService._();

  /// Enregistre un consentement RGPD
  Future<void> recordConsent({
    required String consentType,
    required bool consentGiven,
    String? consentVersion,
  }) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
 throw Exception('Utilisateur non connecté');
      }

 await SupabaseService.from('gdpr_consents').insert({
 'user_id': user.id,
 'consent_type': consentType,
 'consent_given': consentGiven,
 'consent_version': consentVersion ?? '1.0',
 'consent_date': DateTime.now().toIso8601String(),
      });

      // Mettre à jour les paramètres de sécurité
 if (consentType == 'data_processing') {
 await SupabaseService.from('user_security_settings')
            .update({
 'gdpr_consent_given': consentGiven,
 'gdpr_consent_date': DateTime.now().toIso8601String(),
            })
 .eq('id', user.id);
      }
    } catch (e) {
 AppConfig.logger.e('Erreur lors de l\'enregistrement du consentement: $e');
      rethrow;
    }
  }

 /// Récupère tous les consentements de l'utilisateur
  Future<Map<String, bool>> getUserConsents() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return {};

 final response = await SupabaseService.from('gdpr_consents')
 .select('consent_type, consent_given, revoked_at')
 .eq('user_id', user.id)
 .order('consent_date', ascending: false);

      final consents = <String, bool>{};
      
      for (final item in response as List) {
 final type = item['consent_type'] as String;
 final revokedAt = item['revoked_at'];
        
 // Prendre le consentement le plus récent qui n'est pas révoqué
        if (!consents.containsKey(type) && revokedAt == null) {
 consents[type] = item['consent_given'] as bool;
        }
      }

      return consents;
    } catch (e) {
 AppConfig.logger.e('Erreur lors de la récupération des consentements: $e');
      return {};
    }
  }

  /// Révoque un consentement
  Future<void> revokeConsent(String consentType) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
 throw Exception('Utilisateur non connecté');
      }

 await SupabaseService.from('gdpr_consents')
          .update({
 'revoked_at': DateTime.now().toIso8601String(),
          })
 .eq('user_id', user.id)
 .eq('consent_type', consentType)
 .is_('revoked_at', null);
    } catch (e) {
 AppConfig.logger.e('Erreur lors de la révocation du consentement: $e');
      rethrow;
    }
  }

 /// Exporte toutes les données de l'utilisateur (droit à la portabilité)
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
 throw Exception('Utilisateur non connecté');
      }

 // Récupérer toutes les données de l'utilisateur
 final profile = await SupabaseService.from('profiles')
          .select()
 .eq('id', user.id)
          .single();

 final listings = await SupabaseService.from('listings')
          .select()
 .eq('host_id', user.id);

 final reservations = await SupabaseService.from('reservations')
          .select()
 .or('guest_id.eq.${user.id},host_id.eq.${user.id}');

 final messages = await SupabaseService.from('messages')
          .select()
 .or('sender_id.eq.${user.id},recipient_id.eq.${user.id}');

 final reviews = await SupabaseService.from('reviews')
          .select()
 .or('reviewer_id.eq.${user.id},reviewee_id.eq.${user.id}');

 final consents = await SupabaseService.from('gdpr_consents')
          .select()
 .eq('user_id', user.id);

 // Logger l'export
 await SupabaseService.client.rpc('log_security_event', params: {
 'p_event_type': 'data_exported',
 'p_event_details': {},
 'p_severity': 'low',
      });

      return {
 'export_date': DateTime.now().toIso8601String(),
 'user_id': user.id,
 'profile': profile,
 'listings': listings,
 'reservations': reservations,
 'messages': messages,
 'reviews': reviews,
 'consents': consents,
      };
    } catch (e) {
 AppConfig.logger.e('Erreur lors de l\'export des données: $e');
      rethrow;
    }
  }

 /// Supprime toutes les données de l'utilisateur (droit à l'effacement)
  Future<void> deleteUserData() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
 throw Exception('Utilisateur non connecté');
      }

      // Supprimer le compte utilisateur (cascade supprimera toutes les données liées)
      await SupabaseService.client.auth.admin.deleteUser(user.id);

      // Logger la suppression
 await SupabaseService.client.rpc('log_security_event', params: {
 'p_event_type': 'data_deleted',
 'p_event_details': {},
 'p_severity': 'high',
      });
    } catch (e) {
 AppConfig.logger.e('Erreur lors de la suppression des données: $e');
      rethrow;
    }
  }

 /// Vérifie si l'utilisateur a donné son consentement pour le traitement des données
  Future<bool> hasDataProcessingConsent() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return false;

 final response = await SupabaseService.from('user_security_settings')
 .select('gdpr_consent_given')
 .eq('id', user.id)
          .maybeSingle();

 return response?['gdpr_consent_given'] ?? false;
    } catch (e) {
 AppConfig.logger.e('Erreur lors de la vérification du consentement: $e');
      return false;
    }
  }
}


