import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/providers/api_service_provider.dart';
import '../repositories/api_recipe_photo_repository.dart';
import '../repositories/mock_recipe_photo_repository.dart';
import '../repositories/recipe_photo_repository.dart';
import '../services/recipe_photo_picker.dart';

//provides the photo picker and selects the mock or API repository
final recipePhotoPickerProvider = Provider<RecipePhotoPicker>((ref) {
  return ImagePickerRecipePhotoPicker();
});

final recipePhotoRepositoryProvider = Provider<RecipePhotoRepository>((ref) {
  if (AppConfig.mockRecipe) {
    return MockRecipePhotoRepository();
  }
  return ApiRecipePhotoRepository(ref.read(dioProvider));
});
