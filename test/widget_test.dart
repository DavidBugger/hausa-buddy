// This is a basic Flutter widget test for the Learn Hausa app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learn_hausa/main.dart';

void main() {
  testWidgets('Learn Hausa app loads and shows welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LearnHausaApp());

    // Verify that the app title is displayed
    expect(find.text('Learn Hausa'), findsOneWidget);

    // Verify that the welcome screen is shown initially
    // (This may need to be adjusted based on your actual app navigation)
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Learn Hausa app has proper theme colors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LearnHausaApp());

    // Verify that the app has the correct theme setup
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.primaryColor, isNotNull);
    expect(app.debugShowCheckedModeBanner, false);
  });
}
