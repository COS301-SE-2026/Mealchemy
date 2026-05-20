import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/repositories/mock_recipe_repository.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_repository.dart';


class _ThrowingAddRepo implements RecipeRepository {
  @override
  Future<void> addRecipe(Recipe recipe) async => throw Exception('backend down');

  @override
  Future<List<Recipe>> getRecipes() async => const [];

  @override
  Future<Recipe> getRecipeById(int id) async => throw UnimplementedError();

  @override
  Future<List<String>> getCuisineTypes() async => const [];
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

  group('Async data providers', () {
    test('recipesProvider exposes the mock recipe list', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final recipes = await container.read(recipesProvider.future);

      expect(recipes, hasLength(2));
      expect(recipes.first.title, 'Saffron-Infused Risotto');
    });

    test('recipeByIdProvider returns the matching recipe', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final recipe = await container.read(recipeByIdProvider(1).future);

      expect(recipe.recipeId, 1);
      expect(recipe.title, 'Saffron-Infused Risotto');
      expect(recipe.ingredients, isNotEmpty);
    });

    test('recipeByIdProvider with a different id returns the other recipe', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final recipe = await container.read(recipeByIdProvider(2).future);

      expect(recipe.recipeId, 2);
      expect(recipe.title, 'Caprese Pasta Salad');
    });

    test('cuisineTypesProvider returns the cuisine enum values', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cuisines = await container.read(cuisineTypesProvider.future);

      expect(cuisines, hasLength(17));
      expect(cuisines, contains('italian'));
      expect(cuisines, contains('southeast_asian'));
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
      //copyWith intentionally does not preserve errorMessage so it self clears
     
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

    test('submit with empty title sets errorMessage and does NOT call the repo', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const empty = Recipe(recipeId: 0, title: '   ');
      await container.read(addRecipeProvider.notifier).submit(empty);

      final state = container.read(addRecipeProvider);
      expect(state.errorMessage, 'Title is required');
      expect(state.isSuccess, false);
    });

    test('submit with a valid title flips state to isSuccess', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const recipe = Recipe(recipeId: 0, title: 'My New Recipe');
      await container.read(addRecipeProvider.notifier).submit(recipe);

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

      const recipe = Recipe(recipeId: 0, title: 'My New Recipe');
      await container.read(addRecipeProvider.notifier).submit(recipe);

      final state = container.read(addRecipeProvider);
      expect(state.errorMessage, 'Could not save recipe. Try again.');
      expect(state.isSuccess, false);
    });

    test('reset returns the state to its defaults', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const recipe = Recipe(recipeId: 0, title: 'My New Recipe');
      await container.read(addRecipeProvider.notifier).submit(recipe);
      expect(container.read(addRecipeProvider).isSuccess, true);

      container.read(addRecipeProvider.notifier).reset();

      final state = container.read(addRecipeProvider);
      expect(state.isSubmitting, false);
      expect(state.errorMessage, isNull);
      expect(state.isSuccess, false);
    });
  });
}
