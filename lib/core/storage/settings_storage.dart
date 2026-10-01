import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_storage.g.dart';

class SettingsStorage {
  final SharedPreferences _prefs;

  SettingsStorage(this._prefs);

  static const _pomodoroSettingsKey = "pomodoro_settings";
  static const _systemSettingsKey = "system_settings";

  Future<void> saveSettings(String jsonStr) async {
    await _prefs.setString(_pomodoroSettingsKey, jsonStr);
  }

  String? getSettings() {
    return _prefs.getString(_pomodoroSettingsKey);
  }

  Future<void> clearSettings() async {
    await _prefs.remove(_pomodoroSettingsKey);
  }

  Future<void> saveSystemSettings(String jsonStr) async {
    await _prefs.setString(_systemSettingsKey, jsonStr);
  }

  String? getSystemSettings() {
    return _prefs.getString(_systemSettingsKey);
  }
}

@Riverpod(keepAlive: true)
SettingsStorage settingsStorage(Ref ref) {
  throw UnimplementedError('Override settingsStorageProvider in ProviderScope');
}
