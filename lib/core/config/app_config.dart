class AppConfig {
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.197:8080/api/v1',
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
      print('=== APP CONFIGURATION ===');
      print('Environment: $appEnv');
      print('API Base URL: $apiBaseUrl');
      print('Connect Timeout: ${connectTimeoutMs}ms');
      print('Receive Timeout: ${receiveTimeoutMs}ms');
      print('=========================');
    }
  }
}
