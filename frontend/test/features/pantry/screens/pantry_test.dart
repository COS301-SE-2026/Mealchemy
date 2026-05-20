import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/pantry/screens/pantry_screen.dart';

void main() {
  setUpAll(() {
    //disable fonts during tests
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  //make sure renders everything
  testWidgets('PantryScreen renders pantry overview', (tester) async {
    //wrapping screen
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PantryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    //make sure displays 
    expect(find.text('Pantry'), findsWidgets);
    expect(find.text('Meal Optimization'), findsOneWidget);
    expect(find.text('Proteins'), findsOneWidget);
    expect(find.text('Chicken Breast'), findsOneWidget);
  });
}