import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/map/application/map_controller.dart';
import 'package:yellowspotuser/features/parking/data/parking_repository.dart';

class ParkingController extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ParkingRepository _parkingRepository;
  final StateNotifierProviderRef<ParkingController, AsyncValue<List<Map<String, dynamic>>>> _ref;

  ParkingController(this._parkingRepository, this._ref) : super(const AsyncValue.loading()) {
    getNearbyParking();
  }

  static final provider = StateNotifierProvider<ParkingController, AsyncValue<List<Map<String, dynamic>>>>((ref) {
    return ParkingController(ref.watch(ParkingRepository.provider), ref);
  });

  /// A computed provider that filters the parking list based on the search query.
  static final filteredProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
    final parkingState = ref.watch(provider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

    return parkingState.whenData((parkingList) {
      if (searchQuery.isEmpty) return parkingList;
      return parkingList.where((parking) {
        final name = parking['mallName'].toString().toLowerCase();
        final address = parking['address'].toString().toLowerCase();
        return name.contains(searchQuery) || address.contains(searchQuery);
      }).toList();
    });
  });

  Future<void> getNearbyParking() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final parkingList = await _parkingRepository.getNearbyParking();
      _addMarkersToMap(parkingList);
      return parkingList;
    });
  }

  void _addMarkersToMap(List<Map<String, dynamic>> parkingList) {
    final mapController = _ref.read(mapControllerProvider.notifier);
    for (var parking in parkingList) {
      mapController.addMarker(
        Marker(
          markerId: MarkerId(parking['mallName']),
          position: parking['latlng'],
          infoWindow: InfoWindow(title: parking['mallName']),
        ),
      );
    }
  }
}
