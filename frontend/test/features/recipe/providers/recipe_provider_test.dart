import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/repositories/mock_recipe_repository.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_repository.dart';


const _validRecipe = Recipe(
  recipeId: 0,
  title: 'My New Recipe',
  cuisineType: 'italian',
  prepTimeMins: 10,
  cookingTimeMins: 20,
  servingSize: 4,
);

// repo whose addRecipe throws; implements the full current interface
class _ThrowingAddRepo implements RecipeRepository {
  @override
  Future<Recipe> addRecipe(Recipe recipe) async =>
      throw Exception('backend down');

  @override
  Future<Recipe> updateRecipe(int id, Recipe recipe) async =>
      throw UnimplementedError();

  @override
  Future<List<Recipe>> getRecipes() async => const [];

  @override
  Future<Recipe> getRecipeById(int id) async => throw UnimplementedError();

  @override
  Future<List<String>> getCuisineTypes() async => const [];

  @override
  Future<void> addRecipeIngredient(int recipeId, RecipeIngredient ingredient) async {}

  @override
  Future<void> addRecipeStep(int recipeId, RecipeStep step) async {}

  @override
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) async => const [];

  @override
  Future<List<RecipeStep>> getRecipeSteps(int recipeId) async => const [];
}

void main() {
  group('recipeRepositoryProvider', () {
    test('returns MockRecipeRepository while AppConfig.useMockData is true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final repository = container.read(recipeRepositoryProvider);
      expect(repository, isA<MockRecipeRepository>());
    });
  });

  group('AddRecipeState', () {
    test('default values are non-submitting, no error, not successful', () {
      const state = AddRecipeState();
      expect(state.isSubmitting, false);
      expect(state.errorMessage, isNull);
      expect(state.isSuccess, false);
    });

    test('copyWith overrides only the fields passed', () {
      const state = AddRecipeState();
      final next = state.copyWith(isSubmitting: true);
      expect(next.isSubmitting, true);
      expect(next.isSuccess, false);
    });

    test('copyWith clears errorMessage when not provided', () {

      const seeded = AddRecipeState(errorMessage: 'old error');
      final next = seeded.copyWith(isSubmitting: true);
      expect(next.errorMessage, isNull);
    });
  });

  group('AddRecipeNotifier', () {
    test('starts in the default state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(addRecipeProvider);
      expect(state.isSubmitting, false);
      expect(state.errorMessage, isNull);
      expect(state.isSuccess, false);
    });

    test('submit with missing required fields sets errorMessage and returns null', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // only a title cuisine, times, servings all missing
      const incomplete = Recipe(recipeId: 0, title: 'Just a title');
      final result =
          await container.read(addRecipeProvider.notifier).submit(incomplete);

      expect(result, isNull);
      final state = container.read(addRecipeProvider);
      expect(state.errorMessage, 'Please fill in all required fields.');
      expect(state.isSuccess, false);
    });

    test('submit with a fully valid recipe flips state to isSuccess and returns the recipe', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result =
          await container.read(addRecipeProvider.notifier).submit(_validRecipe);

      expect(result, isNotNull);
      final state = container.read(addRecipeProvider);
      expect(state.isSuccess, true);
      expect(state.errorMessage, isNull);
      expect(state.isSubmitting, false);
    });

    test('submit sets a generic error message when the repo throws', () async {
      final container = ProviderContainer(
        overrides: [
          recipeRepositoryProvider.overrideWithValue(_ThrowingAddRepo()),
        ],
      );
      addTearDown(container.dispose);

      final result =
          await container.read(addRecipeProvider.notifier).submit(_validRecipe);

      expect(result, isNull);
      final state = container.read(addRecipeProvider);
      expect(state.errorMessage, 'Could not save recipe. Try again.');
      expect(state.isSuccess, false);
    });

    test('reset returns the state to its defaults', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(addRecipeProvider.notifier).submit(_validRecipe);
      expect(container.read(addRecipeProvider).isSuccess, true);

      container.read(addRecipeProvider.notifier).reset();
      final state = container.read(addRecipeProvider);
      expect(state.isSubmitting, false);
      expect(state.errorMessage, isNull);
      expect(state.isSuccess, false);
    });
  });
}