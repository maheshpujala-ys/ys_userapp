import 'package:yellowspotuser/core/models/user.dart';
import 'package:yellowspotuser/core/services/api/auth_service.dart';

class MockAuthService implements AuthService {
  @override
  Future<User> login(String email, String password) async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, you'd make an API call here.
    // For now, we'll just return a dummy user.
    if (email == 'test@test.com' && password == 'password') {
      return User(id: '1', email: email, name: 'Test User');
    } else {
      throw Exception('Invalid credentials');
    }
  }

  @override
  Future<User> register(String email, String password, String name) async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, you'd make an API call here.
    return User(id: '2', email: email, name: name);
  }

  @override
  Future<void> logout() async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));
  }
}
