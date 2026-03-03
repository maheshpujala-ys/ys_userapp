import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/services/data/services_repository.dart';

class ServicesController extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ServicesRepository _servicesRepository;

  ServicesController(this._servicesRepository) : super(const AsyncValue.loading()) {
    getServicesData();
  }

  static final provider = StateNotifierProvider<ServicesController, AsyncValue<Map<String, dynamic>>>((ref) {
    return ServicesController(ref.watch(ServicesRepository.provider));
  });

  Future<void> getServicesData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _servicesRepository.getServicesData());
  }
}
