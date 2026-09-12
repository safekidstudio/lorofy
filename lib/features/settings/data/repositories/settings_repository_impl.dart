import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final remoteDataSource = ref.read(settingsRemoteDataSourceProvider);
  final localDataSource = ref.read(settingsLocalDataSourceProvider);
  return SettingsRepositoryImpl(remoteDataSource, localDataSource);
});
