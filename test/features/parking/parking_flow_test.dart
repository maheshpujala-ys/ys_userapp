import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/parking/screens/parking_hub_screen.dart';

void main() {
  testWidgets('ParkingHubScreen renders tabs, filters, and booking view', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ParkingHubScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify main header and tabs
    expect(find.text('Smart Parking Hub'), findsOneWidget);
    expect(find.text('Find & Reserve Spot'), findsOneWidget);
    expect(find.text('My Active Bookings (1)'), findsOneWidget);

    // Switch to My Active Bookings tab
    await tester.tap(find.text('My Active Bookings (1)'));
    await tester.pumpAndSettle();

    // Verify active booking card details
    expect(find.text('Active Reservation'), findsOneWidget);
    expect(find.text('Slot B2-45 • Covered EV Bay'), findsOneWidget);
    expect(find.text('Show Gate QR Pass'), findsOneWidget);
  });
}
