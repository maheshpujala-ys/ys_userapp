import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yellowspotuser/core/services/network/dio_interceptor.dart';
import 'package:yellowspotuser/core/services/network/websocket_service.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';

// A provider for the Dio instance, used for making network requests.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.interceptors.add(DioInterceptor(ref.watch(secureStorageProvider)));
  return dio;
});

// A provider for the FlutterSecureStorage instance.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

// The currently selected user role.
final activeRoleProvider = StateProvider<UserRole?>((ref) => null);

// A provider for the WebSocket service.
final webSocketProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  service.connect();
  ref.onDispose(() => service.disconnect());
  return service;
});

final isAdminViewProvider = StateProvider<bool>((ref) => false);

// Search query for parking
final searchQueryProvider = StateProvider<String>((ref) => '');
