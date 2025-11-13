import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';
import '../../core/monitoring/observability_service.dart';
import '../../core/monitoring/error_monitoring_service.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient? _client;

  static Future<void> initialize() async {
    // Supabase est déjà initialisé dans main.dart
    // On récupère simplement l'instance
    try {
      _client = Supabase.instance.client;
    } catch (e) {
      // Si Supabase n'est pas encore initialisé, utiliser les valeurs de AppConfig
      if (AppConfig.supabaseUrl.isNotEmpty &&
          AppConfig.supabaseAnonKey.isNotEmpty) {
        await Supabase.initialize(
          url: AppConfig.supabaseUrl,
          anonKey: AppConfig.supabaseAnonKey,
          debug: AppConfig.isDevelopment,
        );
        _client = Supabase.instance.client;
      } else {
        throw Exception(
          'Supabase not initialized. Ensure SUPABASE_URL and SUPABASE_ANON_KEY are set.',
        );
      }
    }
  }

  static SupabaseClient get client {
    if (_client == null) {
      // Essayer de récupérer l'instance si elle existe
      try {
        _client = Supabase.instance.client;
      } catch (e) {
        throw Exception(
          'Supabase not initialized. Call SupabaseService.initialize() first.',
        );
      }
    }
    return _client!;
  }

  // Auth
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  // Database
  static PostgrestQueryBuilder from(String table) {
    return client.from(table);
  }

  /// Méthode helper pour exécuter une requête avec monitoring
  static Future<T> executeWithMonitoring<T>({
    required String operationName,
    required Future<T> Function() operation,
  }) async {
    try {
      return await ObservabilityService().monitorSupabaseOperation(
        operationName,
        operation,
      );
    } catch (e, stackTrace) {
      await ErrorMonitoringService().captureException(
        e,
        stackTrace: stackTrace,
        context: {'component': 'supabase_service', 'operation': operationName},
      );
      rethrow;
    }
  }

  // Storage
  static SupabaseStorageClient get storage => client.storage;

  static Future<String> uploadImage({
    required String bucket,
    required String path,
    required List<int> fileBytes,
    String? contentType,
  }) async {
    await storage
        .from(bucket)
        .uploadBinary(
          path,
          fileBytes,
          fileOptions: FileOptions(
            contentType: contentType ?? 'image/jpeg',
            upsert: true,
          ),
        );
    return storage.from(bucket).getPublicUrl(path);
  }

  static Future<void> deleteImage({
    required String bucket,
    required String path,
  }) async {
    await storage.from(bucket).remove([path]);
  }
}
