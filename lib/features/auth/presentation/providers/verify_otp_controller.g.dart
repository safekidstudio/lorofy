// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VerifyOtpController)
final verifyOtpControllerProvider = VerifyOtpControllerProvider._();

final class VerifyOtpControllerProvider
    extends $NotifierProvider<VerifyOtpController, VerifyOtpState> {
  VerifyOtpControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verifyOtpControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verifyOtpControllerHash();

  @$internal
  @override
  VerifyOtpController create() => VerifyOtpController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifyOtpState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifyOtpState>(value),
    );
  }
}

String _$verifyOtpControllerHash() =>
    r'229d8e7a56678eadcfd7717baf49ffe7dca29b56';

abstract class _$VerifyOtpController extends $Notifier<VerifyOtpState> {
  VerifyOtpState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VerifyOtpState, VerifyOtpState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VerifyOtpState, VerifyOtpState>,
              VerifyOtpState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
