import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/screens/cook_mode_screen.dart';
import 'package:mealchemy/features/cook_mode/services/screen_awake_service.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';

const _recipe = Recipe(
  recipeId: 7,
  title: 'Weeknight Pasta',
  steps: [
    RecipeStep(stepNr: 2, content: 'Toss with the sauce.'),
    RecipeStep(stepNr: 1, content: 'Boil the pasta.'),
  ],
);

class _FakeScreenAwakeService implements ScreenAwakeService {
  int enableCalls = 0;
  int disableCalls = 0;

  @override
  Future<void> enable() async => enableCalls++;

  @override
  Future<void> disable() async => disableCalls++;
}

Widget _host(Recipe recipe, _FakeScreenAwakeService service) {
  return ProviderScope(
    overrides: [
      recipeDetailProvider(recipe.recipeId).overrideWith((ref) async => recipe),
      screenAwakeServiceProvider.overrideWithValue(service),
    ],
    child: MaterialApp(home: CookModeScreen(recipeId: recipe.recipeId)),
  );
}

void main() {
  testWidgets('renders sorted steps and advances to completion',
      (tester) async {
    final service = _FakeScreenAwakeService();
    await tester.pumpWidget(_host(_recipe, service));
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 2'), findsOneWidget);
    expect(find.text('Boil the pasta.'), findsOneWidget);
    expect(service.enableCalls, 1);

    await tester.tap(find.byKey(const Key('cook-next-button')));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 2'), findsOneWidget);
    expect(find.text('Toss with the sauce.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cook-next-button')));
    await tester.pumpAndSettle();
    expect(find.text('Ready to serve'), findsOneWidget);
  });

  testWidgets('shows an empty state when the recipe has no steps',
      (tester) async {
    final service = _FakeScreenAwakeService();
    const recipe = Recipe(recipeId: 8, title: 'Unfinished', steps: []);

    await tester.pumpWidget(_host(recipe, service));
    await tester.pumpAndSettle();

    expect(find.text('No cooking steps yet'), findsOneWidget);
    expect(service.enableCalls, 0);
  });

  testWidgets('releases wakelock when Cook Mode is removed', (tester) async {
    final service = _FakeScreenAwakeService();
    await tester.pumpWidget(_host(_recipe, service));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(service.disableCalls, 1);
  });
}
