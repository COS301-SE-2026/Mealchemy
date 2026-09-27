import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../vault/models/vault.dart';
import '../../vault/models/vault_member.dart';
import '../../vault/providers/shared_vault_access_provider.dart';
import '../../vault/providers/vault_repository_provider.dart';
import '../models/recipe.dart';
import 'recipe_provider.dart';

typedef SharedRecipeContext = ({
  int vaultId,
  int folderId,
  int recipeId,
});

String sharedRecipeEditLocation(SharedRecipeContext target) {
  return Uri(
    path: '/edit-recipe/${target.recipeId}',
    queryParameters: {
      'vaultId': '${target.vaultId}',
      'folderId': '${target.folderId}',
    },
  ).toString();
}

SharedRecipeContext? sharedRecipeContextFromUri(
  Uri uri, {
  required int recipeId,
}) {
  final hasVault = uri.queryParameters.containsKey('vaultId');
  final hasFolder = uri.queryParameters.containsKey('folderId');

  if (!hasVault && !hasFolder) return null;

  final vaultValues = uri.queryParametersAll['vaultId'];
  final folderValues = uri.queryParametersAll['folderId'];

  if (vaultValues == null ||
      folderValues == null ||
      vaultValues.length != 1 ||
      folderValues.length != 1) {
    throw const FormatException('Invalid shared-recipe context.');
  }

  final vaultId = int.tryParse(vaultValues.single);
  final folderId = int.tryParse(folderValues.single);

  if (recipeId <= 0 ||
      vaultId == null ||
      vaultId <= 0 ||
      folderId == null ||
      folderId <= 0) {
    throw const FormatException('Invalid shared-recipe context.');
  }

  return (
    vaultId: vaultId,
    folderId: folderId,
    recipeId: recipeId,
  );
}

bool canEditSharedRecipe({
  required Recipe recipe,
  required SharedVaultAccess access,
}) {
  return access.canManageMembers ||
      access.role == VaultMemberRole.editor ||
      recipe.ownerId == access.currentMember.userId;
}

final sharedRecipeEditAccessProvider =
    FutureProvider.autoDispose.family<bool, SharedRecipeContext>(
  (ref, target) async {
    final session = ref.watch(vaultSessionProvider);
    final connection = ref.watch(vaultConnectionProvider);

    if (session.restoring ||
        !session.hasValidCredential ||
        session.userId == null ||
        session.token == null ||
        connection != NetworkStatus.online) {
      throw StateError('An online signed-in session is required.');
    }

    if (target.vaultId <= 0 || target.folderId <= 0 || target.recipeId <= 0) {
      throw StateError('Invalid shared-recipe context.');
    }

    final vaultRepository = ref.watch(vaultRepositoryProvider);
    final recipeRepository = ref.watch(recipeRepositoryProvider);

    var disposed = false;
    ref.onDispose(() => disposed = true);

    void checkCurrent() {
      if (disposed) {
        throw StateError('The editing session changed.');
      }
    }

    final vault = await vaultRepository.getVaultById(target.vaultId);
    checkCurrent();

    if (vault.vaultId != target.vaultId ||
        vault.vaultType != VaultTypes.shared) {
      throw StateError('Shared vault unavailable.');
    }

    //membership checked through the backend not inferred from ownership of the recipe alone
    final members = await vaultRepository.getMembers(target.vaultId);
    checkCurrent();

    final matches = members
        .where(
          (member) =>
              member.vaultId == target.vaultId &&
              member.userId == session.userId,
        )
        .toList();

    if (matches.length != 1) {
      throw StateError('Shared vault unavailable.');
    }

    final member = matches.single;
    final ownsVault = vault.ownerId == session.userId;

    if (member.isOwner != ownsVault || (member.isOwner && member.id != null)) {
      throw StateError('Inconsistent vault access.');
    }

    final folders = await vaultRepository.getFolders(target.vaultId);
    checkCurrent();

    if (!folders.any(
      (folder) =>
          folder.vaultId == target.vaultId &&
          folder.folderId == target.folderId,
    )) {
      throw StateError('Shared folder unavailable.');
    }

    final associations = await vaultRepository.getFolderRecipes(
      target.folderId,
    );
    checkCurrent();

    if (!associations.any(
      (association) =>
          association.folderId == target.folderId &&
          association.recipeId == target.recipeId,
    )) {
      throw StateError('Recipe is not in this shared folder.');
    }

    final recipe = await recipeRepository.getRecipeById(target.recipeId);
    checkCurrent();

    if (recipe.recipeId != target.recipeId) {
      throw StateError('Unexpected recipe response.');
    }

    return canEditSharedRecipe(
      recipe: recipe,
      access: SharedVaultAccess(
        vault: vault,
        currentMember: member,
        members: members,
      ),
    );
  },
);
