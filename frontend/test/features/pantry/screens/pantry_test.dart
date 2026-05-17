import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/pantry/screens/pantry_screen.dart';

void main() {
  testWidgets('PantryScreen renders correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PantryScreen()),
    );
    expect(find.text('Pantry'), findsOneWidget);
  });
}