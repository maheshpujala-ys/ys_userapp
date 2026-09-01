import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/main.dart';

void main() {
  testWidgets('YellowSpot OS app launch smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    await tester.pump();
    expect(find.byType(MyApp), findsOneWidget);
  });
}
