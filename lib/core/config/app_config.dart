import 'package:lorofy/core/utils/logger.dart';

class AppConfig {
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.lorofy.space/api/v1',
  );

  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  static const int connectTimeoutMs = int.fromEnvironment(
    'CONNECT_TIMEOUT_MS',
    defaultValue: 15000,
  );

  static const int receiveTimeoutMs = int.fromEnvironment(
    'RECEIVE_TIMEOUT_MS',
    defaultValue: 15000,
  );

  static bool get isDev => appEnv == 'development';
  static bool get isStaging => appEnv == 'staging';
  static bool get isProd => appEnv == 'production';

  static void logConfig() {
    if (isDev) {
      AppLogger.debug('=== APP CONFIGURATION ===', tag: 'AppConfig');
      AppLogger.debug('Environment: $appEnv', tag: 'AppConfig');
      AppLogger.debug('API Base URL: $apiBaseUrl', tag: 'AppConfig');
      AppLogger.debug('Connect Timeout: ${connectTimeoutMs}ms', tag: 'AppConfig');
      AppLogger.debug('Receive Timeout: ${receiveTimeoutMs}ms', tag: 'AppConfig');
      AppLogger.debug('=========================');
    }
  }
}
