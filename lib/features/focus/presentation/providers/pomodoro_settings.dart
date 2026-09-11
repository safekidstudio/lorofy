import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lorofy/core/storage/settings_storage.dart';
import 'package:lorofy/core/utils/logger.dart';
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
    AppLogger.debug('Loaded json string from SharedPreferences: $jsonStr', tag: 'PomodoroSettings');
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(jsonStr);
        final loaded = PomodoroSettings.fromJson(json).copyWith(isLoaded: true);
        AppLogger.debug('Successfully parsed settings. focusMinutes = ${loaded.focusMinutes}', tag: 'PomodoroSettings');
        return loaded;
      } catch (e, stack) {
        AppLogger.error('Failed to load settings from storage', error: e, stackTrace: stack, tag: 'PomodoroSettings');
        // Fallback to default on decoding/schema errors
      }
    }

    AppLogger.debug('No saved settings found. Loading defaults.', tag: 'PomodoroSettings');
    return const PomodoroSettings(
      focusMinutes: 25,
      breakMinutes: 5,
      longBreakMinutes: 10,
      targetRounds: 4,
      ambientSound: AmbientSound.none,
      selectedCategory: null,
      timedReminder: true,
      isDeepFocusMode: true,
      blockMode: BlockMode.medium,
      autoStartBreak: true,
      autoStartFocus: true,
      isLoaded: true,
    );
  }

  void updateSettings(PomodoroSettings newSettings) {
    state = newSettings.copyWith(isLoaded: true);
    AppLogger.debug('updateSettings - saving: focusMinutes = ${state.focusMinutes}, ambientSound = ${state.ambientSound}', tag: 'PomodoroSettings');
    saveToStorage();
  }

  void updateSettingsStateOnly(PomodoroSettings newSettings) {
    state = newSettings.copyWith(isLoaded: true);
  }

  void saveToStorage() {
    AppLogger.debug('saveToStorage - committing to disk: focusMinutes = ${state.focusMinutes}, ambientSound = ${state.ambientSound}', tag: 'PomodoroSettings');
    try {
      final jsonStr = jsonEncode(state.toJson());
      ref.read(settingsStorageProvider).saveSettings(jsonStr);
    } catch (e, stack) {
      AppLogger.error('saveToStorage failed', error: e, stackTrace: stack, tag: 'PomodoroSettings');
    }
  }
}
