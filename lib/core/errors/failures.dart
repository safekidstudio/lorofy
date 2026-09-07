import 'package:flutter/foundation.dart';

/// Base class representing Domain-level failures in Clean Architecture.
@immutable
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

/// Failure representing server-side errors (5xx, 4xx API responses)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server connection error', super.code]);
}

/// Failure representing network connectivity errors (timeouts, no internet)
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Unable to connect to the internet. Please check your network connection.',
    super.code,
  ]);
}

/// Failure representing unauthorized/authentication session expiration
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Your session has expired. Please log in again.',
    super.code,
  ]);
}

/// Failure representing local storage/cache errors
class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Local data storage error',
    super.code,
  ]);
}

/// Failure representing form or data validation errors
class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Invalid input data provided',
    super.code,
  ]);
}
