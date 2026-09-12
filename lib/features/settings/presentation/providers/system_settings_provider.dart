import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/utils/logger.dart';
import 'package:lorofy/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:lorofy/features/settings/domain/models/system_settings_model.dart';

final systemSettingsProvider =
    NotifierProvider<SystemSettingsNotifier, SystemSettingsModel>(
  SystemSettingsNotifier.new,
);

class SystemSettingsNotifier extends Notifier<SystemSettingsModel> {
  @override
  SystemSettingsModel build() {
    final repository = ref.read(settingsRepositoryProvider);
    final cached = repository.getCachedSettings();

    // Trigger background fetch & revalidation
    fetchSettings();

    // Instantly return cached settings (or fallback default if first launch)
    return cached ?? const SystemSettingsModel();
  }

  Future<void> fetchSettings() async {
    try {
      final repository = ref.read(settingsRepositoryProvider);
      final settings = await repository.getAllSettings();
      state = settings;
      AppLogger.info(
        'Global system settings synced and cached from API',
        tag: 'SystemSettings',
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to fetch system settings from API, using cached fallback',
        tag: 'SystemSettings',
        error: e,
        stackTrace: st,
      );
    }
  }
}
