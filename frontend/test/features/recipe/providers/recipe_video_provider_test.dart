import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/constants/app_config.dart';
import 'package:mealchemy/core/providers/api_service_provider.dart';
import 'package:mealchemy/features/recipe/providers/recipe_video_provider.dart';
import 'package:mealchemy/features/recipe/repositories/api_recipe_video_repository.dart';
import 'package:mealchemy/features/recipe/repositories/mock_recipe_video_repository.dart';
import 'package:mealchemy/features/recipe/services/recipe_video_picker.dart';

void main() {
  test('provides the image picker video adapter and configured repository', () {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(Dio()),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(recipeVideoPickerProvider),
      isA<ImagePickerRecipeVideoPicker>(),
    );

    final repository = container.read(recipeVideoRepositoryProvider);
    if (AppConfig.mockRecipe) {
      expect(repository, isA<MockRecipeVideoRepository>());
    } else {
      expect(repository, isA<ApiRecipeVideoRepository>());
    }
  });
}
