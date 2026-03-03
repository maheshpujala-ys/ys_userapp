enum VehicleType { fourWheeler, twoWheeler }
enum PlateType { private, ev, taxi }

class Vehicle {
  final String number;
  final VehicleType type;
  final PlateType plateType;
  final bool isActive;

  Vehicle({
    required this.number,
    required this.type,
    required this.plateType,
    required this.isActive,
  });
}
