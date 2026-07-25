import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pomodoro_settings.g.dart';

enum AmbientSound { none, wind, beach, nature, books, fire, rain, cafe }

class PomodoroSettings {
  final int focusMinutes;
  final int breakMinutes;
  final int longBreakMinutes;
  final int targetRounds;
  final AmbientSound ambientSound;

  const PomodoroSettings({
    required this.focusMinutes,
    required this.breakMinutes,
    required this.longBreakMinutes,
    required this.targetRounds,
    this.ambientSound = AmbientSound.none,
  });

  PomodoroSettings copyWith({
    int? focusMinutes,
    int? breakMinutes,
    int? longBreakMinutes,
    int? targetRounds,
    AmbientSound? ambientSound,
  }) {
    return PomodoroSettings(
      focusMinutes: focusMinutes ?? this.focusMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      targetRounds: targetRounds ?? this.targetRounds,
      ambientSound: ambientSound ?? this.ambientSound,
    );
  }
}

@riverpod
class PomodoroSettingsNotifier extends _$PomodoroSettingsNotifier {
  @override
  PomodoroSettings build() {
    return const PomodoroSettings(
      focusMinutes: 1,
      breakMinutes: 1,
      longBreakMinutes: 5,
      targetRounds: 4,
      ambientSound: AmbientSound.none,
    );
  }

  void updateSettings(PomodoroSettings newSettings) {
    state = newSettings;
  }
}
