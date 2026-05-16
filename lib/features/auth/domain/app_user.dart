enum UserRole { user, admin, security, superAdmin, manager }

extension UserRoleX on UserRole {
  /// Wire-format value used by the backend.
  String get apiValue {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.admin:
        return 'admin';
      case UserRole.security:
        return 'security';
      case UserRole.superAdmin:
        return 'superadmin';
      case UserRole.manager:
        return 'manager';
    }
  }

  static UserRole fromApi(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'security':
        return UserRole.security;
      case 'superadmin':
      case 'super_admin':
        return UserRole.superAdmin;
      case 'manager':
        return UserRole.manager;
      default:
        return UserRole.user;
    }
  }
}

class AppUser {
  const AppUser({
    this.id,
    required this.username,
    this.email,
    required this.name,
    required this.roles,
    this.solutionType,
    required this.token,
  });

  /// Optional — `/api/v1/auth/authenticate` does not return an id.
  /// Populated later by a profile fetch (`/api/v1/users/{id}`) when available.
  final String? id;
  final String username;

  /// Optional — auth response does not include email; fetched on profile.
  final String? email;
  final String name;
  final List<UserRole> roles;

  /// e.g. "CORPORATE" — used to gate feature visibility.
  final String? solutionType;
  final String token;

  AppUser copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    List<UserRole>? roles,
    String? solutionType,
    String? token,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      roles: roles ?? this.roles,
      solutionType: solutionType ?? this.solutionType,
      token: token ?? this.token,
    );
  }
}
