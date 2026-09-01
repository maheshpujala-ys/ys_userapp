import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/services/screens/service_tracking_screen.dart';

void main() {
  testWidgets('ServiceTrackingScreen renders timeline steps', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ServiceTrackingScreen(),
      ),
    );

    expect(find.text('Live Service Tracker'), findsOneWidget);
    expect(find.text('Booking Confirmed'), findsOneWidget);
    expect(find.text('Technician Assigned'), findsOneWidget);
    expect(find.text('Service in Progress'), findsOneWidget);
    expect(find.text('IN PROGRESS'), findsOneWidget);
  });
}
