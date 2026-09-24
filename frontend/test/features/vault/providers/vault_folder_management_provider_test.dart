import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_folder_management_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_repository_provider.dart';
import 'package:mealchemy/features/vault/repositories/vault_repository.dart';

VaultSession _session([int userId = 8]) => (
      userId: userId,
      token: 'token-$userId',
      restoring: false,
      hasValidCredential: true,
    );

final _vault = Vault(
  vaultId: 5,
  ownerId: 7,
  vaultType: VaultTypes.shared,
  name: 'Family',
  createdAt: DateTime(2026, 1, 1),
);

VaultFolder _folder({
  int vaultId = 5,
  String name = 'Dinner',
}) {
  return VaultFolder(
    folderId: 12,
    vaultId: vaultId,
    folderName: name,
    createdAt: DateTime(2026, 1, 1),
  );
}

class _Repository implements VaultRepository {
  VaultMemberRole role = VaultMemberRole.editor;
  Object? failure;
  Future<VaultFolder> Function()? createResponse;
  Future<List<VaultMember>> Function()? membersResponse;

  final creates = <(int, String)>[];
  final renames = <(int, int, String)>[];
  final deletes = <(int, int)>[];

  List<VaultFolder> folders = [_folder()];

  @override
  Future<Vault> getVaultById(int vaultId) async => _vault;

  @override
  Future<List<VaultMember>> getMembers(int vaultId) async {
    if (membersResponse != null) return membersResponse!();

    return [
      VaultMember(
        id: null,
        vaultId: 5,
        userId: 7,
        email: 'owner@example.com',
        joinedAt: DateTime(2026, 1, 1),
        role: VaultMemberRole.owner,
      ),
      VaultMember(
        id: 44,
        vaultId: 5,
        userId: 8,
        email: 'editor@example.com',
        joinedAt: DateTime(2026, 1, 1),
        role: role,
      ),
    ];
  }

  @override
  Future<List<VaultFolder>> getFolders(int vaultId) async {
    return List.of(folders);
  }

  @override
  Future<VaultFolder> createFolder(int vaultId, String folderName) async {
    creates.add((vaultId, folderName));

    if (failure != null) throw failure!;
    if (createResponse != null) return createResponse!();

    final created = VaultFolder(
      folderId: 20,
      vaultId: vaultId,
      folderName: folderName,
      createdAt: DateTime(2026, 1, 2),
    );

    folders.add(created);
    return created;
  }

  @override
  Future<VaultFolder> renameFolder(
    int folderId,
    int vaultId,
    String folderName,
  ) async {
    renames.add((folderId, vaultId, folderName));
    if (failure != null) throw failure!;

    final updated = _folder(name: folderName);
    folders = [updated];
    return updated;
  }

  @override
  Future<void> deleteFolder(int folderId, int vaultId) async {
    deletes.add((folderId, vaultId));
    if (failure != null) throw failure!;
    folders = [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName}');
  }
}

