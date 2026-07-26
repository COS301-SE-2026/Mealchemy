import 'package:dio/dio.dart';

import '../models/recipe.dart';
import 'recipe_repository.dart';

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
    final response = await _dio.get('/recipes/$id');
    return Recipe.fromJson(response.data as Map<String, dynamic>);
  }

  //Creates a new full recipe with ingredients and steps
  @override
  Future<void> addRecipe(Recipe recipe) async {
    await _dio.post('/recipes/copy', data: recipe.toFullRequestJson());
  }

  @override
  Future<List<String>> getCuisineTypes() {
    throw UnimplementedError(
      'Recipe API integration has not been implemented yet.',
    );
  }
}
