import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/residence/amenities/screens/amenities_booking_screen.dart';

void main() {
  testWidgets('AmenitiesBookingScreen renders amenities list and reserve slot action', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AmenitiesBookingScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Amenities
    expect(find.text('Society Amenities'), findsOneWidget);
    expect(find.text('Olympic Swimming Pool'), findsOneWidget);
    expect(find.text('Fitness Center & Gym'), findsOneWidget);
    expect(find.text('Tennis & Pickleball Court'), findsOneWidget);
    expect(find.text('Reserve Slot'), findsWidgets);

    // Tap Reserve Slot on first available amenity
    await tester.tap(find.text('Reserve Slot').first);
    await tester.pump();

    // Verify confirmation feedback
    expect(find.text('Reserved slot for Olympic Swimming Pool!'), findsOneWidget);
  });
}
