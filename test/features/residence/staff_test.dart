import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/residence/staff/screens/domestic_staff_screen.dart';

void main() {
  testWidgets('DomesticStaffScreen renders staff directory and gate status', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DomesticStaffScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & staff names
    expect(find.text('My Domestic Staff'), findsOneWidget);
    expect(find.text('Sunita Devi'), findsOneWidget);
    expect(find.text('Mohan Lal'), findsOneWidget);
    expect(find.text('Anjali Sharma'), findsOneWidget);

    // Verify In / Out status pills
    expect(find.text('INSIDE SOCIETY'), findsOneWidget);
    expect(find.text('OUTSIDE'), findsNWidgets(2));
  });
}
