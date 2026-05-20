import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/vault/widgets/vault_folder_list.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/repositories/mock_vault_repository.dart';

void main() {
  final mockFolders = [
    VaultFolder(
      folderId: 1,
      vaultId: 1,
      name: 'Breakfast',
      createdAt: DateTime(2026, 1, 1),
    ),
    VaultFolder(
      folderId: 2,
      vaultId: 1,
      name: 'Dinner',
      createdAt: DateTime(2026, 1, 2),
    ),
  ];

  Widget buildWidget(List<VaultFolder> folders) {
    return ProviderScope(
      overrides: [
        vaultRepositoryProvider.overrideWithValue(MockVaultRepository()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: VaultFolderList(folders: folders),
              ),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) => const Scaffold(body: Text('Login')),
            ),
          ],
        ),
      ),
    );
  }

  group('VaultFolderList', () {
    //Testing Rendering
    //Page title rendering
    testWidgets('renders  Private Vault label', (tester) async {
      await tester.pumpWidget(buildWidget(mockFolders));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Private Vault'), findsOneWidget);
    });

    //count badge rendering
    testWidgets('renders correct folder count', (tester) async {
      await tester.pumpWidget(buildWidget(mockFolders));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('2 FOLDERS'), findsOneWidget);
    });

    //folder names rendering
    testWidgets('renders folder names', (tester ) async {
      await tester.pumpWidget(buildWidget(mockFolders ));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
    });

    //empty state  
    testWidgets('renders empty state when no folders', (tester) async {
      await tester.pumpWidget( buildWidget([]));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('No folders yet'), findsOneWidget);
    });

    //empty state subtitle rendering
    testWidgets('renders  empty state subtitle', (tester) async {
      await tester.pumpWidget( buildWidget([]));
      await tester.pump(const Duration(milliseconds : 500));
      expect(find.text('Tap + to create your first folder'), findsOneWidget);
    });

    //lock icon rendering
    testWidgets('renders  lock icon', (tester) async {
      await tester.pumpWidget(buildWidget(mockFolders));

      await tester.pump(const  Duration(milliseconds: 500));
      expect(find.byIcon(Icons.lock_outline_rounded ), findsOneWidget);
    });
  });
}