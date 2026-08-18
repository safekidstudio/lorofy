import 'package:lorofy/features/profile/domain/models/notification_item.dart';

abstract class NotificationsRepository {
  Future<List<NotificationItem>> getNotifications();
  Future<void> markAllAsRead();
  Future<void> toggleRead(String id);
}
