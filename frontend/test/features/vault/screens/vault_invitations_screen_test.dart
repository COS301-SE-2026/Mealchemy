import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/core/routes/app_router.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_invitation.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';
import 'package:mealchemy/features/vault/providers/owner_vault_invitations_provider.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_repository_provider.dart';
import 'package:mealchemy/features/vault/repositories/vault_repository.dart';
import 'package:mealchemy/features/vault/screens/vault_invitations_screen.dart';

VaultSession _session([int userId = 7]) => (
      userId: userId,
      token: 'token-$userId',
      restoring: false,
      hasValidCredential: true,
    );

VaultInvitation _invite({
  int id = 12,
  String email = 'chef@example.com',
  VaultInvitationStatus status = VaultInvitationStatus.pending,
}) =>
    VaultInvitation(
      invitationId: id,
      vaultId: 5,
      vaultName: 'Family',
      invitedEmail: email,
      invitedByEmail: 'owner@example.com',
      status: status,
      createdAt: DateTime.utc(2020, 1, 1),
      expiresAt: DateTime.utc(2020, 1, 8),
    );

class _Repository implements VaultRepository {
  VaultMemberRole role = VaultMemberRole.owner;
  int historyCalls = 0;
  final sent = <String>[];
  final cancelled = <int>[];
  final invitations = <VaultInvitation>[];

  Future<VaultInvitation> Function(String email)? sendResponse;
  bool failHistory = false;

  @override
  Future<Vault> getVaultById(int vaultId) async => Vault(
        vaultId: vaultId,
        ownerId: role == VaultMemberRole.owner ? 7 : 9,
        vaultType: VaultTypes.shared,
        name: 'Family',
        createdAt: DateTime.utc(2026, 9, 21),
      );

  @override
  Future<List<VaultMember>> getMembers(int vaultId) async => [
        VaultMember(
          id: role == VaultMemberRole.owner ? null : 1,
          vaultId: vaultId,
          userId: 7,
          email: 'owner@example.com',
          joinedAt: DateTime.utc(2026, 9, 21),
          role: role,
        ),
      ];

  @override
  Future<List<VaultInvitation>> getVaultInvitations(int vaultId) async {
    historyCalls++;
    if (failHistory) throw StateError('History unavailable');
    return [...invitations];
  }

  @override
  Future<VaultInvitation> createInvitation(int vaultId, String email) async {
    sent.add(email);

    if (sendResponse != null) return sendResponse!(email);

    final invite = _invite(id: 20 + sent.length, email: email);
    invitations.add(invite);
    return invite;
  }

