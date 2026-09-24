import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/providers/api_service_provider.dart';
import '../repositories/api_recipe_video_repository.dart';
import '../repositories/mock_recipe_video_repository.dart';
import '../repositories/recipe_video_repository.dart';
import '../services/recipe_video_picker.dart';

final recipeVideoPickerProvider = Provider<RecipeVideoPicker>((ref) {
  return ImagePickerRecipeVideoPicker();
});

final recipeVideoRepositoryProvider = Provider<RecipeVideoRepository>((ref) {
  if (AppConfig.mockRecipe) {
    return MockRecipeVideoRepository();
  }
  return ApiRecipeVideoRepository(ref.read(dioProvider));
});
