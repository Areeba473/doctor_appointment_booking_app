import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Verify simple Text widget', (WidgetTester tester) async {
    // Create a minimal widget for testing
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Text('Running on: Android'),
      ),
    ));

    // Verify that the Text starts with 'Running on:'
    expect(
      find.byWidgetPredicate(
            (Widget widget) =>
        widget is Text && widget.data?.startsWith('Running on:') == true,
      ),
      findsOneWidget,
    );
  });
}
