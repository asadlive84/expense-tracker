import 'package:dio/dio.dart';
import 'package:expense_tracker_app/core/api/auth_interceptor.dart';
import 'package:expense_tracker_app/core/api/error_interceptor.dart';
import 'package:expense_tracker_app/core/storage/secure_token_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider((ref) => SecureTokenStorage());

final apiClientProvider = Provider<Dio>((ref) {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://18.139.46.170/v1',
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final storage = ref.read(secureStorageProvider);
  
  dio.interceptors.addAll([
    AuthInterceptor(storage, () {
      // Handle logout on 401
    }),
    ErrorInterceptor(),
    LogInterceptor(requestBody: true, responseBody: true), // Add this to see errors in terminal
  ]);

  return dio;
});
