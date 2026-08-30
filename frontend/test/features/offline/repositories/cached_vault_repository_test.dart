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

  test('vault detail transport failure returns the viewer cache', () async {
    await cache.replaceVaultsFromCompleteFetch(
      viewerUserId: 11,
      vaults: [_vault('Cached detail')],
      syncedAt: DateTime.now().toUtc(),
    );
    final repository = CachedVaultRepository(
      remote: _VaultRepositoryStub(
        getMyVaultsResult: () async => const [],
        getVaultByIdResult: (_) => Future.error(_connectionError()),
      ),
      cache: cache,
      viewerUserId: 11,
    );

    expect((await repository.getVaultById(7)).name, 'Cached detail');
  });

  test('missing vault detail and HTTP errors are propagated', () async {
    final transportError = _connectionError();
    final httpError = DioException.badResponse(
      statusCode: 404,
      requestOptions: RequestOptions(path: '/vaults/7'),
      response: Response<void>(
        requestOptions: RequestOptions(path: '/vaults/7'),
        statusCode: 404,
      ),
    );
    final missingRepository = CachedVaultRepository(
      remote: _VaultRepositoryStub(
        getMyVaultsResult: () async => const [],
        getVaultByIdResult: (_) => Future.error(transportError),
      ),
      cache: cache,
      viewerUserId: 11,
    );
    final httpRepository = CachedVaultRepository(
      remote: _VaultRepositoryStub(
        getMyVaultsResult: () async => const [],
        getVaultByIdResult: (_) => Future.error(httpError),
      ),
      cache: cache,
      viewerUserId: 11,
    );

    await expectLater(
        missingRepository.getVaultById(7), throwsA(same(transportError)));
    await expectLater(httpRepository.getVaultById(7), throwsA(same(httpError)));
  });

  test('folders refresh cache and fall back after a transport failure',
      () async {
    final folder = _folder('Fresh folder');
    final onlineRepository = CachedVaultRepository(
      remote: _VaultRepositoryStub(
        getMyVaultsResult: () async => const [],
        getFoldersResult: (_) async => [folder],
      ),
      cache: cache,
      viewerUserId: 11,
    );
    expect((await onlineRepository.getFolders(7)).single.folderName,
        'Fresh folder');

    final offlineRepository = CachedVaultRepository(
      remote: _VaultRepositoryStub(
        getMyVaultsResult: () async => const [],
        getFoldersResult: (_) => Future.error(_connectionError()),
      ),
      cache: cache,
      viewerUserId: 11,
    );
    expect((await offlineRepository.getFolders(7)).single.folderName,
        'Fresh folder');
  });

  test('folder recipe links refresh and fall back after transport failure',
      () async {
    final link = _folderRecipe();
    final onlineRepository = CachedVaultRepository(
      remote: _VaultRepositoryStub(
        getMyVaultsResult: () async => const [],
        getFolderRecipesResult: (_) async => [link],
      ),
      cache: cache,
      viewerUserId: 11,
    );
    expect((await onlineRepository.getFolderRecipes(4)).single.recipeId, 7);

    final offlineRepository = CachedVaultRepository(
      remote: _VaultRepositoryStub(
        getMyVaultsResult: () async => const [],
        getFolderRecipesResult: (_) => Future.error(_connectionError()),
      ),
      cache: cache,
      viewerUserId: 11,
    );
    expect((await offlineRepository.getFolderRecipes(4)).single.recipeId, 7);
  });
}

Vault _vault(String name) => Vault(
      vaultId: 7,
      ownerId: 99,
      vaultType: VaultTypes.shared,
      name: name,
      createdAt: DateTime.utc(2026, 1, 1),
    );

VaultFolder _folder(String name) => VaultFolder(
      folderId: 4,
      vaultId: 7,
      folderName: name,
      createdAt: DateTime.utc(2026, 1, 1),
    );

VaultFolderRecipe _folderRecipe() => VaultFolderRecipe(
      id: 5,
      folderId: 4,
      recipeId: 7,
      addedAt: DateTime.utc(2026, 1, 2),
      addedByUserId: 11,
    );

DioException _connectionError() => DioException(
      requestOptions: RequestOptions(path: '/vaults/owner/vaults'),
      type: DioExceptionType.connectionError,
    );

class _VaultRepositoryStub implements VaultRepository {
  _VaultRepositoryStub({
    required this.getMyVaultsResult,
    this.getVaultByIdResult,
    this.getFoldersResult,
    this.getFolderRecipesResult,
  });

  final Future<List<Vault>> Function() getMyVaultsResult;
  final Future<Vault> Function(int vaultId)? getVaultByIdResult;
  final Future<List<VaultFolder>> Function(int vaultId)? getFoldersResult;
  final Future<List<VaultFolderRecipe>> Function(int folderId)?
      getFolderRecipesResult;

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
      getFolderRecipesResult?.call(folderId) ??
      Future<List<VaultFolderRecipe>>.error(UnimplementedError());
  @override
  Future<List<VaultFolder>> getFolders(int vaultId) =>
      getFoldersResult?.call(vaultId) ??
      Future<List<VaultFolder>>.error(UnimplementedError());
  @override
  Future<List<VaultFolderRecipe>> getFoldersForRecipe(int recipeId) =>
      throw UnimplementedError();
  @override
  Future<List<VaultMember>> getMembers(int vaultId) =>
      throw UnimplementedError();
  @override
  Future<Vault> getVaultById(int vaultId) =>
      getVaultByIdResult?.call(vaultId) ??
      Future<Vault>.error(UnimplementedError());
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
