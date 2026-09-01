import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/admin/dashboard/data/admin_repository.dart';

class AdminController extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final AdminRepository _adminRepository;
  StreamSubscription? _webSocketSubscription;

  AdminController(this._adminRepository, Stream<Map<String, dynamic>> webSocketStream)
      : super(const AsyncValue.loading()) {
    _webSocketSubscription = webSocketStream.listen(updateState);
    getDashboardData();
  }

  static final provider = StateNotifierProvider<AdminController, AsyncValue<Map<String, dynamic>>>((ref) {
    final adminRepository = ref.watch(AdminRepository.provider);
    final webSocket = ref.watch(webSocketProvider);
    return AdminController(adminRepository, webSocket.stream);
  });

  Future<void> getDashboardData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _adminRepository.getDashboardData());
  }

  void updateState(Map<String, dynamic> socketEvent) {
    final currentData = state.asData?.value ?? {
      'residents': 480,
      'vehicles': 650,
      'parking': 78,
      'pending': 5,
    };

    if (socketEvent.containsKey('data') && socketEvent['data'] is Map<String, dynamic>) {
      final metrics = socketEvent['data'] as Map<String, dynamic>;
      state = AsyncValue.data({
        ...currentData,
        if (metrics.containsKey('availableParking')) 'parking': metrics['availableParking'],
        if (metrics.containsKey('pendingDeliveries')) 'pending': metrics['pendingDeliveries'],
      });
    } else {
      state = AsyncValue.data({
        ...currentData,
        ...socketEvent,
      });
    }
  }

  @override
  void dispose() {
    _webSocketSubscription?.cancel();
    super.dispose();
  }
}
