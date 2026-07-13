// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_password_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreatePasswordController)
final createPasswordControllerProvider = CreatePasswordControllerProvider._();

final class CreatePasswordControllerProvider
    extends $AsyncNotifierProvider<CreatePasswordController, void> {
  CreatePasswordControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPasswordControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPasswordControllerHash();

  @$internal
  @override
  CreatePasswordController create() => CreatePasswordController();
}

String _$createPasswordControllerHash() =>
    r'42e0c12bb2d6643e9876a1445ed7f86eff2cbffc';

abstract class _$CreatePasswordController extends $AsyncNotifier<void> {
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
