import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/residence/maintenance/screens/maintenance_requests_screen.dart';

void main() {
  testWidgets('MaintenanceRequestsScreen renders tickets and raise ticket action', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MaintenanceRequestsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Tickets
    expect(find.text('Maintenance & Issues'), findsOneWidget);
    expect(find.text('Water Seepage in Master Bathroom'), findsOneWidget);
    expect(find.text('Corridor Light Flickering (Tower A Floor 12)'), findsOneWidget);
    expect(find.text('Raise Ticket'), findsOneWidget);

    // Tap Raise Ticket
    await tester.tap(find.text('Raise Ticket'));
    await tester.pumpAndSettle();

    // Verify Modal
    expect(find.text('Raise Maintenance Complaint'), findsOneWidget);
    expect(find.text('Submit Ticket'), findsOneWidget);
  });
}
