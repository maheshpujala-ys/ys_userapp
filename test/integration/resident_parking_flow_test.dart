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
  testWidgets('E2E Resident Parking Flow: Home -> Parking Hub -> Active Pass', (WidgetTester tester) async {
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
    expect(find.text('Find Parking'), findsOneWidget);

    // Tap Find Parking quick action to navigate to Parking Hub
    await tester.tap(find.text('Find Parking'));
    await tester.pumpAndSettle();

    // Verify Parking Hub Loaded
    expect(find.text('Smart Parking Hub'), findsOneWidget);
    expect(find.text('Find & Reserve Spot'), findsOneWidget);
    expect(find.text('My Active Bookings (1)'), findsOneWidget);

    // Switch to Active Bookings tab
    await tester.tap(find.text('My Active Bookings (1)'));
    await tester.pumpAndSettle();

    // Verify Active Reservation details
    expect(find.text('Active Reservation'), findsOneWidget);
    expect(find.text('Slot B2-45 • Covered EV Bay'), findsOneWidget);
    expect(find.text('Show Gate QR Pass'), findsOneWidget);
  });
}
