import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/auth/repositories/auth_repository.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/widgets/folder_menu.dart';

// Builds a minimal JWT whose payload carries the given `sub` (user id).
// AuthState.userId decodes exactly this claim.
String _jwtForUser(int id) {
  String seg(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  final header = seg({'alg': 'none', 'typ': 'JWT'});
  final payload = seg({'sub': '$id'});
  return '$header.$payload.sig';
}

// A notifier that starts already logged in with a fixed token, so
// authProvider.userId resolves to `id`.
class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(int id, Ref ref) : super(_UnusedRepo(), ref) {
    state = AuthState(isLoggedIn: true, token: _jwtForUser(id));
  }
}

// AuthNotifier needs an AuthRepository; it's never called in these tests.
class _UnusedRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final folder = VaultFolder(
    folderId: 10,
    vaultId: 1,
    folderName: 'Breakfast',
    createdAt: DateTime(2026, 1, 1),
  );

  final vault = Vault(
    vaultId: 1,
    ownerId: 42,
    vaultType: VaultTypes.shared,
    name: 'Team Vault',
    createdAt: DateTime(2026, 1, 1),
  );

  Widget host({required int currentUserId}) {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => _FakeAuthNotifier(currentUserId, ref)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: FolderMenuButton(vault: vault, folder: folder),
        ),
      ),
    );
  }

  testWidgets('owner sees rename and delete actions', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(currentUserId: 42));
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Rename folder'), findsOneWidget);
    expect(find.text('Delete folder'), findsOneWidget);
  });

testWidgets('non-owner cannot open the folder menu', (tester) async {
     await tester.pumpWidget(host(currentUserId: 99));
     await tester.tap(find.byIcon(Icons.more_vert));
     await tester.pumpAndSettle();

     expect(find.text('Rename folder'), findsNothing);
     expect(find.text('Delete folder'), findsNothing);
     expect(find.text('Only the owner can manage folders.'), findsNothing);
   });
}