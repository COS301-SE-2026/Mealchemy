import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_member_management_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_repository_provider.dart';
import 'package:mealchemy/features/vault/repositories/vault_repository.dart';
import 'package:mealchemy/features/vault/screens/vault_members_screen.dart';

VaultSession _session([int userId = 7]) => (
      userId: userId,
      token: 'token-$userId',
      restoring: false,
      hasValidCredential: true,
    );

VaultMember _owner() => VaultMember(
      id: null,
      vaultId: 5,
      userId: 7,
      email: 'owner@example.com',
      joinedAt: DateTime.utc(2026, 9, 21),
      role: VaultMemberRole.owner,
    );

VaultMember _member({
  VaultMemberRole role = VaultMemberRole.viewer,
}) =>
    VaultMember(
      id: 44,
      vaultId: 5,
      userId: 8,
      email: 'chef@example.com',
      joinedAt: DateTime.utc(2026, 9, 22),
      role: role,
    );

class _Repository implements VaultRepository {
  VaultMember? member = _member();

  final roleChanges = <({int vaultId, int userId, VaultMemberRole role})>[];
  final removals = <({int vaultId, int userId})>[];

  Object? failure;
  Future<VaultMember> Function(VaultMemberRole role)? changeResponse;

  @override
  Future<Vault> getVaultById(int vaultId) async => Vault(
        vaultId: vaultId,
        ownerId: 7,
        vaultType: VaultTypes.shared,
        name: 'Family',
        createdAt: DateTime.utc(2026, 9, 21),
      );

  @override
  Future<List<VaultMember>> getMembers(int vaultId) async => [
        _owner(),
        if (member != null) member!,
      ];

  @override
  Future<VaultMember> changeMemberRole(
    int vaultId,
    int userId,
    VaultMemberRole role,
  ) async {
    roleChanges.add((vaultId: vaultId, userId: userId, role: role));

    final error = failure;
    if (error != null) throw error;

    if (changeResponse != null) return changeResponse!(role);

    member = member!.copyWithRole(role);
    return member!;
  }

