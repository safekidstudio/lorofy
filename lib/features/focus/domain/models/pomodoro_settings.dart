import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/domain/models/ambient_sound.dart';
import 'package:lorofy/features/focus/domain/models/focus_category.dart';

class PomodoroSettings {
  final int focusMinutes;
  final int breakMinutes;
  final int longBreakMinutes;
  final int targetRounds;
  final AmbientSound ambientSound;
  final FocusCategory? selectedCategory;
  final bool timedReminder;
  final bool isDeepFocusMode;
  final BlockMode blockMode;
  final Set<String> blockedCategories;
  final bool autoStartBreak;
  final bool autoStartFocus;
  final bool pushNotifications;
  final bool backgroundProcess;

  const PomodoroSettings({
    required this.focusMinutes,
    required this.breakMinutes,
    required this.longBreakMinutes,
    required this.targetRounds,
    this.ambientSound = AmbientSound.none,
    this.selectedCategory,
    this.timedReminder = true,
    this.isDeepFocusMode = false,
    this.blockMode = BlockMode.MEDIUM,
    this.blockedCategories = const {'Social Media'},
    this.autoStartBreak = true,
    this.autoStartFocus = true,
    this.pushNotifications = true,
    this.backgroundProcess = true,
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
    BlockMode? blockMode,
    Set<String>? blockedCategories,
    bool? autoStartBreak,
    bool? autoStartFocus,
    bool? pushNotifications,
    bool? backgroundProcess,
  }) {
    int newFocusMinutes = focusMinutes ?? this.focusMinutes;
    if (newFocusMinutes > 180) {
      newFocusMinutes = 180;
    }

    return PomodoroSettings(
      focusMinutes: newFocusMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      targetRounds: targetRounds ?? this.targetRounds,
      ambientSound: ambientSound ?? this.ambientSound,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      timedReminder: timedReminder ?? this.timedReminder,
      isDeepFocusMode: isDeepFocusMode ?? this.isDeepFocusMode,
      blockMode: blockMode ?? this.blockMode,
      blockedCategories: blockedCategories ?? this.blockedCategories,
      autoStartBreak: autoStartBreak ?? this.autoStartBreak,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      backgroundProcess: backgroundProcess ?? this.backgroundProcess,
    );
  }
}
