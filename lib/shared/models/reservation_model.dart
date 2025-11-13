import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation_model.freezed.dart';
part 'reservation_model.g.dart';

enum ReservationStatus { pending, confirmed, cancelled, completed }

@freezed
class ReservationModel with _$ReservationModel {
  const factory ReservationModel({
    required String id,
    required String listingId,
    required String guestId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int numberOfGuests,
    required double totalPrice,
    required ReservationStatus status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
  }) = _ReservationModel;

  factory ReservationModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationModelFromJson(json);
}

extension ReservationModelExtension on ReservationModel {
  int get numberOfNights {
    return checkOut.difference(checkIn).inDays;
  }
}
