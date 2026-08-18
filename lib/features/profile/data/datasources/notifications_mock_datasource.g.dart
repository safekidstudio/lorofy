// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_mock_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationsMockDataSource)
final notificationsMockDataSourceProvider =
    NotificationsMockDataSourceProvider._();

final class NotificationsMockDataSourceProvider
    extends
        $FunctionalProvider<
          NotificationsMockDataSource,
          NotificationsMockDataSource,
          NotificationsMockDataSource
        >
    with $Provider<NotificationsMockDataSource> {
  NotificationsMockDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsMockDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsMockDataSourceHash();

  @$internal
  @override
  $ProviderElement<NotificationsMockDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationsMockDataSource create(Ref ref) {
    return notificationsMockDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsMockDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsMockDataSource>(value),
    );
  }
}

String _$notificationsMockDataSourceHash() =>
    r'4b73be16a09bce0067d9da4032df182b4a65ea79';
