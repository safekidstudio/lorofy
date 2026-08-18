import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lorofy/features/profile/domain/models/notification_item.dart';

part 'notifications_mock_datasource.g.dart';

class NotificationsMockDataSource {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      sender: 'Lorofy',
      action: 'shared the meeting',
      topic: 'Boctamp Online Course',
      timeAgo: '3 hours ago',
      isUnread: true,
    ),
    NotificationItem(
      id: '2',
      sender: 'Lorofy',
      action: 'shared the meeting',
      topic: 'Boctamp Online Course',
      timeAgo: '3 hours ago',
      isUnread: false,
    ),
    NotificationItem(
      id: '3',
      sender: 'Lorofy',
      action: 'shared the meeting',
      topic: 'Boctamp Online Course',
      timeAgo: '3 hours ago',
      isUnread: false,
    ),
    NotificationItem(
      id: '4',
      sender: 'Lorofy',
      action: 'shared the meeting',
      topic: 'Boctamp Online Course',
      timeAgo: '3 hours ago',
      isUnread: false,
    ),
    NotificationItem(
      id: '5',
      sender: 'Lorofy',
      action: 'shared the meeting',
      topic: 'Boctamp Online Course',
      timeAgo: '3 hours ago',
      isUnread: false,
    ),
    NotificationItem(
      id: '6',
      sender: 'Lorofy',
      action: 'shared the meeting',
      topic: 'Boctamp Online Course',
      timeAgo: '3 hours ago',
      isUnread: false,
    ),
    NotificationItem(
      id: '7',
      sender: 'Lorofy',
      action: 'shared the meeting',
      topic: 'Boctamp Online Course',
      timeAgo: '3 hours ago',
      isUnread: false,
    ),
  ];

  Future<List<NotificationItem>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_notifications);
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].isUnread) {
        _notifications[i] = _notifications[i].copyWith(isUnread: false);
      }
    }
  }

  Future<void> toggleRead(String id) async {
    final index = _notifications.indexWhere((element) => element.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isUnread: !_notifications[index].isUnread,
      );
    }
  }
}

@Riverpod(keepAlive: true)
NotificationsMockDataSource notificationsMockDataSource(Ref ref) {
  return NotificationsMockDataSource();
}
