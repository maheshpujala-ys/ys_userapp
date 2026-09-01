import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/ev_charging/screens/ev_charging_screen.dart';

abstract class EvChargingRepository {
  Future<List<EvStation>> getStations();
  Future<bool> startChargingSession(String stationId);
  Future<bool> stopChargingSession(String stationId);
}

class MockEvChargingRepository implements EvChargingRepository {
  final List<EvStation> _stations = const [
    EvStation(
      id: 'EV-01',
      name: 'Bay B2 - Supercharger 01',
      location: 'Basement 2 (Pillar 44)',
      powerOutput: '60 kW DC Fast',
      connectorType: 'CCS Type 2',
      isAvailable: false,
      ratePerKwh: 15.0,
    ),
    EvStation(
      id: 'EV-02',
      name: 'Bay B2 - AC Fast Charger 02',
      location: 'Basement 2 (Pillar 46)',
      powerOutput: '22 kW AC',
      connectorType: 'Type 2 Gun',
      isAvailable: true,
      ratePerKwh: 11.5,
    ),
    EvStation(
      id: 'EV-03',
      name: 'Bay B1 - Two Wheeler EV Port 01',
      location: 'Basement 1 (Two Wheeler Zone)',
      powerOutput: '3.3 kW AC',
      connectorType: 'Universal 16A',
      isAvailable: true,
      ratePerKwh: 9.0,
    ),
  ];

  @override
  Future<List<EvStation>> getStations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _stations;
  }

  @override
  Future<bool> startChargingSession(String stationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Future<bool> stopChargingSession(String stationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}

final evChargingRepositoryProvider = Provider<EvChargingRepository>((ref) {
  return MockEvChargingRepository();
});
