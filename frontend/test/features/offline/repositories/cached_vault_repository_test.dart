import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/offline/data/offline_cache_database.dart';
import 'package:mealchemy/features/offline/data/offline_cache_store.dart';
import 'package:mealchemy/features/offline/repositories/cached_vault_repository.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/models/vault_folder_recipe.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';
import 'package:mealchemy/features/vault/repositories/vault_repository.dart';

void main() {
  late OfflineCacheDatabase database;
  late OfflineCacheStore cache;

  setUp(() {
    database = OfflineCacheDatabase(NativeDatabase.memory());
    cache = OfflineCacheStore(database);
  });

  tearDown(() => database.close());

  test('a successful complete response refreshes the viewer namespace',
      () async {
    final repository = CachedVaultRepository(
      remote: _VaultRepositoryStub(
        getMyVaultsResult: () async => [_vault('Fresh API vault')],
      ),
      cache: cache,
      viewerUserId: 11,
    );

    final result = await repository.getMyVaults();

    expect(result.single.name, 'Fresh API vault');
    expect(
      (await cache.readVaults(viewerUserId: 11)).single.name,
      'Fresh API vault',
    );
    expect(await cache.readVaults(viewerUserId: 12), isEmpty);
  });

  test('a transport failure falls back to the viewer cache', () async {
    await cache.replaceVaultsFromCompleteFetch(
      viewerUserId: 11,
      vaults: [_vault('Cached vault')],
      syncedAt: DateTime.now().toUtc(),
    );
    final repository = CachedVaultRepository(
      remote: _VaultRepositoryStub(
        getMyVaultsResult: () => Future.error(_connectionError()),
      ),
      cache: cache,
      viewerUserId: 11,
    );

    final result = await repository.getMyVaults();

    expect(result.single.name, 'Cached vault');
  });

  test('an HTTP response is propagated instead of treated as offline',
      () async {
    await cache.replaceVaultsFromCompleteFetch(
      viewerUserId: 11,
      vaults: [_vault('Must not be returned')],
      syncedAt: DateTime.now().toUtc(),
    );
    final error = DioException.badResponse(
      statusCode: 401,
      requestOptions: RequestOptions(path: '/vaults/owner/vaults'),
      response: Response<void>(
        requestOptions: RequestOptions(path: '/vaults/owner/vaults'),
        statusCode: 401,
      ),
    );
    final repository = CachedVaultRepository(
      remote: _VaultRepositoryStub(
        getMyVaultsResult: () => Future.error(error),
      ),
      cache: cache,
      viewerUserId: 11,
    );

    await expectLater(repository.getMyVaults(), throwsA(same(error)));
  });
}

Vault _vault(String name) => Vault(
      vaultId: 7,
      ownerId: 99,
      vaultType: VaultTypes.shared,
      name: name,
      createdAt: DateTime.utc(2026, 1, 1),
    );

DioException _connectionError() => DioException(
      requestOptions: RequestOptions(path: '/vaults/owner/vaults'),
      type: DioExceptionType.connectionError,
    );

class _VaultRepositoryStub implements VaultRepository {
  _VaultRepositoryStub({required this.getMyVaultsResult});

  final Future<List<Vault>> Function() getMyVaultsResult;

  @override
  Future<List<Vault>> getMyVaults() => getMyVaultsResult();

  @override
  Future<VaultMember> addMember(int vaultId, String email) =>
      throw UnimplementedError();
  @override
  Future<VaultFolderRecipe> addRecipeToFolder(int folderId, int recipeId) =>
      throw UnimplementedError();
  @override
  Future<VaultFolder> createFolder(int vaultId, String folderName) =>
      throw UnimplementedError();
  @override
  Future<Vault> createVault(String name) => throw UnimplementedError();
  @override
  Future<void> deleteFolder(int folderId, int vaultId) =>
      throw UnimplementedError();
  @override
  Future<void> deleteVault(int vaultId) => throw UnimplementedError();
  @override
  Future<List<VaultFolderRecipe>> getFolderRecipes(int folderId) =>
      throw UnimplementedError();
  @override
  Future<List<VaultFolder>> getFolders(int vaultId) =>
      throw UnimplementedError();
  @override
  Future<List<VaultFolderRecipe>> getFoldersForRecipe(int recipeId) =>
      throw UnimplementedError();
  @override
  Future<List<VaultMember>> getMembers(int vaultId) =>
      throw UnimplementedError();
  @override
  Future<Vault> getVaultById(int vaultId) => throw UnimplementedError();
  @override
  Future<VaultFolderRecipe> moveRecipe(
          int folderRecipeId, int targetFolderId) =>
      throw UnimplementedError();
  @override
  Future<void> removeMember(int vaultId, String email) =>
      throw UnimplementedError();
  @override
  Future<void> removeRecipeFromFolder(int folderRecipId) =>
      throw UnimplementedError();
  @override
  Future<VaultFolder> renameFolder(
          int folderId, int vaultId, String folderName) =>
      throw UnimplementedError();
}
