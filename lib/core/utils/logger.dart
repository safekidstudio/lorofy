import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized Logger utility for Lorofy application.
/// Silences debug logging in Production builds automatically.
class AppLogger {
  AppLogger._();

  static void debug(String message, {String tag = 'LOROFY'}) {
    if (kDebugMode) {
      developer.log('🔵 $message', name: tag);
    }
  }

  static void info(String message, {String tag = 'LOROFY'}) {
    if (kDebugMode) {
      developer.log('ℹ️ $message', name: tag);
    }
  }

  static void warning(String message, {String tag = 'LOROFY'}) {
    if (kDebugMode) {
      developer.log('⚠️ $message', name: tag);
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String tag = 'LOROFY'}) {
    if (kDebugMode) {
      developer.log(
        '🔴 $message',
        name: tag,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
