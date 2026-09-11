import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Request Android 13+ (API 33+) Notification Permission
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.requestNotificationsPermission();
      }

      // Request iOS Permissions
      final iosPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlatform != null) {
        await iosPlatform.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Show standard focus reminder notification (Medium Mode)
  Future<void> showFocusReminderNotification({
    String title = 'Focus Session Active',
    String body = 'Return to Lorofy to keep your focus session going.',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'focus_reminder_channel',
      'Focus Reminders',
      channelDescription: 'Reminders when focus session is running in background',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/launcher_icon',
      styleInformation: BigTextStyleInformation(body),
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      ),
    );

    try {
      await _notificationsPlugin.show(
        1001,
        title,
        body,
        notificationDetails,
        payload: 'focus_reminder',
      );
    } catch (e) {
      debugPrint('Error showing focus reminder notification: $e');
    }
  }

  /// Show strict mode warning notification (Grace Period)
  Future<void> showStrictWarningNotification({
    int seconds = 10,
    String? title,
    String? body,
  }) async {
    final defaultTitle = 'Warning: Focus Session in Danger';
    final defaultBody = 'You have $seconds seconds to return to Lorofy before your session fails.';

    final androidDetails = AndroidNotificationDetails(
      'strict_warning_channel',
      'Strict Mode Warnings',
      channelDescription: 'Urgent warnings when leaving app in Strict Mode',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      icon: '@mipmap/launcher_icon',
      styleInformation: BigTextStyleInformation(body ?? defaultBody),
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    try {
      await _notificationsPlugin.show(
        1003,
        title ?? defaultTitle,
        body ?? defaultBody,
        notificationDetails,
        payload: 'strict_warning',
      );
    } catch (e) {
      debugPrint('Error showing strict warning notification: $e');
    }
  }

  /// Show session failed notification (Strict Mode Timeout)
  Future<void> showSessionFailedNotification({
    String title = 'Focus Session Failed',
    String body = 'Your focus session was terminated because you left the app in Strict Mode.',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'session_alert_channel',
      'Session Alerts',
      channelDescription: 'Alerts when focus session fails or completes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/launcher_icon',
      styleInformation: BigTextStyleInformation(body),
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      ),
    );

    try {
      await _notificationsPlugin.show(
        1002,
        title,
        body,
        notificationDetails,
        payload: 'session_failed',
      );
    } catch (e) {
      debugPrint('Error showing session failed notification: $e');
    }
  }

  /// Cancel all active notifications
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }
}
