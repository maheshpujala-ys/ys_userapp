import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/auth/data/auth_repository.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';
import 'package:dio/dio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AuthRepository authenticates valid resident user', () async {
    final authRepo = AuthRepository(Dio());
    final user = await authRepo.login('user@test.com', 'password');

    expect(user.email, equals('user@test.com'));
    expect(user.name, equals('Test User'));
    expect(user.roles.contains(UserRole.user), isTrue);
  });

  test('AuthRepository authenticates valid admin user', () async {
    final authRepo = AuthRepository(Dio());
    final user = await authRepo.login('admin@test.com', 'password');

    expect(user.email, equals('admin@test.com'));
    expect(user.roles.contains(UserRole.admin), isTrue);
  });
}
