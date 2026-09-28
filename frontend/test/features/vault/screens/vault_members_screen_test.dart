import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/core/routes/app_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_repository_provider.dart';
import 'package:mealchemy/features/vault/repositories/vault_repository.dart';
import 'package:mealchemy/features/vault/screens/vault_members_screen.dart';
import 'package:mealchemy/features/vault/widgets/shared_vault_members_entry.dart';

const _session = (
  userId: 7,
  token: 'test-token',
  restoring: false,
  hasValidCredential: true,
);

VaultMember _member({
  required int userId,
  required String email,
  required VaultMemberRole role,
}) =>
    VaultMember(
      id: role == VaultMemberRole.owner ? null : userId,
      vaultId: 5,
      userId: userId,
      email: email,
      joinedAt: DateTime.utc(2026, 9, 21),
      role: role,
    );

class _Repository implements VaultRepository {
  int memberCalls = 0;
  bool removed = false;

  Future<List<VaultMember>> Function()? response;

  @override
  Future<Vault> getVaultById(int vaultId) async => Vault(
        vaultId: vaultId,
        ownerId: 9,
        vaultType: VaultTypes.shared,
        name: 'Family Meals',
        createdAt: DateTime.utc(2026, 9, 21),
      );

  @override
  Future<List<VaultMember>> getMembers(int vaultId) async {
    memberCalls++;

    if (response != null) return response!();

    return [
      _member(
        userId: 9,
        email: 'owner@example.com',
        role: VaultMemberRole.owner,
      ),
      if (!removed)
        _member(
          userId: 7,
          email: 'sofia@example.com',
          role: VaultMemberRole.viewer,
        ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName}');
  }
}

void main() {
  late _Repository repository;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    repository = _Repository();
  });

  Widget host({
    VaultSession session = _session,
    NetworkStatus network = NetworkStatus.online,
  }) {
    return ProviderScope(
      overrides: [
        vaultSessionProvider.overrideWithValue(session),
        vaultConnectionProvider.overrideWithValue(network),
        vaultRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: VaultMembersScreen(vaultId: 5),
      ),
    );
  }

  testWidgets('shows owner and viewer with their roles', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('Family Meals'), findsOneWidget);
    expect(find.text('owner@example.com'), findsOneWidget);
    expect(find.text('sofia@example.com'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.text('Viewer · You'), findsOneWidget);
    expect(find.text('Your role: Viewer'), findsOneWidget);
  });

  testWidgets('signed-out user cannot see member data', (tester) async {
    await tester.pumpWidget(
      host(
        session: (
          userId: null,
          token: null,
          restoring: false,
          hasValidCredential: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('owner@example.com'), findsNothing);
    expect(repository.memberCalls, 0);
    expect(
      find.text('Sign in again to view shared-vault members.'),
      findsOneWidget,
    );
  });

  testWidgets('offline member list does not expose previous data',
      (tester) async {
    await tester.pumpWidget(host(network: NetworkStatus.offline));
    await tester.pumpAndSettle();

    expect(repository.memberCalls, 0);
    expect(find.text('owner@example.com'), findsNothing);
    expect(
      find.text(
        'Connect to the internet to check your role and view members.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('refresh removes member data after access is revoked',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('sofia@example.com'), findsOneWidget);

    repository.removed = true;
    await tester.tap(find.byTooltip('Refresh members'));
    await tester.pumpAndSettle();

    expect(find.text('sofia@example.com'), findsNothing);
    expect(find.text('owner@example.com'), findsNothing);
    expect(
      find.text(
        'This shared vault is unavailable or you no longer have access.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('member emails are hidden while access refreshes',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    final pending = Completer<List<VaultMember>>();
    repository.response = () => pending.future;

    await tester.tap(find.byTooltip('Refresh members'));
    await tester.pump();

    expect(find.text('owner@example.com'), findsNothing);
    expect(find.text('Checking vault access…'), findsOneWidget);

    pending.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('Members entry navigates and performs a fresh access check',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: SharedVaultMembersEntry(vaultId: 5),
          ),
        ),
        GoRoute(
          path: AppRoutes.vaultMembers,
          builder: (_, state) => VaultMembersScreen(
            vaultId: int.parse(state.pathParameters['vaultId']!),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vaultSessionProvider.overrideWithValue(_session),
          vaultConnectionProvider.overrideWithValue(NetworkStatus.online),
          vaultRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final beforeNavigation = repository.memberCalls;

    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();

    expect(find.byType(VaultMembersScreen), findsOneWidget);
    expect(repository.memberCalls, greaterThan(beforeNavigation));
  });

  testWidgets('actual app route checks access for direct navigation',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/vault/5/members',
      routes: appRouter.configuration.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vaultSessionProvider.overrideWithValue((
            userId: null,
            token: null,
            restoring: false,
            hasValidCredential: false,
          )),
          vaultConnectionProvider.overrideWithValue(NetworkStatus.online),
          vaultRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(VaultMembersScreen), findsOneWidget);
    expect(repository.memberCalls, 0);
    expect(find.text('owner@example.com'), findsNothing);
  });
}
