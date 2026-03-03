enum UserRole { user, admin, security, superAdmin }

class AppUser {
  final String id;
  final String email;
  final String name;
  final List<UserRole> roles;
  final String token;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.roles,
    required this.token,
  });

  // A factory constructor for creating a new AppUser instance from a map.
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      roles: (json['roles'] as List).map((role) => UserRole.values.byName(role)).toList(),
      token: json['token'],
    );
  }
}
