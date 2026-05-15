import 'package:expense_tracker_app/core/api/app_error.dart';
import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, Object error) {
  if (!context.mounted) return;
  final message = _friendlyMessage(error);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ),
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}

String _friendlyMessage(Object error) {
  if (error is DioAppError) {
    return error.message;
  }
  final str = error.toString();
  // Extract AppError message from DioException wrapper
  if (str.contains('NetworkError')) return 'No internet connection. Please try again.';
  if (str.contains('UnauthorizedError')) return 'Session expired. Please log in again.';
  if (str.contains('ServerError')) return 'Server error. Please try again later.';
  if (str.contains('ConflictError')) {
    final msg = RegExp(r'ConflictError\((.+)\)').firstMatch(str)?.group(1);
    return msg ?? 'This action conflicts with existing data.';
  }
  if (str.contains('NotFoundError')) {
    final msg = RegExp(r'NotFoundError\((.+)\)').firstMatch(str)?.group(1);
    return msg ?? 'Resource not found.';
  }
  return 'Something went wrong. Please try again.';
}

class DioAppError {
  final String message;
  const DioAppError(this.message);
}
