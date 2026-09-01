import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/residence/visitors/screens/visitor_management_screen.dart';

void main() {
  testWidgets('VisitorManagementScreen renders visitor list and invite modal', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VisitorManagementScreen(),
      ),
    );

    // Check header and default sample visitors
    expect(find.text('Visitor Management'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsOneWidget);
    expect(find.text('Pooja Verma'), findsOneWidget);
    expect(find.text('Invite Guest'), findsWidgets);

    // Tap Invite Guest button
    await tester.tap(find.text('Invite Guest').first);
    await tester.pumpAndSettle();

    // Verify modal opened
    expect(find.text('Invite Guest / Visitor'), findsOneWidget);
    expect(find.text('Generate Digital Pass'), findsOneWidget);
  });
}
