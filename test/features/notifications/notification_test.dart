import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/notifications/screens/notification_center_screen.dart';

void main() {
  testWidgets('NotificationCenterScreen renders notifications and category filters', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: NotificationCenterScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Filter chips
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Parking'), findsOneWidget);

    // Verify Notification titles
    expect(find.text('Guest Pass Scanned at Gate 1'), findsOneWidget);
    expect(find.text('Parking Reservation Expiring Soon'), findsOneWidget);
    expect(find.text('Package Waiting at Main Security'), findsOneWidget);
  });
}
