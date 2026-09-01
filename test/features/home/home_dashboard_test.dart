import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/home/screens/home_dashboard_screen.dart';

void main() {
  testWidgets('HomeDashboardScreen renders header, quick actions, and sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeDashboardScreen(),
        ),
      ),
    );

    // Settle all futures and animations
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Verify Greeting and Quick Actions exist
    expect(find.textContaining('Good Morning'), findsOneWidget);
    expect(find.text('Find Parking'), findsOneWidget);
    expect(find.text('Invite Guest'), findsOneWidget);
    expect(find.text('Access Pass'), findsOneWidget);
    expect(find.text('My Garage'), findsOneWidget);
    expect(find.text('EV Charging'), findsOneWidget);
    expect(find.text('Vehicle Help'), findsOneWidget);

    // Verify Section Headers
    expect(find.text("Today's Activity"), findsOneWidget);
    expect(find.text('My Primary Vehicle'), findsOneWidget);
    expect(find.text('Community Updates'), findsOneWidget);
  });
}
