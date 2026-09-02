import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/recipe/repositories/api_recipe_repository.dart';

class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({
        'recipeId': 77,
        'title': 'Updated recipe',
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('full update uses the edit endpoint and sends nested data', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://backend.test'))
      ..httpClientAdapter = adapter;
    final repository = ApiRecipeRepository(dio);
    const recipe = Recipe(
      recipeId: 77,
      title: 'Updated recipe',
      cuisineType: 'italian',
      prepTimeMins: 10,
      cookingTimeMins: 20,
      servingSize: 4,
      ingredients: [
        RecipeIngredient(
          ingId: 5,
          quantity: 2,
          unit: 'g',
          sortOrder: 0,
        ),
      ],
      steps: [
        RecipeStep(stepNr: 1, content: 'Mix'),
      ],
    );

    await repository.updateRecipeFull(77, recipe, removePhoto: true);

    expect(adapter.request!.method, 'PUT');
    expect(adapter.request!.path, '/recipes/edit/77');
    expect(adapter.request!.data['removePhoto'], isTrue);
    expect(adapter.request!.data['photoUrl'], isNull);
    expect(adapter.request!.data['ingredients'], hasLength(1));
    expect(adapter.request!.data['steps'], hasLength(1));
  });
}
