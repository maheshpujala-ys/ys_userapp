import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/ev_charging/screens/ev_charging_screen.dart';

void main() {
  testWidgets('EvChargingScreen renders live session monitor and station list', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EvChargingScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title, Live session monitor
    expect(find.text('Smart EV Charging Bay'), findsOneWidget);
    expect(find.text('Live Charging Session'), findsOneWidget);
    expect(find.text('CHARGING (68%)'), findsOneWidget);
    expect(find.text('Stop Charging Session'), findsOneWidget);

    // Verify Available Stations
    expect(find.text('Available Charging Stations in Palm Meadows'), findsOneWidget);
    expect(find.text('Bay B2 - Supercharger 01'), findsOneWidget);
    expect(find.text('Bay B2 - AC Fast Charger 02'), findsOneWidget);

    // Stop Charging
    await tester.tap(find.text('Stop Charging Session'));
    await tester.pumpAndSettle();

    // Live session card removed
    expect(find.text('Live Charging Session'), findsNothing);
  });
}
