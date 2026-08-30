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

  test('anonymous viewers use remote data and never use another cache',
      () async {
    await cache.replaceVaultsFromCompleteFetch(
      viewerUserId: 11,
      vaults: [_vault('Another user cache')],
      syncedAt: DateTime.now().toUtc(),
    );
    final error = _connectionError();
    final repository = CachedVaultRepository(
      remote: _VaultRepositoryStub(
        getMyVaultsResult: () => Future.error(error),
      ),
      cache: cache,
      viewerUserId: null,
    );

    await expectLater(repository.getMyVaults(), throwsA(same(error)));
  });

  test('forwards all mutation and reference operations to the remote',
      () async {
    final remote = _RecordingVaultRepository();
    final repository = CachedVaultRepository(
      remote: remote,
      cache: cache,
      viewerUserId: 11,
    );

    expect((await repository.getVaultById(7)).vaultId, 7);
    expect((await repository.createVault('Dinner')).name, 'Dinner');
    await repository.deleteVault(7);
    expect((await repository.createFolder(7, 'Soups')).folderName, 'Soups');
    await repository.deleteFolder(4, 7);
    expect((await repository.renameFolder(4, 7, 'Mains')).folderName, 'Mains');
    expect((await repository.addRecipeToFolder(4, 9)).recipeId, 9);
    expect((await repository.moveRecipe(5, 6)).folderId, 6);
    await repository.removeRecipeFromFolder(5);
    expect(await repository.getFoldersForRecipe(9), hasLength(1));
    expect(await repository.getMembers(7), hasLength(1));
    expect((await repository.addMember(7, 'chef@example.test')).userId, 11);
    await repository.removeMember(7, 'chef@example.test');

    expect(
      remote.calls,
      containsAll(<String>[
        'getVaultById',
        'createVault',
        'deleteVault',
        'createFolder',
        'deleteFolder',
        'renameFolder',
        'addRecipeToFolder',
        'moveRecipe',
        'removeRecipeFromFolder',
        'getFoldersForRecipe',
        'getMembers',
        'addMember',
        'removeMember',
      ]),
    );
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

class _RecordingVaultRepository implements VaultRepository {
  final calls = <String>[];

  @override
  Future<Vault> getVaultById(int vaultId) async {
    calls.add('getVaultById');
    return _vault('Remote detail');
  }

  @override
  Future<Vault> createVault(String name) async {
    calls.add('createVault');
    return _vault(name);
  }

  @override
  Future<void> deleteVault(int vaultId) async => calls.add('deleteVault');

  @override
  Future<VaultFolder> createFolder(int vaultId, String folderName) async {
    calls.add('createFolder');
    return _folder(folderName);
  }

  @override
  Future<void> deleteFolder(int folderId, int vaultId) async {
    calls.add('deleteFolder');
  }

  @override
  Future<VaultFolder> renameFolder(
    int folderId,
    int vaultId,
    String folderName,
  ) async {
    calls.add('renameFolder');
    return _folder(folderName);
  }

  @override
  Future<VaultFolderRecipe> addRecipeToFolder(
    int folderId,
    int recipeId,
  ) async {
    calls.add('addRecipeToFolder');
    return VaultFolderRecipe(
      id: 5,
      folderId: folderId,
      recipeId: recipeId,
      addedAt: DateTime.utc(2026, 1, 2),
      addedByUserId: 11,
    );
  }

  @override
  Future<VaultFolderRecipe> moveRecipe(
    int folderRecipeId,
    int targetFolderId,
  ) async {
    calls.add('moveRecipe');
    return VaultFolderRecipe(
      id: folderRecipeId,
      folderId: targetFolderId,
      recipeId: 9,
      addedAt: DateTime.utc(2026, 1, 2),
      addedByUserId: 11,
    );
  }

  @override
  Future<void> removeRecipeFromFolder(int folderRecipId) async {
    calls.add('removeRecipeFromFolder');
  }

  @override
  Future<List<VaultFolderRecipe>> getFoldersForRecipe(int recipeId) async {
    calls.add('getFoldersForRecipe');
    return [_folderRecipe()];
  }

  @override
  Future<List<VaultMember>> getMembers(int vaultId) async {
    calls.add('getMembers');
    return [_member()];
  }

  @override
  Future<VaultMember> addMember(int vaultId, String email) async {
    calls.add('addMember');
    return _member();
  }

  @override
  Future<void> removeMember(int vaultId, String email) async {
    calls.add('removeMember');
  }

  @override
  Future<List<Vault>> getMyVaults() async => const [];

  @override
  Future<List<VaultFolder>> getFolders(int vaultId) async => const [];

  @override
  Future<List<VaultFolderRecipe>> getFolderRecipes(int folderId) async =>
      const [];
}

VaultMember _member() => VaultMember(
      id: 3,
      vaultId: 7,
      userId: 11,
      joinedAt: DateTime.utc(2026, 1, 3),
    );
