import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lorofy/core/utils/logger.dart';

class IOSFamilyControlsService {
  static const MethodChannel _channel =
      MethodChannel('com.lorofy.app/ios_family_controls');
  static const String _tag = 'IOSFamilyControlsService';

  static final IOSFamilyControlsService _instance =
      IOSFamilyControlsService._internal();
  factory IOSFamilyControlsService() => _instance;
  IOSFamilyControlsService._internal();

  /// Check if the current device is running iOS 15.0+ and supports Family Controls
  Future<bool> isSupported() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    try {
      final bool? supported = await _channel.invokeMethod<bool>('isSupported');
      return supported ?? false;
    } catch (e, stack) {
      AppLogger.error('Error checking FamilyControls support',
          error: e, stackTrace: stack, tag: _tag);
      return false;
    }
  }

  /// Check if Family Controls permission has been authorized by the user
  Future<bool> hasAuthorization() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    try {
      final bool? authorized =
          await _channel.invokeMethod<bool>('hasAuthorization');
      return authorized ?? false;
    } catch (e, stack) {
      AppLogger.error('Error checking FamilyControls authorization',
          error: e, stackTrace: stack, tag: _tag);
      return false;
    }
  }

  /// Request Family Controls authorization from iOS
  Future<bool> requestAuthorization() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    try {
      final bool? granted =
          await _channel.invokeMethod<bool>('requestAuthorization');
      return granted ?? false;
    } catch (e, stack) {
      AppLogger.error('Error requesting FamilyControls authorization',
          error: e, stackTrace: stack, tag: _tag);
      return false;
    }
  }

  /// Present native iOS SwiftUI FamilyActivityPicker UI
  Future<bool> openAppPicker() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    try {
      final bool? success = await _channel.invokeMethod<bool>('openAppPicker');
      return success ?? false;
    } catch (e, stack) {
      AppLogger.error('Error opening iOS FamilyActivityPicker',
          error: e, stackTrace: stack, tag: _tag);
      return false;
    }
  }

  /// Start shielding / blocking unallowed apps during a Focus session
  Future<bool> startBlocking() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    try {
      final bool? success = await _channel.invokeMethod<bool>('startBlocking');
      return success ?? false;
    } catch (e, stack) {
      AppLogger.error('Error starting iOS app blocking',
          error: e, stackTrace: stack, tag: _tag);
      return false;
    }
  }

  /// Stop shielding / restore apps when a Focus session ends or resets
  Future<bool> stopBlocking() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    try {
      final bool? success = await _channel.invokeMethod<bool>('stopBlocking');
      return success ?? false;
    } catch (e, stack) {
      AppLogger.error('Error stopping iOS app blocking',
          error: e, stackTrace: stack, tag: _tag);
      return false;
    }
  }
}
