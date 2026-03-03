import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends StateNotifier<AsyncValue<Set<Marker>>> {
  MapController() : super(const AsyncValue.data({}));

  void addMarker(Marker marker) {
    state = state.whenData((markers) => {...markers, marker});
  }
}

final mapControllerProvider = StateNotifierProvider<MapController, AsyncValue<Set<Marker>>>((ref) {
  return MapController();
});
