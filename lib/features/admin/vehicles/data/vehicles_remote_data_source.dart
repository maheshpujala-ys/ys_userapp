import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/network/api_endpoints.dart';
import 'package:yellowspotuser/core/network/api_exception.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';

/// Request body for `POST /api/v1/vehicle` (VehicleRegistrationDto).
class VehicleCreateRequest {
  const VehicleCreateRequest({
    required this.tenantId,
    required this.vehicleTypeId,
    required this.vehicleNumber,
    required this.registrationType,
    required this.startDate,
    this.empId,
    this.smartCardId,
    this.fastagRfNumber,
    this.carType,
    this.endDate,
    this.locationId,
    this.zoneId,
    this.activeInd = 'Y',
  });

  final int tenantId;
  final int vehicleTypeId;
  final String vehicleNumber;

  /// e.g. `TEMP`, `PERMANENT`, `VISITOR`.
  final String registrationType;

  /// `YYYY-MM-DD` (date-only) per backend example.
  final String startDate;

  final String? empId;
  final int? smartCardId;
  final String? fastagRfNumber;
  final String? carType;
  final String? endDate;
  final int? locationId;
  final int? zoneId;
  final String activeInd;

  Map<String, dynamic> toJson() => {
        'tenantId': tenantId,
        'vehicleTypeId': vehicleTypeId,
        'vehicleNumber': vehicleNumber,
        'registrationType': registrationType,
        'startDate': startDate,
        if (empId != null) 'empId': empId,
        if (smartCardId != null) 'smartCardId': smartCardId,
        if (fastagRfNumber != null) 'fastagRfNumber': fastagRfNumber,
        if (carType != null) 'carType': carType,
        if (endDate != null) 'endDate': endDate,
        if (locationId != null) 'locationId': locationId,
        if (zoneId != null) 'zoneId': zoneId,
        'activeInd': activeInd,
      };
}

/// Projection of VehicleRegistrationResponseDto — carries everything needed
/// for both list display and pre-filling the edit form.
class VehicleRegistrationSummary {
  const VehicleRegistrationSummary({
    required this.registrationId,
    required this.vehicleNumber,
    this.tenantId,
    this.tenantName,
    this.vehicleTypeId,
    this.smartCardId,
    this.fastagRfNumber,
    this.carType,
    this.registrationType,
    this.startDate,
    this.endDate,
    this.activeInd,
    this.empId,
    this.locationId,
    this.zoneId,
  });

  factory VehicleRegistrationSummary.fromJson(Map<String, dynamic> json) {
    final tenant = json['tenant'];
    int? tenantId;
    String? tenantName;
    if (tenant is Map) {
      final t = tenant.cast<String, dynamic>();
      final id = t['tenantId'];
      if (id is num) tenantId = id.toInt();
      final n = t['name'];
      if (n is String) tenantName = n;
    }
    if (tenantId == null && json['tenantId'] is num) {
      tenantId = (json['tenantId'] as num).toInt();
    }
    tenantName ??= _asString(json['tenantName']);

    final smartCard = json['smartCard'];
    int? smartCardId;
    if (smartCard is Map) {
      final v = smartCard['smartCardId'];
      if (v is num) smartCardId = v.toInt();
    }
    if (smartCardId == null && json['smartCardId'] is num) {
      smartCardId = (json['smartCardId'] as num).toInt();
    }

    return VehicleRegistrationSummary(
      registrationId: _asInt(json['registrationId']),
      vehicleNumber: _asString(json['vehicleNumber']),
      tenantId: tenantId,
      tenantName: tenantName,
      vehicleTypeId: (json['vehicleTypeId'] as num?)?.toInt(),
      smartCardId: smartCardId,
      fastagRfNumber: _asNullableString(json['fastagRfNumber']),
      carType: _asNullableString(json['carType']),
      registrationType: _asNullableString(json['registrationType']),
      startDate: _asDate(json['startDate']),
      endDate: _asDate(json['endDate']),
      activeInd: _asNullableString(json['activeInd']),
      empId: _asNullableString(json['empId']),
      locationId: (json['locationId'] as num?)?.toInt(),
      zoneId: (json['zoneId'] as num?)?.toInt(),
    );
  }

  final int registrationId;
  final String vehicleNumber;
  final int? tenantId;
  final String? tenantName;
  final int? vehicleTypeId;
  final int? smartCardId;
  final String? fastagRfNumber;
  final String? carType;
  final String? registrationType;
  final String? startDate;
  final String? endDate;
  final String? activeInd;
  final String? empId;
  final int? locationId;
  final int? zoneId;

  bool get isActive => (activeInd ?? '').toUpperCase() == 'Y';

  static int _asInt(dynamic v) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static String _asString(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    return v.toString();
  }

  static String? _asNullableString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    return v.toString();
  }

  /// Normalises a date field to ISO `YYYY-MM-DD`.
  /// Backend may emit either a string (`"2025-06-30"`) or a Jackson
  /// `LocalDate` array (`[2025, 6, 30]`). Returns `''` if neither applies.
  static String _asDate(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is List && v.length >= 3) {
      try {
        final y = (v[0] as num).toInt();
        final m = (v[1] as num).toInt();
        final d = (v[2] as num).toInt();
        return '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
      } catch (_) {
        return '';
      }
    }
    return '';
  }
}

class VehiclesRemoteDataSource {
  VehiclesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> createVehicle(VehicleCreateRequest request) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.vehicles,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not register vehicle');
    }
  }

  /// Update an existing vehicle registration via `PUT /api/v1/vehicle/{id}`.
  Future<void> updateVehicle(
      int registrationId, VehicleCreateRequest request) async {
    try {
      await _dio.put<dynamic>(
        '${ApiEndpoints.vehicles}/$registrationId',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not update vehicle');
    }
  }

  Future<List<VehicleRegistrationSummary>> getVehicles(
      {int page = 0, int size = 50}) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.vehicles,
        queryParameters: {'page': page, 'size': size},
      );
      final rows = _extractRows(response.data);
      return rows
          .map(VehicleRegistrationSummary.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not load vehicles');
    }
  }

  /// Accepts PagedModel `{content: [...]}`, HATEOAS `{_embedded: {x: [...]}}`,
  /// or a bare top-level list.
  static List<Map<String, dynamic>> _extractRows(dynamic body) {
    if (body is List) return _coerceMaps(body);
    if (body is Map) {
      final m = body.cast<String, dynamic>();
      final content = m['content'];
      if (content is List) return _coerceMaps(content);
      final embedded = m['_embedded'];
      if (embedded is Map) {
        for (final v in embedded.values) {
          if (v is List) return _coerceMaps(v);
        }
      }
      final data = m['data'];
      if (data is List) return _coerceMaps(data);
    }
    return const [];
  }

  static List<Map<String, dynamic>> _coerceMaps(List raw) {
    final out = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is Map) out.add(item.cast<String, dynamic>());
    }
    return out;
  }
}

final vehiclesRemoteDataSourceProvider = Provider<VehiclesRemoteDataSource>(
  (ref) => VehiclesRemoteDataSource(ref.watch(dioProvider)),
);

final vehiclesListProvider =
    FutureProvider.autoDispose<List<VehicleRegistrationSummary>>((ref) {
  return ref.watch(vehiclesRemoteDataSourceProvider).getVehicles();
});
