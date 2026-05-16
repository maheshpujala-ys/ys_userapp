import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/admin/residents/application/add_resident_controller.dart';
import 'package:yellowspotuser/features/admin/residents/domain/tenant_models.dart';
import 'package:yellowspotuser/features/admin/vehicles/data/registrations_remote_data_source.dart';
import 'package:yellowspotuser/features/admin/vehicles/domain/registration_models.dart';

final registrationsRemoteDataSourceProvider =
    Provider<RegistrationsRemoteDataSource>(
  (ref) => RegistrationsRemoteDataSource(ref.watch(dioProvider)),
);

final vehicleTypesProvider =
    FutureProvider.autoDispose<List<VehicleTypeSummary>>((ref) {
  return ref.watch(registrationsRemoteDataSourceProvider).getVehicleTypes();
});

/// Tenants list, used to pick a host for a visitor pass / vehicle registration.
final tenantsListProvider =
    FutureProvider.autoDispose<List<TenantSummary>>((ref) {
  return ref.watch(tenantsRemoteDataSourceProvider).getTenants();
});

class RegistrationController extends StateNotifier<AsyncValue<void>> {
  RegistrationController(this._dataSource)
      : super(const AsyncValue.data(null));

  final RegistrationsRemoteDataSource _dataSource;

  static final provider = StateNotifierProvider.autoDispose<
      RegistrationController, AsyncValue<void>>((ref) {
    return RegistrationController(
        ref.watch(registrationsRemoteDataSourceProvider));
  });

  Future<bool> submit(VehicleRegistrationCreateRequest request) async {
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard(() => _dataSource.createRegistration(request));
    return !state.hasError;
  }
}
