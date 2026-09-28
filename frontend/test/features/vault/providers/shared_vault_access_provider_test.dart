import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_repository_provider.dart';
import 'package:mealchemy/features/vault/repositories/vault_repository.dart';

VaultSession _session({
  int? userId = 7,
  bool valid = true,
}) =>
    (
      userId: userId,
      token: userId == null ? null : 'token-$userId',
      restoring: false,
      hasValidCredential: valid,
    );

Vault _vault({int ownerId = 9}) => Vault(
      vaultId: 5,
      ownerId: ownerId,
      vaultType: VaultTypes.shared,
      name: 'Family',
      createdAt: DateTime.utc(2026, 9, 21),
    );

VaultMember _member({
  int userId = 7,
  VaultMemberRole role = VaultMemberRole.viewer,
}) =>
    VaultMember(
      id: role == VaultMemberRole.owner ? null : userId,
      vaultId: 5,
      userId: userId,
      email: '$userId@example.com',
      joinedAt: DateTime.utc(2026, 9, 21),
      role: role,
    );

class _Repository implements VaultRepository {
  int vaultCalls = 0;
  int memberCalls = 0;

  Future<Vault> Function() loadVault = () async => _vault();
  Future<List<VaultMember>> Function() loadMembers = () async => [_member()];

  @override
  Future<Vault> getVaultById(int vaultId) {
    vaultCalls++;
    return loadVault();
  }

  @override
  Future<List<VaultMember>> getMembers(int vaultId) {
    memberCalls++;
    return loadMembers();
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
  late StateProvider<NetworkStatus> network;

  setUp(() {
    repository = _Repository();
    session = StateProvider((ref) => _session());
    network = StateProvider((ref) => NetworkStatus.online);

    container = ProviderContainer(
      overrides: [
        vaultRepositoryProvider.overrideWithValue(repository),
        vaultSessionProvider.overrideWith((ref) => ref.watch(session)),
        vaultConnectionProvider.overrideWith((ref) => ref.watch(network)),
      ],
    );

    addTearDown(container.dispose);
  });

  Future<SharedVaultAccess> load() {
    final subscription = container.listen(
      sharedVaultAccessProvider(5),
      (_, __) {},
    );
    addTearDown(subscription.close);

    return container.read(sharedVaultAccessProvider(5).future);
  }

  test('Viewer can read members but cannot manage members or folders',
      () async {
    final access = await load();

    expect(access.role, VaultMemberRole.viewer);
    expect(access.canManageMembers, isFalse);
    expect(access.canManageFolders, isFalse);
  });

  test('Editor can manage folders but not members', () async {
    repository.loadMembers = () async => [
          _member(role: VaultMemberRole.editor),
        ];

    final access = await load();

    expect(access.canManageFolders, isTrue);
    expect(access.canManageMembers, isFalse);
  });

  test('owner is verified against vault ownership and synthetic entry',
      () async {
    repository.loadVault = () async => _vault(ownerId: 7);
    repository.loadMembers = () async => [
          _member(role: VaultMemberRole.owner),
        ];

    final access = await load();

    expect(access.canManageMembers, isTrue);
    expect(access.canManageFolders, isTrue);
    expect(access.currentMember.id, isNull);
  });

  test('inconsistent OWNER response does not grant access', () async {
    repository.loadMembers = () async => [
          _member(role: VaultMemberRole.owner),
        ];

    await expectLater(
      load(),
      throwsA(isA<SharedVaultAccessException>()),
    );
  });

  test('missing current member does not grant access', () async {
    repository.loadMembers = () async => [_member(userId: 8)];

    await expectLater(
      load(),
      throwsA(isA<SharedVaultAccessException>()),
    );
  });

  test('signed-out user makes no repository requests', () async {
    container.read(session.notifier).state =
        _session(userId: null, valid: false);

    await expectLater(
      load(),
      throwsA(
        isA<SharedVaultAccessException>().having(
          (error) => error.failure,
          'failure',
          SharedVaultAccessFailure.signInRequired,
        ),
      ),
    );

    expect(repository.vaultCalls, 0);
    expect(repository.memberCalls, 0);
  });

  for (final state in [NetworkStatus.offline, NetworkStatus.checking]) {
    test('${state.name} does not use cached metadata to grant access',
        () async {
      container.read(network.notifier).state = state;

      await expectLater(
        load(),
        throwsA(isA<SharedVaultAccessException>()),
      );

      expect(repository.vaultCalls, 0);
      expect(repository.memberCalls, 0);
    });
  }

  for (final status in [403, 404]) {
    test('HTTP $status marks the vault unavailable', () async {
      repository.loadMembers = () async {
        final options = RequestOptions(path: '/vault/5/members/all');
        throw DioException(
          requestOptions: options,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: status,
          ),
        );
      };

      await expectLater(
        load(),
        throwsA(
          isA<SharedVaultAccessException>().having(
            (error) => error.failure,
            'failure',
            SharedVaultAccessFailure.unavailable,
          ),
        ),
      );
    });
  }

  test('refresh picks up an Editor demotion', () async {
    repository.loadMembers = () async => [
          _member(role: VaultMemberRole.editor),
        ];

    expect((await load()).canManageFolders, isTrue);

    repository.loadMembers = () async => [_member()];
    container.invalidate(sharedVaultAccessProvider(5));

    final refreshed = await container.read(
      sharedVaultAccessProvider(5).future,
    );

    expect(refreshed.role, VaultMemberRole.viewer);
    expect(refreshed.canManageFolders, isFalse);
  });

  test('late result from the previous account cannot replace current access',
      () async {
    final oldMembers = Completer<List<VaultMember>>();
    final started = Completer<void>();

    repository.loadMembers = () {
      started.complete();
      return oldMembers.future;
    };

    final subscription = container.listen(
      sharedVaultAccessProvider(5),
      (_, __) {},
    );
    addTearDown(subscription.close);

    await started.future;

    repository.loadMembers = () async => [_member(userId: 8)];
    container.read(session.notifier).state = _session(userId: 8);

    final current = await container.read(
      sharedVaultAccessProvider(5).future,
    );
    expect(current.currentMember.userId, 8);

    oldMembers.complete([_member()]);
    await Future<void>.delayed(Duration.zero);

    expect(
      container
          .read(sharedVaultAccessProvider(5))
          .requireValue
          .currentMember
          .userId,
      8,
    );
  });

  test('changing accounts resets selection, shared mode and search', () {
    container.read(selectedVaultIdProvider.notifier).state = 5;
    container.read(isSharedModeProvider.notifier).state = true;
    container.read(vaultSearchQueryProvider.notifier).state = 'pasta';

    container.read(session.notifier).state = _session(userId: 8);

    expect(container.read(selectedVaultIdProvider), isNull);
    expect(container.read(isSharedModeProvider), isFalse);
    expect(container.read(vaultSearchQueryProvider), isEmpty);
  });
}
