// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mascot_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MascotNotifier)
final mascotProvider = MascotNotifierProvider._();

final class MascotNotifierProvider
    extends $NotifierProvider<MascotNotifier, MascotState> {
  MascotNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mascotProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mascotNotifierHash();

  @$internal
  @override
  MascotNotifier create() => MascotNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MascotState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MascotState>(value),
    );
  }
}

String _$mascotNotifierHash() => r'2536c2d2fcebaa7c70d0cee58c1273b5d54e7b32';

abstract class _$MascotNotifier extends $Notifier<MascotState> {
  MascotState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MascotState, MascotState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MascotState, MascotState>,
              MascotState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
