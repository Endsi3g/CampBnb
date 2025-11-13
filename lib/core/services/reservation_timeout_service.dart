/// Service pour gérer les timeouts de réservations
/// Vérifie périodiquement les réservations expirées et les annule automatiquement
import 'dart:async';
import 'package:logger/logger.dart';
import '../../shared/services/supabase_service.dart';
import '../../core/monitoring/error_monitoring_service.dart';

class ReservationTimeoutService {
  static final Logger _logger = Logger();
  static ReservationTimeoutService? _instance;
  Timer? _timeoutCheckTimer;
  bool _isRunning = false;

  factory ReservationTimeoutService() =>
      _instance ??= ReservationTimeoutService._internal();
  ReservationTimeoutService._internal();

  /// Démarre le service de vérification des timeouts
  /// Vérifie toutes les 5 minutes
  void start() {
    if (_isRunning) {
      _logger.w('ReservationTimeoutService est déjà en cours d\'exécution');
      return;
    }

    _isRunning = true;
    _logger.i('Démarrage du ReservationTimeoutService');

    // Vérifier immédiatement au démarrage
    _checkExpiredReservations();

    // Puis vérifier toutes les 5 minutes
    _timeoutCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _checkExpiredReservations(),
    );
  }

  /// Arrête le service
  void stop() {
    _timeoutCheckTimer?.cancel();
    _timeoutCheckTimer = null;
    _isRunning = false;
    _logger.i('Arrêt du ReservationTimeoutService');
  }

  /// Vérifie et annule les réservations expirées
  Future<void> _checkExpiredReservations() async {
    try {
      _logger.d('Vérification des réservations expirées...');

      // Appeler l'Edge Function qui gère les timeouts
      final response = await SupabaseService.client.functions.invoke(
        'reservation-timeouts',
        body: {},
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        final processed = data['processed'] as int? ?? 0;

        if (processed > 0) {
          _logger.i(
            '$processed réservation(s) expirée(s) annulée(s) automatiquement',
          );

          // Ajouter un breadcrumb pour Sentry
          ErrorMonitoringService().addBreadcrumb(
            message: '$processed réservation(s) annulée(s) par timeout',
            category: 'reservation_timeout',
            data: {
              'processed': processed,
              'reservation_ids': data['reservationIds'],
            },
          );
        } else {
          _logger.d('Aucune réservation expirée');
        }
      } else {
        _logger.w(
          'Erreur lors de la vérification des timeouts: ${response.status}',
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Erreur lors de la vérification des réservations expirées',
        error: e,
        stackTrace: stackTrace,
      );

      ErrorMonitoringService().captureException(
        e,
        stackTrace: stackTrace,
        context: {
          'component': 'reservation_timeout_service',
          'action': 'check_expired_reservations',
        },
      );
    }
  }

  /// Vérifie si une réservation spécifique est proche du timeout
  /// Retourne le nombre d'heures restantes avant expiration
  Future<int?> getHoursUntilTimeout(String reservationId) async {
    try {
      final response = await SupabaseService.client
          .from('reservations')
          .select('requested_at, status')
          .eq('id', reservationId)
          .single();

      if (response == null) return null;

      final requestedAt = DateTime.parse(response['requested_at'] as String);
      final status = response['status'] as String;

      if (status != 'pending') return null;

      final now = DateTime.now();
      final hoursSinceRequest = now.difference(requestedAt).inHours;
      const timeoutHours = 24;

      return timeoutHours - hoursSinceRequest;
    } catch (e) {
      _logger.e('Erreur lors de la récupération du timeout', error: e);
      return null;
    }
  }

  /// Vérifie manuellement les réservations expirées (pour tests ou actions manuelles)
  Future<Map<String, dynamic>> checkExpiredReservationsManually() async {
    try {
      final response = await SupabaseService.client.functions.invoke(
        'reservation-timeouts',
        body: {},
      );

      if (response.status == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Erreur HTTP ${response.status}');
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Erreur lors de la vérification manuelle',
        error: e,
        stackTrace: stackTrace,
      );
      ErrorMonitoringService().captureException(
        e,
        stackTrace: stackTrace,
        context: {
          'component': 'reservation_timeout_service',
          'action': 'check_manually',
        },
      );
      rethrow;
    }
  }

  /// Dispose des ressources
  void dispose() {
    stop();
  }
}
