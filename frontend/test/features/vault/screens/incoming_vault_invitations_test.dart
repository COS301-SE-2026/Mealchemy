import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/core/routes/app_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_invitation.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';
import 'package:mealchemy/features/vault/providers/incoming_vault_invitations_provider.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_repository_provider.dart';
import 'package:mealchemy/features/vault/repositories/vault_repository.dart';
import 'package:mealchemy/features/vault/screens/incoming_vault_invitations_screen.dart';

VaultSession _session([int? userId = 7]) => (
      userId: userId,
      token: userId == null ? null : 'token-$userId',
      restoring: false,
      hasValidCredential: userId != null,
    );

VaultInvitation _invite() => VaultInvitation(
      invitationId: 12,
      vaultId: 5,
      vaultName: 'Family Meals',
      invitedEmail: 'sofia@example.com',
      invitedByEmail: 'owner@example.com',
      status: VaultInvitationStatus.pending,
      createdAt: DateTime.utc(2020, 1, 1),
      expiresAt: DateTime.utc(2020, 1, 8),
    );

VaultMember _member() => VaultMember(
      id: 22,
      vaultId: 5,
      userId: 7,
      email: 'sofia@example.com',
      joinedAt: DateTime.utc(2026, 9, 23),
      role: VaultMemberRole.viewer,
    );

class _Repository implements VaultRepository {
  final invitations = <VaultInvitation>[_invite()];
  final accepted = <int>[];
  final declined = <int>[];
  int loads = 0;
  bool joined = false;
  bool failLoad = false;

  Future<VaultMember> Function()? acceptResponse;

  @override
  Future<List<VaultInvitation>> getMyInvitations() async {
    loads++;
    if (failLoad) throw StateError('Unable to load');
    return [...invitations];
  }

  @override
  Future<VaultMember> acceptInvitation(int invitationId) async {
    accepted.add(invitationId);
    if (acceptResponse != null) return acceptResponse!();

    joined = true;
    invitations.removeWhere(
      (invite) => invite.invitationId == invitationId,
    );
    return _member();
  }

  @override
  Future<VaultInvitation> declineInvitation(int invitationId) async {
    declined.add(invitationId);
    final invite = invitations.firstWhere(
      (invite) => invite.invitationId == invitationId,
    );
    invitations.remove(invite);

    return invite.withResponse(
      VaultInvitationStatus.declined,
      DateTime.now().toUtc(),
    );
  }

