import 'dart:io' show HttpClient;

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yellowspotuser/core/config/app_config.dart';
import 'package:yellowspotuser/core/services/network/dio_interceptor.dart';
import 'package:yellowspotuser/core/services/network/websocket_service.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';

/// FlutterSecureStorage — single shared instance.
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

/// In-memory token cache + cache-invalidating interceptor.
final dioInterceptorProvider = Provider<DioInterceptor>(
  (ref) => DioInterceptor(ref.watch(secureStorageProvider)),
);

/// Dio with sane timeouts and (in debug) request/response logging.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
    ),
  );
  dio.interceptors.add(ref.watch(dioInterceptorProvider));
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Dev-only TLS workaround.
  // The UAT host's CA chain isn't trusted by the OS root store, which causes
  // CERTIFICATE_VERIFY_FAILED on Android emulators / unprovisioned devices.
  // Allow self-signed / unknown certs ONLY in debug + non-production builds.
  // Production must hit a properly chained cert (or pin one explicitly).
  if (kDebugMode && AppConfig.current != AppEnvironment.production) {
    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }
  }

  return dio;
});

/// Currently selected user role (for multi-role accounts).
final activeRoleProvider = StateProvider<UserRole?>((ref) => null);

/// Realtime updates — only kept alive while at least one consumer listens.
/// Connects on first listen, disconnects when no listeners remain.
final webSocketProvider = Provider.autoDispose<WebSocketService>((ref) {
  final service = WebSocketService();
  service.connect();
  ref.onDispose(service.dispose);
  return service;
});

/// Whether the (admin) user is currently viewing the admin dashboard.
final isAdminViewProvider = StateProvider<bool>((ref) => false);

/// Search query for parking.
final searchQueryProvider = StateProvider<String>((ref) => '');
