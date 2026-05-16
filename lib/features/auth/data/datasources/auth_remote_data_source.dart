import 'package:dio/dio.dart';
import 'package:yellowspotuser/core/network/api_endpoints.dart';
import 'package:yellowspotuser/core/network/api_exception.dart';
import 'package:yellowspotuser/features/auth/data/dtos/auth_response_dto.dart';
import 'package:yellowspotuser/features/auth/domain/entities/auth_credentials.dart';
import 'package:yellowspotuser/features/auth/domain/entities/change_password_request.dart';
import 'package:yellowspotuser/features/auth/domain/entities/register_request.dart';

/// Thin HTTP layer — only knows about JSON & endpoints.
/// Translates DioExceptions into ApiException so callers don't depend on Dio.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// Hardcoded tenant context — UI only collects username + password.
  /// Move these to `AppConfig` / `--dart-define` once we have multi-tenant builds.
  static const String _subdomain = 'demo';
  static const String _customerCode = 'demo';

  Future<AuthResponseDto> authenticate(AuthCredentials credentials) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authenticate,
        data: {
          'username': credentials.username,
          'password': credentials.password,
          'subdomain': _subdomain,
          'customerCode': _customerCode,
        },
      );
      return AuthResponseDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Authentication failed');
    }
  }

  Future<void> register(RegisterRequest request) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.register,
        data: {
          'username': request.username,
          'fullname': request.fullname,
          'email': request.email,
          if (request.password != null) 'password': request.password,
          if (request.role != null) 'role': request.role,
          if (request.phone != null) 'phone': request.phone,
          if (request.customerId != null) 'customerId': request.customerId,
          if (request.locationId != null) 'locationId': request.locationId,
          if (request.solutionType != null) 'solutionType': request.solutionType,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Registration failed');
    }
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.changePassword,
        data: {'newPassword': request.newPassword},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Password change failed');
    }
  }
}
