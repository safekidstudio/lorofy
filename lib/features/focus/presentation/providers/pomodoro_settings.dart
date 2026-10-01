import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lorofy/core/storage/settings_storage.dart';
import 'package:lorofy/core/utils/logger.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/domain/models/ambient_sound.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_settings.dart';
import 'package:lorofy/features/settings/data/repositories/settings_repository_impl.dart';

part 'pomodoro_settings.g.dart';

@riverpod
class PomodoroSettingsNotifier extends _$PomodoroSettingsNotifier {
  Timer? _debounceTimer;

  @override
  PomodoroSettings build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    final storage = ref.read(settingsStorageProvider);
    final jsonStr = storage.getSettings();
    AppLogger.debug('Loaded json string from SharedPreferences: $jsonStr', tag: 'PomodoroSettings');
    
    PomodoroSettings initialSettings;
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(jsonStr);
        initialSettings = PomodoroSettings.fromJson(json).copyWith(isLoaded: true);
        AppLogger.debug('Successfully parsed settings. focusMinutes = ${initialSettings.focusMinutes}', tag: 'PomodoroSettings');
      } catch (e, stack) {
        AppLogger.error('Failed to load settings from storage', error: e, stackTrace: stack, tag: 'PomodoroSettings');
        initialSettings = _defaultSettings();
      }
    } else {
      AppLogger.debug('No saved settings found. Loading defaults.', tag: 'PomodoroSettings');
      initialSettings = _defaultSettings();
    }

    // Schedule remote sync in background after build
    Future.microtask(() => syncFromRemote());

    return initialSettings;
  }

  PomodoroSettings _defaultSettings() => const PomodoroSettings(
        focusMinutes: 25,
        breakMinutes: 5,
        longBreakMinutes: 10,
        targetRounds: 4,
        ambientSound: AmbientSound.none,
        selectedCategory: null,
        timedReminder: true,
        isPomodoroMode: false,
        blockMode: BlockMode.medium,
        autoStartBreak: true,
        autoStartFocus: true,
        isLoaded: true,
      );

  /// Background sync from multi-platform remote API endpoint
  Future<void> syncFromRemote() async {
    try {
      final repository = ref.read(settingsRepositoryProvider);
      final remoteSettings = await repository.fetchUserSettings();
      if (remoteSettings != null && remoteSettings != state) {
        AppLogger.info('Remote settings synced from API', tag: 'PomodoroSettings');
        state = remoteSettings.copyWith(isLoaded: true);
      }
    } catch (e, stack) {
      AppLogger.error('Failed to sync settings from remote', error: e, stackTrace: stack, tag: 'PomodoroSettings');
    }
  }

  /// Update settings locally immediately and debounce remote API sync (800ms)
  Future<void> updateSettings(PomodoroSettings newSettings) async {
    final updated = newSettings.copyWith(isLoaded: true);
    state = updated;
    AppLogger.debug('updateSettings - saving: focusMinutes = ${state.focusMinutes}, ambientSound = ${state.ambientSound}', tag: 'PomodoroSettings');
    
    // Save locally immediately for fast responsive UI
    saveToStorage();

    // Debounce remote API sync by 4 seconds so rapid user adjustments don't flood the server
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 4), () async {
      try {
        final repository = ref.read(settingsRepositoryProvider);
        final synced = await repository.updateUserSettings(updated);
        state = synced;
        AppLogger.info('Debounced settings synced to remote successfully', tag: 'PomodoroSettings');
      } catch (e, stack) {
        AppLogger.error('Failed to sync updated settings to remote', error: e, stackTrace: stack, tag: 'PomodoroSettings');
      }
    });
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
