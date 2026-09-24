import '../models/recipe_edit_lock.dart';

abstract class RecipeLockRepository {
  //returns null when backend reports no active lock
  Future<RecipeEditLock?> getLock(int recipeId);

  //acquires a lock or renews the current user's active lock
  Future<RecipeEditLock> acquireLock(int recipeId);

  //releases current user's lock
  Future<void> releaseLock(int recipeId);
}
