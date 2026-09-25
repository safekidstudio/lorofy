import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/storage/settings_storage.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_settings.dart';
import 'package:lorofy/features/settings/domain/models/system_settings_model.dart';

class SettingsLocalDataSource {
  final SettingsStorage _storage;

  SettingsLocalDataSource(this._storage);

  Future<void> saveSystemSettings(SystemSettingsModel settings) async {
    final jsonStr = jsonEncode(settings.toMap());
    await _storage.saveSystemSettings(jsonStr);
  }

  SystemSettingsModel? getSystemSettings() {
    final jsonStr = _storage.getSystemSettings();
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return SystemSettingsModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePomodoroSettings(PomodoroSettings settings) async {
    final jsonStr = jsonEncode(settings.toJson());
    await _storage.saveSettings(jsonStr);
  }

  PomodoroSettings? getPomodoroSettings() {
    final jsonStr = _storage.getSettings();
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return PomodoroSettings.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  final storage = ref.read(settingsStorageProvider);
  return SettingsLocalDataSource(storage);
});
