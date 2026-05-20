import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/repositories/mock_recipe_repository.dart';

void main() {
  group('MockRecipeRepository.getRecipes', () {
    test('returns the seeded recipes', () async {
      final repository = MockRecipeRepository();

      final recipes = await repository.getRecipes();

      expect(recipes, hasLength(2));
      expect(recipes.first.title, 'Saffron-Infused Risotto');
      expect(recipes.last.title, 'Caprese Pasta Salad');
    });

    test('each returned recipe has its ingredients populated', () async {
      final repository = MockRecipeRepository();

      final recipes = await repository.getRecipes();

      for (final recipe in recipes) {
        expect(recipe.ingredients, isNotNull);
        expect(recipe.ingredients!, isNotEmpty);
      }
    });
  });

  group('MockRecipeRepository.getRecipeById', () {
    test('returns Saffron Risotto with chef info and 5 ingredients for id 1', () async {
      final repository = MockRecipeRepository();

      final recipe = await repository.getRecipeById(1);

      expect(recipe.recipeId, 1);
      expect(recipe.title, 'Saffron-Infused Risotto');
      expect(recipe.cuisineType, 'italian');
      expect(recipe.chefName, 'Chef Isabella V.');
      expect(recipe.rating, 4.8);
      expect(recipe.ingredients, hasLength(5));
      expect(recipe.steps, hasLength(3));
    });

    test('returns Caprese Pasta Salad for id 2', () async {
      final repository = MockRecipeRepository();

      final recipe = await repository.getRecipeById(2);

      expect(recipe.recipeId, 2);
      expect(recipe.title, 'Caprese Pasta Salad');
      expect(recipe.cuisineType, 'italian');
      //caprese has no chef / rating on purpose to verify both code paths
      expect(recipe.chefName, isNull);
      expect(recipe.rating, isNull);
    });

    test('throws StateError when the id is unknown', () async {
      final repository = MockRecipeRepository();

      expect(
        () => repository.getRecipeById(999),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('MockRecipeRepository.addRecipe', () {
    test('completes successfully without mutating the seeded recipes', () async {
      final repository = MockRecipeRepository();
      const newRecipe = Recipe(recipeId: 0, title: 'Brand New Bake');

      //should not throw
      await repository.addRecipe(newRecipe);

      //mock contract: data is NOT saved
      final recipes = await repository.getRecipes();
      expect(recipes, hasLength(2));
      expect(
        recipes.any((r) => r.title == 'Brand New Bake'),
        isFalse,
      );
    });
  });

  group('MockRecipeRepository.getCuisineTypes', () {
    test('returns the 17 cuisine_type_enum values', () async {
      final repository = MockRecipeRepository();

      final cuisines = await repository.getCuisineTypes();

      expect(cuisines, hasLength(17));
    });

    test('includes the values most likely to appear in the UI', () async {
      final repository = MockRecipeRepository();

      final cuisines = await repository.getCuisineTypes();

      expect(cuisines, contains('italian'));
      expect(cuisines, contains('asian'));
      expect(cuisines, contains('mexican'));
      //multi-word value to confirm we kept the snake_case raw form
      expect(cuisines, contains('southeast_asian'));
      expect(cuisines, contains('other'));
    });
  });
}
