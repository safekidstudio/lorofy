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
    r'ff9940838d8df4b12a1d8778c60b03252e355f17';

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
