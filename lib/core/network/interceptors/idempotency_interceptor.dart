import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Constants for Idempotency
const String kIdempotencyExtraKey = 'idempotencyKey';
const String kRequiresIdempotencyExtraKey = 'idempotent';
const String kIdempotencyHeaderName = 'X-Idempotency-Key';

/// Global Interceptor to automatically manage Idempotency Keys for Dio requests.
///
/// **Flow:**
/// 1. Triggered when `options.extra['idempotent'] == true` or when `X-Idempotency-Key` header is present.
/// 2. For a NEW request: Generates a new UUID v4 and stores it in `options.extra['idempotencyKey']`.
/// 3. For a RETRY request (due to network failure / token refresh): Reuses the existing UUID.
/// 4. Respects manually provided `X-Idempotency-Key` if specified by developer.
class IdempotencyInterceptor extends Interceptor {
  final Uuid _uuid;

  IdempotencyInterceptor({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Check if idempotency is requested via extra or header
    final bool isExplicitlyRequested =
        options.extra[kRequiresIdempotencyExtraKey] == true;
    final bool hasHeader = options.headers.containsKey(kIdempotencyHeaderName);

    if (isExplicitlyRequested || hasHeader) {
      // 1. If header is already manually provided, do nothing
      if (hasHeader && options.headers[kIdempotencyHeaderName] != null) {
        return handler.next(options);
      }

      // 2. Check if this is a RETRY request with a pre-existing key
      String? key = options.extra[kIdempotencyExtraKey] as String?;

      if (key == null || key.isEmpty) {
        // 3. New request: generate fresh UUID
        key = _uuid.v4();
        options.extra[kIdempotencyExtraKey] = key;
      }

      // Attach key to header
      options.headers[kIdempotencyHeaderName] = key;
      debugPrint('IdempotencyInterceptor: Attached Key [$key] to ${options.path}');
    }

    return handler.next(options);
  }
}
