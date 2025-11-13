import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

@freezed
class ReviewModel with _$ReviewModel {
  const factory ReviewModel({
    required String id,
    required String listingId,
    required String guestId,
    required String guestName,
    String? guestAvatarUrl,
    required int rating,
    required String comment,
    String? hostResponse,
    DateTime? hostResponseDate,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _ReviewModel;

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);
}

