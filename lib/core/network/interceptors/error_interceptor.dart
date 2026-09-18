import 'package:dio/dio.dart';
import 'package:lorofy/core/errors/exceptions.dart';

/// Maps raw [DioException] responses to typed [AppException] subclasses.
///
/// Note: 401 and 403 responses that reach this interceptor have already been
/// processed by [AuthInterceptor] (refresh attempted, retry done). Any 401/403
/// seen here is a genuine auth failure — it will propagate as-is so callers
/// can present the appropriate UI.
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
        final serverMessage = (data is Map) ? data['message'] as String? : null;
        final codeString = statusCode?.toString();

        if (statusCode == 401) {
          appException = UnauthorizedException(
            serverMessage ?? "Session has expired. Please log in again.",
            codeString,
          );
        } else if (statusCode == 403) {
          appException = ForbiddenException(
            serverMessage ?? "You don't have permission to access this resource.",
            codeString,
          );
        } else if (statusCode == 400) {
          appException = BadRequestException(
            serverMessage ?? "Invalid request data provided.",
            codeString,
          );
        } else if (statusCode == 404) {
          appException = AppException(
            serverMessage ?? "The requested resource was not found.",
            codeString,
          );
        } else if (statusCode == 422) {
          appException = BadRequestException(
            serverMessage ?? "Validation failed. Please check your input.",
            codeString,
          );
        } else if (statusCode == 429) {
          appException = AppException(
            serverMessage ?? "Too many requests. Please slow down.",
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

    // Attach appException to dio error so Repositories can catch it directly
    return handler.next(err.copyWith(error: appException));
  }
}
