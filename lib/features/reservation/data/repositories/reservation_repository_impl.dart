import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/models/reservation_model.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../domain/repositories/reservation_repository.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final Dio _dio = Dio();
  final String _baseUrl;

  ReservationRepositoryImpl() : _baseUrl = AppConfig.supabaseUrl {
    _dio.options.baseUrl = '$_baseUrl/functions/v1';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  String? get _authToken {
    return SupabaseService.client.auth.currentSession?.accessToken;
  }

  @override
  Future<ReservationModel> createReservation({
    required String listingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int numberOfGuests,
    String? message,
  }) async {
    try {
      final response = await _dio.post(
        '/reservations',
        data: {
          'listing_id': listingId,
          'check_in_date': checkIn.toIso8601String().split('T')[0],
          'check_out_date': checkOut.toIso8601String().split('T')[0],
          'number_of_guests': numberOfGuests,
          'number_of_adults': numberOfGuests,
          'number_of_children': 0,
          'guest_message': message,
        },
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );

      return _mapToReservationModel(response.data['data']);
    } catch (e) {
      throw Exception('Erreur lors de la création de la réservation: $e');
    }
  }

  @override
  Future<ReservationModel> getReservationById(String id) async {
    try {
      final response = await _dio.get(
        '/reservations/$id',
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );

      return _mapToReservationModel(response.data['data']);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la réservation: $e');
    }
  }

  @override
  Future<List<ReservationModel>> getReservations({
    String? userId,
    ReservationStatus? status,
    bool isHost = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{'role': isHost ? 'host' : 'guest'};

      if (status != null) {
        queryParams['status'] = status.name;
      }

      final response = await _dio.get(
        '/reservations',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => _mapToReservationModel(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réservations: $e');
    }
  }

  @override
  Future<ReservationModel> acceptReservation(String reservationId) async {
    try {
      final response = await _dio.put(
        '/reservations/$reservationId',
        data: {'status': 'confirmed'},
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );

      return _mapToReservationModel(response.data['data']);
    } catch (e) {
      throw Exception('Erreur lors de l\'acceptation de la réservation: $e');
    }
  }

  @override
  Future<ReservationModel> rejectReservation(
    String reservationId, {
    String? reason,
  }) async {
    try {
      final response = await _dio.put(
        '/reservations/$reservationId',
        data: {'status': 'rejected', 'host_message': reason},
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );

      return _mapToReservationModel(response.data['data']);
    } catch (e) {
      throw Exception('Erreur lors du refus de la réservation: $e');
    }
  }

  @override
  Future<ReservationModel> cancelReservation(
    String reservationId, {
    String? reason,
  }) async {
    try {
      final response = await _dio.put(
        '/reservations/$reservationId',
        data: {'status': 'cancelled', 'cancellation_reason': reason},
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );

      return _mapToReservationModel(response.data['data']);
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de la réservation: $e');
    }
  }

  @override
  Future<void> suggestAlternativeDates({
    required String reservationId,
    required DateTime newCheckIn,
    required DateTime newCheckOut,
    String? message,
  }) async {
    try {
      await _dio.post(
        '/reservations/$reservationId/suggest-dates',
        data: {
          'new_check_in_date': newCheckIn.toIso8601String().split('T')[0],
          'new_check_out_date': newCheckOut.toIso8601String().split('T')[0],
          'message': message,
        },
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );
    } catch (e) {
      throw Exception('Erreur lors de la suggestion de dates: $e');
    }
  }

  ReservationModel _mapToReservationModel(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      guestId: json['guest_id'] as String,
      checkIn: DateTime.parse(json['check_in_date'] as String),
      checkOut: DateTime.parse(json['check_out_date'] as String),
      numberOfGuests: json['number_of_guests'] as int,
      totalPrice: (json['total_price'] as num).toDouble(),
      status: _mapStatus(json['status'] as String),
      message: json['guest_message'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
    );
  }

  ReservationStatus _mapStatus(String status) {
    switch (status) {
      case 'pending':
        return ReservationStatus.pending;
      case 'confirmed':
        return ReservationStatus.confirmed;
      case 'cancelled':
      case 'rejected':
        return ReservationStatus.cancelled;
      case 'completed':
        return ReservationStatus.completed;
      default:
        return ReservationStatus.pending;
    }
  }
}
