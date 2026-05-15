import 'package:dio/dio.dart';
import 'package:expense_tracker_app/core/storage/secure_token_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureTokenStorage _storage;
  final Function() _onUnauthorized;

  AuthInterceptor(this._storage, this._onUnauthorized);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip for auth endpoints
    if (options.path.contains('/auth/') || options.path.contains('/healthz')) {
      return handler.next(options);
    }

    final token = await _storage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.clear();
      _onUnauthorized();
    }
    return handler.next(err);
  }
}
