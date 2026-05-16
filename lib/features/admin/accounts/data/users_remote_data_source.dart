import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/network/api_endpoints.dart';
import 'package:yellowspotuser/core/network/api_exception.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';

/// Request body for `POST /api/v1/users` (UserDto).
class UserCreateRequest {
  const UserCreateRequest({
    required this.username,
    required this.fullname,
    required this.email,
    this.password,
    this.role,
    this.phone,
    this.solutionType,
    this.customerId,
    this.locationId,
    this.activeInd = 'Y',
  });

  final String username;
  final String fullname;
  final String email;
  final String? password;
  final String? role;
  final String? phone;
  final String? solutionType;
  final int? customerId;
  final int? locationId;
  final String activeInd;

  Map<String, dynamic> toJson() => {
        'username': username,
        'fullname': fullname,
        'email': email,
        if (password != null) 'password': password,
        if (role != null) 'role': role,
        if (phone != null) 'phone': phone,
        if (solutionType != null) 'solutionType': solutionType,
        if (customerId != null) 'customerId': customerId,
        if (locationId != null) 'locationId': locationId,
        'activeInd': activeInd,
      };
}

class UserSummary {
  const UserSummary({
    required this.id,
    required this.username,
    this.fullname,
    this.email,
    this.role,
    this.activeInd,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String? ?? '',
      fullname: json['fullname'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      activeInd: json['activeInd'] as String?,
    );
  }

  final int id;
  final String username;
  final String? fullname;
  final String? email;
  final String? role;
  final String? activeInd;
}

class UsersRemoteDataSource {
  UsersRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserSummary> createUser(UserCreateRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.users,
        data: request.toJson(),
      );
      return UserSummary.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not create user');
    }
  }

  Future<List<UserSummary>> getUsers({int page = 0, int size = 50}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.users,
        queryParameters: {'page': page, 'size': size},
      );
      final content = (response.data?['content'] as List?) ?? const [];
      return content
          .whereType<Map<String, dynamic>>()
          .map(UserSummary.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e, fallback: 'Could not load users');
    }
  }
}

final usersRemoteDataSourceProvider = Provider<UsersRemoteDataSource>(
  (ref) => UsersRemoteDataSource(ref.watch(dioProvider)),
);
