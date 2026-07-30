import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lorofy/features/focus/data/models/focus_category.dart';

part 'pomodoro_settings.g.dart';

enum AmbientSound { none, wind, beach, nature, books, fire, rain, cafe }

class PomodoroSettings {
  final int focusMinutes;
  final int breakMinutes;
  final int longBreakMinutes;
  final int targetRounds;
  final AmbientSound ambientSound;
  final FocusCategory? selectedCategory;
  final bool timedReminder;
  final bool isDeepFocusMode;

  const PomodoroSettings({
    required this.focusMinutes,
    required this.breakMinutes,
    required this.longBreakMinutes,
    required this.targetRounds,
    this.ambientSound = AmbientSound.none,
    this.selectedCategory,
    this.timedReminder = true,
    this.isDeepFocusMode = false,
  });

  PomodoroSettings copyWith({
    int? focusMinutes,
    int? breakMinutes,
    int? longBreakMinutes,
    int? targetRounds,
    AmbientSound? ambientSound,
    FocusCategory? selectedCategory,
    bool? timedReminder,
    bool? isDeepFocusMode,
  }) {
    final newIsDeep = isDeepFocusMode ?? this.isDeepFocusMode;
    int newTargetRounds = targetRounds ?? this.targetRounds;
    int newBreakMinutes = breakMinutes ?? this.breakMinutes;
    int newFocusMinutes = focusMinutes ?? this.focusMinutes;

    if (newIsDeep) {
      newTargetRounds = 1;
      newBreakMinutes = 0;
    } else {
      if (this.isDeepFocusMode && !newIsDeep) {
        if (newTargetRounds == 1) newTargetRounds = 4;
        if (newBreakMinutes == 0) newBreakMinutes = 5;
      }
      if (newFocusMinutes > 90) {
        newFocusMinutes = 90;
      }
    }

    return PomodoroSettings(
      focusMinutes: newFocusMinutes,
      breakMinutes: newBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      targetRounds: newTargetRounds,
      ambientSound: ambientSound ?? this.ambientSound,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      timedReminder: timedReminder ?? this.timedReminder,
      isDeepFocusMode: newIsDeep,
    );
  }
}

@riverpod
class PomodoroSettingsNotifier extends _$PomodoroSettingsNotifier {
  @override
  PomodoroSettings build() {
    return const PomodoroSettings(
      focusMinutes: 25, // Changing default to 25 to match typical Pomodoro and the reference design
      breakMinutes: 5,
      longBreakMinutes: 15,
      targetRounds: 4,
      ambientSound: AmbientSound.none,
      selectedCategory: null,
      timedReminder: true,
    );
  }

  void updateSettings(PomodoroSettings newSettings) {
    state = newSettings;
  }
}
