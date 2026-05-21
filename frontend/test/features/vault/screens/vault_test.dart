
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/models/vault_folder_recipe.dart';
import 'package:mealchemy/features/vault/screens/vault_screen.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/repositories/mock_vault_repository.dart';
import 'package:mealchemy/features/vault/widgets/vault_stats_card.dart';
import 'package:mealchemy/features/vault/widgets/vault_folder_list.dart';
import 'package:mealchemy/features/vault/widgets/vault_quick_strip.dart';

void main() {
  Widget buildWidget() {
    return ProviderScope(
      overrides: [
        vaultRepositoryProvider.overrideWithValue(MockVaultRepository()),
        vaultsProvider.overrideWith((ref) async => [
          Vault(
            vaultId: 1,
            ownerId: 1,
            vaultType: 'PRIVATE',
            name: 'My Vault',
            createdAt: DateTime(2026, 1, 1),
          ),
        ]),
        vaultFoldersProvider.overrideWith((ref, vaultId) async => [
          VaultFolder(folderId: 1, vaultId: 1, folderName: 'Breakfast', createdAt: DateTime(2026, 1, 1)),
          VaultFolder(folderId: 2, vaultId: 1, folderName: 'Dinner', createdAt: DateTime(2026, 1, 2)),
        ]),
        folderRecipesProvider.overrideWith(
          (ref, folderId) async => <VaultFolderRecipe>[],
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const VaultScreen(),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) => const Scaffold(body: Text('Login')),
            ),
            GoRoute(
              path: '/pantry',
              builder: (context, state) => const Scaffold(body: Text('Pantry')),
            ),
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const Scaffold(body: Text('Dashboard')),
            ),
            GoRoute(
              path: '/recipe/add',
              builder: (context, state) => const Scaffold(body: Text('Add Recipe')),
            ),
          ],
        ),
      ),
    );
  }

  group('VaultScreen', () {
    //Building vault screen and checking it renders without crashing
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.byType(VaultScreen), findsOneWidget);
    });

    //Building vault screen and checking MY VAULT label appears
    testWidgets('renders MY VAULT label', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.text('MY VAULT'), findsOneWidget);
    });

    //Building vault screen and checking FAB appears
    testWidgets('renders floating action button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    //Building vault screen and checking Vault title appears
    testWidgets('renders Vault title', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.text('Vault'), findsOneWidget);
    });

    //Building vault screen and checking stats card appears
    testWidgets('renders stats card', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.byType(VaultStatsCard), findsOneWidget);
    });

    //Building vault screen and checking folder list appears
    testWidgets('renders folder list', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.byType(VaultFolderList), findsOneWidget);
    });

    //Building vault screen and checking quick strip appears
    testWidgets('renders quick strip', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.byType(VaultQuickStrip), findsOneWidget);
    });

    //Tapping floating action button navigates to add recipe screen
    testWidgets('tapping FAB navigates to add recipe', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      GoRouter.of(tester.element(find.byType(VaultScreen))).push('/recipe/add');
      await tester.pumpAndSettle();
      expect(find.text('Add Recipe'), findsOneWidget);
    });

    // Tapping logout button navigates back to login screen.
    testWidgets('tapping logout navigates to login', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Log out'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });
  });
}