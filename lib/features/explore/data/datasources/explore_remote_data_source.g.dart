// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exploreRemoteDataSource)
final exploreRemoteDataSourceProvider = ExploreRemoteDataSourceProvider._();

final class ExploreRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ExploreRemoteDataSource,
          ExploreRemoteDataSource,
          ExploreRemoteDataSource
        >
    with $Provider<ExploreRemoteDataSource> {
  ExploreRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ExploreRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExploreRemoteDataSource create(Ref ref) {
    return exploreRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExploreRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExploreRemoteDataSource>(value),
    );
  }
}

String _$exploreRemoteDataSourceHash() =>
    r'b57cd808be7992d27b00a2ab7a5438bab560f624';
