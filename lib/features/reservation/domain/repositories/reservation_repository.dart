import '../../../../shared/models/reservation_model.dart';

/// Interface du repository pour les réservations
abstract class ReservationRepository {
  /// Créer une réservation
  Future<ReservationModel> createReservation({
    required String listingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int numberOfGuests,
    String? message,
  });

  /// Récupérer une réservation par ID
  Future<ReservationModel> getReservationById(String id);

  /// Récupérer les réservations d'un utilisateur (guest ou host)
  Future<List<ReservationModel>> getReservations({
    String? userId,
    ReservationStatus? status,
    bool isHost = false,
  });

  /// Accepter une réservation (hôte)
  Future<ReservationModel> acceptReservation(String reservationId);

  /// Refuser une réservation (hôte)
  Future<ReservationModel> rejectReservation(
    String reservationId, {
    String? reason,
  });

  /// Annuler une réservation (guest ou host)
  Future<ReservationModel> cancelReservation(
    String reservationId, {
    String? reason,
  });

  /// Suggérer des dates alternatives
  Future<void> suggestAlternativeDates({
    required String reservationId,
    required DateTime newCheckIn,
    required DateTime newCheckOut,
    String? message,
  });
}
