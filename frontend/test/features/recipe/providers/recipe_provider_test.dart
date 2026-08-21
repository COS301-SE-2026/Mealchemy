import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/recipe/models/unit_of_measurement.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_repository.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/models/vault_folder_recipe.dart';
import 'package:mealchemy/features/vault/providers/vault_repository_provider.dart';
import 'package:mealchemy/features/vault/repositories/vault_repository.dart';

const _validRecipe = Recipe(
  recipeId: 0,
  title: 'My New Recipe',
  cuisineType: 'italian',
  prepTimeMins: 10,
  cookingTimeMins: 20,
  servingSize: 4,
);


class _RecordingRepo implements RecipeRepository {
  final List<(Recipe, int)> saved = [];
  final List<(int, Recipe, bool)> updated = [];

  @override
  Future<Recipe> addRecipe(Recipe recipe, int folderId) async {
    saved.add((recipe, folderId));
    return _validRecipe.copyWith(recipeId: 501);
  }

  @override
  Future<Recipe> updateRecipe(int id, Recipe recipe) async =>
      throw UnimplementedError();

  @override
  Future<Recipe> updateRecipeFull(int id, Recipe recipe,
      {bool removePhoto = false}) async {
    updated.add((id, recipe, removePhoto));
    return recipe.copyWith(recipeId: id);
  }

  @override
  Future<List<Recipe>> getRecipes() async => const [];

  @override
  Future<Recipe> getRecipeById(int id) async => throw UnimplementedError();

  @override
  Future<List<String>> getCuisineTypes() async => const [];

  @override
  Future<List<UnitOfMeasurement>> getUnits() async => const [];

  @override
  Future<void> addRecipeIngredient(int recipeId, RecipeIngredient i) async {}

  @override
  Future<void> addRecipeStep(int recipeId, RecipeStep step) async {}

  @override
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) async =>
      const [];

  @override
  Future<List<RecipeStep>> getRecipeSteps(int recipeId) async => const [];

  @override
  Future<void> deleteRecipe(int recipeId) async {}
}


class _ThrowingAddRepo extends _RecordingRepo {
  @override
  Future<Recipe> addRecipe(Recipe recipe, int folderId) async =>
      throw Exception('backend down');
}


class _FakeVaultRepo implements VaultRepository {
  bool createFolderCalled = false;

