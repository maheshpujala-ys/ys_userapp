import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/admin/residents/data/tenants_remote_data_source.dart';
import 'package:yellowspotuser/features/admin/residents/domain/tenant_models.dart';

final tenantsRemoteDataSourceProvider = Provider<TenantsRemoteDataSource>(
  (ref) => TenantsRemoteDataSource(ref.watch(dioProvider)),
);

/// Locations available for the "Add Resident" picker.
final parkingLocationsProvider =
    FutureProvider.autoDispose<List<ParkingLocationSummary>>((ref) {
  return ref.watch(tenantsRemoteDataSourceProvider).getParkingLocations();
});

/// One-shot "Add Resident" submission state.
class AddResidentController extends StateNotifier<AsyncValue<void>> {
  AddResidentController(this._dataSource) : super(const AsyncValue.data(null));

  final TenantsRemoteDataSource _dataSource;

  static final provider = StateNotifierProvider.autoDispose<
      AddResidentController, AsyncValue<void>>((ref) {
    return AddResidentController(ref.watch(tenantsRemoteDataSourceProvider));
  });

  Future<bool> submit(TenantCreateRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _dataSource.createTenant(request).then((_) => null));
    return !state.hasError;
  }

  Future<bool> update(int tenantId, TenantCreateRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _dataSource.updateTenant(tenantId, request).then((_) => null));
    return !state.hasError;
  }
}
