import '../models/recipe_nutrition.dart';

//shared contract for mock data now and nutrition API later
abstract class RecipeNutritionRepository {
  Future<RecipeNutrition> getRecipeNutrition(int recipeId);
}
