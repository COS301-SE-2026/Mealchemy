import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_servings_section.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: Scaffold(
          body: RecipeServingsSection(recipeId: 1, baseServings: 4),
        ),
      ),
    );
  }

  testWidgets(' seeds to the base serving count', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Servings'), findsOneWidget);
  });

  testWidgets('incrementing and decrementing the serving count', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('will not go below one serving', (tester) async {
    await tester.pumpWidget(host(
      overrides: [servingsProvider(1).overrideWith((ref) => 1)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('Serving'), findsOneWidget); 

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();

    // still one the minus is disabled at the floor
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('reset appears only after a change and restores the base',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    // no reset at the base count
    expect(find.text('Reset'), findsNothing);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Reset'), findsNothing);
  });
}