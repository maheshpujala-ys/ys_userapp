import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';

class AuthRepository {
  final Dio dio;

  AuthRepository(this.dio);

  static final provider = Provider<AuthRepository>(
    (ref) => AuthRepository(ref.watch(dioProvider)),
  );

  Future<AppUser> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'admin@test.com' && password == 'password') {
      return AppUser(id: 'admin1', email: email, name: 'Admin User', roles: [UserRole.admin, UserRole.user], token: 'multi-role-token');
    } else if (email == 'user@test.com' && password == 'password') {
      return AppUser(id: 'user1', email: email, name: 'Test User', roles: [UserRole.user], token: 'user-token');
    } else {
      throw DioError(requestOptions: RequestOptions(path: ''), error: 'Invalid credentials');
    }
  }

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // In a real app, you'd make a POST request to your sign-up endpoint.
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate successful sign-up
    return AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      roles: [UserRole.user],
      token: 'new-user-token',
    );
  }

  Future<void> forgotPassword(String email) async {
    // In a real app, you'd make a POST request to your forgot-password endpoint.
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate success
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Please enter a valid email address');
    }
  }

  Future<AppUser> updateUser(String id, String name, String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return AppUser(id: id, email: email, name: name, roles: [UserRole.user], token: 'user-token');
  }
}
