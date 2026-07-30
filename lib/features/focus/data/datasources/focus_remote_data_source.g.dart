// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(focusRemoteDataSource)
final focusRemoteDataSourceProvider = FocusRemoteDataSourceProvider._();

final class FocusRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          FocusRemoteDataSource,
          FocusRemoteDataSource,
          FocusRemoteDataSource
        >
    with $Provider<FocusRemoteDataSource> {
  FocusRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<FocusRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FocusRemoteDataSource create(Ref ref) {
    return focusRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusRemoteDataSource>(value),
    );
  }
}

String _$focusRemoteDataSourceHash() =>
    r'a617fe0382bc45685ec4faf6611d334be452bb73';
