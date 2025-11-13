import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final response = await SupabaseService.signUp(
      email: email,
      password: password,
      data: {
 'first_name': firstName,
 'last_name': lastName,
      },
    );

    if (response.user == null) {
 throw Exception('Échec de l\'inscription');
    }

    // Créer le profil utilisateur dans la table users
 await SupabaseService.from('users').insert({
 'id': response.user!.id,
 'email': email,
 'first_name': firstName,
 'last_name': lastName,
    });

    return UserModel(
      id: response.user!.id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await SupabaseService.signIn(
      email: email,
      password: password,
    );

    if (response.user == null) {
 throw Exception('Email ou mot de passe incorrect');
    }

    // Récupérer le profil utilisateur
 final userData = await SupabaseService.from('users')
        .select()
 .eq('id', response.user!.id)
        .single();

    return UserModel.fromJson(userData);
  }

  @override
  Future<void> signOut() async {
    await SupabaseService.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = SupabaseService.currentUser;
    if (user == null) return null;

    try {
 final userData = await SupabaseService.from('users')
          .select()
 .eq('id', user.id)
          .single();

      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserModel?> watchCurrentUser() {
    return SupabaseService.authStateChanges.map((authState) {
      final user = authState.session?.user;
      if (user == null) return null;

      // En production, il faudrait écouter les changements de la table users
 // Pour l'instant, on retourne un stream basique
      return getCurrentUser();
    }).asyncMap((future) => future);
  }
}