  @override
  Future<List<Vault>> getMyVaults() async => [
        Vault(
          vaultId: 1,
          vaultType: VaultTypes.private,
          name: 'My Vault',
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

  @override
  Future<List<VaultFolder>> getFolders(int vaultId) async => [
        VaultFolder(
          folderId: 10,
          vaultId: 1,
          folderName: 'My Recipes',
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

  @override
  Future<VaultFolder> createFolder(int vaultId, String name) async {
    createFolderCalled = true;
    return VaultFolder(
      folderId: 99,
      vaultId: vaultId,
      folderName: name,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  @override
  Future<VaultFolderRecipe> addRecipeToFolder(
      int folderId, int recipeId) async {
    return VaultFolderRecipe(
      id: 1,
      folderId: folderId,
      recipeId: recipeId,
      addedAt: DateTime(2026, 1, 1),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}


ProviderContainer makeContainer({
  RecipeRepository? recipeRepo,
  VaultRepository? vaultRepo,
}) {
  return ProviderContainer(
    overrides: [
      if (recipeRepo != null)
        recipeRepositoryProvider.overrideWithValue(recipeRepo),
      vaultRepositoryProvider.overrideWithValue(vaultRepo ?? _FakeVaultRepo()),
    ],
  );
}

void main() {
  group('recipeRepositoryProvider', () {
    test('resolves a RecipeRepository', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(recipeRepositoryProvider), isA<RecipeRepository>());
    });
  });

  group('AddRecipeState', () {
    test('default values are non-submitting, no error, not successful', () {
      const state = AddRecipeState();
      expect(state.isSubmitting, false);
      expect(state.errorMessage, isNull);
      expect(state.isSuccess, false);
    });

    test('copyWith overrides only the fields passed', () {
      const state = AddRecipeState();
      final next = state.copyWith(isSubmitting: true);
      expect(next.isSubmitting, true);
      expect(next.isSuccess, false);
    });

    test('copyWith clears errorMessage when not provided', () {
      const seeded = AddRecipeState(errorMessage: 'error');
      final next = seeded.copyWith(isSubmitting: true);
      expect(next.errorMessage, isNull);
    });
  });

  group('AddRecipeNotifier', () {
    test('starts in the default state', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final state = container.read(addRecipeProvider);
      expect(state.isSubmitting, false);
      expect(state.errorMessage, isNull);
      expect(state.isSuccess, false);
    });

    test('submit with missing required fields sets an error and returns null',
        () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      const incomplete = Recipe(recipeId: 0, title: 'Just a title');
      final result =
          await container.read(addRecipeProvider.notifier).submit(incomplete);

      expect(result, isNull);
      expect(container.read(addRecipeProvider).errorMessage,
          'Please fill in all required fields.');
      expect(container.read(addRecipeProvider).isSuccess, false);
    });

    test('submit with an explicit folderId saves and flips to isSuccess',
        () async {
      final repo = _RecordingRepo();
      final container = makeContainer(recipeRepo: repo);
      addTearDown(container.dispose);

      final result = await container
          .read(addRecipeProvider.notifier)
          .submit(_validRecipe, folderId: 10);

      expect(result, isNotNull);
      expect(result!.recipeId, 501); // backend-assigned id flows back
      expect(repo.saved.single.$2, 10); // filed into the given folder
      final state = container.read(addRecipeProvider);
      expect(state.isSuccess, true);
      expect(state.errorMessage, isNull);
      expect(state.isSubmitting, false);
    });

    test('submit without a folderId resolves the default "My Recipes" folder',
        () async {
      final repo = _RecordingRepo();
      final vault = _FakeVaultRepo();
      final container = makeContainer(recipeRepo: repo, vaultRepo: vault);
      addTearDown(container.dispose);

      await container.read(addRecipeProvider.notifier).submit(_validRecipe);

      expect(vault.createFolderCalled, false);
      expect(repo.saved.single.$2, 10);
      expect(container.read(addRecipeProvider).isSuccess, true);
    });

    test('submit sets a generic error when the repo throws', () async {
      final container = makeContainer(recipeRepo: _ThrowingAddRepo());
      addTearDown(container.dispose);

      final result = await container
          .read(addRecipeProvider.notifier)
          .submit(_validRecipe, folderId: 10);

      expect(result, isNull);
      expect(container.read(addRecipeProvider).errorMessage,
          'Could not save recipe. Try again.');
      expect(container.read(addRecipeProvider).isSuccess, false);
    });

    test('edit submit forwards the recipe id and photo removal choice',
        () async {
      final repo = _RecordingRepo();
      final container = makeContainer(recipeRepo: repo);
      addTearDown(container.dispose);

      final result = await container.read(addRecipeProvider.notifier).submit(
            _validRecipe,
            recipeId: 77,
            removePhoto: true,
          );

      expect(result, isNotNull);
      expect(repo.updated.single.$1, 77);
      expect(repo.updated.single.$2, _validRecipe);
      expect(repo.updated.single.$3, isTrue);
      expect(container.read(addRecipeProvider).isSuccess, true);
    });

    test('reset returns the state to its defaults', () async {
      final repo = _RecordingRepo();
      final container = makeContainer(recipeRepo: repo);
      addTearDown(container.dispose);

      await container
          .read(addRecipeProvider.notifier)
          .submit(_validRecipe, folderId: 10);
      expect(container.read(addRecipeProvider).isSuccess, true);

      container.read(addRecipeProvider.notifier).reset();
      final state = container.read(addRecipeProvider);
      expect(state.isSubmitting, false);
      expect(state.errorMessage, isNull);
      expect(state.isSuccess, false);
    });
  });
}