// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PomodoroSettingsNotifier)
final pomodoroSettingsProvider = PomodoroSettingsNotifierProvider._();

final class PomodoroSettingsNotifierProvider
    extends $NotifierProvider<PomodoroSettingsNotifier, PomodoroSettings> {
  PomodoroSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pomodoroSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pomodoroSettingsNotifierHash();

  @$internal
  @override
  PomodoroSettingsNotifier create() => PomodoroSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PomodoroSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PomodoroSettings>(value),
    );
  }
}

String _$pomodoroSettingsNotifierHash() =>
    r'980f2a30e8fe97a5da80aad7fb222105e7a98d4d';

abstract class _$PomodoroSettingsNotifier extends $Notifier<PomodoroSettings> {
  PomodoroSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PomodoroSettings, PomodoroSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PomodoroSettings, PomodoroSettings>,
              PomodoroSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
