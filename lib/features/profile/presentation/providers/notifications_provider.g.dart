// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Notifications)
final notificationsProvider = NotificationsProvider._();

final class NotificationsProvider
    extends $AsyncNotifierProvider<Notifications, List<NotificationItem>> {
  NotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsHash();

  @$internal
  @override
  Notifications create() => Notifications();
}

String _$notificationsHash() => r'8a22d4dac144ebcbaa9fc1d567f9dad299b7af18';

abstract class _$Notifications extends $AsyncNotifier<List<NotificationItem>> {
  FutureOr<List<NotificationItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<NotificationItem>>, List<NotificationItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<NotificationItem>>,
                List<NotificationItem>
              >,
              AsyncValue<List<NotificationItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
