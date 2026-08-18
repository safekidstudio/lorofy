import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lorofy/features/profile/data/datasources/notifications_mock_datasource.dart';
import 'package:lorofy/features/profile/domain/models/notification_item.dart';
import 'package:lorofy/features/profile/domain/repositories/notifications_repository.dart';

part 'notifications_repository_impl.g.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsMockDataSource _dataSource;

  NotificationsRepositoryImpl(this._dataSource);

  @override
  Future<List<NotificationItem>> getNotifications() {
    return _dataSource.getNotifications();
  }

  @override
  Future<void> markAllAsRead() {
    return _dataSource.markAllAsRead();
  }

  @override
  Future<void> toggleRead(String id) {
    return _dataSource.toggleRead(id);
  }
}

@Riverpod(keepAlive: true)
NotificationsRepository notificationsRepository(Ref ref) {
  final dataSource = ref.read(notificationsMockDataSourceProvider);
  return NotificationsRepositoryImpl(dataSource);
}
