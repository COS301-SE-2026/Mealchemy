import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/recipe/models/unit_of_measurement.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_repository.dart';
import 'package:mealchemy/features/recipe/screens/add_recipe_screen.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/models/vault_folder_recipe.dart';
import 'package:mealchemy/features/vault/providers/vault_repository_provider.dart';
import 'package:mealchemy/features/vault/repositories/vault_repository.dart';


class _RecordingRepo implements RecipeRepository {
  final List<Recipe> savedRecipes = [];
  final List<int> savedFolderIds = [];

  @override
  Future<Recipe> addRecipe(Recipe recipe, int folderId) async {
    savedRecipes.add(recipe);
    savedFolderIds.add(folderId);
    return Recipe(
      recipeId: 501,
      title: recipe.title,
      description: recipe.description,
      cuisineType: recipe.cuisineType,
      prepTimeMins: recipe.prepTimeMins,
      cookingTimeMins: recipe.cookingTimeMins,
      servingSize: recipe.servingSize,
      isCommunityPublished: recipe.isCommunityPublished,
    );
  }

  @override
  Future<Recipe> updateRecipe(int id, Recipe recipe) async => recipe;

  @override
  Future<List<Recipe>> getRecipes() async => const [];

  @override
  Future<Recipe> getRecipeById(int id) async => throw UnimplementedError();

  @override
  Future<List<String>> getCuisineTypes() async =>
      const ['italian', 'asian', 'mexican'];

  @override
  Future<List<UnitOfMeasurement>> getUnits() async => const [
        UnitOfMeasurement(unitId: 1, name: 'g', system: 'METRIC'),
        UnitOfMeasurement(unitId: 2, name: 'tbsp', system: null),
      ];

  @override
  Future<void> addRecipeIngredient(int recipeId, RecipeIngredient i) async {}

  @override
  Future<void> addRecipeStep(int recipeId, RecipeStep s) async {}

  @override
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) async =>
      const [];

  @override
  Future<List<RecipeStep>> getRecipeSteps(int recipeId) async => const [];
}

class _SlowCuisinesRepo extends _RecordingRepo {
  final _completer = Completer<List<String>>();
  @override
  Future<List<String>> getCuisineTypes() => _completer.future;
}

class _ThrowingCuisinesRepo extends _RecordingRepo {
  @override
  Future<List<String>> getCuisineTypes() async => throw Exception('boom');
}


class _FakeVaultRepo implements VaultRepository {
  @override
  Future<List<Vault>> getMyVaults() async => [
        Vault(
          vaultId: 1,
          vaultType: VaultTypes.private,
          name: 'My Vault',
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

  @override
  Future<List<VaultFolder>> getFolders(int vaultId) async => [
        VaultFolder(
          folderId: 10,
          vaultId: 1,
          folderName: 'My Recipes',
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

  @override
  Future<VaultFolderRecipe> addRecipeToFolder(
      int folderId, int recipeId) async {
    return VaultFolderRecipe(
      id: 1,
      folderId: folderId,
      recipeId: recipeId,
      addedAt: DateTime(2026, 1, 1),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host({
    required RecipeRepository recipeRepo,
    VaultRepository? vaultRepo,
  }) {
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
      overrides: [
        recipeRepositoryProvider.overrideWithValue(recipeRepo),
        vaultRepositoryProvider
            .overrideWithValue(vaultRepo ?? _FakeVaultRepo()),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> pumpAddRecipe(
    WidgetTester tester, {
    required RecipeRepository recipeRepo,
    VaultRepository? vaultRepo,
  }) async {
    tester.view.physicalSize = const Size(414, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(host(recipeRepo: recipeRepo, vaultRepo: vaultRepo));
  }

  Future<void> tapCreateRecipe(WidgetTester tester) async {
    await tester.tap(find.text('Create Recipe').last);
    await tester.pumpAndSettle();
  }

  testWidgets('shows a loading indicator while cuisines are loading',
      (tester) async {
    await pumpAddRecipe(tester, recipeRepo: _SlowCuisinesRepo());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error widget when cuisines fail to load',
      (tester) async {
    await pumpAddRecipe(tester, recipeRepo: _ThrowingCuisinesRepo());
    await tester.pumpAndSettle();
    expect(find.text('Unable to load form data.'), findsOneWidget);
  });

  testWidgets('renders the header, section titles and CTAs', (tester) async {
    await pumpAddRecipe(tester, recipeRepo: _RecordingRepo());
    await tester.pumpAndSettle();

    expect(find.text('Create Recipe'), findsWidgets); 
    expect(find.text('Recipe Details'), findsOneWidget);
    expect(find.text('Time & Servings'), findsOneWidget);
    expect(find.text('Save To'), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Preparation Steps'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('submit with missing required fields shows per-field errors',
      (tester) async {
    final repo = _RecordingRepo();
    await pumpAddRecipe(tester, recipeRepo: repo);
    await tester.pumpAndSettle();

    await tapCreateRecipe(tester);

    expect(find.text('Title is required.'), findsOneWidget);
    expect(find.text('Cuisine is required.'), findsOneWidget);
    expect(find.text('Prep, cook, and servings are all required.'),
        findsOneWidget);
    expect(repo.savedRecipes, isEmpty); 
  });

  testWidgets('a fully valid form saves the recipe with the entered values',
      (tester) async {
    final repo = _RecordingRepo();
    await pumpAddRecipe(tester, recipeRepo: repo);
    await tester.pumpAndSettle();

    
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'My New Recipe');
    await tester.enterText(fields.at(2), '10');
    await tester.enterText(fields.at(3), '25');
    await tester.enterText(fields.at(4), '6');

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Italian').last);
    await tester.pumpAndSettle();

    await tapCreateRecipe(tester);

    expect(repo.savedRecipes, hasLength(1));
    final saved = repo.savedRecipes.first;
    expect(saved.title, 'My New Recipe');
    expect(saved.cuisineType, 'italian');
    expect(saved.prepTimeMins, 10);
    expect(saved.cookingTimeMins, 25);
    expect(saved.servingSize, 6);
    expect(saved.recipeId, 0); 
    expect(saved.isCommunityPublished, isFalse); 
    expect(repo.savedFolderIds, [10]);
  });

  testWidgets('empty description is sent as null, not an empty string',
      (tester) async {
    final repo = _RecordingRepo();
    await pumpAddRecipe(tester, recipeRepo: repo);
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Just a title');
    await tester.enterText(fields.at(2), '5');
    await tester.enterText(fields.at(3), '5');
    await tester.enterText(fields.at(4), '2');
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Asian').last);
    await tester.pumpAndSettle();

    await tapCreateRecipe(tester);

    expect(repo.savedRecipes.first.description, isNull);
  });
}