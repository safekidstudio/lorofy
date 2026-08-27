import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_storage.g.dart';

class SettingsStorage {
  final SharedPreferences _prefs;

  SettingsStorage(this._prefs);

  static const _settingsKey = "pomodoro_settings";

  Future<void> saveSettings(String jsonStr) async {
    await _prefs.setString(_settingsKey, jsonStr);
  }

  String? getSettings() {
    return _prefs.getString(_settingsKey);
  }
}

@Riverpod(keepAlive: true)
SettingsStorage settingsStorage(Ref ref) {
  throw UnimplementedError('Override settingsStorageProvider in ProviderScope');
}
