import '../models/selected_recipe_video.dart';
import 'recipe_video_repository.dart';

class MockRecipeVideoRepository implements RecipeVideoRepository {
  @override
  Future<String> uploadRecipeVideo({
    required int recipeId,
    required SelectedRecipeVideo video,
  }) async {
    return 'https://storage.googleapis.com/'
        'mealchemy-recipe-videos-staging/recipes/$recipeId/mock.mp4';
  }
}
