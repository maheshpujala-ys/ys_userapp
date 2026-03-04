import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends StateNotifier<AsyncValue<Set<Marker>>> {
  GoogleMapController? _mapController;

  MapController() : super(const AsyncValue.data({}));

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void addMarker(Marker marker) {
    state = state.whenData((markers) => {...markers, marker});
  }

  void animateToLocation(LatLng location) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

final mapControllerProvider = StateNotifierProvider<MapController, AsyncValue<Set<Marker>>>((ref) {
  return MapController();
});
