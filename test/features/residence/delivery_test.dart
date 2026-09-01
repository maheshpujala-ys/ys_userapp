import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/residence/deliveries/screens/delivery_management_screen.dart';

void main() {
  testWidgets('DeliveryManagementScreen renders packages and gate actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DeliveryManagementScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & courier cards
    expect(find.text('Deliveries & Gate Parcels'), findsOneWidget);
    expect(find.text('Amazon India'), findsOneWidget);
    expect(find.text('Swiggy Instamart'), findsOneWidget);
    expect(find.text('BlueDart Express'), findsOneWidget);

    // Verify Gate Action Buttons
    expect(find.text('Approve Entry'), findsOneWidget);
    expect(find.text('Hold at Gate'), findsOneWidget);

    // Tap Approve Entry
    await tester.tap(find.text('Approve Entry'));
    await tester.pump();

    // Status changes to Approved for Entry
    expect(find.text('Approved for Entry'), findsWidgets);
  });
}
