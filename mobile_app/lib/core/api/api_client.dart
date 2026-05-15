import 'package:dio/dio.dart';
import 'package:expense_tracker_app/core/api/auth_interceptor.dart';
import 'package:expense_tracker_app/core/api/error_interceptor.dart';
import 'package:expense_tracker_app/core/storage/secure_token_storage.dart';
import 'package:expense_tracker_app/core/storage/server_url_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider((ref) => SecureTokenStorage());

// Runtime-configurable server URL. Loaded from SharedPreferences at startup.
final serverUrlProvider = StateProvider<String>((ref) {
  // Default — overwritten in main.dart after SharedPreferences loads
  const compiledDefault = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://hisabkhata.duckdns.org/v1',
  );
  return compiledDefault;
});

final apiClientProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(serverUrlProvider);
  final storage = ref.read(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(storage, () {}),
    ErrorInterceptor(),
  ]);

  return dio;
});
