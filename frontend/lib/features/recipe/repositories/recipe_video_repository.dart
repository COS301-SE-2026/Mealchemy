import '../models/selected_recipe_video.dart';

abstract class RecipeVideoRepository {
  Future<String> uploadRecipeVideo({
    required int recipeId,
    required SelectedRecipeVideo video,
  });
}
