import 'package:yellowspotuser/core/models/user.dart';

abstract class AuthService {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String name);
  Future<void> logout();
}
