import 'package:dio/dio.dart';
import 'package:expense_tracker_app/core/network/server_status_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServerStatusInterceptor extends Interceptor {
  final Ref _ref;
  final Dio _dio;

  ServerStatusInterceptor(this._ref, this._dio);

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    // Any successful response means server is up
    _ref.read(serverStatusProvider.notifier).markOnline();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Connection refused, timeout, no route to host → server is down
    // (distinct from 4xx errors which mean the server IS up but rejected the request)
    final isConnectionError = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    final isServerError = err.response?.statusCode != null &&
        err.response!.statusCode! >= 500;

    if (isConnectionError || isServerError) {
      _ref.read(serverStatusProvider.notifier).markDown(_dio);
    } else {
      // 4xx or anything else → server is reachable, just rejected the request
      _ref.read(serverStatusProvider.notifier).markOnline();
    }

    handler.next(err);
  }
}
