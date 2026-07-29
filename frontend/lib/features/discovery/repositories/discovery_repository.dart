import 'package:mealchemy/features/recipe/models/recipe.dart';

abstract class DiscoveryRepository {
  Future<List<Recipe>> getPublishedRecipes();
  Future<List<String>> getCuisineTypes();
}