import '../../../../shared/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> watchCurrentUser();
}

