// Domain models for the admin "Residents" feature.
// Backend speaks "tenants" — UI uses "residents". Same concept.

/// Request body for `POST /api/v1/tenants` and `PUT /api/v1/tenants/{id}`
/// (TenantRequestDto).
class TenantCreateRequest {
  const TenantCreateRequest({
    required this.name,
    required this.locationId,
    this.type,
    this.tower,
    this.floor,
    this.flat,
    this.email,
    this.mobile,
    this.altMobile,
    this.address,
    this.activeInd = 'Y',
  });

  final String name;
  final int locationId;
  final String? type;
  final String? tower;
  final String? floor;
  final String? flat;
  final String? email;
  final String? mobile;
  final String? altMobile;
  final String? address;
  final String activeInd;

  Map<String, dynamic> toJson() => {
        'name': name,
        'locationId': locationId,
        if (type != null) 'type': type,
        if (tower != null) 'tower': tower,
        if (floor != null) 'floor': floor,
        if (flat != null) 'flat': flat,
        if (email != null) 'email': email,
        if (mobile != null) 'mobile': mobile,
        if (altMobile != null) 'altmobile': altMobile,
        if (address != null) 'address': address,
        'activeInd': activeInd,
      };
}

/// Projection of `TenantResponseDto` — carries everything needed for both
/// list display *and* pre-filling the edit form.
class TenantSummary {
  const TenantSummary({
    required this.tenantId,
    required this.name,
    this.type,
    this.tower,
    this.floor,
    this.flat,
    this.email,
    this.mobile,
    this.altMobile,
    this.address,
    this.locationId,
    this.locationName,
    this.activeInd,
  });

  factory TenantSummary.fromJson(Map<String, dynamic> json) {
    final loc = json['location'];
    int? locId;
    String? locName;
    if (loc is Map) {
      final l = loc.cast<String, dynamic>();
      final v = l['locationId'];
      if (v is num) locId = v.toInt();
      final n = l['name'];
      if (n is String) locName = n;
    }
    // Some responses include `locationId` at the top level too.
    if (locId == null && json['locationId'] is num) {
      locId = (json['locationId'] as num).toInt();
    }
    return TenantSummary(
      tenantId: (json['tenantId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      type: json['type'] as String?,
      tower: json['tower'] as String?,
      floor: json['floor'] as String?,
      flat: json['flat'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      altMobile: (json['altMobile'] ?? json['altmobile']) as String?,
      address: json['address'] as String?,
      locationId: locId,
      locationName: locName,
      activeInd: json['activeInd'] as String?,
    );
  }

  final int tenantId;
  final String name;
  final String? type;
  final String? tower;
  final String? floor;
  final String? flat;
  final String? email;
  final String? mobile;
  final String? altMobile;
  final String? address;
  final int? locationId;
  final String? locationName;
  final String? activeInd;

  bool get isActive => (activeInd ?? '').toUpperCase() == 'Y';
}

/// Slim projection of `ParkingLocationDto` for the location picker.
class ParkingLocationSummary {
  const ParkingLocationSummary({required this.locationId, required this.name});

  factory ParkingLocationSummary.fromJson(Map<String, dynamic> json) {
    return ParkingLocationSummary(
      locationId: (json['locationId'] as num).toInt(),
      name: json['name'] as String? ?? '',
    );
  }

  final int locationId;
  final String name;
}
