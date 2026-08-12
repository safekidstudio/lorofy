// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FocusCategories)
final focusCategoriesProvider = FocusCategoriesProvider._();

final class FocusCategoriesProvider
    extends $AsyncNotifierProvider<FocusCategories, List<FocusCategory>> {
  FocusCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusCategoriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusCategoriesHash();

  @$internal
  @override
  FocusCategories create() => FocusCategories();
}

String _$focusCategoriesHash() => r'54be96bcba52877ad059202fae4c4e4b05a22e6f';

abstract class _$FocusCategories extends $AsyncNotifier<List<FocusCategory>> {
  FutureOr<List<FocusCategory>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<FocusCategory>>, List<FocusCategory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FocusCategory>>, List<FocusCategory>>,
              AsyncValue<List<FocusCategory>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
