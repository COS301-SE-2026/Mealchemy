import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_repository.dart';
import 'package:mealchemy/features/recipe/screens/recipe_detail_screen.dart';

//returns a fixed recipe or throws for getRecipeById
class _FakeRecipeRepository implements RecipeRepository {
  _FakeRecipeRepository({this.recipe, this.shouldError = false});

  final Recipe? recipe;
  final bool shouldError;

  @override
  Future<Recipe> getRecipeById(int id) async {
    if (shouldError) throw Exception('Backend exploded');
    return recipe!;
  }

  @override
  Future<List<Recipe>> getRecipes() async => const [];

  @override
  Future<void> addRecipe(Recipe recipe) async {}

  @override
  Future<List<String>> getCuisineTypes() async => const [];
}

//never completes its future, used to lock the screen in the loading branch
class _SlowRecipeRepository implements RecipeRepository {
  final _completer = Completer<Recipe>();

  @override
  Future<Recipe> getRecipeById(int id) => _completer.future;

  @override
  Future<List<Recipe>> getRecipes() async => const [];

  @override
  Future<void> addRecipe(Recipe recipe) async {}

  @override
  Future<List<String>> getCuisineTypes() async => const [];
}

//disable network font fetching for testing to prevent socket errors
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  //ingredients and steps are out of order on purpose to test sort methods
  const fixture = Recipe(
    recipeId: 1,
    title: 'Saffron-Infused Risotto',
    description: 'A rich Italian classic',
    cuisineType: 'italian',
    prepTimeMins: 15,
    cookingTimeMins: 30,
    servingSize: 4,
    ingredients: [
      RecipeIngredient(
        ingredientId: 2,
        recipeId: 1,
        nameRaw: 'Saffron threads',
        quantity: 1,
        unit: 'pinch',
        sortOrder: 2,
      ),
      RecipeIngredient(
        ingredientId: 1,
        recipeId: 1,
        nameRaw: 'Arborio rice',
        quantity: 320,
        unit: 'g',
        sortOrder: 1,
      ),
    ],
    steps: [
      RecipeStep(
        stepId: 2,
        recipeId: 1,
        stepNr: 2,
        content: 'Toast the rice.',
      ),
      RecipeStep(
        stepId: 1,
        recipeId: 1,
        stepNr: 1,
        content: 'Warm the stock.',
      ),
    ],
  );

  //screen uses context.pop() so wrap in a real GoRouter, otherwise an exception would be thrown
  //ProviderScope overrides the repository so test never use real data
  Widget host({required RecipeRepository repo, int recipeId = 1}) {
    final router = GoRouter(
      initialLocation: '/recipe/$recipeId',
      routes: [
        GoRoute(
          path: '/recipe/:id',
          builder: (context, state) => RecipeDetailScreen(
            recipeId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ],
    );
    return ProviderScope(
      overrides: [recipeRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  //create a phone size viewpoint otherwise, otherwise build window doesnt reach ingredients,
  //steps and tip card.
  Future<void> pumpDetailScreen(
    WidgetTester tester, {
    required RecipeRepository repo,
    int recipeId = 1,
  }) async {
    tester.view.physicalSize = const Size(414, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(host(repo: repo, recipeId: recipeId));
  }

  testWidgets('shows a loading indicator while the recipe is loading', (
    tester,
  ) async {
    await pumpDetailScreen(tester, repo: _SlowRecipeRepository());
    //one frame so the FutureProvider emits its initial loading state, to catch loading
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error widget when the repository throws', (
    tester,
  ) async {
    await pumpDetailScreen(tester, repo: _FakeRecipeRepository(shouldError: true));
    await tester.pumpAndSettle();

    expect(find.text('Unable to load recipe.'), findsOneWidget);
  });

  testWidgets('renders the hero, tabs, ingredients, steps and CTA on data', (
    tester,
  ) async {
    await pumpDetailScreen(tester, repo: _FakeRecipeRepository(recipe: fixture));
    await tester.pumpAndSettle();

    //hero
    expect(find.text('Saffron-Infused Risotto'), findsOneWidget);

    //tab bar has all 4 tabs - count Tab widgets directly because the
    //section titles inside Overview also render the word "Ingredients"
    expect(find.byType(Tab), findsNWidgets(4));

    //stat cards - uses cookingTimeMins and prepTimeMins from fixture
    expect(find.text('30m'), findsOneWidget);
    expect(find.text('15m'), findsOneWidget);
    expect(find.text('Cook time'), findsOneWidget);
    expect(find.text('Prep time'), findsOneWidget);

    //ingredients and steps both visible on Overview tab
    expect(find.text('Arborio rice'), findsOneWidget);
    expect(find.text('Saffron threads'), findsOneWidget);
    expect(find.text('Warm the stock.'), findsOneWidget);
    expect(find.text('Toast the rice.'), findsOneWidget);

    //CTA
    expect(find.text('Start Cooking'), findsOneWidget);
  });

  testWidgets('sorts ingredients by sortOrder ascending on Overview', (
    tester,
  ) async {
    await pumpDetailScreen(tester, repo: _FakeRecipeRepository(recipe: fixture));
    await tester.pumpAndSettle();

    //Arborio rice has sort order 1 must appear above Saffron has 2. compare to see ascending order.
    final arborioY = tester.getTopLeft(find.text('Arborio rice')).dy;
    final saffronY = tester.getTopLeft(find.text('Saffron threads')).dy;
  //test sort is  ascending
    expect(arborioY, lessThan(saffronY));
  });

  testWidgets('sorts steps by stepNr ascending on Overview', (tester) async {
    await pumpDetailScreen(tester, repo: _FakeRecipeRepository(recipe: fixture));
    await tester.pumpAndSettle();

    final step1Y = tester.getTopLeft(find.text('Warm the stock.')).dy;
    final step2Y = tester.getTopLeft(find.text('Toast the rice.')).dy;

    expect(step1Y, lessThan(step2Y));
  });

  testWidgets('tapping Nutrition shows the coming-soon placeholder', (
    tester,
  ) async {
    await pumpDetailScreen(tester, repo: _FakeRecipeRepository(recipe: fixture));
    await tester.pumpAndSettle();

    //widgetWithText targets the Tab widget specifically so we don't accidentally
    //tap a section title with the same label
    await tester.tap(find.widgetWithText(Tab, 'Nutrition'));
    await tester.pumpAndSettle();

    expect(find.text('Nutrition data coming soon'), findsOneWidget);
  });

  testWidgets('tapping the Ingredients tab keeps ingredient rows visible', (
    tester,
  ) async {
    await pumpDetailScreen(tester, repo: _FakeRecipeRepository(recipe: fixture));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(Tab, 'Ingredients'));
    await tester.pumpAndSettle();

    //ingredients still on screen after the tab swap, therefore n widgets. after tab swap both are still in tree
    expect(find.text('Arborio rice'), findsAtLeastNWidgets(1));
    expect(find.text('Saffron threads'), findsAtLeastNWidgets(1));
  });

  testWidgets('tapping the Steps tab keeps step rows visible', (tester) async {
    await pumpDetailScreen(tester, repo: _FakeRecipeRepository(recipe: fixture));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(Tab, 'Steps'));
    await tester.pumpAndSettle();

    expect(find.text('Warm the stock.'), findsAtLeastNWidgets(1));
    expect(find.text('Toast the rice.'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows a placeholder dash for missing prep / cook times', (tester) async {
    const minimal = Recipe(recipeId: 9, title: 'Minimal Recipe');
    await pumpDetailScreen(
      tester,
      repo: _FakeRecipeRepository(recipe: minimal),
      recipeId: 9,
    );
    await tester.pumpAndSettle();

    expect(find.text('Minimal Recipe'), findsOneWidget);
    expect(find.text('-'), findsNWidgets(2));
  });

  testWidgets('renders without crashing when ingredients and steps are null', (
    tester,
  ) async {
    const empty = Recipe(recipeId: 7, title: 'Empty Recipe');
    await pumpDetailScreen(
      tester,
      repo: _FakeRecipeRepository(recipe: empty),
      recipeId: 7,
    );
    await tester.pumpAndSettle();

    expect(find.text('Empty Recipe'), findsOneWidget);
    expect(find.text('Start Cooking'), findsOneWidget);
  });

  testWidgets('renders the alchemist tip on the Overview tab', (tester) async {
    await pumpDetailScreen(tester, repo: _FakeRecipeRepository(recipe: fixture));
    await tester.pumpAndSettle();

    expect(find.text("ALCHEMIST'S TIP"), findsOneWidget);
    expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
  });

  testWidgets('renders the back, favorite and share buttons in the hero', (
    tester,
  ) async {
    await pumpDetailScreen(tester, repo: _FakeRecipeRepository(recipe: fixture));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.share_outlined), findsOneWidget);
  });

  testWidgets('renders the Cook time and Prep time stat labels on Overview', (
    tester,
  ) async {
    await pumpDetailScreen(tester, repo: _FakeRecipeRepository(recipe: fixture));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.local_fire_department_outlined), findsOneWidget);
    expect(find.byIcon(Icons.access_time), findsOneWidget);
  });
}
