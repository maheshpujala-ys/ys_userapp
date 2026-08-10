/// One row from `/dashboard/parking-logs` — used by the corporate dashboard's
/// Recent Activities table.
class ParkingLogRow {
  const ParkingLogRow({
    required this.tenantName,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.tagSerial,
    required this.flatUnit,
    required this.logTime,
    required this.logType,
    required this.gate,
  });

  factory ParkingLogRow.fromJson(Map<String, dynamic> json) {
    return ParkingLogRow(
      tenantName: _strOrEmpty(json['tenantName']),
      vehicleType: _strOrEmpty(json['vehicleType']),
      vehicleNumber: _strOrEmpty(json['vehicleNumber']),
      tagSerial: _strOrEmpty(json['tagSerialNumber']),
      flatUnit: _strOrEmpty(json['flatNo']),
      logTime: _parseLocalDateTime(json['logTime']),
      logType: _strOrEmpty(json['logType']).toUpperCase(),
      gate: _strOrEmpty(json['name']),
    );
  }

  final String tenantName;
  final String vehicleType;
  final String vehicleNumber;
  final String tagSerial;
  final String flatUnit;
  final DateTime? logTime;
  final String logType;
  final String gate;

  bool get isEntry => logType == 'ENTRY' || logType == 'IN';
}

/// Aggregated corporate dashboard payload — replaces the residential
/// `dashboard/stats` + `tenants/stats` pair with one parking-logs call.
class CorporateDashboardData {
  const CorporateDashboardData({
    required this.totalTransactions,
    required this.vehicleIn,
    required this.vehicleOut,
    required this.active2W,
    required this.active4W,
    required this.visitorsToday,
    required this.parkingOccupancy,
    required this.recentActivities,
  });

  final int totalTransactions;
  final int vehicleIn;
  final int vehicleOut;
  final int active2W;
  final int active4W;
  final int visitorsToday;

  /// Vehicles currently inside (entries minus matching exits).
  final int parkingOccupancy;

  /// Latest log rows, newest first.
  final List<ParkingLogRow> recentActivities;
}

String _strOrEmpty(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  return v.toString();
}

DateTime? _parseLocalDateTime(dynamic v) {
  if (v == null) return null;
  if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
  if (v is List && v.length >= 3) {
    try {
      return DateTime(
        (v[0] as num).toInt(),
        (v[1] as num).toInt(),
        (v[2] as num).toInt(),
        v.length > 3 ? (v[3] as num).toInt() : 0,
        v.length > 4 ? (v[4] as num).toInt() : 0,
        v.length > 5 ? (v[5] as num).toInt() : 0,
      );
    } catch (_) {
      return null;
    }
  }
  return null;
}

/// Row in the corporate Availability List report.
/// Fields are parsed defensively — backend column names aren't fully pinned.
class AvailabilityRow {
  const AvailabilityRow({
    required this.companyName,
    required this.vehicleType,
    required this.total,
    required this.occupied,
    required this.vacant,
  });

  factory AvailabilityRow.fromJson(Map<String, dynamic> json) {
    return AvailabilityRow(
      companyName: _str(json, const [
        'companyName',
        'company',
        'companyTitle',
        'name',
      ]),
      vehicleType: _str(json, const [
        'vehicleType',
        'vehicleTypeName',
        'type',
      ]),
      total: _int(json, const ['total', 'totalSlots', 'allottedSlots']),
      occupied: _int(json, const ['occupied', 'occupiedSlots', 'used']),
      vacant: _int(json, const ['vacant', 'vacantSlots', 'available']),
    );
  }

  final String companyName;
  final String vehicleType;
  final int total;
  final int occupied;
  final int vacant;
}

/// Row in the corporate Day-wise (datewise) report.
class DayWiseRow {
  const DayWiseRow({
    required this.companyName,
    required this.allottedSlots,
    required this.totalTransaction,
    required this.entryGranted,
    required this.entryGrantedForVacated,
    required this.entryRestrictedParkingFull,
    required this.exitRegistered,
    required this.notExited,
    required this.parkingFull,
    required this.autoClose,
    required this.vacant,
  });

