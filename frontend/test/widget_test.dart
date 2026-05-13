//intial smoke test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/main.dart';
import 'package:mealchemy/main.dart' as entry;

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const MealchemyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('main entry point launches the app', (WidgetTester tester) async {
    entry.main();
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
