import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String token,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    String? name,
    String? phone,
    String? email,
    @JsonKey(name: 'default_bucket_id') String? defaultBucketId,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    @JsonKey(name: 'user_id') required String userId,
    required String email,
    String? name,
    String? phone,
    @JsonKey(name: 'default_bucket_id') String? defaultBucketId,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
