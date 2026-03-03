import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/data/admin_repository.dart';

class AdminController extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final AdminRepository _adminRepository;

  AdminController(this._adminRepository) : super(const AsyncValue.loading()) {
    getDashboardData();
  }

  Future<void> getDashboardData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _adminRepository.getDashboardData());
  }
}
