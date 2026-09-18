import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lorofy/core/config/app_config.dart';
import 'package:lorofy/core/storage/auth_storage.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Key used to mark retry requests so we don't enter infinite refresh loops.
const _kIsRetry = '_isRetry';

/// Production-grade auth interceptor using [QueuedInterceptorsWrapper].
///
/// Handles both:
/// - **401 Unauthorized** — standard token-expired signal
/// - **403 Forbidden** — some backends (e.g. Spring Boot) return 403 for
///   expired JWTs instead of 401. We attempt a refresh first, then if the
///   retry still returns 403, we treat it as a genuine access-denied error.
///
/// Flow:
/// 1. Attach Bearer token to every protected request (onRequest).
/// 2. On 401 or 403 (first try) → attempt silent token refresh → retry.
/// 3. On 401 or 403 (retry, _isRetry=true) → token genuinely invalid → logout.
/// 4. On any other error → pass through.
class AuthInterceptor extends QueuedInterceptorsWrapper {
  final Dio dio;
  final Ref ref;

  AuthInterceptor(this.dio, this.ref);

  // ─── onRequest ────────────────────────────────────────────────────────────

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth) {
      // Read from RAM first (fast path), fall back to secure storage
      var accessToken = ref.read(authProvider).accessToken;
      accessToken ??= await ref.read(authStorageProvider).getAccessToken();

      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    return handler.next(options);
  }

  // ─── onError ──────────────────────────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final requiresAuth = err.requestOptions.extra['requiresAuth'] != false;
    final isRetry = err.requestOptions.extra[_kIsRetry] == true;

    // Only intercept auth-required requests with 401 or 403
    final isAuthError = (statusCode == 401 || statusCode == 403) && requiresAuth;

    if (isAuthError) {
      // If this was already a retry, the refresh didn't help → force logout
      if (isRetry) {
        debugPrint(
          'AuthInterceptor: [$statusCode] retry still failed → logging out',
        );
        await ref.read(authProvider.notifier).logout();
        return handler.next(err);
      }

      // First failure: attempt silent token refresh
      try {
        final refreshed = await _performTokenRefresh();

        if (refreshed) {
          // Refresh succeeded → retry the original request once
          final newToken = ref.read(authProvider).accessToken;
          final retryOptions = err.requestOptions
            ..headers['Authorization'] = 'Bearer $newToken'
            ..extra[_kIsRetry] = true;

          debugPrint(
            'AuthInterceptor: [$statusCode] token refreshed → retrying ${retryOptions.path}',
          );

          final response = await dio.fetch(retryOptions);
          return handler.resolve(response);
        }
      } catch (e) {
        debugPrint('AuthInterceptor: token refresh threw: $e');
      }

      // Refresh failed or returned false → session is unrecoverable → logout
      debugPrint('AuthInterceptor: [$statusCode] refresh failed → logging out');
      await ref.read(authProvider.notifier).logout();
    }

    return handler.next(err);
  }

  // ─── Token Refresh ────────────────────────────────────────────────────────

  /// Calls `/auth/refresh` on a separate Dio instance (no interceptors)
  /// to avoid recursive interceptor invocations.
  Future<bool> _performTokenRefresh() async {
    final refreshToken = await ref.read(authStorageProvider).getRefreshToken();
    if (refreshToken == null) {
      debugPrint('AuthInterceptor: no refresh token stored → cannot refresh');
      return false;
    }

    final refreshDio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final response = await refreshDio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    if (response.statusCode == 200) {
      final data = response.data?['data'];
      if (data != null) {
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          await ref.read(authProvider.notifier).updateTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          debugPrint('AuthInterceptor: tokens refreshed successfully');
          return true;
        }
      }
    }

    return false;
  }
}
