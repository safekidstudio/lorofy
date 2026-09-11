import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lorofy/core/utils/logger.dart';

class ForegroundAppService {
  static const MethodChannel _channel = MethodChannel('com.lorofy.app/foreground_app');
  static const String _tag = 'ForegroundAppService';

  static final ForegroundAppService _instance = ForegroundAppService._internal();
  factory ForegroundAppService() => _instance;
  ForegroundAppService._internal();

  /// Check if the user has granted Usage Access (PACKAGE_USAGE_STATS) permission
  Future<bool> hasUsagePermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    try {
      final bool? hasPermission = await _channel.invokeMethod<bool>('hasUsagePermission');
      return hasPermission ?? false;
    } catch (e, stack) {
      AppLogger.error('Error checking usage permission', error: e, stackTrace: stack, tag: _tag);
      return false;
    }
  }

  /// Request Usage Access permission by opening Android Settings
  Future<void> requestUsagePermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod('requestUsagePermission');
    } catch (e, stack) {
      AppLogger.error('Error opening usage permission settings', error: e, stackTrace: stack, tag: _tag);
    }
  }

  /// Query the current foreground application package name from native Android UsageStatsManager
  Future<String?> getForegroundAppPackage() async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final String? packageName = await _channel.invokeMethod<String?>('getForegroundApp');
      return packageName;
    } catch (e, stack) {
      AppLogger.error('Error getting foreground app package', error: e, stackTrace: stack, tag: _tag);
      return null;
    }
  }

  /// Check if the package is a system launcher or Home screen
  Future<bool> isLauncherPackage(String packageName) async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final bool? isLauncher = await _channel.invokeMethod<bool>(
        'isLauncherApp',
        {'packageName': packageName},
      );
      return isLauncher ?? false;
    } catch (e, stack) {
      AppLogger.error('Error checking if launcher package', error: e, stackTrace: stack, tag: _tag);
      return false;
    }
  }
}
