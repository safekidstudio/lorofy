import 'package:lorofy/features/settings/domain/models/system_settings_model.dart';

abstract class SettingsRepository {
  SystemSettingsModel? getCachedSettings();
  Future<SystemSettingsModel> getAllSettings();
}
