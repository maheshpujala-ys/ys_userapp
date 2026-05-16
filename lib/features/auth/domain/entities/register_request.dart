/// Inputs for `POST /api/v1/auth/register` (backed by UserDto).
/// Only username, fullname, email are required by the API.
class RegisterRequest {
  const RegisterRequest({
    required this.username,
    required this.fullname,
    required this.email,
    this.password,
    this.role,
    this.phone,
    this.customerId,
    this.locationId,
    this.solutionType,
  });

  final String username;
  final String fullname;
  final String email;
  final String? password;
  final String? role;
  final String? phone;
  final int? customerId;
  final int? locationId;
  final String? solutionType;
}
