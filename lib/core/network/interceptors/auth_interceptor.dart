import 'package:dio/dio.dart';
import 'package:lorofy/core/config/app_config.dart';
import 'package:lorofy/core/storage/auth_storage.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final Dio dio;
  final Ref ref;

  AuthInterceptor(this.dio, this.ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth) {
      var accessToken = ref.read(authProvider).accessToken;

      // ignore: prefer_conditional_assignment
      if (accessToken == null) {
        accessToken = await ref.read(authStorageProvider).getAccessToken();
      }

      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        err.requestOptions.extra['requiresAuth'] != false) {
      try {
        final success = await _performTokenRefresh();

        if (success) {
          final newToken = ref.read(authProvider).accessToken;

          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newToken';

          final response = await dio.fetch(requestOptions);
          return handler.resolve(response);
        }
      } catch (e) {
        ref.read(authProvider.notifier).logout();
      }
    }
    return handler.next(err);
  }

  Future<bool> _performTokenRefresh() async {
    final refreshToken = await ref.read(authStorageProvider).getRefreshToken();
    if (refreshToken == null) return false;

    final refreshDio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));

    final response = await refreshDio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    if (response.statusCode == 200) {
      final newAccessToken = response.data['accessToken'];
      final newRefreshToken = response.data['refreshToken'];

      // Lưu lại token mới vào storage
      await ref
          .read(authStorageProvider)
          .saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
      return true;
    }
    return false;
  }
}
