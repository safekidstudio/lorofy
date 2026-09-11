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

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Show reminder notification when app goes to background during Medium Mode focus
  Future<void> showFocusReminderNotification({
    String title = 'Phiên tập trung đang diễn ra! 🌿',
    String body = 'Vui lòng quay lại Lorofy để không gián đoạn quá trình phát triển mầm cây.',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'focus_reminder_channel',
      'Focus Reminders',
      channelDescription: 'Notifications to remind you to stay focused in Lorofy',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/launcher_icon',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _notificationsPlugin.show(
        1001, // Notification ID for Focus Reminder
        title,
        body,
        notificationDetails,
        payload: 'focus_reminder',
      );
    } catch (e) {
      debugPrint('Error showing focus reminder notification: $e');
    }
  }

  /// Show alert notification when focus session fails in Strict Mode
  Future<void> showSessionFailedNotification({
    String title = 'Phiên tập trung đã thất bại! 🥀',
    String body = 'Bạn đã rời khỏi Lorofy trong chế độ Chặn Nghiêm Ngặt (Strict Mode).',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'session_alert_channel',
      'Session Alerts',
      channelDescription: 'Alerts when focus sessions complete or fail',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/launcher_icon',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _notificationsPlugin.show(
        1002, // Notification ID for Session Fail
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
