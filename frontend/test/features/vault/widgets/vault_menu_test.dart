import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/auth/repositories/auth_repository.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/widgets/vault_menu.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';

// Minimal JWT whose payload carries the given `sub` (user id); AuthState.userId
// decodes exactly this claim.
String _jwtForUser(int id) {
  String seg(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${seg({'alg': 'none'})}.${seg({'sub': '$id'})}.sig';
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(int id, Ref ref) : super(_UnusedRepo(), ref) {
    state = AuthState(isLoggedIn: true, token: _jwtForUser(id));
  }
}

class _UnusedRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Vault vaultOwnedBy(int ownerId, {required String type}) => Vault(
        vaultId: 1,
        ownerId: ownerId,
        vaultType: type,
        name: 'Team Vault',
        createdAt: DateTime(2026, 1, 1),
      );

  Widget host({required int currentUserId, required Vault vault}) {
    return ProviderScope(
      overrides: [
        vaultSessionProvider.overrideWithValue((
          userId: currentUserId,
          token: 'test-token',
          restoring: false,
          hasValidCredential: true,
        )),
        vaultConnectionProvider.overrideWithValue(NetworkStatus.online),
        sharedVaultAccessProvider.overrideWith((ref, vaultId) async {
          final member = VaultMember(
            id: currentUserId == vault.ownerId ? null : 44,
            vaultId: vaultId,
            userId: currentUserId,
            email: 'user@example.com',
            joinedAt: DateTime(2026, 1, 1),
            role: currentUserId == vault.ownerId
                ? VaultMemberRole.owner
                : VaultMemberRole.viewer,
          );

          return SharedVaultAccess(
            vault: vault,
            currentMember: member,
            members: [member],
          );
        }),
        authProvider
            .overrideWith((ref) => _FakeAuthNotifier(currentUserId, ref)),
      ],
      child: MaterialApp(
        home: Scaffold(body: VaultMenuButton(vault: vault)),
      ),
    );
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
  }

  testWidgets('non-owner see only the leave vault option', (tester) async {
    await tester.pumpWidget(host(
      currentUserId: 99,
      vault: vaultOwnedBy(42, type: VaultTypes.shared),
    ));
    await openMenu(tester);

    expect(find.text('Leave vault (coming soon)'), findsOneWidget);
    expect(find.text('Create folder'), findsNothing);
    expect(find.text('Invite member'), findsNothing);
    expect(find.text('Delete vault'), findsNothing);
  });

  testWidgets('owner of a private vault sees only create folder',
      (tester) async {
    await tester.pumpWidget(host(
      currentUserId: 42,
      vault: vaultOwnedBy(42, type: VaultTypes.private),
    ));
    await openMenu(tester);

    expect(find.text('Create folder'), findsOneWidget);
    // Member/delete are shared-only.
    expect(find.text('Invite member'), findsNothing);
    expect(find.text('Delete vault'), findsNothing);
  });

  testWidgets('owner of a shared vault sees create, invite member and delete',
      (tester) async {
    await tester.pumpWidget(host(
      currentUserId: 42,
      vault: vaultOwnedBy(42, type: VaultTypes.shared),
    ));
    await openMenu(tester);

    expect(find.text('Create folder'), findsOneWidget);
    expect(find.text('Invite member'), findsOneWidget);
    expect(find.text('Delete vault'), findsOneWidget);
  });

    testWidgets('the menu is disabled when offline', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vaultSessionProvider.overrideWithValue((
            userId: 42,
            token: 'test-token',
            restoring: false,
            hasValidCredential: true,
          )),
          vaultConnectionProvider.overrideWithValue(NetworkStatus.offline),
          authProvider.overrideWith((ref) => _FakeAuthNotifier(42, ref)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: VaultMenuButton(
              vault: vaultOwnedBy(42, type: VaultTypes.private),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Create folder'), findsNothing);
  });

  testWidgets('selecting delete opens the confirm dialog', (tester) async {
    await tester.pumpWidget(host(
      currentUserId: 42,
      vault: vaultOwnedBy(42, type: VaultTypes.shared),
    ));
    await openMenu(tester);
    await tester.tap(find.text('Delete vault'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Vault'), findsOneWidget);
    expect(find.textContaining('Team Vault'), findsOneWidget);
  });
}