  @override
  Future<List<Vault>> getMyVaults() async => [
        if (joined)
          Vault(
            vaultId: 5,
            ownerId: 9,
            vaultType: VaultTypes.shared,
            name: 'Family Meals',
            createdAt: DateTime.utc(2026, 9, 21),
          ),
      ];

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
        vaultsProvider.overrideWith((ref) => repository.getMyVaults()),
      ],
    );

    addTearDown(container.dispose);
  });

  Future<void> showScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: IncomingVaultInvitationsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> loadProviders() async {
    final history = container.listen(
      incomingVaultInvitationsProvider,
      (_, __) {},
    );
    final operation = container.listen(
      incomingVaultInvitationOperationProvider,
      (_, __) {},
    );
    addTearDown(history.close);
    addTearDown(operation.close);

    await container.read(incomingVaultInvitationsProvider.future);
  }

  testWidgets('shows invitation and Viewer explanation', (tester) async {
    await showScreen(tester);

    expect(find.text('Family Meals'), findsOneWidget);
    expect(find.text('Invited by owner@example.com'), findsOneWidget);
    expect(
        find.textContaining('join a shared vault as a Viewer'), findsOneWidget);
    expect(find.text('Accept invitation'), findsOneWidget);
  });

  testWidgets('accepts, removes invitation and refreshes accessible vaults',
      (tester) async {
    final subscription = container.listen(vaultsProvider, (_, __) {});
    addTearDown(subscription.close);
    expect(await container.read(vaultsProvider.future), isEmpty);

    await showScreen(tester);
    await tester.tap(find.text('Accept invitation'));
    await tester.pumpAndSettle();

    expect(repository.accepted, [12]);
    expect(find.text('You joined Family Meals as a Viewer.'), findsOneWidget);
    expect(find.text('Open vault'), findsOneWidget);
    expect(find.text('No pending invitations.'), findsOneWidget);
    expect(
      (await container.read(vaultsProvider.future)).single.vaultId,
      5,
    );
  });

  testWidgets('decline can be cancelled before submission', (tester) async {
    await showScreen(tester);

    await tester.tap(find.text('Decline invitation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep invite'));
    await tester.pumpAndSettle();

    expect(repository.declined, isEmpty);
    expect(find.text('Family Meals'), findsOneWidget);
  });

  testWidgets('confirmed decline removes invitation without joining',
      (tester) async {
    await showScreen(tester);

    await tester.tap(find.text('Decline invitation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Decline'));
    await tester.pumpAndSettle();

    expect(repository.declined, [12]);
    expect(repository.joined, isFalse);
    expect(find.text('Invitation declined.'), findsOneWidget);
    expect(find.text('No pending invitations.'), findsOneWidget);
    expect(find.text('Open vault'), findsNothing);
  });

  testWidgets('load failure offers retry', (tester) async {
    repository.failLoad = true;
    await showScreen(tester);

    expect(find.text('Retry invitations'), findsOneWidget);

    repository.failLoad = false;
    await tester.tap(find.text('Retry invitations'));
    await tester.pumpAndSettle();

    expect(find.text('Family Meals'), findsOneWidget);
  });

  testWidgets('signed-out users make no invitation request', (tester) async {
    container.read(session.notifier).state = _session(null);
    await showScreen(tester);

    expect(repository.loads, 0);
    expect(
        find.text('Sign in again to view your invitations.'), findsOneWidget);
    expect(find.text('Family Meals'), findsNothing);
  });

  for (final status in [NetworkStatus.offline, NetworkStatus.checking]) {
    testWidgets('${status.name} prevents invitation loading', (tester) async {
      container.read(network.notifier).state = status;
      await showScreen(tester);

      expect(repository.loads, 0);
      expect(find.text('Accept invitation'), findsNothing);
    });
  }

  testWidgets('409 displays backend explanation and refreshes invitations',
      (tester) async {
    repository.acceptResponse = () async {
      repository.invitations.clear();
      final options = RequestOptions(path: '/invitations/12/accept');
      throw DioException(
        requestOptions: options,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: 409,
          data: {'message': 'Invitation has the wrong status.'},
        ),
      );
    };

    await showScreen(tester);
    await tester.tap(find.text('Accept invitation'));
    await tester.pumpAndSettle();

    expect(find.text('Invitation has the wrong status.'), findsOneWidget);
    expect(find.text('No pending invitations.'), findsOneWidget);
    expect(find.text('Open vault'), findsNothing);
  });

  testWidgets('Open vault selects shared mode and the accepted vault',
      (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.incomingVaultInvitations,
      routes: [
        GoRoute(
          path: AppRoutes.incomingVaultInvitations,
          builder: (_, __) => const IncomingVaultInvitationsScreen(),
        ),
        GoRoute(
          path: AppRoutes.vault,
          builder: (_, __) => const Scaffold(body: Text('Vault destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Accept invitation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open vault'));
    await tester.pumpAndSettle();

    expect(find.text('Vault destination'), findsOneWidget);
    expect(container.read(isSharedModeProvider), isTrue);
    expect(container.read(selectedVaultIdProvider), 5);
  });

  testWidgets('actual route requires a signed-in session', (tester) async {
    container.read(session.notifier).state = _session(null);

    final router = GoRouter(
      initialLocation: AppRoutes.incomingVaultInvitations,
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

    expect(find.byType(IncomingVaultInvitationsScreen), findsOneWidget);
    expect(repository.loads, 0);
  });

  test('past expiry timestamp does not prevent a pending invitation response',
      () async {
    await loadProviders();

    final accepted = await container
        .read(incomingVaultInvitationOperationProvider.notifier)
        .respond(
          invitation: _invite(),
          accept: true,
          expectedSession: _session(),
        );

    expect(accepted, isTrue);
    expect(repository.accepted, [12]);
  });

  test('prevents duplicate in-flight and completed submissions', () async {
    await loadProviders();
    final pending = Completer<VaultMember>();
    repository.acceptResponse = () => pending.future;

    final notifier = container.read(
      incomingVaultInvitationOperationProvider.notifier,
    );

    final first = notifier.respond(
      invitation: _invite(),
      accept: true,
      expectedSession: _session(),
    );

    expect(
      await notifier.respond(
        invitation: _invite(),
        accept: true,
        expectedSession: _session(),
      ),
      isFalse,
    );

    pending.complete(_member());
    expect(await first, isTrue);

    expect(
      await notifier.respond(
        invitation: _invite(),
        accept: true,
        expectedSession: _session(),
      ),
      isFalse,
    );
    expect(repository.accepted, [12]);
  });

  test('rechecks connectivity before responding', () async {
    await loadProviders();
    container.read(network.notifier).state = NetworkStatus.offline;

    final result = await container
        .read(incomingVaultInvitationOperationProvider.notifier)
        .respond(
          invitation: _invite(),
          accept: true,
          expectedSession: _session(),
        );

    expect(result, isFalse);
    expect(repository.accepted, isEmpty);
  });

  test('confirmation from a previous session cannot decline', () async {
    await loadProviders();
    container.read(session.notifier).state = _session(8);

    final result = await container
        .read(incomingVaultInvitationOperationProvider.notifier)
        .respond(
          invitation: _invite(),
          accept: false,
          expectedSession: _session(7),
        );

    expect(result, isFalse);
    expect(repository.declined, isEmpty);
  });

  test('late acceptance from the old session cannot expose Open vault',
      () async {
    await loadProviders();
    final pending = Completer<VaultMember>();
    repository.acceptResponse = () => pending.future;

    final oldResponse = container
        .read(incomingVaultInvitationOperationProvider.notifier)
        .respond(
          invitation: _invite(),
          accept: true,
          expectedSession: _session(7),
        );

    container.read(session.notifier).state = _session(8);
    container.read(incomingVaultInvitationOperationProvider);

    pending.complete(_member());
    expect(await oldResponse, isFalse);

    final state = container.read(incomingVaultInvitationOperationProvider);
    expect(state.joinedVaultId, isNull);
    expect(state.message, isNull);
    expect(container.read(selectedVaultIdProvider), isNull);
  });
}
