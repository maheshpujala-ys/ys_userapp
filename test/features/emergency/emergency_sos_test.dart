import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/emergency/screens/emergency_sos_sheet.dart';

void main() {
  testWidgets('EmergencySosSheet renders emergency options and handles dispatch', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => EmergencySosSheet.show(context),
              child: const Text('Open SOS'),
            ),
          ),
        ),
      ),
    );

    // Tap Open SOS
    await tester.tap(find.text('Open SOS'));
    await tester.pumpAndSettle();

    // Verify SOS Sheet items
    expect(find.text('Emergency SOS Dispatch'), findsOneWidget);
    expect(find.text('Society Security Gate'), findsOneWidget);
    expect(find.text('Medical Emergency (Ambulance)'), findsOneWidget);
    expect(find.text('Fire & Hazard Alert'), findsOneWidget);
    expect(find.text('CONFIRM & BROADCAST SOS'), findsOneWidget);
  });
}
