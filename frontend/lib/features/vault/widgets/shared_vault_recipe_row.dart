import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../recipe/models/recipe.dart';
import '../../recipe/providers/recipe_provider.dart';
import '../../recipe/providers/shared_recipe_edit_provider.dart';
import '../providers/shared_vault_access_provider.dart';
import '../providers/vault_provider.dart';
import 'folder_recipe_row.dart';

class SharedVaultRecipeRow extends ConsumerWidget {
  const SharedVaultRecipeRow({
    super.key,
    required this.vaultId,
    required this.folderId,
    required this.recipe,
    this.onDeleteConfirmed,
  });

  final int vaultId;
  final int folderId;
  final Recipe recipe;
  final VoidCallback? onDeleteConfirmed;

  SharedRecipeContext get _target => (
        vaultId: vaultId,
        folderId: folderId,
        recipeId: recipe.recipeId,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessState = ref.watch(sharedVaultAccessProvider(vaultId));
    final access = accessState.valueOrNull;
    final online = ref.watch(vaultConnectionProvider) == NetworkStatus.online;

    final allowed = !accessState.isLoading &&
        !accessState.hasError &&
        access != null &&
        canEditSharedRecipe(recipe: recipe, access: access);

    return FolderRecipeRow(
      recipe: recipe,
      allowReporting: false,
      mutationsEnabled: online,
      showEditAction: allowed,
      showDeleteAction: allowed && onDeleteConfirmed != null,
      onEditTap: () async {
        final session = ref.read(vaultSessionProvider);

        ref.invalidate(sharedRecipeEditAccessProvider(_target));

        await context.push(sharedRecipeEditLocation(_target));

        if (!context.mounted || ref.read(vaultSessionProvider) != session) {
          return;
        }

        ref.invalidate(sharedVaultAccessProvider(vaultId));
        ref.invalidate(folderRecipesProvider(folderId));
        ref.invalidate(folderRecipeDisplayProvider(folderId));
        ref.invalidate(recipeDetailProvider(recipe.recipeId));
      },
      onDeleteConfirmed: onDeleteConfirmed == null
          ? null
          : () async {
              final session = ref.read(vaultSessionProvider);

              try {
                ref.invalidate(sharedRecipeEditAccessProvider(_target));

                final canDelete = await ref.read(
                  sharedRecipeEditAccessProvider(_target).future,
                );

                if (!context.mounted ||
                    ref.read(vaultSessionProvider) != session) {
                  return;
                }

                if (!canDelete) {
                  throw StateError('Recipe changes are unavailable.');
                }

                onDeleteConfirmed!();
              } catch (_) {
                if (!context.mounted ||
                    ref.read(vaultSessionProvider) != session) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Could not verify permission to delete this recipe.',
                    ),
                  ),
                );
              }
            },
    );
  }
}
