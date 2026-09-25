import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/network/dio_client.dart';
import 'package:lorofy/core/network/response/api_response.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_settings.dart';
import 'package:lorofy/features/settings/domain/models/system_settings_model.dart';

class SettingsRemoteDataSource {
  final Dio _dio;

  SettingsRemoteDataSource(this._dio);

  Future<SystemSettingsModel> getSettings() async {
    final response = await _dio.get(
      '/settings',
      options: ApiOptions.public,
    );
    final map = response.unwrap((json) => json as Map<String, dynamic>);
    return SystemSettingsModel.fromMap(map);
  }

  /// Get user-specific Pomodoro & app preferences from remote API for sync
  Future<PomodoroSettings?> getUserSettings() async {
    final response = await _dio.get(
      '/profiles/settings',
      options: ApiOptions.protected,
    );
    return response.unwrap((json) {
      if (json == null) return null;
      return PomodoroSettings.fromRemoteJson(json as Map<String, dynamic>);
    });
  }

  /// Update user-specific Pomodoro & app preferences to remote API for multi-platform sync
  Future<PomodoroSettings> updateUserSettings(PomodoroSettings settings) async {
    final response = await _dio.put(
      '/profiles/settings',
      data: settings.toRemoteJson(),
      options: ApiOptions.protected,
    );
    return response.unwrap((json) {
      if (json == null) return settings;
      return PomodoroSettings.fromRemoteJson(json as Map<String, dynamic>);
    });
  }
}

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return SettingsRemoteDataSource(dio);
});
