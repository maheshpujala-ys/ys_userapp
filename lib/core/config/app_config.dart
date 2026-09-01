enum AppEnvironment {
  development,
  staging,
  production,
}

class AppConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String webSocketUrl;
  final bool enableMockFallback;
  final int timeoutMs;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.webSocketUrl,
    required this.enableMockFallback,
    this.timeoutMs = 15000,
  });

  static AppConfig development = const AppConfig(
    environment: AppEnvironment.development,
    apiBaseUrl: 'http://localhost:8080/api/v1',
    webSocketUrl: 'ws://localhost:8080/ws',
    enableMockFallback: true,
  );

  static AppConfig staging = const AppConfig(
    environment: AppEnvironment.staging,
    apiBaseUrl: 'https://staging-api.yellowspot.io/api/v1',
    webSocketUrl: 'wss://staging-api.yellowspot.io/ws',
    enableMockFallback: true,
  );

  static AppConfig production = const AppConfig(
    environment: AppEnvironment.production,
    apiBaseUrl: 'https://api.yellowspot.io/api/v1',
    webSocketUrl: 'wss://api.yellowspot.io/ws',
    enableMockFallback: false,
  );

  static AppConfig current = development;
}
