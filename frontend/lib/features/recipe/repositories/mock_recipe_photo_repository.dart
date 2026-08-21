import '../models/selected_recipe_photo.dart';
import 'recipe_photo_repository.dart';

//returns a photo URL without contacting GCS
class MockRecipePhotoRepository implements RecipePhotoRepository {
  @override
  Future<String> uploadRecipePhoto({
    required int recipeId,
    required SelectedRecipePhoto photo,
  }) async {
    return 'https://storage.googleapis.com/'
        'mealchemy-recipe-photos-staging/recipes/$recipeId/mock.jpg';
  }
}
