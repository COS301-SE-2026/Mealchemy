import '../models/recipe.dart';
import '../models/recipe_step.dart';
import '../models/recipe_ingredient.dart';
import '../models/unit_of_measurement.dart';
//essentially an abstract class/interface

//uses mock/API data
abstract class RecipeRepository {
  Future<List<Recipe>> getRecipes();

  Future<Recipe> getRecipeById(int id);

  //not saved in mock
  Future<Recipe> addRecipe(Recipe recipe, int folderId);
  Future<Recipe> updateRecipe(int id, Recipe recipe);

  //cuisine type enum values
  Future<List<String>> getCuisineTypes();
  Future<void> addRecipeStep(int recipeId, RecipeStep step);
  Future<void> addRecipeIngredient(int recipeId, RecipeIngredient ingredient);
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId);
  Future<List<RecipeStep>> getRecipeSteps(int recipeId);
  Future<List<UnitOfMeasurement>> getUnits();

  //Delete 
  Future<void> deleteRecipe(int recipeId);
}
