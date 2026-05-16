// Lightweight smoke tests for pure-Dart helpers.
//
// The default Flutter counter widget test was removed — it called
// `pumpWidget(MyApp())` which triggers secure-storage reads and Dio setup
// that hang in headless CI.
//
// Replace / extend this file with proper widget tests once we have a
// `ProviderScope` test harness with mocked secure storage and dio.

import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';

void main() {
  group('UserRoleX.fromApi', () {
    test('maps known roles case-insensitively', () {
      expect(UserRoleX.fromApi('admin'), UserRole.admin);
      expect(UserRoleX.fromApi('ADMIN'), UserRole.admin);
      expect(UserRoleX.fromApi('security'), UserRole.security);
      expect(UserRoleX.fromApi('manager'), UserRole.manager);
    });

    test('recognises both superadmin variants', () {
      expect(UserRoleX.fromApi('superadmin'), UserRole.superAdmin);
      expect(UserRoleX.fromApi('super_admin'), UserRole.superAdmin);
    });

    test('falls back to user for null / empty / unknown', () {
      expect(UserRoleX.fromApi(null), UserRole.user);
      expect(UserRoleX.fromApi(''), UserRole.user);
      expect(UserRoleX.fromApi('alien-role'), UserRole.user);
    });
  });

  group('AppUser.copyWith', () {
    test('returns a new instance with only overridden fields changed', () {
      const base = AppUser(
        id: '1',
        username: 'alice',
        email: 'alice@example.com',
        name: 'Alice',
        roles: [UserRole.admin],
        token: 'tok-123',
      );
      final updated = base.copyWith(name: 'Alice 2');

      expect(updated.name, 'Alice 2');
      expect(updated.username, base.username);
      expect(updated.email, base.email);
      expect(updated.roles, base.roles);
      expect(updated.token, base.token);
    });
  });
}
