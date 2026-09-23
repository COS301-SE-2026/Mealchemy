import '../../recipe/models/recipe.dart';

abstract class SizzlesRepository {
  Future<List<Recipe>> getSizzles();
}
