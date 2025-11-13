/// Service de notifications utilisant Supabase Realtime et notifications locales
/// Note: Utilise uniquement Supabase (pas Firebase)
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';
import 'supabase_service.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final SupabaseClient _supabase = Supabase.instance.client;

  static bool _initialized = false;
  static RealtimeChannel? _notificationChannel;

  /// Initialiser le service de notifications
  static Future<void> initialize() async {
    if (_initialized) return;

    // Demander la permission
    await _requestPermission();

    // Configurer les notifications locales
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Configurer Supabase Realtime pour les notifications
    await _setupSupabaseNotifications();

    _initialized = true;
    AppConfig.logger.i(' NotificationService initialisé');
  }

  /// Demander la permission de notification
  static Future<bool> _requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Configurer Supabase Realtime pour les notifications
  static Future<void> _setupSupabaseNotifications() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        AppConfig.logger.w(
          'Utilisateur non connecte, notifications desactivees',
        );
        return;
      }

      // S'abonner aux notifications pour cet utilisateur
      _notificationChannel = _supabase
          .channel('notifications:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              _handleNotification(payload.newRecord);
            },
          )
          .subscribe();

      AppConfig.logger.d(' Abonné aux notifications Supabase');
    } catch (e) {
      AppConfig.logger.e('Erreur configuration notifications Supabase: $e');
    }
  }

  /// Gérer une notification reçue
  static void _handleNotification(Map<String, dynamic> notification) {
    _showLocalNotification(
      title: notification['title'] ?? 'Nouvelle notification',
      body: notification['body'] ?? '',
      payload: notification['data']?.toString(),
      notificationId: notification['id']?.toString(),
    );

    // Marquer la notification comme lue dans Supabase
    _markAsRead(notification['id']);
  }

  /// Afficher une notification locale
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String? notificationId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'campbnb_channel',
      'Campbnb Notifications',
      channelDescription: 'Notifications pour Campbnb Québec',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final id = notificationId != null
        ? int.tryParse(notificationId) ??
              DateTime.now().millisecondsSinceEpoch.remainder(100000)
        : DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  /// Callback quand une notification est tapée
  static void _onNotificationTapped(NotificationResponse response) {
    // TODO: Naviguer vers l'écran approprié selon le payload
    AppConfig.logger.d('Notification tapée: ${response.payload}');
  }

  /// Marquer une notification comme lue
  static Future<void> _markAsRead(String? notificationId) async {
    if (notificationId == null) return;

    try {
      await SupabaseService.from('notifications')
          .update({'read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('id', notificationId)
          .execute();
    } catch (e) {
      AppConfig.logger.e('Erreur marquage notification comme lue: $e');
    }
  }

  /// Envoyer une notification locale (pour tests ou notifications programmées)
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showLocalNotification(title: title, body: body, payload: payload);
  }

  /// Obtenir les notifications non lues
  static Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return [];

      final response = await SupabaseService.from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('read', false)
          .order('created_at', ascending: false)
          .execute();

      return List<Map<String, dynamic>>.from(response.data ?? []);
    } catch (e) {
      AppConfig.logger.e('Erreur récupération notifications: $e');
      return [];
    }
  }

  /// Marquer toutes les notifications comme lues
  static Future<void> markAllAsRead() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      await SupabaseService.from('notifications')
          .update({'read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .eq('read', false)
          .execute();
    } catch (e) {
      AppConfig.logger.e('Erreur marquage toutes notifications comme lues: $e');
    }
  }

  /// Se désabonner des notifications
  static Future<void> unsubscribe() async {
    await _notificationChannel?.unsubscribe();
    _notificationChannel = null;
  }

  /// Réinitialiser le service
  static Future<void> reset() async {
    await unsubscribe();
    _initialized = false;
  }
}
