import 'package:drift/drift.dart';

import '../../recipe/models/recipe.dart';
import '../../recipe/models/recipe_ingredient.dart';
import '../../recipe/models/recipe_step.dart';
import '../../vault/models/vault.dart';
import '../../vault/models/vault_folder.dart';
import '../../vault/models/vault_folder_recipe.dart';
import 'offline_cache_database.dart';

class OfflineCacheStore {
  OfflineCacheStore(this._database);

  final OfflineCacheDatabase _database;

  Future<List<Vault>> readVaults({required int viewerUserId}) async {
    final query = _database.select(_database.cachedVaultRows)
      ..where((row) => row.viewerUserId.equals(viewerUserId));
    final rows = await query.get();
    return rows
        .map(
          (row) => Vault(
            vaultId: row.vaultId,
            ownerId: row.ownerId,
            vaultType: row.vaultType,
            name: row.name,
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }

  Future<Vault?> readVault({
    required int viewerUserId,
    required int vaultId,
  }) async {
    final row = await (_database.select(_database.cachedVaultRows)
          ..where(
            (row) =>
                row.viewerUserId.equals(viewerUserId) &
                row.vaultId.equals(vaultId),
          ))
        .getSingleOrNull();
    if (row == null) return null;
    return Vault(
      vaultId: row.vaultId,
      ownerId: row.ownerId,
      vaultType: row.vaultType,
      name: row.name,
      createdAt: row.createdAt,
    );
  }

  Future<void> replaceVaultsFromCompleteFetch({
    required int viewerUserId,
    required List<Vault> vaults,
    required DateTime syncedAt,
  }) {
    return _database.transaction(() async {
      final previous = await (_database.select(_database.cachedVaultRows)
            ..where((row) => row.viewerUserId.equals(viewerUserId)))
          .get();
      final incomingIds = vaults.map((vault) => vault.vaultId).toSet();
      final removedIds = previous
          .map((vault) => vault.vaultId)
          .where((id) => !incomingIds.contains(id))
          .toSet();

      if (removedIds.isNotEmpty) {
        final removedFolders =
            await (_database.select(_database.cachedVaultFolderRows)
                  ..where(
                    (row) =>
                        row.viewerUserId.equals(viewerUserId) &
                        row.vaultId.isIn(removedIds),
                  ))
                .get();
        final removedFolderIds =
            removedFolders.map((folder) => folder.folderId).toSet();
        if (removedFolderIds.isNotEmpty) {
          await (_database.delete(_database.cachedVaultFolderRecipeRows)
                ..where(
                  (row) =>
                      row.viewerUserId.equals(viewerUserId) &
                      row.folderId.isIn(removedFolderIds),
                ))
              .go();
        }
        await (_database.delete(_database.cachedVaultFolderRows)
              ..where(
                (row) =>
                    row.viewerUserId.equals(viewerUserId) &
                    row.vaultId.isIn(removedIds),
              ))
            .go();
        await (_database.delete(_database.cachedVaultRows)
              ..where(
                (row) =>
                    row.viewerUserId.equals(viewerUserId) &
                    row.vaultId.isIn(removedIds),
              ))
            .go();
      }

      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.cachedVaultRows,
          vaults
              .map(
                (vault) => CachedVaultRowsCompanion.insert(
                  viewerUserId: viewerUserId,
                  vaultId: vault.vaultId,
                  ownerId: Value(vault.ownerId),
                  vaultType: vault.vaultType,
                  name: vault.name,
                  createdAt: vault.createdAt,
                ),
              )
              .toList(),
        );
      });
      await writeSyncMetadata(
        viewerUserId: viewerUserId,
        collection: CacheCollection.vaults,
        scopeId: CacheScope.all,
        syncedAt: syncedAt,
      );
    });
  }

  Future<List<VaultFolder>> readFolders({
    required int viewerUserId,
    required int vaultId,
  }) async {
    final query = _database.select(_database.cachedVaultFolderRows)
      ..where(
        (row) =>
            row.viewerUserId.equals(viewerUserId) & row.vaultId.equals(vaultId),
      );
    final rows = await query.get();
    return rows
        .map(
          (row) => VaultFolder(
            folderId: row.folderId,
            vaultId: row.vaultId,
            folderName: row.folderName,
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }

  Future<void> replaceFoldersFromCompleteFetch({
    required int viewerUserId,
    required int vaultId,
    required List<VaultFolder> folders,
    required DateTime syncedAt,
  }) {
    return _database.transaction(() async {
      final previous = await (_database.select(_database.cachedVaultFolderRows)
            ..where(
              (row) =>
                  row.viewerUserId.equals(viewerUserId) &
                  row.vaultId.equals(vaultId),
            ))
          .get();
      final incomingIds = folders.map((folder) => folder.folderId).toSet();
      final removedIds = previous
          .map((folder) => folder.folderId)
          .where((id) => !incomingIds.contains(id))
          .toSet();

      if (removedIds.isNotEmpty) {
        await (_database.delete(_database.cachedVaultFolderRecipeRows)
              ..where(
                (row) =>
                    row.viewerUserId.equals(viewerUserId) &
                    row.folderId.isIn(removedIds),
              ))
            .go();
        await (_database.delete(_database.cachedVaultFolderRows)
              ..where(
                (row) =>
                    row.viewerUserId.equals(viewerUserId) &
                    row.folderId.isIn(removedIds),
              ))
            .go();
      }

      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.cachedVaultFolderRows,
          folders
              .map(
                (folder) => CachedVaultFolderRowsCompanion.insert(
                  viewerUserId: viewerUserId,
                  folderId: folder.folderId,
                  vaultId: folder.vaultId,
                  folderName: folder.folderName,
                  createdAt: folder.createdAt,
                ),
              )
              .toList(),
        );
      });
      await writeSyncMetadata(
        viewerUserId: viewerUserId,
        collection: CacheCollection.folders,
        scopeId: vaultId.toString(),
        syncedAt: syncedAt,
      );
    });
  }

  Future<List<VaultFolderRecipe>> readFolderRecipes({
    required int viewerUserId,
    required int folderId,
  }) async {
    final query = _database.select(_database.cachedVaultFolderRecipeRows)
      ..where(
        (row) =>
            row.viewerUserId.equals(viewerUserId) &
            row.folderId.equals(folderId),
      );
    final rows = await query.get();
    return rows
        .map(
          (row) => VaultFolderRecipe(
            id: row.folderRecipeId,
            folderId: row.folderId,
            recipeId: row.recipeId,
            addedAt: row.addedAt,
            addedByUserId: row.addedByUserId,
          ),
        )
        .toList();
  }

  Future<void> replaceFolderRecipesFromCompleteFetch({
    required int viewerUserId,
    required int folderId,
    required List<VaultFolderRecipe> folderRecipes,
    required DateTime syncedAt,
  }) {
    return _database.transaction(() async {
      await (_database.delete(_database.cachedVaultFolderRecipeRows)
            ..where(
              (row) =>
                  row.viewerUserId.equals(viewerUserId) &
                  row.folderId.equals(folderId),
            ))
          .go();
      await _database.batch((batch) {
        batch.insertAll(
          _database.cachedVaultFolderRecipeRows,
          folderRecipes
              .map(
                (entry) => CachedVaultFolderRecipeRowsCompanion.insert(
                  viewerUserId: viewerUserId,
                  folderRecipeId: entry.id,
                  folderId: entry.folderId,
                  recipeId: entry.recipeId,
                  addedAt: entry.addedAt,
                  addedByUserId: Value(entry.addedByUserId),
                ),
              )
              .toList(),
        );
      });
      await writeSyncMetadata(
        viewerUserId: viewerUserId,
        collection: CacheCollection.folderRecipes,
        scopeId: folderId.toString(),
        syncedAt: syncedAt,
      );
    });
  }

  Future<Recipe?> readCompleteRecipe({
    required int viewerUserId,
    required int recipeId,
  }) async {
    final recipeRow = await (_database.select(_database.cachedRecipeRows)
          ..where(
            (row) =>
                row.viewerUserId.equals(viewerUserId) &
                row.recipeId.equals(recipeId) &
                row.isComplete.equals(true),
          ))
        .getSingleOrNull();
    if (recipeRow == null) return null;

    final ingredientRows =
        await (_database.select(_database.cachedRecipeIngredientRows)
              ..where(
                (row) =>
                    row.viewerUserId.equals(viewerUserId) &
                    row.recipeId.equals(recipeId),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.lineIndex)]))
            .get();
    final stepRows = await (_database.select(_database.cachedRecipeStepRows)
          ..where(
            (row) =>
                row.viewerUserId.equals(viewerUserId) &
                row.recipeId.equals(recipeId),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.lineIndex)]))
        .get();

    return Recipe(
      recipeId: recipeRow.recipeId,
      ownerId: recipeRow.ownerId,
      title: recipeRow.title,
      description: recipeRow.description,
      cuisineType: recipeRow.cuisineType,
      prepTimeMins: recipeRow.prepTimeMins,
      cookingTimeMins: recipeRow.cookingTimeMins,
      servingSize: recipeRow.servingSize,
      photoUrl: recipeRow.photoUrl,
      videoUrl: recipeRow.videoUrl,
      externalUrl: recipeRow.externalUrl,
      isCommunityPublished: recipeRow.isCommunityPublished,
      createdAt: recipeRow.createdAt,
      updatedAt: recipeRow.updatedAt,
      ingredients: ingredientRows
          .map(
            (row) => RecipeIngredient(
              ingredientId: row.ingredientId,
              recipeId: row.recipeId,
              ingId: row.ingId,
              name: row.name,
              quantity: row.quantity,
              unit: row.unit,
              sortOrder: row.sortOrder,
            ),
          )
          .toList(),
      steps: stepRows
          .map(
            (row) => RecipeStep(
              stepId: row.stepId,
              recipeId: row.recipeId,
              stepNr: row.stepNr,
              content: row.content,
            ),
          )
          .toList(),
    );
  }

  Future<List<Recipe>> readRecipes({required int viewerUserId}) async {
    final query = _database.select(_database.cachedRecipeRows)
      ..where((row) => row.viewerUserId.equals(viewerUserId))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);
    final rows = await query.get();
    return rows.map(_recipeSummaryFromRow).toList();
  }

  Future<void> replaceRecipeSummariesFromCompleteFetch({
    required int viewerUserId,
    required List<Recipe> recipes,
    required DateTime syncedAt,
  }) {
    return _database.transaction(() async {
      final previous = await (_database.select(_database.cachedRecipeRows)
            ..where((row) => row.viewerUserId.equals(viewerUserId)))
          .get();
      final incomingIds = recipes.map((recipe) => recipe.recipeId).toSet();
      final removedIds = previous
          .map((recipe) => recipe.recipeId)
          .where((id) => !incomingIds.contains(id))
          .toSet();

      if (removedIds.isNotEmpty) {
        await (_database.delete(_database.cachedRecipeIngredientRows)
              ..where(
                (row) =>
                    row.viewerUserId.equals(viewerUserId) &
                    row.recipeId.isIn(removedIds),
              ))
            .go();
        await (_database.delete(_database.cachedRecipeStepRows)
              ..where(
                (row) =>
                    row.viewerUserId.equals(viewerUserId) &
                    row.recipeId.isIn(removedIds),
              ))
            .go();
        await (_database.delete(_database.cachedRecipeRows)
              ..where(
                (row) =>
                    row.viewerUserId.equals(viewerUserId) &
                    row.recipeId.isIn(removedIds),
              ))
            .go();
      }

      for (final recipe in recipes) {
        final existing = previous
            .where((row) => row.recipeId == recipe.recipeId)
            .firstOrNull;
        await _database.into(_database.cachedRecipeRows).insertOnConflictUpdate(
              _recipeCompanion(
                viewerUserId: viewerUserId,
                recipe: recipe,
                isComplete: existing?.isComplete ?? false,
              ),
            );
      }
      await writeSyncMetadata(
        viewerUserId: viewerUserId,
        collection: CacheCollection.recipes,
        scopeId: CacheScope.all,
        syncedAt: syncedAt,
      );
    });
  }

  Future<void> storeCompleteRecipe({
    required int viewerUserId,
    required Recipe recipe,
    required DateTime syncedAt,
  }) async {
    final ingredients = recipe.ingredients;
    final steps = recipe.steps;
    if (ingredients == null || steps == null) {
      throw ArgumentError(
        'A recipe must be fully assembled before it can be cached.',
      );
    }

    await _database.transaction(() async {
      await _database.into(_database.cachedRecipeRows).insertOnConflictUpdate(
            _recipeCompanion(
              viewerUserId: viewerUserId,
              recipe: recipe,
              isComplete: true,
            ),
          );
      await (_database.delete(_database.cachedRecipeIngredientRows)
            ..where(
              (row) =>
                  row.viewerUserId.equals(viewerUserId) &
                  row.recipeId.equals(recipe.recipeId),
            ))
          .go();
      await (_database.delete(_database.cachedRecipeStepRows)
            ..where(
              (row) =>
                  row.viewerUserId.equals(viewerUserId) &
                  row.recipeId.equals(recipe.recipeId),
            ))
          .go();

      await _database.batch((batch) {
        batch.insertAll(
          _database.cachedRecipeIngredientRows,
          [
            for (var index = 0; index < ingredients.length; index++)
              CachedRecipeIngredientRowsCompanion.insert(
                viewerUserId: viewerUserId,
                recipeId: recipe.recipeId,
                lineIndex: index,
                ingredientId: Value(ingredients[index].ingredientId),
                ingId: ingredients[index].ingId,
                name: Value(ingredients[index].name),
                quantity: Value(ingredients[index].quantity),
                unit: Value(ingredients[index].unit),
                sortOrder: ingredients[index].sortOrder,
              ),
          ],
        );
        batch.insertAll(
          _database.cachedRecipeStepRows,
          [
            for (var index = 0; index < steps.length; index++)
              CachedRecipeStepRowsCompanion.insert(
                viewerUserId: viewerUserId,
                recipeId: recipe.recipeId,
                lineIndex: index,
                stepId: Value(steps[index].stepId),
                stepNr: steps[index].stepNr,
                content: steps[index].content,
              ),
          ],
        );
      });
      await writeSyncMetadata(
        viewerUserId: viewerUserId,
        collection: CacheCollection.recipe,
        scopeId: recipe.recipeId.toString(),
        syncedAt: syncedAt,
      );
    });
  }

  Future<CacheSyncMetadataRow?> readSyncMetadata({
    required int viewerUserId,
    required String collection,
    required String scopeId,
  }) {
    return (_database.select(_database.cacheSyncMetadataRows)
          ..where(
            (row) =>
                row.viewerUserId.equals(viewerUserId) &
                row.collection.equals(collection) &
                row.scopeId.equals(scopeId),
          ))
        .getSingleOrNull();
  }

  Future<void> writeSyncMetadata({
    required int viewerUserId,
    required String collection,
    required String scopeId,
    required DateTime syncedAt,
  }) {
    return _database
        .into(_database.cacheSyncMetadataRows)
        .insertOnConflictUpdate(
          CacheSyncMetadataRowsCompanion.insert(
            viewerUserId: viewerUserId,
            collection: collection,
            scopeId: scopeId,
            lastSyncedAt: syncedAt,
          ),
        );
  }

  CachedRecipeRowsCompanion _recipeCompanion({
    required int viewerUserId,
    required Recipe recipe,
    required bool isComplete,
  }) {
    return CachedRecipeRowsCompanion.insert(
      viewerUserId: viewerUserId,
      recipeId: recipe.recipeId,
      ownerId: Value(recipe.ownerId),
      title: recipe.title,
      description: Value(recipe.description),
      cuisineType: Value(recipe.cuisineType),
      prepTimeMins: Value(recipe.prepTimeMins),
      cookingTimeMins: Value(recipe.cookingTimeMins),
      servingSize: Value(recipe.servingSize),
      photoUrl: Value(recipe.photoUrl),
      videoUrl: Value(recipe.videoUrl),
      externalUrl: Value(recipe.externalUrl),
      isCommunityPublished: recipe.isCommunityPublished,
      createdAt: Value(recipe.createdAt),
      updatedAt: Value(recipe.updatedAt),
      isComplete: Value(isComplete),
    );
  }

  Recipe _recipeSummaryFromRow(CachedRecipeRow row) {
    return Recipe(
      recipeId: row.recipeId,
      ownerId: row.ownerId,
      title: row.title,
      description: row.description,
      cuisineType: row.cuisineType,
      prepTimeMins: row.prepTimeMins,
      cookingTimeMins: row.cookingTimeMins,
      servingSize: row.servingSize,
      photoUrl: row.photoUrl,
      videoUrl: row.videoUrl,
      externalUrl: row.externalUrl,
      isCommunityPublished: row.isCommunityPublished,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

abstract final class CacheCollection {
  static const vaults = 'vaults';
  static const folders = 'folders';
  static const folderRecipes = 'folderRecipes';
  static const recipes = 'recipes';
  static const recipe = 'recipe';
  static const pantry = 'pantry';
  static const shoppingLists = 'shoppingLists';
  static const shoppingList = 'shoppingList';
}

abstract final class CacheScope {
  static const all = 'all';
}
