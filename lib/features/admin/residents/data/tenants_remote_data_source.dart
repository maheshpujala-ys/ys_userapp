import 'package:dio/dio.dart';
import 'package:yellowspotuser/core/network/api_endpoints.dart';
import 'package:yellowspotuser/core/network/api_exception.dart';
import 'package:yellowspotuser/features/admin/residents/domain/tenant_models.dart';

/// HTTP gateway to /api/v1/tenants/* and /api/v1/parking_location.
class TenantsRemoteDataSource {
  TenantsRemoteDataSource(this._dio);

  final Dio _dio;

  /// Create a tenant. The backend treats "residents" as tenants.
  Future<TenantSummary> createTenant(TenantCreateRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.tenants,
        data: request.toJson(),
      );
      return TenantSummary.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not create resident');
    }
  }

  /// Update an existing tenant. Same body shape as create.
  Future<TenantSummary> updateTenant(
      int tenantId, TenantCreateRequest request) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '${ApiEndpoints.tenants}/$tenantId',
        data: request.toJson(),
      );
      return TenantSummary.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not update resident');
    }
  }

  /// First page of tenants. Pagination can be added when a list screen exists.
  Future<List<TenantSummary>> getTenants({int page = 0, int size = 50}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.tenants,
        queryParameters: {'page': page, 'size': size},
      );
      final content = (response.data?['content'] as List?) ?? const [];
      return content
          .whereType<Map<String, dynamic>>()
          .map(TenantSummary.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not load residents');
    }
  }

  /// Allowed tenant types (`Owner`, `Tenant`, etc.).
  Future<List<String>> getTenantTypes() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.tenantTypes);
      final data = response.data;
      if (data is List) {
        return data.map((e) => e.toString()).toList(growable: false);
      }
      if (data is Map && data['types'] is List) {
        return (data['types'] as List)
            .map((e) => e.toString())
            .toList(growable: false);
      }
      return const ['Owner', 'Tenant'];
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not load tenant types');
    }
  }

  Future<List<ParkingLocationSummary>> getParkingLocations() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.parkingLocations);
      final data = response.data;
      final List rows = data is List
          ? data
          : (data is Map && data['content'] is List)
              ? data['content'] as List
              : const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(ParkingLocationSummary.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not load locations');
    }
  }
}
