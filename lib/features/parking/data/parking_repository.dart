import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';

class ParkingRepository {
  final Dio dio;

  ParkingRepository(this.dio);

  static final provider = Provider<ParkingRepository>(
    (ref) => ParkingRepository(ref.watch(dioProvider)),
  );

  // In a real app, you'd fetch this data from your API
  Future<List<Map<String, dynamic>>> getNearbyParking() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'mallName': 'AMB Cinemas (SLN Terminus)',
        'distance': '1.2 km',
        'availability': '28 Available',
        'address': 'Gachibowli - Miyapur Rd, Jayabheri Enclave, Gachibowli, Hyderabad',
        'price': '₹40/hour',
        'latlng': const LatLng(17.4564, 78.3677),
      },
      {
        'mallName': 'RGIA Airport Parking',
        'distance': '22.5 km',
        'availability': '150+ Available',
        'address': 'Shamshabad, Hyderabad, Telangana 500409',
        'price': '₹50/hour',
        'latlng': const LatLng(17.2403, 78.4294),
      },
      {
        'mallName': 'IKEA Hyderabad',
        'distance': '3.1 km',
        'availability': '85 Available',
        'address': 'Raidurg, HITEC City, Hyderabad, Telangana 500081',
        'price': 'Free',
        'latlng': const LatLng(17.4385, 78.3768),
      },
      {
        'mallName': 'GVK One Mall',
        'distance': '8.5 km',
        'availability': '45 Available',
        'address': 'Banjara Hills, Road No. 1, Hyderabad, Telangana 500034',
        'price': '₹30/hour',
        'latlng': const LatLng(17.4173, 78.4497),
      },
      {
        'mallName': 'Inorbit Mall',
        'distance': '2.4 km',
        'availability': '12 Available',
        'address': 'HITEC City, Madhapur, Hyderabad, Telangana 500081',
        'price': '₹35/hour',
        'latlng': const LatLng(17.4269, 78.3863),
      },
    ];
  }
}
