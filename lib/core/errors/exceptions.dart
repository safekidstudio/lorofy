import 'package:dio/dio.dart';

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
  String get errorMessage {
    final error = this;
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
        return "Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng.";
      }

      final status = error.response?.statusCode;
      if (status != null) {
        return "[$status] Đã xảy ra lỗi không mong muốn.";
      }

      return error.message ?? "Đã xảy ra lỗi kết nối.";
    }

    if (error is AppException) {
      return error.toString();
    }

    return error.toString();
  }
}