void main() {
  late _Repository repository;
  late ProviderContainer container;
  late StateProvider<VaultSession> session;
  late StateProvider<NetworkStatus> connection;

  setUp(() {
    repository = _Repository();
    session = StateProvider((ref) => _session());
    connection = StateProvider((ref) => NetworkStatus.online);

    container = ProviderContainer(
      overrides: [
        vaultRepositoryProvider.overrideWithValue(repository),
        vaultSessionProvider.overrideWith((ref) => ref.watch(session)),
        vaultConnectionProvider.overrideWith(
          (ref) => ref.watch(connection),
        ),
      ],
    );

    container.listen(
      canManageVaultFoldersProvider(_vault),
      (_, __) {},
      fireImmediately: true,
    );
    container.listen(
      vaultFolderManagementProvider(5),
      (_, __) {},
      fireImmediately: true,
    );

    addTearDown(container.dispose);
  });

  Future<void> ready() async {
    container.invalidate(sharedVaultAccessProvider(5));
    await container.read(sharedVaultAccessProvider(5).future);
  }

  Future<String?> submit(
    VaultFolderAction action, {
    String? name,
    VaultFolder? folder,
    VaultSession? expectedSession,
  }) {
    return container.read(vaultFolderManagementProvider(5).notifier).submit(
          vault: _vault,
          action: action,
          expectedSession: expectedSession ?? _session(),
          name: name,
          folder: folder,
        );
  }

  test('Editor can create a folder and the name is trimmed', () async {
    await ready();

    expect(
      await submit(VaultFolderAction.create, name: '  Lunch  '),
      'Folder created.',
    );
    expect(repository.creates, [(5, 'Lunch')]);
  });

  test('Editor can rename a folder', () async {
    await ready();

    expect(
      await submit(
        VaultFolderAction.rename,
        folder: _folder(),
        name: 'Quick dinners',
      ),
      'Folder renamed.',
    );
    expect(repository.renames, [(12, 5, 'Quick dinners')]);
  });

  test('Editor can delete the folder without deleting recipe records',
      () async {
    await ready();

    expect(
      await submit(VaultFolderAction.delete, folder: _folder()),
      'Folder deleted. The recipes are preserved.',
    );
    expect(repository.deletes, [(12, 5)]);
    expect(repository.creates, isEmpty);
    expect(repository.renames, isEmpty);
  });

  test('Owner can manage shared-vault folders', () async {
    container.read(session.notifier).state = _session(7);
    await ready();

    expect(
      await submit(
        VaultFolderAction.create,
        name: 'Lunch',
        expectedSession: _session(7),
      ),
      'Folder created.',
    );
    expect(repository.creates, [(5, 'Lunch')]);
  });

  test('Viewer cannot create, rename or delete folders', () async {
    repository.role = VaultMemberRole.viewer;
    await ready();

    expect(
      container.read(canManageVaultFoldersProvider(_vault)),
      isFalse,
    );

    await submit(VaultFolderAction.create, name: 'Lunch');
    await submit(
      VaultFolderAction.rename,
      folder: _folder(),
      name: 'Lunch',
    );
    await submit(VaultFolderAction.delete, folder: _folder());

    expect(repository.creates, isEmpty);
    expect(repository.renames, isEmpty);
    expect(repository.deletes, isEmpty);
  });

  test('permissions are checked again before a mutation', () async {
    await ready();

    // The client still has the earlier Editor result.
    repository.role = VaultMemberRole.viewer;

    expect(
      await submit(VaultFolderAction.create, name: 'Lunch'),
      'Only the vault Owner or an Editor can manage folders.',
    );
    expect(repository.creates, isEmpty);
  });

  for (final status in [
    NetworkStatus.offline,
    NetworkStatus.checking,
  ]) {
    test('$status prevents folder mutations', () async {
      await ready();
      container.read(connection.notifier).state = status;

      await submit(VaultFolderAction.create, name: 'Lunch');

      expect(repository.creates, isEmpty);
    });
  }

  test('empty names are rejected', () async {
    await ready();

    expect(
      await submit(VaultFolderAction.create, name: '   '),
      'Enter a folder name.',
    );
    expect(repository.creates, isEmpty);
  });

  test('a folder from another vault is rejected', () async {
    await ready();

    await submit(
      VaultFolderAction.delete,
      folder: _folder(vaultId: 99),
    );

    expect(repository.deletes, isEmpty);
  });

  test('backend permission failures return useful feedback', () async {
    await ready();

    final request = RequestOptions(path: '/folders');
    repository.failure = DioException(
      requestOptions: request,
      response: Response<dynamic>(
        requestOptions: request,
        statusCode: 403,
      ),
      type: DioExceptionType.badResponse,
    );

    expect(
      await submit(VaultFolderAction.create, name: 'Lunch'),
      'You no longer have permission to manage these folders.',
    );
    expect(container.read(vaultFolderManagementProvider(5)), isFalse);
  });

  test('duplicate submission is blocked while the first is running', () async {
    await ready();

    final pending = Completer<VaultFolder>();
    repository.createResponse = () => pending.future;

    final first = submit(VaultFolderAction.create, name: 'Lunch');

    expect(container.read(vaultFolderManagementProvider(5)), isTrue);
    expect(
      await submit(VaultFolderAction.create, name: 'Lunch'),
      isNull,
    );

    await Future<void>.delayed(Duration.zero);

    expect(repository.creates, [(5, 'Lunch')]);

    pending.complete(_folder(name: 'Lunch'));

    expect(await first, 'Folder created.');
    expect(container.read(vaultFolderManagementProvider(5)), isFalse);
  });

  test('a confirmation from a previous session cannot save', () async {
    await ready();
    container.read(session.notifier).state = _session(9);

    expect(
      await submit(
        VaultFolderAction.create,
        name: 'Lunch',
        expectedSession: _session(),
      ),
      isNull,
    );
    expect(repository.creates, isEmpty);
  });

  test('late responses do not report success to another session', () async {
    await ready();

    final pending = Completer<VaultFolder>();
    repository.createResponse = () => pending.future;

    final request = submit(VaultFolderAction.create, name: 'Lunch');

    await Future<void>.delayed(Duration.zero);
    expect(repository.creates, hasLength(1));

    container.read(session.notifier).state = _session(9);
    pending.complete(_folder(name: 'Lunch'));

    expect(await request, isNull);
    expect(container.read(vaultFolderManagementProvider(5)), isFalse);
  });

  test('successful changes refresh the folder list', () async {
    await ready();

    container.listen(
      vaultFoldersProvider(5),
      (_, __) {},
      fireImmediately: true,
    );

    expect(
      await container.read(vaultFoldersProvider(5).future),
      hasLength(1),
    );

    await submit(VaultFolderAction.create, name: 'Lunch');

    final refreshed = await container.read(vaultFoldersProvider(5).future);

    expect(refreshed, hasLength(2));
    expect(refreshed.last.folderName, 'Lunch');
  });

  test('private folder permissions belong to the private-vault owner', () {
    final privateVault = Vault(
      vaultId: 6,
      ownerId: 8,
      vaultType: VaultTypes.private,
      name: 'My Vault',
      createdAt: DateTime(2026, 1, 1),
    );

    expect(
      container.read(canManageVaultFoldersProvider(privateVault)),
      isTrue,
    );

    container.read(session.notifier).state = _session(9);

    expect(
      container.read(canManageVaultFoldersProvider(privateVault)),
      isFalse,
    );
  });
}
