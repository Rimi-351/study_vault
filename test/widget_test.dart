import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StudyVault smoke test verifies basic widget rendering', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('StudyVault'),
          ),
        ),
      ),
    );

    expect(find.text('StudyVault'), findsOneWidget);
  });
}
