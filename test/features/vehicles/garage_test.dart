import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/vehicles/screens/my_garage_screen.dart';

void main() {
  testWidgets('MyGarageScreen renders vehicle list and add vehicle action', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MyGarageScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Vehicles
    expect(find.text('My Garage & Vehicles'), findsOneWidget);
    expect(find.text('Hyundai Creta SX (O) Turbo'), findsOneWidget);
    expect(find.text('TS 09 EQ 4821'), findsOneWidget);
    expect(find.text('PRIMARY'), findsOneWidget);
    expect(find.text('Tata Nexon EV Empowered+'), findsOneWidget);
    expect(find.text('Add Vehicle'), findsOneWidget);
  });
}
