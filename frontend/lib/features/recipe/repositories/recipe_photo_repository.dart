import '../models/selected_recipe_photo.dart';

//photo upload contract used by mock and API repositories
abstract class RecipePhotoRepository {
  Future<String> uploadRecipePhoto({
    required int recipeId,
    required SelectedRecipePhoto photo,
  });
}
