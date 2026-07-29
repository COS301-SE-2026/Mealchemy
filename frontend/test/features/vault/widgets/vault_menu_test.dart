import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/auth/repositories/auth_repository.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/widgets/vault_menu.dart';

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
        authProvider
            .overrideWith((ref) => _FakeAuthNotifier(currentUserId, ref)),
      ],
      child: MaterialApp(
        home: Scaffold(body: VaultMenuButton(vault: vault)),
      ),
    );
  }

  Future<void> openMenu(WidgetTester tester) async {
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
    expect(find.text('Add member'), findsNothing);
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
    expect(find.text('Add member'), findsNothing);
    expect(find.text('Delete vault'), findsNothing);
  });

  testWidgets('owner of a shared vault sees create, add member and delete',
      (tester) async {
    await tester.pumpWidget(host(
      currentUserId: 42,
      vault: vaultOwnedBy(42, type: VaultTypes.shared),
    ));
    await openMenu(tester);

    expect(find.text('Create folder'), findsOneWidget);
    expect(find.text('Add member'), findsOneWidget);
    expect(find.text('Delete vault'), findsOneWidget);
  });
}