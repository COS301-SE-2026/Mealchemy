import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/auth/repositories/auth_repository.dart';
import 'package:mealchemy/features/external_links/models/link.dart';
import 'package:mealchemy/features/external_links/providers/link_provider.dart';
import 'package:mealchemy/features/external_links/repositories/link_repository.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/widgets/vault_folder_list.dart';

// Minimal JWT so AuthState.userId resolves to `id` (the folder menu reads it).
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

class _EmptyLinkRepository implements LinkRepository {
  @override
  Future<List<Link>> getLinks() async => const [];

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final vault = Vault(
    vaultId: 1,
    ownerId: 42,
    vaultType: VaultTypes.private,
    name: 'My Vault',
    createdAt: DateTime(2026, 1, 1),
  );

  final folders = [
    VaultFolder(
      folderId: 1,
      vaultId: 1,
      folderName: 'Breakfast',
      createdAt: DateTime(2026, 1, 1),
    ),
    VaultFolder(
      folderId: 2,
      vaultId: 1,
      folderName: 'Dinner',
      createdAt: DateTime(2026, 1, 2),
    ),
  ];

  Widget host({
    required List<VaultFolder> folderList,
    bool sharedMode = false,
  }) {
    return ProviderScope(
      overrides: [
        isSharedModeProvider.overrideWith((ref) => sharedMode),
        folderRecipeDisplayProvider.overrideWith((ref, int folderId) async => <Recipe>[]),
        authProvider.overrideWith((ref) => _FakeAuthNotifier(42, ref)),
        linkRepositoryProvider.overrideWithValue(_EmptyLinkRepository()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => Scaffold(
                body: VaultFolderList(vault: vault, folders: folderList),
              ),
            ),
            GoRoute(
              path: '/recipe/:id',
              builder: (_, __) => const Scaffold(body: Text('Recipe Detail')),
            ),
          ],
        ),
      ),
    );
  }

  group('VaultFolderList', () {
    testWidgets('renders the vault name in uppercase', (tester) async {
      await tester.pumpWidget(host(folderList: folders));
      await tester.pumpAndSettle();
      expect(find.text('MY VAULT'), findsOneWidget);
    });

    testWidgets('renders a row for each folder name', (tester) async {
      await tester.pumpWidget(host(folderList: folders));
      await tester.pumpAndSettle();
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
    });

    testWidgets('shows the empty state when there are no folders',
        (tester) async {
      await tester.pumpWidget(host(folderList: const []));
      await tester.pumpAndSettle();
      expect(find.text('No folders in this vault yet.'), findsOneWidget);
    });

    testWidgets('renders the  My Links row on a private vault', (tester) async {
      await tester.pumpWidget(host(folderList: folders));
      await tester.pumpAndSettle();
      expect(find.text('My Links'), findsOneWidget);
    });

    testWidgets('shows a menu per folder plu vault and My Links menus',
        (tester) async {
      await tester.pumpWidget(host(folderList: folders, sharedMode: false));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.more_vert), findsNWidgets(4));
    });
  });
}