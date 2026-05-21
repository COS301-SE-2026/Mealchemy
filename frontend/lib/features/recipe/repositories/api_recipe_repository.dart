import '../models/recipe.dart';
import 'recipe_repository.dart';

//placeholder for api integration
class ApiRecipeRepository implements RecipeRepository {
  @override
  Future<List<Recipe>> getRecipes() {
    throw UnimplementedError(
      'Recipe API integration has not been implemented yet.',
    );
  }

  @override
  Future<Recipe> getRecipeById(int id) {
    throw UnimplementedError(
      'Recipe API integration has not been implemented yet.',
    );
  }

  @override
  Future<void> addRecipe(Recipe recipe) {
    throw UnimplementedError(
      'Recipe API integration has not been implemented yet.',
    );
  }

  @override
  Future<List<String>> getCuisineTypes() {
    throw UnimplementedError(
      'Recipe API integration has not been implemented yet.',
    );
  }
}
