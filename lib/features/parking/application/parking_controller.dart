import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/map/application/map_controller.dart';
import 'package:yellowspotuser/features/parking/data/parking_repository.dart';

class ParkingController
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  ParkingController(this._parkingRepository, this._ref)
      : super(const AsyncValue.loading()) {
    getNearbyParking();
  }

  final ParkingRepository _parkingRepository;
  final Ref _ref;

  static final provider = StateNotifierProvider.autoDispose<ParkingController,
      AsyncValue<List<Map<String, dynamic>>>>((ref) {
    return ParkingController(ref.watch(ParkingRepository.provider), ref);
  });

  /// Computed provider — filters the parking list by the current search query.
  static final filteredProvider = Provider.autoDispose<
      AsyncValue<List<Map<String, dynamic>>>>((ref) {
    final parkingState = ref.watch(provider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    return parkingState.whenData((parkingList) {
      if (searchQuery.isEmpty) return parkingList;
      return parkingList.where((p) {
        final name = (p['mallName'] as String? ?? '').toLowerCase();
        final address = (p['address'] as String? ?? '').toLowerCase();
        return name.contains(searchQuery) || address.contains(searchQuery);
      }).toList(growable: false);
    });
  });

  Future<void> getNearbyParking() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final list = await _parkingRepository.getNearbyParking();
      _publishMarkers(list);
      return list;
    });
  }

  void _publishMarkers(List<Map<String, dynamic>> parkingList) {
    final markers = <Marker>{
      for (final p in parkingList)
        Marker(
          markerId: MarkerId(p['mallName'] as String),
          position: p['latlng'] as LatLng,
          infoWindow: InfoWindow(title: p['mallName'] as String),
        ),
    };
    _ref.read(mapControllerProvider.notifier).setMarkers(markers);
  }
}
