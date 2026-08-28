import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lorofy/core/storage/settings_storage.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/domain/models/ambient_sound.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_settings.dart';

part 'pomodoro_settings.g.dart';

@riverpod
class PomodoroSettingsNotifier extends _$PomodoroSettingsNotifier {
  @override
  PomodoroSettings build() {
    final storage = ref.read(settingsStorageProvider);
    final jsonStr = storage.getSettings();
    print('POMODORO_SETTINGS: Loaded json string from SharedPreferences: $jsonStr');
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(jsonStr);
        final loaded = PomodoroSettings.fromJson(json).copyWith(isLoaded: true);
        print('POMODORO_SETTINGS: Successfully parsed settings. focusMinutes = ${loaded.focusMinutes}');
        return loaded;
      } catch (e, stack) {
        print('POMODORO_SETTINGS_LOAD_ERROR: $e\n$stack');
        // Fallback to default on decoding/schema errors
      }
    }

    print('POMODORO_SETTINGS: No saved settings found. Loading defaults.');
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
      isLoaded: true,
    );
  }

  void updateSettings(PomodoroSettings newSettings) {
    state = newSettings.copyWith(isLoaded: true);
    print('POMODORO_SETTINGS: updateSettings - saving: focusMinutes = ${state.focusMinutes}, ambientSound = ${state.ambientSound}');
    saveToStorage();
  }

  void updateSettingsStateOnly(PomodoroSettings newSettings) {
    state = newSettings.copyWith(isLoaded: true);
  }

  void saveToStorage() {
    print('POMODORO_SETTINGS: saveToStorage - committing to disk: focusMinutes = ${state.focusMinutes}, ambientSound = ${state.ambientSound}');
    try {
      final jsonStr = jsonEncode(state.toJson());
      ref.read(settingsStorageProvider).saveSettings(jsonStr);
    } catch (e) {
      print('POMODORO_SETTINGS_SAVE_ERROR: $e');
    }
  }
}
