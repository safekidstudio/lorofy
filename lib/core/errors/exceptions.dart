import 'package:dio/dio.dart';
import 'failures.dart';

class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() {
    if (code != null) {
      return '[$code] $message';
    }
    return message;
  }
}

class NetworkException extends AppException {
  NetworkException([super.message = "Can't connect to the server", super.code]);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = "Session expired", super.code]);
}

class ServerException extends AppException {
  ServerException([super.message = "Server error", super.code]);
}

class BadRequestException extends AppException {
  BadRequestException([super.message = "Bad request", super.code]);
}

extension ErrorExtractor on Object {
  Failure toFailure() {
    final error = this;
    if (error is Failure) return error;

    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        return UnauthorizedFailure(errorMessage, 'UNAUTHORIZED');
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return NetworkFailure(errorMessage, 'NETWORK_ERROR');
      }
      return ServerFailure(errorMessage, error.response?.statusCode?.toString());
    }

    if (error is UnauthorizedException) {
      return UnauthorizedFailure(error.message, error.code);
    }
    if (error is NetworkException) {
      return NetworkFailure(error.message, error.code);
    }
    if (error is ServerException) {
      return ServerFailure(error.message, error.code);
    }

    return ServerFailure(errorMessage);
  }

  String get errorMessage {
    final error = this;
    if (error is Failure) {
      return error.message;
    }

    if (error is DioException) {
      final appError = error.error;
      if (appError is AppException) {
        return appError.toString();
      }

      final data = error.response?.data;
      if (data is Map) {
        final msg = data['message'];
        final status = data['status'] ?? error.response?.statusCode;
        if (msg is String) {
          if (status != null) {
            return "[$status] $msg";
          }
          return msg;
        }
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return "Unable to connect to server. Please check your network connection.";
      }

      final status = error.response?.statusCode;
      if (status != null) {
        return "[$status] An unexpected error occurred.";
      }

      return error.message ?? "Connection error occurred.";
    }

    if (error is AppException) {
      return error.toString();
    }

    return error.toString();
  }
}

