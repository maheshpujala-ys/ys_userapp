import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/admin/application/admin_controller.dart';
import 'package:yellowspotuser/features/admin/data/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(dioProvider)),
);

/// Dashboard controller — only alive while the admin dashboard is mounted.
/// Subscribes to the websocket stream lazily to avoid wasted ticks.
final adminControllerProvider = StateNotifierProvider.autoDispose<
    AdminController, AsyncValue<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  final webSocket = ref.watch(webSocketProvider);
  return AdminController(repo, webSocketStream: webSocket.stream);
});

final entryExitDataProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getEntryExitData();
});

final requestsDataProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getRequestsData();
});

final securityDataProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.watch(adminRepositoryProvider).getSecurityData();
});

final activityDataProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getActivityData();
});
