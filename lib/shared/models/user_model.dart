import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isHost,
    @Default([]) List<String> favoriteListingIds,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  String get fullName {
    if (firstName != null && lastName != null) {
 return '$firstName $lastName';
    }
 return firstName ?? lastName ?? email.split('@').first;
  }
}

