enum VehicleType { fourWheeler, twoWheeler }
enum PlateType { private, ev, taxi }

class Vehicle {
  final String number;
  final VehicleType type;
  final PlateType plateType;
  final bool isActive;
  final String make;
  final String model;
  final String? parkingSlot;

  Vehicle({
    required this.number,
    this.type = VehicleType.fourWheeler,
    this.plateType = PlateType.private,
    this.isActive = true,
    this.make = '',
    this.model = '',
    this.parkingSlot,
  });

  /// Alias for backward-compatible naming
  String get registrationNumber => number;
}
