import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_model.freezed.dart';
part 'listing_model.g.dart';

enum ListingType {
  tent,
  rv,
  readyToCamp,
  wild,
}

enum ListingStatus {
  active,
  inactive,
  pending,
  rejected,
}

@freezed
class ListingModel with _$ListingModel {
  const factory ListingModel({
    required String id,
    required String hostId,
    required String title,
    required String description,
    required ListingType type,
    required double latitude,
    required double longitude,
    required String address,
    required String city,
    required String province,
    required String postalCode,
    required double pricePerNight,
    required int maxGuests,
    required int bedrooms,
    required int bathrooms,
    @Default([]) List<String> images,
    @Default([]) List<String> amenities,
    @Default(ListingStatus.active) ListingStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? reviewCount,
  }) = _ListingModel;

  factory ListingModel.fromJson(Map<String, dynamic> json) =>
      _$ListingModelFromJson(json);
}

