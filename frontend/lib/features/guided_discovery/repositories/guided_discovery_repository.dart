import '../models/discovery_recipe.dart';

//used by mock and api data
abstract class GuidedDiscoveryRepository {
  Future<List<DiscoveryRecipe>> getDiscoveryRecipes();
}