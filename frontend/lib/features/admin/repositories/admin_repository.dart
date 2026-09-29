import '../models/admin_models.dart';

abstract class AdminRepository {
  Future<List<FlaggedRecipe>> getFlags({
    FlagStatus status = FlagStatus.pending,
  });

  Future<FlaggedRecipeDetail> getFlagDetail(int flaggedId);

  Future<FlaggedRecipe> dismissFlag(int flaggedId);

  Future<FlaggedRecipe> removeFromCommunity(int flaggedId);

  Future<AdminUserSummary> findUserByEmail(String email);

  Future<AdminUserSummary> promoteUser(int userId);
}
