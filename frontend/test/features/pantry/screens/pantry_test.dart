import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/pantry/screens/pantry_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('PantryScreen renders pantry overview', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PantryScreen(),
      ),
    );

    expect(find.text('Pantry'), findsWidgets);
    expect(find.text('Meal Optimization'), findsOneWidget);
    expect(find.text('Proteins'), findsOneWidget);
    expect(find.text('Chicken Breast'), findsOneWidget);
  });
}