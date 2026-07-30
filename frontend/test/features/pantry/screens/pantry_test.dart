import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/pantry/screens/pantry_screen.dart';
import 'package:mealchemy/features/pantry/providers/pantry_provider.dart';
import 'package:mealchemy/features/pantry/repositories/mock_pantry_repository.dart';

void main() {
  setUpAll(() {
    //disable fonts during tests
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpPantryScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pantryRepositoryProvider.overrideWithValue(MockPantryRepository()),
        ],
        child: const MaterialApp(
          home: PantryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  //make sure renders everything
  testWidgets('PantryScreen renders pantry overview', (tester) async {
    await pumpPantryScreen(tester);

    await tester.pumpAndSettle();

    expect(find.text('Pantry'), findsWidgets);
    expect(find.text('Meal Optimization'), findsOneWidget);
    expect(find.text('Proteins'), findsOneWidget);
    expect(find.text('Chicken Breast'), findsOneWidget);
  });

  testWidgets('PantryScreen filters pantry items by search query', (
    tester,
  ) async {
    await pumpPantryScreen(tester);

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'milk');
    await tester.pumpAndSettle();

    expect(find.text('Full Cream Milk'), findsOneWidget);
    expect(find.text('Chicken Breast'), findsNothing);
  });

  testWidgets('PantryScreen filters pantry items by category', (tester) async {
    await pumpPantryScreen(tester);

    await tester.pumpAndSettle();

    final dairyFilter = find.textContaining('Dairy').first;
    await tester.ensureVisible(dairyFilter);
    await tester.tap(dairyFilter);
    await tester.pumpAndSettle();

    expect(find.text('Full Cream Milk'), findsOneWidget);
    expect(find.text('Chicken Breast'), findsNothing);
  });
}
