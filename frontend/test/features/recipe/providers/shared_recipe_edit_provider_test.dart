import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/providers/shared_recipe_edit_provider.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_repository.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/models/vault_folder_recipe.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_repository_provider.dart';
import 'package:mealchemy/features/vault/repositories/vault_repository.dart';

const _target = (vaultId: 5, folderId: 12, recipeId: 99);

class _VaultRepository implements VaultRepository {
  VaultMemberRole role = VaultMemberRole.editor;
  bool includeMember = true;
  bool includeFolder = true;
  int associatedRecipeId = 99;

  @override
  Future<Vault> getVaultById(int vaultId) async => Vault(
        vaultId: 5,
        ownerId: 7,
        vaultType: VaultTypes.shared,
        name: 'Family',
        createdAt: DateTime(2026, 1, 1),
      );

  @override
  Future<List<VaultMember>> getMembers(int vaultId) async => [
        VaultMember(
          id: null,
          vaultId: 5,
          userId: 7,
          email: 'owner@example.com',
          joinedAt: DateTime(2026, 1, 1),
          role: VaultMemberRole.owner,
        ),
        if (includeMember)
          VaultMember(
            id: 44,
            vaultId: 5,
            userId: 8,
            email: 'member@example.com',
            joinedAt: DateTime(2026, 1, 1),
            role: role,
          ),
      ];

  @override
  Future<List<VaultFolder>> getFolders(int vaultId) async => [
        if (includeFolder)
          VaultFolder(
            folderId: 12,
            vaultId: 5,
            folderName: 'Dinner',
            createdAt: DateTime(2026, 1, 1),
          ),
      ];

  @override
  Future<List<VaultFolderRecipe>> getFolderRecipes(int folderId) async => [
        VaultFolderRecipe(
          id: 50,
          folderId: 12,
          recipeId: associatedRecipeId,
          addedAt: DateTime(2026, 1, 1),
        ),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _RecipeRepository implements RecipeRepository {
  int ownerId = 9;
  final requestedIds = <int>[];

  @override
  Future<Recipe> getRecipeById(int id) async {
    requestedIds.add(id);

    return Recipe(
      recipeId: id,
      ownerId: ownerId,
      title: 'Shared copy',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late _VaultRepository vaultRepository;
  late _RecipeRepository recipeRepository;

  setUp(() {
    vaultRepository = _VaultRepository();
    recipeRepository = _RecipeRepository();
  });

  ProviderContainer containerFor({
    int userId = 8,
    NetworkStatus connection = NetworkStatus.online,
  }) {
    final container = ProviderContainer(
      overrides: [
        vaultRepositoryProvider.overrideWithValue(vaultRepository),
        recipeRepositoryProvider.overrideWithValue(recipeRepository),
        vaultSessionProvider.overrideWithValue((
          userId: userId,
          token: 'token-$userId',
          restoring: false,
          hasValidCredential: true,
        )),
        vaultConnectionProvider.overrideWithValue(connection),
      ],
    );

    container.listen(
      sharedRecipeEditAccessProvider(_target),
      (_, __) {},
      fireImmediately: true,
    );

    addTearDown(container.dispose);
    return container;
  }

  test('Editor can edit another member’s copy', () async {
    final container = containerFor();

    expect(
      await container.read(sharedRecipeEditAccessProvider(_target).future),
      isTrue,
    );
    expect(recipeRepository.requestedIds, [99]);
  });

  test('vault Owner can edit another member’s copy', () async {
    final container = containerFor(userId: 7);

    expect(
      await container.read(sharedRecipeEditAccessProvider(_target).future),
      isTrue,
    );
  });

  test('Viewer can edit their own copy', () async {
    vaultRepository.role = VaultMemberRole.viewer;
    recipeRepository.ownerId = 8;

    final container = containerFor();

    expect(
      await container.read(sharedRecipeEditAccessProvider(_target).future),
      isTrue,
    );
  });

  test('Viewer cannot edit another member’s copy', () async {
    vaultRepository.role = VaultMemberRole.viewer;

    final container = containerFor();

    expect(
      await container.read(sharedRecipeEditAccessProvider(_target).future),
      isFalse,
    );
  });

  test('removed member cannot enter the shared-copy editor', () async {
    vaultRepository.includeMember = false;
    recipeRepository.ownerId = 8;

    final container = containerFor();

    await expectLater(
      container.read(sharedRecipeEditAccessProvider(_target).future),
      throwsA(isA<StateError>()),
    );

    expect(recipeRepository.requestedIds, isEmpty);
  });

  test('a folder outside the verified vault is rejected', () async {
    vaultRepository.includeFolder = false;

    final container = containerFor();

    await expectLater(
      container.read(sharedRecipeEditAccessProvider(_target).future),
      throwsA(isA<StateError>()),
    );
  });

  test('the original recipe ID cannot replace the shared-copy ID', () async {
    vaultRepository.associatedRecipeId = 42;

    final container = containerFor();

    await expectLater(
      container.read(sharedRecipeEditAccessProvider(_target).future),
      throwsA(isA<StateError>()),
    );

    expect(recipeRepository.requestedIds, isEmpty);
  });

  for (final connection in [
    NetworkStatus.offline,
    NetworkStatus.checking,
  ]) {
    test('$connection does not grant editing access', () async {
      final container = containerFor(connection: connection);

      await expectLater(
        container.read(sharedRecipeEditAccessProvider(_target).future),
        throwsA(isA<StateError>()),
      );
    });
  }

  test('rechecking applies a demotion to someone else’s copy', () async {
    final container = containerFor();

    expect(
      await container.read(sharedRecipeEditAccessProvider(_target).future),
      isTrue,
    );

    vaultRepository.role = VaultMemberRole.viewer;
    container.invalidate(sharedRecipeEditAccessProvider(_target));

    expect(
      await container.read(sharedRecipeEditAccessProvider(_target).future),
      isFalse,
    );
  });

  test('edit location retains the copy, vault and folder IDs', () {
    final location = sharedRecipeEditLocation(_target);

    expect(
      location,
      '/edit-recipe/99?vaultId=5&folderId=12',
    );
    expect(
      sharedRecipeContextFromUri(Uri.parse(location), recipeId: 99),
      _target,
    );
  });

  test('ordinary edit URLs have no shared context', () {
    expect(
      sharedRecipeContextFromUri(
        Uri.parse('/edit-recipe/42'),
        recipeId: 42,
      ),
      isNull,
    );
  });

  for (final query in [
    'vaultId=5',
    'folderId=12',
    'vaultId=wrong&folderId=12',
    'vaultId=5&folderId=0',
    'vaultId=5&vaultId=6&folderId=12',
  ]) {
    test('rejects malformed context: $query', () {
      expect(
        () => sharedRecipeContextFromUri(
          Uri.parse('/edit-recipe/99?$query'),
          recipeId: 99,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  }
}
