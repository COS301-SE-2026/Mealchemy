import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_step_row.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('RecipeStepRow renders zero-padded step number and content', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
         const RecipeStepRow(
          step: RecipeStep(
            stepNr: 1,
            content: 'Warm the stock and steep the saffron.',
          ),
        ),
      ),
    );

    expect(find.text('01'), findsOneWidget);
    expect(find.text('Warm the stock and steep the saffron.'), findsOneWidget);
  });

  testWidgets('RecipeStepRow renders two-digit step numbers without padding', (
    tester,
  ) async {
    await tester.pumpWidget(
       host(
        const RecipeStepRow(
          step: RecipeStep(
            stepNr: 12,
            content: 'Final step content.',
          ),
        ),
      ),
    );

    expect(find.text('12'), findsOneWidget);
    expect(find.text('Final step content.'), findsOneWidget);
  });
}
