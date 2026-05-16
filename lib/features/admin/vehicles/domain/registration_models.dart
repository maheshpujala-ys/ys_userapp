/// Request body for `POST /api/v1/registrations` (SharedRegistrationRequestDto).
/// Used for both regular vehicle registrations and visitor passes
/// (visitor pass = registration with a short start/end window).
class VehicleRegistrationCreateRequest {
  const VehicleRegistrationCreateRequest({
    required this.tenantId,
    required this.vehicleNumber,
    required this.vehicleTypeId,
    required this.ownerName,
    required this.ownerMobile,
    required this.cardNumber,
    required this.cardType,
    required this.startDate,
    this.endDate,
    this.serialNumber,
    this.empCode,
  });

  final int tenantId;
  final String vehicleNumber;
  final int vehicleTypeId;
  final String ownerName;
  final String ownerMobile;
  final String cardNumber;
  final String cardType;

  /// ISO-8601 date/time strings.
  final String startDate;
  final String? endDate;
  final String? serialNumber;
  final String? empCode;

  Map<String, dynamic> toJson() => {
        'tenantId': tenantId,
        'vehicleNumber': vehicleNumber,
        'vehicleTypeId': vehicleTypeId,
        'ownerName': ownerName,
        'ownerMobile': ownerMobile,
        'cardNumber': cardNumber,
        'cardType': cardType,
        'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (serialNumber != null) 'serialNumber': serialNumber,
        if (empCode != null) 'empCode': empCode,
      };
}

/// Slim projection of VehicleTypeDto for the type picker.
class VehicleTypeSummary {
  const VehicleTypeSummary({required this.vehicleTypeId, required this.name});

  factory VehicleTypeSummary.fromJson(Map<String, dynamic> json) {
    return VehicleTypeSummary(
      vehicleTypeId: (json['vehicleTypeId'] as num).toInt(),
      name: json['name'] as String? ?? '',
    );
  }

  final int vehicleTypeId;
  final String name;
}
