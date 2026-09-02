import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/core/theme/app_theme.dart';
import 'package:yellowspotuser/core/theme/theme_controller.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';
import 'package:yellowspotuser/features/auth/screens/profile_screen.dart';

import '../../core/theme_controller_test.dart';

class MockAuthController extends StateNotifier<AsyncValue<AppUser?>> implements AuthController {
  MockAuthController(AppUser user) : super(AsyncValue.data(user));

  @override
  Future<void> tryAutoLogin() async {}

  @override
  Future<void> login(String email, String password) async {}

  @override
  Future<void> signUp({required String name, required String email, required String password}) async {}

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> updateUser(String name, String email) async {}

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('ProfileScreen renders Appearance section and switches themes live', (tester) async {
    final fakeStorage = FakeSecureStorage();
    final testUser = AppUser(
      id: 'usr-001',
      email: 'resident@yellowspot.io',
      name: 'Alex Morgan',
      roles: [UserRole.user],
      token: 'jwt-resident-token',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageProvider.overrideWithValue(fakeStorage),
          AuthController.provider.overrideWith(
            (ref) => MockAuthController(testUser),
          ),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final themeMode = ref.watch(themeControllerProvider);
            return MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const ProfileScreen(),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Appearance section and options are present
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Light Theme'), findsOneWidget);
    expect(find.text('Dark Theme'), findsOneWidget);
    expect(find.text('System Default'), findsOneWidget);

    // Default theme is Light - verify checkmark exists
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // Tap Dark Theme
    await tester.tap(find.text('Dark Theme'));
    await tester.pumpAndSettle();

    // Verify storage updated to 'dark'
    expect(await fakeStorage.read(key: kThemeStorageKey), equals('dark'));

    // Tap System Default
    await tester.tap(find.text('System Default'));
    await tester.pumpAndSettle();

    // Verify storage updated to 'system'
    expect(await fakeStorage.read(key: kThemeStorageKey), equals('system'));

    // Tap Light Theme back
    await tester.tap(find.text('Light Theme'));
    await tester.pumpAndSettle();

    // Verify storage updated to 'light'
    expect(await fakeStorage.read(key: kThemeStorageKey), equals('light'));
  });
}
