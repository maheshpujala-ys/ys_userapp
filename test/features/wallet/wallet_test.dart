import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/wallet/screens/wallet_screen.dart';

void main() {
  testWidgets('WalletScreen renders balance, top up action, and transactions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WalletScreen(),
      ),
    );

    // Verify Title & Balance display
    expect(find.text('YellowSpot Wallet'), findsOneWidget);
    expect(find.text('Total Available Balance'), findsOneWidget);
    expect(find.text('Add Money'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);

    // Verify Sample Transactions
    expect(find.text('EV Charging Session (Bay B2)'), findsOneWidget);
    expect(find.text('Parking Spot B2-45 Reservation'), findsOneWidget);
  });
}
