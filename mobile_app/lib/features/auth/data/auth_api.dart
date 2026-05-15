import 'package:dio/dio.dart';
import 'package:expense_tracker_app/core/api/api_client.dart';
import 'package:expense_tracker_app/features/auth/data/auth_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authApiProvider = Provider((ref) => AuthApi(ref.read(apiClientProvider)));

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>('auth/login', data: request.toJson());
    return LoginResponse.fromJson(response.data!);
  }

  Future<LoginResponse> register(RegisterRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>('auth/register', data: request.toJson());
    return LoginResponse.fromJson(response.data!);
  }

  Future<UserProfile> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>('me');
    return UserProfile.fromJson(response.data!);
  }

  Future<UserProfile> updateProfile({
    String? name,
    String? phone,
    String? defaultBucketId,
    bool clearDefault = false,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>('me', data: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (defaultBucketId != null) 'default_bucket_id': defaultBucketId,
      if (clearDefault) 'clear_default': true,
    });
    return UserProfile.fromJson(response.data!);
  }
}
