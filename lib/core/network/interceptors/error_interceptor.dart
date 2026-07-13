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
          "Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng.",
        );
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;

        // Đọc thông báo lỗi tùy biến từ Spring Boot API trả về nếu có
        final serverMessage = (data is Map) ? data['message'] : null;

        if (statusCode == 401) {
          appException = UnauthorizedException(
            serverMessage ?? "Phiên đăng nhập đã hết hạn.",
          );
        } else if (statusCode == 400) {
          appException = BadRequestException(
            serverMessage ?? "Dữ liệu yêu cầu không hợp lệ.",
          );
        } else if (statusCode != null && statusCode >= 500) {
          appException = ServerException(
            serverMessage ?? "Máy chủ đang gặp sự cố. Thử lại sau.",
          );
        } else {
          appException = AppException(
            serverMessage ?? "Đã xảy ra lỗi không mong muốn.",
          );
        }
        break;

      default:
        appException = AppException("Đã xảy ra lỗi kết nối.");
    }

    // Ném appException vào error handler của dio để tầng trên (Repository) catch được trực tiếp
    return handler.next(err.copyWith(error: appException));
  }
}
