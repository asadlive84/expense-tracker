sealed class AppError {
  const AppError();

  const factory AppError.validation(Map<String, dynamic> fields) = ValidationError;
  const factory AppError.unauthorized() = UnauthorizedError;
  const factory AppError.notFound(String message) = NotFoundError;
  const factory AppError.conflict(String message) = ConflictError;
  const factory AppError.server() = ServerError;
  factory AppError.network({String? originalMessage, Object? originalError}) =>
      NetworkError(originalMessage: originalMessage, originalError: originalError);
  const factory AppError.unknown(Object error) = UnknownError;
}

class ValidationError extends AppError {
  final Map<String, dynamic> fields;
  const ValidationError(this.fields);
}

class UnauthorizedError extends AppError {
  const UnauthorizedError();
}

class NotFoundError extends AppError {
  final String message;
  const NotFoundError(this.message);
}

class ConflictError extends AppError {
  final String message;
  const ConflictError(this.message);
}

class ServerError extends AppError {
  const ServerError();
}

class NetworkError extends AppError {
  final String? originalMessage;
  final Object? originalError;
  const NetworkError({this.originalMessage, this.originalError});
}

class UnknownError extends AppError {
  final Object error;
  const UnknownError(this.error);
}