  factory DayWiseRow.fromJson(Map<String, dynamic> json) {
    return DayWiseRow(
      companyName: _str(json, const [
        'companyName',
        'company',
        'name',
      ]),
      allottedSlots: _int(json, const ['allottedSlots', 'allotted']),
      totalTransaction: _int(json, const [
        'totalTransaction',
        'totalTransactions',
      ]),
      entryGranted: _int(json, const ['entryGranted']),
      entryGrantedForVacated: _int(json, const [
        'entryGrantedForVacatedSlotsVehicles',
        'entryGrantedForVacated',
        'entryGrantedVacated',
      ]),
      entryRestrictedParkingFull: _int(json, const [
        'entryRestrictedDueToParkingFull',
        'entryRestricted',
      ]),
      exitRegistered: _int(json, const ['exitRegistered', 'exits']),
      notExited: _int(json, const ['notExited']),
      parkingFull: _int(json, const ['parkingFull']),
      autoClose: _int(json, const ['autoClose']),
      vacant: _int(json, const ['vacant']),
    );
  }

  final String companyName;
  final int allottedSlots;
  final int totalTransaction;
  final int entryGranted;
  final int entryGrantedForVacated;
  final int entryRestrictedParkingFull;
  final int exitRegistered;
  final int notExited;
  final int parkingFull;
  final int autoClose;
  final int vacant;
}

/// One day group inside a day-wise report.
class DayWiseDay {
  const DayWiseDay({required this.reportDate, required this.rows});

  factory DayWiseDay.fromJson(Map<String, dynamic> json) {
    final rowsRaw = json['rows'];
    final rows = <DayWiseRow>[];
    if (rowsRaw is List) {
      for (final r in rowsRaw) {
        if (r is Map) rows.add(DayWiseRow.fromJson(r.cast<String, dynamic>()));
      }
    }
    return DayWiseDay(
      reportDate: _parseLocalDate(json['reportDate']),
      rows: rows,
    );
  }

  final DateTime? reportDate;
  final List<DayWiseRow> rows;
}

/// Full day-wise report payload: a list of per-day groups.
class DayWiseReport {
  const DayWiseReport({
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  factory DayWiseReport.fromJson(Map<String, dynamic> json) {
    final daysRaw = json['days'];
    final days = <DayWiseDay>[];
    if (daysRaw is List) {
      for (final d in daysRaw) {
        if (d is Map) days.add(DayWiseDay.fromJson(d.cast<String, dynamic>()));
      }
    }
    return DayWiseReport(
      startDate: _parseLocalDate(json['startDate']),
      endDate: _parseLocalDate(json['endDate']),
      days: days,
    );
  }

  /// Tolerant fallback when the backend returns a bare list of rows for a
  /// single day (legacy shape).
  factory DayWiseReport.fromFlatRows(List<DayWiseRow> rows) {
    return DayWiseReport(
      startDate: null,
      endDate: null,
      days: [DayWiseDay(reportDate: null, rows: rows)],
    );
  }

  final DateTime? startDate;
  final DateTime? endDate;
  final List<DayWiseDay> days;

  bool get isEmpty => days.every((d) => d.rows.isEmpty);
}

/// Parses Jackson's `LocalDate` array shape `[year, month, day]`.
DateTime? _parseLocalDate(dynamic v) {
  if (v == null) return null;
  if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
  if (v is List && v.length >= 3) {
    try {
      return DateTime(
        (v[0] as num).toInt(),
        (v[1] as num).toInt(),
        (v[2] as num).toInt(),
      );
    } catch (_) {
      return null;
    }
  }
  return null;
}

/// Parameters for the day-wise report query.
class DayWiseQuery {
  const DayWiseQuery({
    required this.startDate,
    required this.endDate,
    this.companyName,
    this.vehicleTypeId,
  });

  /// ISO date `yyyy-MM-dd`.
  final String startDate;
  final String endDate;
  final String? companyName;
  final int? vehicleTypeId;

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      'startDate': startDate,
      'endDate': endDate,
      if (companyName != null && companyName!.isNotEmpty)
        'companyName': companyName,
      if (vehicleTypeId != null) 'vehicleTypeId': vehicleTypeId,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is DayWiseQuery &&
      startDate == other.startDate &&
      endDate == other.endDate &&
      companyName == other.companyName &&
      vehicleTypeId == other.vehicleTypeId;

  @override
  int get hashCode =>
      Object.hash(startDate, endDate, companyName, vehicleTypeId);
}

String _str(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final v = json[k];
    if (v is String && v.isNotEmpty) return v;
    if (v != null && v is! Map && v is! List) return v.toString();
  }
  return '';
}

int _int(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final v = json[k];
    if (v is num) return v.toInt();
    if (v is String) {
      final parsed = int.tryParse(v);
      if (parsed != null) return parsed;
    }
  }
  return 0;
}
