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
  final bool isPomodoroMode;
  final BlockMode blockMode;
  final Set<String> allowedAppPackages;
  final bool autoStartBreak;
  final bool autoStartFocus;
  final bool isLoaded;

  const PomodoroSettings({
    required this.focusMinutes,
    required this.breakMinutes,
    required this.longBreakMinutes,
    required this.targetRounds,
    this.ambientSound = AmbientSound.none,
    this.selectedCategory,
    this.timedReminder = true,
    this.isPomodoroMode = true,
    this.blockMode = BlockMode.medium,
    this.allowedAppPackages = const {},
    this.autoStartBreak = true,
    this.autoStartFocus = true,
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
    bool? isPomodoroMode,
    BlockMode? blockMode,
    Set<String>? allowedAppPackages,
    bool? autoStartBreak,
    bool? autoStartFocus,
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
      isPomodoroMode: isPomodoroMode ?? this.isPomodoroMode,
      blockMode: blockMode ?? this.blockMode,
      allowedAppPackages: allowedAppPackages ?? this.allowedAppPackages,
      autoStartBreak: autoStartBreak ?? this.autoStartBreak,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
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
        'isPomodoroMode': isPomodoroMode,
        'blockMode': blockMode.name,
        'allowedAppPackages': allowedAppPackages.toList(),
        'autoStartBreak': autoStartBreak,
        'autoStartFocus': autoStartFocus,
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
      isPomodoroMode: json['isPomodoroMode'] as bool? ?? true,
      blockMode: BlockMode.values.firstWhere(
        (e) => e.name == json['blockMode'] || e.value == json['blockMode'],
        orElse: () => BlockMode.medium,
      ),
      allowedAppPackages: (json['allowedAppPackages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
      autoStartBreak: json['autoStartBreak'] as bool? ?? true,
      autoStartFocus: json['autoStartFocus'] as bool? ?? true,
      isLoaded: json['isLoaded'] as bool? ?? true,
    );
  }

  /// Convert settings to remote payload for multi-platform sync API endpoint
  Map<String, dynamic> toRemoteJson() => {
        'focusDurationMinutes': focusMinutes,
        'breakDurationMinutes': breakMinutes,
        'longBreakDurationMinutes': longBreakMinutes,
        'targetRounds': targetRounds,
        'ambientSound': ambientSound.name,
        'timedReminder': timedReminder,
        'isPomodoroMode': isPomodoroMode,
        'blockMode': blockMode.name.toUpperCase(),
        'autoStartBreak': autoStartBreak,
        'autoStartFocus': autoStartFocus,
      };

  /// Parse from remote payload retrieved from multi-platform sync API endpoint
  factory PomodoroSettings.fromRemoteJson(Map<String, dynamic> json) {
    final rawBlockMode = json['blockMode']?.toString().toLowerCase();
    final bool pomodoro = (json['isPomodoroMode'] ?? json['pomodoroMode'] ?? true) as bool;

    return PomodoroSettings(
      focusMinutes: (json['focusDurationMinutes'] ?? json['focusMinutes'] ?? 25) as int,
      breakMinutes: (json['breakDurationMinutes'] ?? json['breakMinutes'] ?? 5) as int,
      longBreakMinutes: (json['longBreakDurationMinutes'] ?? json['longBreakMinutes'] ?? 10) as int,
      targetRounds: (json['targetRounds'] ?? 4) as int,
      ambientSound: AmbientSound.values.firstWhere(
        (e) => e.name == json['ambientSound'],
        orElse: () => AmbientSound.none,
      ),
      timedReminder: json['timedReminder'] as bool? ?? true,
      isPomodoroMode: pomodoro,
      blockMode: BlockMode.values.firstWhere(
        (e) => e.name.toLowerCase() == rawBlockMode || e.value.toLowerCase() == rawBlockMode,
        orElse: () => BlockMode.medium,
      ),
      autoStartBreak: json['autoStartBreak'] as bool? ?? true,
      autoStartFocus: json['autoStartFocus'] as bool? ?? true,
      isLoaded: true,
    );
  }
}
