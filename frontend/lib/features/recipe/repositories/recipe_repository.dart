import '../models/recipe.dart';
//essentially an abstract class/interface


//uses mock/API data
abstract class RecipeRepository {
  Future<List<Recipe>> getRecipes();

  Future<Recipe> getRecipeById(int id);

  //not saved in mock
  Future<void> addRecipe(Recipe recipe);

  //cuisine type enum values
  Future<List<String>> getCuisineTypes();
}
