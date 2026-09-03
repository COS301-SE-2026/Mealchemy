import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/screens/vault_screen.dart';
import 'package:mealchemy/features/vault/widgets/vault_folder_list.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final vault = Vault(
    vaultId: 1,
    ownerId: 1,
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

  Widget buildWidget({
    Future<List<Vault>>? vaultsFuture,
    int cartCount = 0,
    bool sharedMode = false,
    Vault? selected,
  }) {
    return ProviderScope(
      overrides: [
        vaultsProvider
            .overrideWith((ref) => vaultsFuture ?? Future.value([vault])),
        selectedVaultProvider.overrideWithValue(selected ?? vault),
        isSharedModeProvider.overrideWith((ref) => sharedMode),
        vaultFoldersProvider.overrideWith((ref, vaultId) async => folders),
        folderRecipeDisplayProvider
            .overrideWith((ref, folderId) async => <Recipe>[]),
        shoppingListCountProvider.overrideWith((ref) => cartCount),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (_, __) => const VaultScreen()),
            GoRoute(
              path: '/add-recipe',
              builder: (_, __) => const Scaffold(body: Text('Add Recipe')),
            ),
            GoRoute(
              path: '/dashboard',
              builder: (_, __) => const Scaffold(body: Text('Dashboard')),
            ),
          ],
        ),
      ),
    );
  }

  group('VaultScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.byType(VaultScreen), findsOneWidget);
    });

    testWidgets('renders the Vault hero title', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.text('Vault'), findsOneWidget);
    });

    testWidgets('renders the folder list with the vault name label',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byType(VaultFolderList), findsOneWidget);
      expect(find.text('MY VAULT'), findsOneWidget); // vault.name.toUpperCase()
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
    });

    testWidgets('renders the add floating action button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('tapping the FAB navigates to add recipe', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add Recipe'), findsOneWidget);
    });

    testWidgets('shows an error state when no vault is found', (tester) async {
      await tester.pumpWidget(buildWidget(vaultsFuture: Future.value([])));
      await tester.pumpAndSettle();

      expect(find.text('Unable to load vault.'), findsOneWidget);
      expect(find.textContaining('No vault found.'), findsOneWidget);
    });
  });

  testWidgets('shows cart badge when shopping lists exist', (tester) async {
    await tester.pumpWidget(buildWidget(cartCount: 2));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
  });
}
