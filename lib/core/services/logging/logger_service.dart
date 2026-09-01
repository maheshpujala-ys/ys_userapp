import 'package:flutter/foundation.dart';

class LoggerService {
  static const Set<String> _sensitiveKeys = {
    'password',
    'token',
    'secret',
    'authorization',
    'credit_card',
    'cardNumber',
    'cvv',
    'api_key',
  };

  static void info(String message, {String tag = 'YellowSpot'}) {
    if (kDebugMode) {
      debugPrint('[$tag][INFO] ${_sanitize(message)}');
    }
  }

  static void warning(String message, {String tag = 'YellowSpot'}) {
    debugPrint('[$tag][WARN] ${_sanitize(message)}');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String tag = 'YellowSpot'}) {
    debugPrint('[$tag][ERROR] ${_sanitize(message)}');
    if (error != null) {
      debugPrint('[$tag][ERROR_DETAIL] ${_sanitize(error.toString())}');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('[$tag][STACKTRACE]\n$stackTrace');
    }
  }

  static void logApiEvent(String method, String endpoint, int? statusCode, {String? error}) {
    final statusStr = statusCode != null ? '$statusCode' : 'FAILED';
    if (error != null) {
      warning('API $method $endpoint -> $statusStr | Error: $error', tag: 'Network');
    } else {
      info('API $method $endpoint -> $statusStr', tag: 'Network');
    }
  }

  static void logWebSocketEvent(String eventType, String status) {
    info('WebSocket Event: $eventType | Status: $status', tag: 'RealTime');
  }

  static void logHardwareEvent(String deviceType, String deviceId, String status) {
    info('Hardware Device: $deviceType ($deviceId) -> $status', tag: 'IoT');
  }

  static String _sanitize(String text) {
    var sanitized = text;
    for (final key in _sensitiveKeys) {
      final regex = RegExp('$key[:=]\\s*([^\\s,}&]+)', caseSensitive: false);
      sanitized = sanitized.replaceAllMapped(regex, (match) => '$key: [REDACTED]');
    }
    return sanitized;
  }
}
