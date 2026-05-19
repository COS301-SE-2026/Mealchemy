import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/pantry/screens/add_ingredient_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('AddIngredientScreen renders manual ingredient form', (
    tester,
  ) async {
    await tester.pumpWidget(
      //need provider scope because screen reads Riverpod providers
      const ProviderScope(
        child: MaterialApp(
          home: AddIngredientScreen(),
        ),
      ),
    );

    //waits for mock data to load
    await tester.pumpAndSettle();

    expect(find.text('Add Ingredient\nManually'), findsOneWidget);
    expect(find.text('Ingredient Details'), findsOneWidget);
    expect(find.text('Ingredient name'), findsOneWidget);
    expect(find.text('Quantity'), findsWidgets);
  });
}