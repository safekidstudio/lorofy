// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardController)
final onboardControllerProvider = OnboardControllerProvider._();

final class OnboardControllerProvider
    extends $AsyncNotifierProvider<OnboardController, void> {
  OnboardControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardControllerHash();

  @$internal
  @override
  OnboardController create() => OnboardController();
}

String _$onboardControllerHash() => r'fe83848478896d5c6eee094f933d94405d282efa';

abstract class _$OnboardController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
