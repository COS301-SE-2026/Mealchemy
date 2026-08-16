import 'package:dio/dio.dart';

import '../models/recipe.dart';
import 'recipe_repository.dart';
import '../models/recipe_step.dart';
import '../models/recipe_ingredient.dart';
import '../models/unit_of_measurement.dart';

//placeholder for api integration
class ApiRecipeRepository implements RecipeRepository {
  final Dio _dio;
  ApiRecipeRepository(this._dio);

  //Get all recipes from the API
  @override
  Future<List<Recipe>> getRecipes() async {
    final response = await _dio.get('/recipes/all');
    final data = response.data as List<dynamic>;
    return data.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
  }

  //Get a single recipe by ID
  @override
  Future<Recipe> getRecipeById(int id) async {
    final response = await _dio.get('/recipes/single/$id');
    return Recipe.fromJson(response.data as Map<String, dynamic>);
  }

  //Create the recipe with (metadata only) returns the new recipe with its id
  @override
  Future<Recipe> addRecipe(Recipe recipe, int folderId) async {
    final response = await _dio.post('/recipes/create', data: {
      ...recipe.toCreateRequestJson(),
      'folderId': folderId,
    });
    return Recipe.fromJson(response.data as Map<String, dynamic>);
  }

// Updates the recipe
  @override
  Future<Recipe> updateRecipeFull(int id, Recipe recipe) async {
    final response =
        await _dio.put('/recipes/$id/full', data: recipe.toFullRequestJson());
    return Recipe.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<String>> getCuisineTypes() async {
    final response = await _dio.get('/flavourprofileoptions/all');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => (e as Map<String, dynamic>)['value'] as String)
        .toList();
  }

  @override
  Future<void> addRecipeStep(int recipeId, RecipeStep step) async {
    await _dio.post(
      '/steps/recipe/$recipeId/step/create',
      data: step.toJson(),
    );
  }

  @override
  Future<void> addRecipeIngredient(
      int recipeId, RecipeIngredient ingredient) async {
    await _dio.post(
      '/ingredients/recipe/$recipeId/ingredient/create',
      data: ingredient.toJson(),
    );
  }

  @override
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) async {
    final response = await _dio.get('/ingredients/recipe/$recipeId');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RecipeStep>> getRecipeSteps(int recipeId) async {
    final response = await _dio.get('/steps/recipe/$recipeId');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<UnitOfMeasurement>> getUnits() async {
    final response = await _dio.get('/api/units-of-measurement');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => UnitOfMeasurement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deleteRecipe(int recipeId) async {
    await _dio.delete('/recipes/delete/$recipeId');
  }
}
