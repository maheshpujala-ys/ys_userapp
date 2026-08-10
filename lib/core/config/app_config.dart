/// Single source of truth for environment-specific configuration.
///
/// Switch [current] to point at the right environment for a build.
/// In production, drive this from a `--dart-define` flag instead.
enum AppEnvironment { localDev, uat, production }

class AppConfig {
  AppConfig._();

  static const AppEnvironment current = AppEnvironment.uat;

  static String get apiBaseUrl {
    switch (current) {
      case AppEnvironment.localDev:
        return 'http://192.168.1.47:8080';
      case AppEnvironment.uat:
        return 'https://uat.yellowspottech.com';
      case AppEnvironment.production:
        return 'https://api.yellowspottech.com';
    }
  }
}

// API endpoints have moved to `lib/core/network/api_endpoints.dart`.
