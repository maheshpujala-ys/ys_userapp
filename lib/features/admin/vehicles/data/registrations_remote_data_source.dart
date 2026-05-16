import 'package:dio/dio.dart';
import 'package:yellowspotuser/core/network/api_endpoints.dart';
import 'package:yellowspotuser/core/network/api_exception.dart';
import 'package:yellowspotuser/features/admin/vehicles/domain/registration_models.dart';

/// HTTP gateway to /api/v1/registrations and /api/v1/vehicle_type.
class RegistrationsRemoteDataSource {
  RegistrationsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> createRegistration(
      VehicleRegistrationCreateRequest request) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.registrations,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not register vehicle');
    }
  }

  Future<List<VehicleTypeSummary>> getVehicleTypes(
      {int page = 0, int size = 50}) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.vehicleTypes,
        queryParameters: {'page': page, 'size': size},
      );
      final data = response.data;
      final List rows = data is List
          ? data
          : (data is Map && data['content'] is List)
              ? data['content'] as List
              : const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(VehicleTypeSummary.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e,
          fallback: 'Could not load vehicle types');
    }
  }
}
