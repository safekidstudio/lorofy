import 'package:lorofy/features/focus/domain/models/pomodoro_settings.dart';
import 'package:lorofy/features/settings/domain/models/system_settings_model.dart';

abstract class SettingsRepository {
  SystemSettingsModel? getCachedSettings();
  Future<SystemSettingsModel> getAllSettings();

  PomodoroSettings? getCachedUserSettings();
  Future<PomodoroSettings?> fetchUserSettings();
  Future<PomodoroSettings> updateUserSettings(PomodoroSettings settings);
}
