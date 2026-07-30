// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(focusRepository)
final focusRepositoryProvider = FocusRepositoryProvider._();

final class FocusRepositoryProvider
    extends
        $FunctionalProvider<FocusRepository, FocusRepository, FocusRepository>
    with $Provider<FocusRepository> {
  FocusRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusRepositoryHash();

  @$internal
  @override
  $ProviderElement<FocusRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FocusRepository create(Ref ref) {
    return focusRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusRepository>(value),
    );
  }
}

String _$focusRepositoryHash() => r'd754be4c934459d68c730dafe49b1ea0f739bf9c';
