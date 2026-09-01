import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/data/auth_repository.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';
import 'package:yellowspotuser/features/core/screens/home_screen.dart';

class MockAuthController extends AuthController {
  MockAuthController(AppUser user, StateNotifierProviderRef ref)
      : super(AuthRepository(Dio()), const FlutterSecureStorage(), ref) {
    state = AsyncValue.data(user);
  }

  @override
  Future<void> tryAutoLogin() async {}
}

void main() {
  testWidgets('E2E Visitor Flow: Home -> Invite Guest -> Visitor Management', (WidgetTester tester) async {
    final testUser = AppUser(
      id: 'u-1',
      email: 'user@test.com',
      name: 'Resident User',
      roles: [UserRole.user],
      token: 'test-token',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          AuthController.provider.overrideWith((ref) => MockAuthController(testUser, ref)),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Home Dashboard loaded
    expect(find.text('Invite Guest'), findsOneWidget);

    // Tap Invite Guest to open Visitor Management
    await tester.tap(find.text('Invite Guest'));
    await tester.pumpAndSettle();

    // Verify Visitor Management screen
    expect(find.text('Visitor Management'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsOneWidget);
    expect(find.text('Pooja Verma'), findsOneWidget);
  });
}
