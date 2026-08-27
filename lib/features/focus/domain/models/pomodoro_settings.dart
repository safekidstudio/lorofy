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
  final bool isLoaded;

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
    this.isLoaded = false,
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
    bool? isLoaded,
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
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  Map<String, dynamic> toJson() => {
        'focusMinutes': focusMinutes,
        'breakMinutes': breakMinutes,
        'longBreakMinutes': longBreakMinutes,
        'targetRounds': targetRounds,
        'ambientSound': ambientSound.name,
        'selectedCategory': selectedCategory?.toJson(),
        'timedReminder': timedReminder,
        'isDeepFocusMode': isDeepFocusMode,
        'blockMode': blockMode.name,
        'blockedCategories': blockedCategories.toList(),
        'autoStartBreak': autoStartBreak,
        'autoStartFocus': autoStartFocus,
        'pushNotifications': pushNotifications,
        'backgroundProcess': backgroundProcess,
        'isLoaded': isLoaded,
      };

  factory PomodoroSettings.fromJson(Map<String, dynamic> json) {
    return PomodoroSettings(
      focusMinutes: (json['focusMinutes'] as num? ?? 25).toInt(),
      breakMinutes: (json['breakMinutes'] as num? ?? 5).toInt(),
      longBreakMinutes: (json['longBreakMinutes'] as num? ?? 10).toInt(),
      targetRounds: (json['targetRounds'] as num? ?? 4).toInt(),
      ambientSound: AmbientSound.values.firstWhere(
        (e) => e.name == json['ambientSound'],
        orElse: () => AmbientSound.none,
      ),
      selectedCategory: json['selectedCategory'] != null
          ? FocusCategory.fromJson(
              json['selectedCategory'] as Map<String, dynamic>)
          : null,
      timedReminder: json['timedReminder'] as bool? ?? true,
      isDeepFocusMode: json['isDeepFocusMode'] as bool? ?? false,
      blockMode: BlockMode.values.firstWhere(
        (e) => e.name == json['blockMode'],
        orElse: () => BlockMode.MEDIUM,
      ),
      blockedCategories: (json['blockedCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {'Social Media'},
      autoStartBreak: json['autoStartBreak'] as bool? ?? true,
      autoStartFocus: json['autoStartFocus'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      backgroundProcess: json['backgroundProcess'] as bool? ?? true,
      isLoaded: json['isLoaded'] as bool? ?? true,
    );
  }
}
