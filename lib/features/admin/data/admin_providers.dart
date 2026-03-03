import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/admin/application/admin_controller.dart';
import 'package:yellowspotuser/features/admin/data/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(dioProvider)),
);

final adminControllerProvider = StateNotifierProvider<AdminController, AsyncValue<Map<String, dynamic>>>((ref) {
  return AdminController(ref.watch(adminRepositoryProvider));
});

final entryExitDataProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final adminRepository = ref.watch(adminRepositoryProvider);
  return adminRepository.getEntryExitData();
});

final requestsDataProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final adminRepository = ref.watch(adminRepositoryProvider);
  return adminRepository.getRequestsData();
});

final securityDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final adminRepository = ref.watch(adminRepositoryProvider);
  return adminRepository.getSecurityData();
});

final activityDataProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final adminRepository = ref.watch(adminRepositoryProvider);
  return adminRepository.getActivityData();
});
