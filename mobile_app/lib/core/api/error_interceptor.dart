import 'package:dio/dio.dart';
import 'package:expense_tracker_app/core/api/app_error.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appError = _mapToAppError(err);
    // We wrap the original error with our custom one
    return handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: appError,
      ),
    );
  }

  AppError _mapToAppError(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return AppError.network(
        originalMessage: err.message,
        originalError: err.error,
      );
    }

    final response = err.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final data = response.data;
      
      final errorMap = (data is Map<String, dynamic> && data['error'] is Map<String, dynamic>)
          ? data['error'] as Map<String, dynamic>
          : null;
      final message = (errorMap?['message'] as String?) ?? 'Unknown error';

      if (statusCode == 400) {
        final fields = errorMap?['fields'];
        return AppError.validation(
          fields is Map<String, dynamic> ? fields : <String, dynamic>{},
        );
      }
      if (statusCode == 401) return const AppError.unauthorized();
      if (statusCode == 404) return AppError.notFound(message);
      if (statusCode == 409) return AppError.conflict(message);
      if (statusCode != null && statusCode >= 500) return const AppError.server();
    }

    return AppError.unknown(err);
  }
}
