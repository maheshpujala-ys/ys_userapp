import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/data/admin_repository.dart';

class AdminController extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final AdminRepository _adminRepository;
  StreamSubscription<Map<String, dynamic>>? _webSocketSubscription;

  AdminController(
    this._adminRepository, {
    Stream<Map<String, dynamic>>? webSocketStream,
  }) : super(const AsyncValue.loading()) {
    _webSocketSubscription = webSocketStream?.listen(_onWebSocketEvent);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    state = await AsyncValue.guard(_adminRepository.getDashboardData);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_adminRepository.getDashboardData);
  }

  void _onWebSocketEvent(Map<String, dynamic> data) {
    if (mounted) state = AsyncValue.data(data);
  }

  @override
  void dispose() {
    _webSocketSubscription?.cancel();
    super.dispose();
  }
}
