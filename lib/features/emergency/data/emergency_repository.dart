import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EmergencyType {
  security,
  medical,
  fire,
  police,
  breakdown,
}

class EmergencyDispatchResult {
  final String dispatchId;
  final String estimatedArrival;
  final String assignedUnit;
  final bool isDispatched;

  const EmergencyDispatchResult({
    required this.dispatchId,
    required this.estimatedArrival,
    required this.assignedUnit,
    required this.isDispatched,
  });
}

abstract class EmergencyRepository {
  Future<EmergencyDispatchResult> dispatchEmergency({
    required EmergencyType type,
    required String location,
    required String residentName,
    required String phone,
  });
}

class MockEmergencyRepository implements EmergencyRepository {
  @override
  Future<EmergencyDispatchResult> dispatchEmergency({
    required EmergencyType type,
    required String location,
    required String residentName,
    required String phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return EmergencyDispatchResult(
      dispatchId: 'EMG-${DateTime.now().millisecondsSinceEpoch}',
      estimatedArrival: '2 - 4 mins',
      assignedUnit: 'Palm Meadows Quick Response Team #1',
      isDispatched: true,
    );
  }
}

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  return MockEmergencyRepository();
});
