import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/residential/data/residential_repository.dart';

class ResidentialController extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ResidentialRepository _residentialRepository;

  ResidentialController(this._residentialRepository) : super(const AsyncValue.loading()) {
    getResidentialData();
  }

  static final provider = StateNotifierProvider<ResidentialController, AsyncValue<Map<String, dynamic>>>((ref) {
    return ResidentialController(ref.watch(ResidentialRepository.provider));
  });

  Future<void> getResidentialData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _residentialRepository.getResidentialData());
  }
}
