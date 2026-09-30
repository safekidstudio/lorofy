import 'dart:async';
import 'package:dio/dio.dart';
import 'package:lorofy/core/config/app_config.dart';
import 'package:lorofy/core/storage/auth_storage.dart';
import 'package:lorofy/core/utils/logger.dart';
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
/// Single-Flight Token Refresh Flow:
/// 1. Attach Bearer token to every protected request (onRequest).
/// 2. On 401 or 403 (first try) → attempt silent token refresh.
/// 3. If a refresh is already in progress, concurrent 401 requests queue and wait for the single refresh.
/// 4. Once refreshed, all queued requests retry with the new token.
/// 5. On 401 or 403 (retry, _isRetry=true) → token genuinely invalid → logout.
class AuthInterceptor extends QueuedInterceptorsWrapper {
  final Dio dio;
  final Ref ref;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

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
        AppLogger.warning(
          '[$statusCode] retry still failed → logging out',
          tag: 'AuthInterceptor',
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

          AppLogger.info(
            '[$statusCode] token refreshed → retrying ${retryOptions.path}',
            tag: 'AuthInterceptor',
          );

          final response = await dio.fetch(retryOptions);
          return handler.resolve(response);
        }
      } catch (e) {
        AppLogger.error('token refresh threw: $e', tag: 'AuthInterceptor');
      }

      // Refresh failed or returned false → session is unrecoverable → logout
      AppLogger.warning(
        '[$statusCode] refresh failed → logging out',
        tag: 'AuthInterceptor',
      );
      await ref.read(authProvider.notifier).logout();
    }

    return handler.next(err);
  }

  // ─── Token Refresh ────────────────────────────────────────────────────────

  /// Calls `/auth/refresh` on a separate Dio instance (no interceptors)
  /// to avoid recursive interceptor invocations.
  ///
  /// Uses a single-flight pattern with [Completer] so concurrent 401/403
  /// failures wait for a single refresh request rather than spamming multiple refresh calls.
  Future<bool> _performTokenRefresh() async {
    if (_isRefreshing && _refreshCompleter != null) {
      AppLogger.info(
        'token refresh already in progress → queuing request to wait for completion',
        tag: 'AuthInterceptor',
      );
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await ref.read(authStorageProvider).getRefreshToken();
      if (refreshToken == null) {
        AppLogger.warning(
          'no refresh token stored → cannot refresh',
          tag: 'AuthInterceptor',
        );
        if (!_refreshCompleter!.isCompleted) {
          _refreshCompleter!.complete(false);
        }
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
            AppLogger.info(
              'tokens refreshed successfully',
              tag: 'AuthInterceptor',
            );
            if (!_refreshCompleter!.isCompleted) {
              _refreshCompleter!.complete(true);
            }
            return true;
          }
        }
      }

      if (!_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(false);
      }
      return false;
    } catch (e) {
      AppLogger.error('token refresh threw: $e', tag: 'AuthInterceptor');
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(false);
      }
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }
}
