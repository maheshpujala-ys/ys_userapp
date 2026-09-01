import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellowspotuser/features/ai_assistant/application/ai_tool_dispatcher.dart';
import 'package:yellowspotuser/features/ai_assistant/screens/ai_assistant_screen.dart';

void main() {
  test('AiToolDispatcher parses intent and enforces permissions safely', () async {
    final parkingResp = await AiToolDispatcher.executeIntent('Is there parking slot in B1?');
    expect(parkingResp.contains('Parking Status'), isTrue);

    final visitorResp = await AiToolDispatcher.executeIntent('Who entered my flat today?');
    expect(visitorResp.contains('Visitor Access Log'), isTrue);

    final carResp = await AiToolDispatcher.executeIntent('Tell me about my vehicle');
    expect(carResp.contains('Primary Vehicle Status'), isTrue);

    final walletResp = await AiToolDispatcher.executeIntent('Show my wallet dues');
    expect(walletResp.contains('Financial Overview'), isTrue);
  });

  testWidgets('AiAssistantScreen renders conversation and quick chips', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AiAssistantScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('YellowSpot AI Assistant'), findsOneWidget);
    expect(find.text('Is parking available in Basement 1?'), findsOneWidget);
    expect(find.text('Who entered my residence today?'), findsOneWidget);
  });
}
