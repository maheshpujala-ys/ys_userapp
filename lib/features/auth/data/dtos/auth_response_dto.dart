import 'package:yellowspotuser/features/auth/domain/app_user.dart';

/// DTO for `POST /api/v1/auth/authenticate`.
/// API shape: { token, userName, role, fullName, solutionType }
class AuthResponseDto {
  AuthResponseDto({
    required this.token,
    this.userName,
    this.fullName,
    this.role,
    this.solutionType,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    final token = (json['token'] ?? json['accessToken'] ?? json['jwt']) as String?;
    if (token == null || token.isEmpty) {
      throw const FormatException('Auth response missing token');
    }
    return AuthResponseDto(
      token: token,
      userName: (json['userName'] ?? json['username']) as String?,
      fullName: (json['fullName'] ?? json['fullname']) as String?,
      role: json['role'] as String?,
      solutionType: json['solutionType'] as String?,
    );
  }

  final String token;
  final String? userName;
  final String? fullName;
  final String? role;
  final String? solutionType;

  AppUser toDomain({required String fallbackUsername}) {
    final resolvedRole = role != null && role!.isNotEmpty
        ? UserRoleX.fromApi(role)
        : UserRole.user;
    return AppUser(
      username: userName ?? fallbackUsername,
      name: fullName ?? userName ?? fallbackUsername,
      roles: [resolvedRole],
      solutionType: solutionType,
      token: token,
    );
  }
}
