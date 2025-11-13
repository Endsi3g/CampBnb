import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/services/supabase_service.dart';
import '../config/app_config.dart';

/// Service de gestion des permissions et rôles
class PermissionsService {
  PermissionsService._();
  static final PermissionsService instance = PermissionsService._();

  /// Vérifie si l'utilisateur a un rôle spécifique
  Future<bool> hasRole(String role) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return false;

      final response = await SupabaseService.from('user_roles')
          .select()
          .eq('user_id', user.id)
          .eq('role', role)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return false;

      // Vérifier si le rôle n'est pas expiré
      final expiresAt = response['expires_at'];
      if (expiresAt != null) {
        final expiryDate = DateTime.parse(expiresAt);
        if (expiryDate.isBefore(DateTime.now())) {
          return false;
        }
      }

      return true;
    } catch (e) {
      AppConfig.logger.e('Erreur lors de la vérification du rôle: $e');
      return false;
    }
  }

  /// Vérifie si l'utilisateur a une permission spécifique
  Future<bool> hasPermission(
    String permission, {
    String? resourceType,
    String? resourceId,
  }) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return false;

      // Vérifier via la fonction SQL
      final response = await SupabaseService.client.rpc(
        'has_permission',
        params: {
          'p_user_id': user.id,
          'p_permission': permission,
          'p_resource_type': resourceType,
          'p_resource_id': resourceId,
        },
      );

      return response as bool? ?? false;
    } catch (e) {
      AppConfig.logger.e('Erreur lors de la vérification de la permission: $e');
      return false;
    }
  }

  /// Récupère tous les rôles de l'utilisateur
  Future<List<String>> getUserRoles() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return [];

      final response = await SupabaseService.from(
        'user_roles',
      ).select('role').eq('user_id', user.id).eq('is_active', true);

      return (response as List).map((e) => e['role'] as String).toList();
    } catch (e) {
      AppConfig.logger.e('Erreur lors de la récupération des rôles: $e');
      return [];
    }
  }

  /// Récupère toutes les permissions de l'utilisateur
  Future<List<String>> getUserPermissions() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return [];

      final response = await SupabaseService.from(
        'user_permissions',
      ).select('permission').eq('user_id', user.id).eq('is_active', true);

      return (response as List).map((e) => e['permission'] as String).toList();
    } catch (e) {
      AppConfig.logger.e('Erreur lors de la récupération des permissions: $e');
      return [];
    }
  }

  /// Vérifie si l'utilisateur est un administrateur
  Future<bool> isAdmin() => hasRole('admin');

  /// Vérifie si l'utilisateur est un modérateur
  Future<bool> isModerator() => hasRole('moderator');

  /// Vérifie si l'utilisateur est un hôte
  Future<bool> isHost() => hasRole('host');

  /// Vérifie si l'utilisateur est un invité
  Future<bool> isGuest() => hasRole('guest');

  /// Vérifie si l'utilisateur peut créer des listings
  Future<bool> canCreateListing() async {
    return await hasRole('host') || await hasRole('admin');
  }

  /// Vérifie si l'utilisateur peut modifier un listing spécifique
  Future<bool> canEditListing(String listingId) async {
    if (await isAdmin()) return true;

    if (!await isHost()) return false;

    // Vérifier si l'utilisateur est le propriétaire du listing
    try {
      final response = await SupabaseService.from(
        'listings',
      ).select('host_id').eq('id', listingId).single();

      final user = SupabaseService.currentUser;
      return response['host_id'] == user?.id;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si l'utilisateur peut modérer du contenu
  Future<bool> canModerate() async {
    return await hasRole('admin') || await hasRole('moderator');
  }
}
