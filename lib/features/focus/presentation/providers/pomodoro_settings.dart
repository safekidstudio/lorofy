import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/domain/models/ambient_sound.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_settings.dart';

part 'pomodoro_settings.g.dart';


@riverpod
class PomodoroSettingsNotifier extends _$PomodoroSettingsNotifier {
  @override
  PomodoroSettings build() {
    return const PomodoroSettings(
      focusMinutes: 25,
      breakMinutes: 5,
      longBreakMinutes: 10,
      targetRounds: 4,
      ambientSound: AmbientSound.none,
      selectedCategory: null,
      timedReminder: true,
      isDeepFocusMode: true,
      blockMode: BlockMode.MEDIUM,
      blockedCategories: {'Social Media'},
      autoStartBreak: true,
      autoStartFocus: true,
      pushNotifications: true,
      backgroundProcess: true,
    );
  }

  void updateSettings(PomodoroSettings newSettings) {
    state = newSettings;
  }
}

