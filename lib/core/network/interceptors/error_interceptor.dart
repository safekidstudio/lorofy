import 'package:dio/dio.dart';
import 'package:lorofy/core/errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException appException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        appException = NetworkException(
          "Unable to connect to server. Please check your network connection.",
          "NETWORK_ERROR",
        );
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;

        // Parse custom server error message returned from Spring Boot API if present
        final serverMessage = (data is Map) ? data['message'] : null;
        final codeString = statusCode?.toString();

        if (statusCode == 401) {
          appException = UnauthorizedException(
            serverMessage ?? "Session has expired. Please log in again.",
            codeString,
          );
        } else if (statusCode == 400) {
          appException = BadRequestException(
            serverMessage ?? "Invalid request data provided.",
            codeString,
          );
        } else if (statusCode != null && statusCode >= 500) {
          appException = ServerException(
            serverMessage ?? "Server error occurred. Please try again later.",
            codeString,
          );
        } else {
          appException = AppException(
            serverMessage ?? "An unexpected error occurred.",
            codeString,
          );
        }
        break;

      default:
        appException = AppException("Connection error occurred.");
    }

    // Attach appException to dio error handler so Repositories can catch it directly
    return handler.next(err.copyWith(error: appException));
  }
}