  @override
  Future<void> cancelInvitation(int invitationId) async {
    cancelled.add(invitationId);
    final index = invitations.indexWhere(
      (invite) => invite.invitationId == invitationId,
    );
    invitations[index] = invitations[index].withResponse(
      VaultInvitationStatus.cancelled,
      DateTime.now().toUtc(),
    );
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
          home: VaultInvitationsScreen(vaultId: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> sendEmail(WidgetTester tester, String email) async {
    await tester.enterText(find.byType(TextField), email);
    await tester.tap(find.text('Send invitation'));
    await tester.pumpAndSettle();
  }

  testWidgets('owner sees invite form and empty history', (tester) async {
    await showScreen(tester);

    expect(find.text('Send invitation'), findsOneWidget);
    expect(find.text('No invitations sent yet.'), findsOneWidget);
    expect(
      find.textContaining('They will join as a Viewer'),
      findsOneWidget,
    );
  });

  for (final role in [VaultMemberRole.viewer, VaultMemberRole.editor]) {
    testWidgets('${role.name} cannot load invitation history', (tester) async {
      repository.role = role;

      await showScreen(tester);

      expect(repository.historyCalls, 0);
      expect(find.byType(TextField), findsNothing);
      expect(
        find.text('Only the vault owner can manage invitations.'),
        findsOneWidget,
      );
    });
  }

  testWidgets('invalid email and self-invitation make no request',
      (tester) async {
    await showScreen(tester);

    await sendEmail(tester, 'invalid');
    expect(find.text('Enter a valid email address.'), findsOneWidget);

    await sendEmail(tester, 'OWNER@example.com');
    expect(find.text('You cannot invite yourself.'), findsOneWidget);

    expect(repository.sent, isEmpty);
  });

  testWidgets('sending trims email and refreshes invitation history',
      (tester) async {
    await showScreen(tester);

    await sendEmail(tester, '  chef@example.com  ');

    expect(repository.sent, ['chef@example.com']);
    expect(
      find.text('Invitation sent to chef@example.com.'),
      findsOneWidget,
    );
    final invitationCard = find.widgetWithText(
      Card,
      'chef@example.com',
    );

    expect(invitationCard, findsOneWidget);
    expect(
      find.descendant(
        of: invitationCard,
        matching: find.text('Pending'),
      ),
      findsOneWidget,
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
  });

  testWidgets('backend duplicate explanation is displayed', (tester) async {
    repository.sendResponse = (_) async {
      final options = RequestOptions(path: '/vault/5/invitations');
      throw DioException(
        requestOptions: options,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: 409,
          data: {'message': 'User already has a pending invitation for vault.'},
        ),
      );
    };

    await showScreen(tester);
    await sendEmail(tester, 'chef@example.com');

    expect(
      find.text('User already has a pending invitation for vault.'),
      findsOneWidget,
    );
  });

  testWidgets('cancelling requires confirmation and keeps history',
      (tester) async {
    repository.invitations.add(_invite());
    await showScreen(tester);

    await tester.ensureVisible(find.text('Cancel invitation'));
    await tester.tap(find.text('Cancel invitation'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keep invite'));
    await tester.pumpAndSettle();
    expect(repository.cancelled, isEmpty);

    await tester.tap(find.text('Cancel invitation'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel invite'));
    await tester.pumpAndSettle();

    expect(repository.cancelled, [12]);
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Cancel invitation'), findsNothing);
  });

  testWidgets('accepted invitation has no cancellation action', (tester) async {
    repository.invitations.add(
      _invite(status: VaultInvitationStatus.accepted),
    );
    await showScreen(tester);

    expect(find.text('Accepted'), findsOneWidget);
    expect(find.text('Cancel invitation'), findsNothing);
  });

  testWidgets('past expiry does not change a pending invitation',
      (tester) async {
    repository.invitations.add(_invite());
    await showScreen(tester);

    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Expired'), findsNothing);
    expect(find.text('Cancel invitation'), findsOneWidget);
  });

  testWidgets('history failure offers retry', (tester) async {
    repository.failHistory = true;
    await showScreen(tester);

    expect(find.text('Retry invitations'), findsOneWidget);

    repository.failHistory = false;
    await tester.ensureVisible(find.text('Retry invitations'));
    await tester.tap(find.text('Retry invitations'));
    await tester.pumpAndSettle();

    expect(find.text('No invitations sent yet.'), findsOneWidget);
  });

  testWidgets('offline access makes no history or mutation requests',
      (tester) async {
    container.read(network.notifier).state = NetworkStatus.offline;

    await showScreen(tester);

    expect(repository.historyCalls, 0);
    expect(repository.sent, isEmpty);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('direct app route denies invitation access to a Viewer',
      (tester) async {
    repository.role = VaultMemberRole.viewer;

    final router = GoRouter(
      initialLocation: '/vault/5/invitations',
      routes: appRouter.configuration.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(VaultInvitationsScreen), findsOneWidget);
    expect(repository.historyCalls, 0);
    expect(find.byType(TextField), findsNothing);
  });

  test('operation prevents duplicate submissions while request is running',
      () async {
    final accessSubscription = container.listen(
      sharedVaultAccessProvider(5),
      (_, __) {},
    );
    addTearDown(accessSubscription.close);
    await container.read(sharedVaultAccessProvider(5).future);

    final operationSubscription = container.listen(
      ownerVaultInvitationOperationProvider(5),
      (_, __) {},
    );
    addTearDown(operationSubscription.close);

    final pending = Completer<VaultInvitation>();
    repository.sendResponse = (_) => pending.future;

    final notifier = container.read(
      ownerVaultInvitationOperationProvider(5).notifier,
    );

    final first = notifier.send(
      email: 'chef@example.com',
      expectedSession: _session(),
    );

    final second = await notifier.send(
      email: 'chef@example.com',
      expectedSession: _session(),
    );

    expect(second, isFalse);
    expect(repository.sent, ['chef@example.com']);

    pending.complete(_invite());
    expect(await first, isTrue);
  });

  test('confirmation from a previous session cannot cancel an invitation',
      () async {
    container.read(session.notifier).state = _session(8);

    final subscription = container.listen(
      ownerVaultInvitationOperationProvider(5),
      (_, __) {},
    );
    addTearDown(subscription.close);

    final result = await container
        .read(ownerVaultInvitationOperationProvider(5).notifier)
        .cancel(
          invitation: _invite(),
          expectedSession: _session(7),
        );

    expect(result, isFalse);
    expect(repository.cancelled, isEmpty);
  });

  test('late send result cannot overwrite a new session', () async {
    final accessSubscription = container.listen(
      sharedVaultAccessProvider(5),
      (_, __) {},
    );
    addTearDown(accessSubscription.close);
    await container.read(sharedVaultAccessProvider(5).future);

    final operationSubscription = container.listen(
      ownerVaultInvitationOperationProvider(5),
      (_, __) {},
    );
    addTearDown(operationSubscription.close);

    final pending = Completer<VaultInvitation>();
    repository.sendResponse = (_) => pending.future;

    final oldOperation =
        container.read(ownerVaultInvitationOperationProvider(5).notifier).send(
              email: 'chef@example.com',
              expectedSession: _session(7),
            );

    container.read(session.notifier).state = _session(8);
    container.read(ownerVaultInvitationOperationProvider(5));

    pending.complete(_invite());
    expect(await oldOperation, isFalse);

    expect(
      container.read(ownerVaultInvitationOperationProvider(5)).message,
      isNull,
    );
  });
}
