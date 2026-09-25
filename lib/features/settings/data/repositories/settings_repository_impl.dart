import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/utils/logger.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_settings.dart';
import 'package:lorofy/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:lorofy/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:lorofy/features/settings/domain/models/system_settings_model.dart';
import 'package:lorofy/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource _remoteDataSource;
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  SystemSettingsModel? getCachedSettings() {
    return _localDataSource.getSystemSettings();
  }

  @override
  Future<SystemSettingsModel> getAllSettings() async {
    try {
      final remoteSettings = await _remoteDataSource.getSettings();
      await _localDataSource.saveSystemSettings(remoteSettings);
      return remoteSettings;
    } catch (e) {
      final cached = _localDataSource.getSystemSettings();
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  PomodoroSettings? getCachedUserSettings() {
    return _localDataSource.getPomodoroSettings();
  }

  @override
  Future<PomodoroSettings?> fetchUserSettings() async {
    try {
      final remote = await _remoteDataSource.getUserSettings();
      if (remote != null) {
        final cached = _localDataSource.getPomodoroSettings();
        final merged = remote.copyWith(
          allowedAppPackages: cached?.allowedAppPackages,
          selectedCategory: cached?.selectedCategory,
        );
        await _localDataSource.savePomodoroSettings(merged);
        return merged;
      }
    } catch (e, stack) {
      AppLogger.error(
        'Failed to fetch user settings from remote API, using local cache fallback',
        error: e,
        stackTrace: stack,
        tag: 'SettingsRepository',
      );
    }
    return _localDataSource.getPomodoroSettings();
  }

  @override
  Future<PomodoroSettings> updateUserSettings(PomodoroSettings settings) async {
    // 1. Optimistic save to local storage
    await _localDataSource.savePomodoroSettings(settings);

    // 2. Sync to remote API
    try {
      final synced = await _remoteDataSource.updateUserSettings(settings);
      final merged = synced.copyWith(
        allowedAppPackages: settings.allowedAppPackages,
        selectedCategory: settings.selectedCategory,
      );
      await _localDataSource.savePomodoroSettings(merged);
      return merged;
    } catch (e, stack) {
      AppLogger.error(
        'Failed to push updated user settings to remote API, cached locally',
        error: e,
        stackTrace: stack,
        tag: 'SettingsRepository',
      );
      return settings;
    }
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final remoteDataSource = ref.read(settingsRemoteDataSourceProvider);
  final localDataSource = ref.read(settingsLocalDataSourceProvider);
  return SettingsRepositoryImpl(remoteDataSource, localDataSource);
});
