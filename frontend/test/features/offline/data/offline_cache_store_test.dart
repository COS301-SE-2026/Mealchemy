import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/offline/data/offline_cache_database.dart';
import 'package:mealchemy/features/offline/data/offline_cache_store.dart';
import 'package:mealchemy/features/recipe/models/equipment.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/models/recipe_nutrition.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';

void main() {
  late OfflineCacheDatabase database;
  late OfflineCacheStore store;

  setUp(() {
    database = OfflineCacheDatabase(NativeDatabase.memory());
    store = OfflineCacheStore(database);
  });

  tearDown(() => database.close());

  test('the same remote id remains isolated between viewer namespaces',
      () async {
    final syncedAt = DateTime.utc(2026, 8, 29);
    await store.replaceVaultsFromCompleteFetch(
      viewerUserId: 1,
      vaults: [_vault(7, 'User one view')],
      syncedAt: syncedAt,
    );
    await store.replaceVaultsFromCompleteFetch(
      viewerUserId: 2,
      vaults: [_vault(7, 'User two view')],
      syncedAt: syncedAt,
    );

    expect(
        (await store.readVaults(viewerUserId: 1)).single.name, 'User one view');
    expect(
        (await store.readVaults(viewerUserId: 2)).single.name, 'User two view');
  });

  test('complete reconciliation only removes rows in its viewer and scope',
      () async {
    final syncedAt = DateTime.utc(2026, 8, 29);
    await store.replaceFoldersFromCompleteFetch(
      viewerUserId: 1,
      vaultId: 10,
      folders: [_folder(100, 10, 'Old A')],
      syncedAt: syncedAt,
    );
    await store.replaceFoldersFromCompleteFetch(
      viewerUserId: 1,
      vaultId: 20,
      folders: [_folder(200, 20, 'Keep B')],
      syncedAt: syncedAt,
    );

    await store.replaceFoldersFromCompleteFetch(
      viewerUserId: 1,
      vaultId: 10,
      folders: const [],
      syncedAt: syncedAt.add(const Duration(minutes: 1)),
    );

    expect(
      await store.readFolders(viewerUserId: 1, vaultId: 10),
      isEmpty,
    );
    expect(
      (await store.readFolders(viewerUserId: 1, vaultId: 20)).single.folderName,
      'Keep B',
    );
  });

  test('incomplete assembly cannot overwrite a complete cached recipe',
      () async {
    final syncedAt = DateTime.utc(2026, 8, 29);
    await store.storeCompleteRecipe(
      viewerUserId: 1,
      recipe: _completeRecipe('Cached complete recipe'),
      syncedAt: syncedAt,
    );

    await expectLater(
      store.storeCompleteRecipe(
        viewerUserId: 1,
        recipe: const Recipe(recipeId: 42, title: 'Partial response'),
        syncedAt: syncedAt.add(const Duration(minutes: 1)),
      ),
      throwsArgumentError,
    );

    final cached =
        await store.readCompleteRecipe(viewerUserId: 1, recipeId: 42);
    expect(cached?.title, 'Cached complete recipe');
    expect(cached?.ingredients, hasLength(1));
    expect(cached?.steps, hasLength(1));
    expect(cached?.equipment?.single.label, 'Mixing bowl');
  });

  test('sync metadata is independent per collection and scope', () async {
    final vaultSync = DateTime.utc(2026, 8, 29, 8);
    final recipeSync = DateTime.utc(2026, 8, 26, 8);
    await store.replaceVaultsFromCompleteFetch(
      viewerUserId: 1,
      vaults: [_vault(7, 'Vault')],
      syncedAt: vaultSync,
    );
    await store.storeCompleteRecipe(
      viewerUserId: 1,
      recipe: _completeRecipe('Recipe'),
      syncedAt: recipeSync,
    );
    await store.readVaults(viewerUserId: 1);

    final vaultMetadata = await store.readSyncMetadata(
      viewerUserId: 1,
      collection: CacheCollection.vaults,
      scopeId: CacheScope.all,
    );
    final recipeMetadata = await store.readSyncMetadata(
      viewerUserId: 1,
      collection: CacheCollection.recipe,
      scopeId: '42',
    );

    expect(vaultMetadata?.lastSyncedAt, vaultSync);
    expect(vaultMetadata?.lastAccessedAt, isNotNull);
    expect(recipeMetadata?.lastSyncedAt, recipeSync);
  });

  test('recipe nutrition summary round trips without ingredient breakdown',
      () async {
    final syncedAt = DateTime.utc(2026, 9, 29);
    await store.storeRecipeNutrition(
      viewerUserId: 1,
      nutrition: _nutrition(),
      syncedAt: syncedAt,
    );

    final cached = await store.readRecipeNutrition(
      viewerUserId: 1,
      recipeId: 42,
    );

    expect(cached?.servings, 2);
    expect(cached?.totals.caloriesKcal, 600);
    expect(cached?.perServing.proteinG, 15);
    expect(cached?.ingredients, isEmpty);
    expect(
      await store.readRecipeNutrition(viewerUserId: 2, recipeId: 42),
      isNull,
    );
  });
}

Vault _vault(int id, String name) => Vault(
      vaultId: id,
      ownerId: 99,
      vaultType: VaultTypes.shared,
      name: name,
      createdAt: DateTime.utc(2026, 1, 1),
    );

VaultFolder _folder(int id, int vaultId, String name) => VaultFolder(
      folderId: id,
      vaultId: vaultId,
      folderName: name,
      createdAt: DateTime.utc(2026, 1, 1),
    );

Recipe _completeRecipe(String title) => Recipe(
      recipeId: 42,
      ownerId: 99,
      title: title,
      ingredients: const [
        RecipeIngredient(
          ingredientId: 1,
          recipeId: 42,
          ingId: 5,
          name: 'Salt',
          quantity: 1,
          unit: 'tsp',
        ),
      ],
      steps: const [
        RecipeStep(
          stepId: 1,
          recipeId: 42,
          stepNr: 1,
          content: 'Mix.',
        ),
      ],
      equipment: const [
        Equipment(id: 3, value: 'mixing_bowl', label: 'Mixing bowl'),
      ],
    );

RecipeNutrition _nutrition() => const RecipeNutrition(
      recipeId: 42,
      servings: 2,
      totals: NutritionValues(
        caloriesKcal: 600,
        proteinG: 30,
        carbsG: 70,
        fatG: 20,
        fibreG: 8,
        sodiumMg: 900,
      ),
      perServing: NutritionValues(
        caloriesKcal: 300,
        proteinG: 15,
        carbsG: 35,
        fatG: 10,
        fibreG: 4,
        sodiumMg: 450,
      ),
      ingredients: [],
    );
