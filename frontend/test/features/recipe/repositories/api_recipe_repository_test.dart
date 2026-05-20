import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/repositories/api_recipe_repository.dart';

void main() {
  test('ApiRecipeRepository throws for getRecipes until the API is implemented', () {
    final repository = ApiRecipeRepository();

    expect(repository.getRecipes, throwsA(isA<UnimplementedError>()));
  });

  test('ApiRecipeRepository throws for getRecipeById until the API is implemented', () {
    final repository = ApiRecipeRepository();

    expect(
      () => repository.getRecipeById(1),
      throwsA(isA<UnimplementedError>()),
    );
  });

  test('ApiRecipeRepository throws for addRecipe until the API is implemented', () {
    final repository = ApiRecipeRepository();
    const recipe = Recipe(recipeId: 0, title: 'New Recipe');

    expect(
      () => repository.addRecipe(recipe),
      throwsA(isA<UnimplementedError>()),
    );
  });

  test('ApiRecipeRepository throws for getCuisineTypes until the API is implemented', () {
    final repository = ApiRecipeRepository();

    expect(repository.getCuisineTypes, throwsA(isA<UnimplementedError>()));
  });
}
