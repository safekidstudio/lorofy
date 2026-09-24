import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lorofy/core/config/app_config.dart';
import 'package:lorofy/core/network/interceptors/auth_interceptor.dart';
import 'package:lorofy/core/network/interceptors/error_interceptor.dart';
import 'package:lorofy/core/network/interceptors/idempotency_interceptor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_client.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeoutMs),
      sendTimeout: Duration(milliseconds: AppConfig.connectTimeoutMs),
      headers: {
        "Content-Type": 'application/json',
        "Accept": 'application/json',
      },
    ),
  );

  // 1. Logging Interceptor (Dev Mode)
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint(object.toString()),
      ),
    );
  }

  // 2. Idempotency Interceptor
  dio.interceptors.add(IdempotencyInterceptor());

  // 3. Auth & Auto-Refresh Token Interceptor
  dio.interceptors.add(AuthInterceptor(dio, ref));

  // 4. Error Interceptor
  dio.interceptors.add(ErrorInterceptor());
  return dio;
}

// Lớp cấu hình options cho API kết nối
class ApiOptions {
  // Dùng cho API công khai không cần đăng nhập (Login, Register...)
  static Options get public => Options(extra: {'requiresAuth': false});

  // Dùng cho API yêu cầu đăng nhập (Đính kèm JWT token)
  static Options get protected => Options(extra: {'requiresAuth': true});

  // Dùng cho API yêu cầu đăng nhập và cần chống trùng lặp (Đính kèm X-Idempotency-Key)
  static Options get idempotent => Options(extra: {'requiresAuth': true, 'idempotent': true});
}