  @override
  Future<void> removeMember(int vaultId, int userId) async {
    removals.add((vaultId: vaultId, userId: userId));

    final error = failure;
    if (error != null) throw error;

    member = null;
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
    GoogleFonts.config.allowRuntimeFetching = false;

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

  Future<void> showScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: VaultMembersScreen(vaultId: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapAction(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> loadProviders() async {
    final access = container.listen(
      sharedVaultAccessProvider(5),
      (_, __) {},
    );
    final operation = container.listen(
      vaultMemberManagementProvider(5),
      (_, __) {},
    );

    addTearDown(access.close);
    addTearDown(operation.close);

    await container.read(sharedVaultAccessProvider(5).future);
  }

  Future<bool> submit(
    VaultMemberAction action, {
    VaultMember? member,
    VaultSession? expectedSession,
  }) {
    return container.read(vaultMemberManagementProvider(5).notifier).submit(
          member: member ?? repository.member!,
          action: action,
          expectedSession: expectedSession ?? _session(),
        );
  }

  testWidgets('owner sees actions only for the regular member', (tester) async {
    await showScreen(tester);

    expect(find.text('Make Editor'), findsOneWidget);
    expect(find.text('Remove member'), findsOneWidget);

    final ownerCard = find.widgetWithText(Card, 'owner@example.com');

    expect(
      find.descendant(
        of: ownerCard,
        matching: find.text('Remove member'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: ownerCard,
        matching: find.text('Make Viewer'),
      ),
      findsNothing,
    );
  });

  for (final role in [VaultMemberRole.viewer, VaultMemberRole.editor]) {
    testWidgets('${role.name} sees no member-management controls',
        (tester) async {
      repository.member = _member(role: role);
      container.read(session.notifier).state = _session(8);

      await showScreen(tester);

      expect(find.text('chef@example.com'), findsOneWidget);
      expect(find.text('Make Editor'), findsNothing);
      expect(find.text('Make Viewer'), findsNothing);
      expect(find.text('Remove member'), findsNothing);
    });
  }

  testWidgets('role change can be cancelled', (tester) async {
    await showScreen(tester);

    await tapAction(tester, 'Make Editor');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repository.roleChanges, isEmpty);
    expect(repository.member!.role, VaultMemberRole.viewer);
  });

  testWidgets('confirmed promotion refreshes the displayed role',
      (tester) async {
    await showScreen(tester);

    await tapAction(tester, 'Make Editor');
    await tester.tap(find.text('Change role'));
    await tester.pumpAndSettle();

    expect(
      repository.roleChanges,
      [(vaultId: 5, userId: 8, role: VaultMemberRole.editor)],
    );
    expect(
      find.text('chef@example.com now has the Editor role.'),
      findsOneWidget,
    );
    expect(find.text('Make Viewer'), findsOneWidget);
    expect(find.text('Make Editor'), findsNothing);
  });

  testWidgets('confirmed demotion changes Editor to Viewer', (tester) async {
    repository.member = _member(role: VaultMemberRole.editor);

    await showScreen(tester);
    await tapAction(tester, 'Make Viewer');
    await tester.tap(find.text('Change role'));
    await tester.pumpAndSettle();

    expect(repository.member!.role, VaultMemberRole.viewer);
    expect(find.text('Make Editor'), findsOneWidget);
  });

  testWidgets('removal can be cancelled', (tester) async {
    await showScreen(tester);

    await tapAction(tester, 'Remove member');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repository.removals, isEmpty);
    expect(repository.member, isNotNull);
  });

  testWidgets('confirmed removal uses user ID and refreshes member list',
      (tester) async {
    await showScreen(tester);

    await tapAction(tester, 'Remove member');
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(repository.removals, [(vaultId: 5, userId: 8)]);
    expect(find.text('chef@example.com'), findsNothing);
    expect(find.text('owner@example.com'), findsOneWidget);
    expect(
      find.text('chef@example.com was removed from this vault.'),
      findsOneWidget,
    );
  });

  testWidgets('backend failure preserves the member and displays explanation',
      (tester) async {
    final options = RequestOptions(path: '/vault/5/members/8');

    repository.failure = DioException(
      requestOptions: options,
      response: Response<dynamic>(
        requestOptions: options,
        statusCode: 403,
        data: {'message': 'Only the owner can remove members.'},
      ),
    );

    await showScreen(tester);
    await tapAction(tester, 'Remove member');
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('Only the owner can remove members.'), findsOneWidget);
    expect(find.text('chef@example.com'), findsOneWidget);
  });

  test('owner cannot be removed or demoted through the notifier', () async {
    await loadProviders();

    expect(
      await submit(VaultMemberAction.remove, member: _owner()),
      isFalse,
    );
    expect(
      await submit(VaultMemberAction.makeViewer, member: _owner()),
      isFalse,
    );

    expect(repository.removals, isEmpty);
    expect(repository.roleChanges, isEmpty);
  });

  test('Viewer cannot mutate members through the notifier', () async {
    container.read(session.notifier).state = _session(8);
    await loadProviders();

    expect(
      await submit(
        VaultMemberAction.makeEditor,
        expectedSession: _session(8),
      ),
      isFalse,
    );

    expect(repository.roleChanges, isEmpty);
  });

  for (final status in [NetworkStatus.offline, NetworkStatus.checking]) {
    test('${status.name} blocks a previously available action', () async {
      await loadProviders();
      container.read(network.notifier).state = status;

      expect(await submit(VaultMemberAction.remove), isFalse);
      expect(repository.removals, isEmpty);
    });
  }

  test('member changed during confirmation requires a fresh decision',
      () async {
    await loadProviders();
    final original = repository.member!;

    repository.member = original.copyWithRole(VaultMemberRole.editor);
    container.invalidate(sharedVaultAccessProvider(5));
    await container.read(sharedVaultAccessProvider(5).future);

    expect(
      await submit(VaultMemberAction.remove, member: original),
      isFalse,
    );

    expect(repository.removals, isEmpty);
  });

  test('prevents duplicate in-flight operations', () async {
    await loadProviders();

    final pending = Completer<VaultMember>();
    repository.changeResponse = (_) => pending.future;

    final first = submit(VaultMemberAction.makeEditor);
    final second = await submit(VaultMemberAction.makeEditor);

    expect(second, isFalse);
    expect(repository.roleChanges, hasLength(1));

    final updated = repository.member!.copyWithRole(VaultMemberRole.editor);
    repository.member = updated;
    pending.complete(updated);

    expect(await first, isTrue);
  });

  test('previous-session confirmation cannot remove a member', () async {
    await loadProviders();
    container.read(session.notifier).state = _session(8);

    expect(
      await submit(
        VaultMemberAction.remove,
        expectedSession: _session(7),
      ),
      isFalse,
    );

    expect(repository.removals, isEmpty);
  });

  test('late response cannot overwrite a new session', () async {
    await loadProviders();

    final pending = Completer<VaultMember>();
    repository.changeResponse = (_) => pending.future;

    final oldRequest = submit(VaultMemberAction.makeEditor);

    container.read(session.notifier).state = _session(8);
    container.read(vaultMemberManagementProvider(5));

    pending.complete(_member(role: VaultMemberRole.editor));

    expect(await oldRequest, isFalse);
    expect(
      container.read(vaultMemberManagementProvider(5)).message,
      isNull,
    );
  });
}
