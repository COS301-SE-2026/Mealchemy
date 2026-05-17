import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/preference/screens/preference_screen.dart';

void main() {
  testWidgets('PreferenceScreen renders correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PreferenceScreen()),
    );
    expect(find.text('Preference'), findsOneWidget);
  });
}