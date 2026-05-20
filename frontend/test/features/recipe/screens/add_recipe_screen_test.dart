import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_chip.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_repository.dart';
import 'package:mealchemy/features/recipe/screens/add_recipe_screen.dart';

//records every addRecipe call, tests can asset what was sent to repository
class _RecordingRepo implements RecipeRepository {
  final List<Recipe> savedRecipes = [];

  @override
  Future<void> addRecipe(Recipe recipe) async {
    savedRecipes.add(recipe);
  }

  @override
  Future<List<Recipe>> getRecipes() async => const [];

  @override
  Future<Recipe> getRecipeById(int id) async => throw UnimplementedError();

  @override
  Future<List<String>> getCuisineTypes() async =>
      const ['italian', 'asian', 'mexican'];
}

//getCuisineTypes never completes
//loading state to asset loading indicator shows
class _SlowCuisinesRepo implements RecipeRepository {
  final _completer = Completer<List<String>>();

  @override
  Future<List<String>> getCuisineTypes() => _completer.future;

  @override
  Future<List<Recipe>> getRecipes() async => const [];

  @override
  Future<Recipe> getRecipeById(int id) async => throw UnimplementedError();

  @override
  Future<void> addRecipe(Recipe recipe) async {}
}

//getCuisineTypes throws, test error
class _ThrowingCuisinesRepo implements RecipeRepository {
  @override
  Future<List<String>> getCuisineTypes() async => throw Exception('boom');

  @override
  Future<List<Recipe>> getRecipes() async => const [];

  @override
  Future<Recipe> getRecipeById(int id) async => throw UnimplementedError();

  @override
  Future<void> addRecipe(Recipe recipe) async {}
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  //screen uses context pop so wrap in a real GoRouter
  Widget host({required RecipeRepository repo}) {
    final router = GoRouter(
      initialLocation: '/recipe/add',
      routes: [
        GoRoute(
          path: '/recipe/add',
          builder: (context, state) => const AddRecipeScreen(),
        ),
      ],
    );
    return ProviderScope(
      overrides: [recipeRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  //the form is taller than the default
  //real estate or the bottom buttons end up outside the build window
  //use a phone sized viewpoint
  Future<void> pumpAddRecipe(
    WidgetTester tester, {
    required RecipeRepository repo,
  }) async {
    tester.view.physicalSize = const Size(414, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(host(repo: repo));
  }

  testWidgets('shows a loading indicator while cuisines are loading', (
    tester,
  ) async {
    await pumpAddRecipe(tester, repo: _SlowCuisinesRepo());
    //one frame, test loading value
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error widget when cuisines fail to load', (
    tester,
  ) async {
    await pumpAddRecipe(tester, repo: _ThrowingCuisinesRepo());
    await tester.pumpAndSettle();

    expect(find.text('Unable to load form data.'), findsOneWidget);
  });

  testWidgets('renders the kicker, heading, section headers and CTAs', (
    tester,
  ) async {
    await pumpAddRecipe(tester, repo: _RecordingRepo());
    await tester.pumpAndSettle();

    expect(find.text('NEW RECIPE'), findsOneWidget);
    expect(find.text('Add a Recipe\nto Your Vault'), findsOneWidget);
    expect(find.text('Recipe Details'), findsOneWidget);
    expect(find.text('Time & Servings'), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Preparation Steps'), findsOneWidget);
    expect(find.text('Save Recipe'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('renders the photo upload tile and coming-soon placeholders', (
    tester,
  ) async {
    await pumpAddRecipe(tester, repo: _RecordingRepo());
    await tester.pumpAndSettle();

    expect(find.text('Hero photo'), findsOneWidget);
    expect(find.text('Ingredient editor coming soon.'), findsOneWidget);
    expect(find.text('Step-by-step editor coming soon.'), findsOneWidget);
  });

  testWidgets('renders cuisine chips formatted from snake_case enum values', (
    tester,
  ) async {
    await pumpAddRecipe(tester, repo: _RecordingRepo());
    await tester.pumpAndSettle();

    //_formatCuisine turns 'italian' into 'Italian' etc.
    expect(find.text('Italian'), findsOneWidget);
    expect(find.text('Asian'), findsOneWidget);
    expect(find.text('Mexican'), findsOneWidget);
  });

  testWidgets('tapping a cuisine chip marks it as selected', (tester) async {
    await pumpAddRecipe(tester, repo: _RecordingRepo());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Italian'));
    await tester.pumpAndSettle();

    final chip = tester.widget<AppChip>(
      find.widgetWithText(AppChip, 'Italian'),
    );
    expect(chip.selected, true);
  });

  testWidgets('tapping a selected cuisine chip deselects it', (tester) async {
    await pumpAddRecipe(tester, repo: _RecordingRepo());
    await tester.pumpAndSettle();

    //select then deselect
    await tester.tap(find.text('Italian'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Italian'));
    await tester.pumpAndSettle();

    final chip = tester.widget<AppChip>(
      find.widgetWithText(AppChip, 'Italian'),
    );
    expect(chip.selected, false);
  });

  testWidgets('submit with an empty title shows the Title is required SnackBar', (
    tester,
  ) async {
    final repo = _RecordingRepo();
    await pumpAddRecipe(tester, repo: repo);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();

    expect(find.text('Title is required'), findsOneWidget);
    //notifier short-circuits before calling the repo
    expect(repo.savedRecipes, isEmpty);
  });

  testWidgets('submit with a valid title calls repo.addRecipe with the form data', (
    tester,
  ) async {
    final repo = _RecordingRepo();
    await pumpAddRecipe(tester, repo: repo);
    await tester.pumpAndSettle();

    //title is the first TextField, prep, cook, servings
    //indexed by posotion
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'My New Recipe');
    await tester.enterText(textFields.at(2), '10');
    await tester.enterText(textFields.at(3), '25');
    await tester.enterText(textFields.at(4), '6');

    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();

    expect(repo.savedRecipes, hasLength(1));
    final saved = repo.savedRecipes.first;
    expect(saved.title, 'My New Recipe');
    expect(saved.prepTimeMins, 10);
    expect(saved.cookingTimeMins, 25);
    expect(saved.servingSize, 6);
    //placeholder id used for new inserts
    expect(saved.recipeId, 0);
  });

  testWidgets('submit forwards the selected cuisine on the saved recipe', (
    tester,
  ) async {
    final repo = _RecordingRepo();
    await pumpAddRecipe(tester, repo: repo);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Italian'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Pasta dish');
    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();

    expect(repo.savedRecipes, hasLength(1));
    expect(repo.savedRecipes.first.cuisineType, 'italian');
  });

  testWidgets('shows the success SnackBar after a successful submit', (
    tester,
  ) async {
    await pumpAddRecipe(tester, repo: _RecordingRepo());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Good recipe');
    await tester.tap(find.text('Save Recipe'));
    //first for ref listen callback, seconder for snackbar into widget tree
    await tester.pump();
    await tester.pump();

    expect(find.text('Recipe saved'), findsOneWidget);
  });

  testWidgets('empty description is sent to repo as null, not an empty string', (
    tester,
  ) async {
    final repo = _RecordingRepo();
    await pumpAddRecipe(tester, repo: repo);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Just a title');
    //leave description
    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();
  //empty string converted to null, description is optional
    expect(repo.savedRecipes.first.description, isNull);
  });
}
