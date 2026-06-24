// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:praktikum_and_experiment_1/main_app.dart';

void main() {
  testWidgets('Landing page shows login access', (WidgetTester tester) async {
    await tester.pumpWidget(const IntelligenceEngineeringApp(isLoggedIn: false));

    expect(find.text('Intelligence Engineering'), findsWidgets);
    expect(find.byIcon(Icons.login_rounded), findsOneWidget);
  });
}
