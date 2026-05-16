import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends StateNotifier<AsyncValue<Set<Marker>>> {
  MapController() : super(const AsyncValue.data(<Marker>{}));

  void setMarkers(Set<Marker> markers) {
    if (!mounted) return;
    state = AsyncValue.data(markers);
  }

  void addMarker(Marker marker) {
    state = state.whenData((markers) => {...markers, marker});
  }

  void clear() {
    if (!mounted) return;
    state = const AsyncValue.data(<Marker>{});
  }
}

/// autoDispose so markers reset when the parking screen is unmounted —
/// prevents marker accumulation across navigations.
final mapControllerProvider =
    StateNotifierProvider.autoDispose<MapController, AsyncValue<Set<Marker>>>(
  (ref) => MapController(),
);
