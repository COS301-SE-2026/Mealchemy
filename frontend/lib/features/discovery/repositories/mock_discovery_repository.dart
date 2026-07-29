import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/discovery/repositories/discovery_repository.dart';

class MockDiscoveryRepository implements DiscoveryRepository {
  @override
  Future<List<Recipe>> getPublishedRecipes() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      Recipe(recipeId: 1, title: 'Margherita Pizza', cuisineType: 'italian'),
      Recipe(recipeId: 2, title: 'Chicken Tikka Masala', cuisineType: 'indian'),
      Recipe(recipeId: 3, title: 'Beef Tacos', cuisineType: 'mexican'),
      Recipe(recipeId: 4, title: 'Ramen', cuisineType: 'japanese'),
      Recipe(recipeId: 5, title: 'Pad Thai', cuisineType: 'thai'),
      Recipe(recipeId: 6, title: 'Carbonara', cuisineType: 'italian'),
    ];
  }

  @override
  Future<List<String>> getCuisineTypes() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const ['italian', 'indian', 'mexican', 'japanese', 'thai'];
  }
}