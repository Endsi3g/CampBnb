import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../shared/models/reservation_model.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../../data/repositories/reservation_repository_impl.dart';

part 'reservation_provider.g.dart';

/// Provider pour le repository de réservations
@riverpod
ReservationRepository reservationRepository(ReservationRepositoryRef ref) {
  return ReservationRepositoryImpl();
}

/// Provider pour récupérer une réservation par ID
@riverpod
Future<ReservationModel> reservationById(
  ReservationByIdRef ref,
  String id,
) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return await repository.getReservationById(id);
}

/// Provider pour récupérer les réservations d'un utilisateur
@riverpod
Future<List<ReservationModel>> reservations(
  ReservationsRef ref, {
  String? userId,
  ReservationStatus? status,
  bool isHost = false,
}) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return await repository.getReservations(
    userId: userId,
    status: status,
    isHost: isHost,
  );
}

/// Provider pour les réservations en attente (hôte)
@riverpod
Future<List<ReservationModel>> pendingReservations(PendingReservationsRef ref) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return await repository.getReservations(
    status: ReservationStatus.pending,
    isHost: true,
  );
}

/// Provider pour les réservations confirmées
@riverpod
Future<List<ReservationModel>> confirmedReservations(
  ConfirmedReservationsRef ref, {
  bool isHost = false,
}) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return await repository.getReservations(
    status: ReservationStatus.confirmed,
    isHost: isHost,
  );
}

/// État du notifier de réservation
class ReservationNotifierState {
  final bool isLoading;
  final String? error;

  ReservationNotifierState({
    this.isLoading = false,
    this.error,
  });

  ReservationNotifierState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return ReservationNotifierState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier pour gérer les actions sur les réservations
@riverpod
class ReservationNotifier extends _$ReservationNotifier {
  @override
  ReservationNotifierState build() {
    return ReservationNotifierState();
  }

  /// Créer une réservation
  Future<ReservationModel> createReservation({
    required String listingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int numberOfGuests,
    String? message,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(reservationRepositoryProvider);
      final reservation = await repository.createReservation(
        listingId: listingId,
        checkIn: checkIn,
        checkOut: checkOut,
        numberOfGuests: numberOfGuests,
        message: message,
      );
      
      // Invalider les providers pour rafraîchir les listes
      ref.invalidate(reservationsProvider);
      ref.invalidate(pendingReservationsProvider);
      
      state = state.copyWith(isLoading: false);
      return reservation;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Accepter une réservation
  Future<void> acceptReservation(String reservationId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(reservationRepositoryProvider);
      await repository.acceptReservation(reservationId);
      
      // Invalider les providers
      ref.invalidate(reservationByIdProvider(reservationId));
      ref.invalidate(reservationsProvider);
      ref.invalidate(pendingReservationsProvider);
      ref.invalidate(confirmedReservationsProvider);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Refuser une réservation
  Future<void> rejectReservation(String reservationId, {String? reason}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(reservationRepositoryProvider);
      await repository.rejectReservation(reservationId, reason: reason);
      
      // Invalider les providers
      ref.invalidate(reservationByIdProvider(reservationId));
      ref.invalidate(reservationsProvider);
      ref.invalidate(pendingReservationsProvider);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Annuler une réservation
  Future<void> cancelReservation(String reservationId, {String? reason}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(reservationRepositoryProvider);
      await repository.cancelReservation(reservationId, reason: reason);
      
      // Invalider les providers
      ref.invalidate(reservationByIdProvider(reservationId));
      ref.invalidate(reservationsProvider);
      ref.invalidate(confirmedReservationsProvider);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Suggérer des dates alternatives
  Future<void> suggestAlternativeDates({
    required String reservationId,
    required DateTime newCheckIn,
    required DateTime newCheckOut,
    String? message,
  }) async {
    final repository = ref.read(reservationRepositoryProvider);
    await repository.suggestAlternativeDates(
      reservationId: reservationId,
      newCheckIn: newCheckIn,
      newCheckOut: newCheckOut,
      message: message,
    );
  }
}

