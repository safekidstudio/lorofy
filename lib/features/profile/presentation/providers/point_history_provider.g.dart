// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pointHistory)
final pointHistoryProvider = PointHistoryProvider._();

final class PointHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PointHistoryModel>>,
          List<PointHistoryModel>,
          FutureOr<List<PointHistoryModel>>
        >
    with
        $FutureModifier<List<PointHistoryModel>>,
        $FutureProvider<List<PointHistoryModel>> {
  PointHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pointHistoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pointHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<PointHistoryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PointHistoryModel>> create(Ref ref) {
    return pointHistory(ref);
  }
}

String _$pointHistoryHash() => r'59dac67f607a6a43e4ca99c60518c031e2e92f7f';
