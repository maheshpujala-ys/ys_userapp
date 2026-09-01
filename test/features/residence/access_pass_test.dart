import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/residence/access_pass/screens/digital_access_pass_screen.dart';

void main() {
  testWidgets('DigitalAccessPassScreen renders Resident ID card and zones', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DigitalAccessPassScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title, Card details
    expect(find.text('Digital Resident ID'), findsOneWidget);
    expect(find.text('YELLOWSPOT PASS'), findsOneWidget);
    expect(find.text('CARD ID: YS-RES-2026-99218'), findsOneWidget);
    expect(find.text('Unit A-1204 • Palm Meadows Luxury Society'), findsOneWidget);
  });
}
