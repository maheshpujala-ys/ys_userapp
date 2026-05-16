import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/vehicles/data/vehicles_remote_data_source.dart';

/// One-shot "Add Vehicle" submission state.
class AddVehicleController extends StateNotifier<AsyncValue<void>> {
  AddVehicleController(this._dataSource) : super(const AsyncValue.data(null));

  final VehiclesRemoteDataSource _dataSource;

  static final provider = StateNotifierProvider.autoDispose<
      AddVehicleController, AsyncValue<void>>((ref) {
    return AddVehicleController(ref.watch(vehiclesRemoteDataSourceProvider));
  });

  Future<bool> submit(VehicleCreateRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _dataSource.createVehicle(request));
    return !state.hasError;
  }

  Future<bool> update(int registrationId, VehicleCreateRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _dataSource.updateVehicle(registrationId, request));
    return !state.hasError;
  }
}
