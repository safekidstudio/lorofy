import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lorofy/features/profile/domain/models/notification_item.dart';
import 'package:lorofy/features/profile/data/repositories/notifications_repository_impl.dart';

part 'notifications_provider.g.dart';

@riverpod
class Notifications extends _$Notifications {
  @override
  FutureOr<List<NotificationItem>> build() async {
    final repository = ref.read(notificationsRepositoryProvider);
    return await repository.getNotifications();
  }

  Future<void> markAllAsRead() async {
    // Optimistically update local state for instant UI reaction,
    // then fetch fresh list from repository.
    final currentList = state.value;
    if (currentList != null) {
      state = AsyncValue.data(
        currentList.map((item) => item.copyWith(isUnread: false)).toList(),
      );
    }
    state = await AsyncValue.guard(() async {
      final repository = ref.read(notificationsRepositoryProvider);
      await repository.markAllAsRead();
      return await repository.getNotifications();
    });
  }

  Future<void> toggleRead(String id) async {
    final currentList = state.value;
    if (currentList != null) {
      state = AsyncValue.data(
        currentList.map((item) {
          if (item.id == id) {
            return item.copyWith(isUnread: !item.isUnread);
          }
          return item;
        }).toList(),
      );
    }
    state = await AsyncValue.guard(() async {
      final repository = ref.read(notificationsRepositoryProvider);
      await repository.toggleRead(id);
      return await repository.getNotifications();
    });
  }
}
