import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/network/dio_client.dart';
import 'package:lorofy/core/network/response/api_response.dart';
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
}

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return SettingsRemoteDataSource(dio);
});
