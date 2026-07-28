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
import 'package:mealchemy/features/vault/widgets/vault_folder_row.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final vault = Vault(
    vaultId: 1,
    ownerId: 42,
    vaultType: VaultTypes.private,
    name: 'My Vault',
    createdAt: DateTime(2026, 1, 1),
  );

  final folder = VaultFolder(
    folderId: 1,
    vaultId: 1,
    folderName: 'Breakfast',
    createdAt: DateTime(2026, 1, 5),
  );

  const recipes = [
    Recipe(recipeId: 7, title: 'Pancakes'),
    Recipe(recipeId: 8, title: 'Omelette'),
  ];

  
  Widget host({List<Recipe> folderRecipes = recipes}) {
    return ProviderScope(
      overrides: [
        folderRecipeDisplayProvider(1)
            .overrideWith((ref) async => folderRecipes),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => Scaffold(
                body: VaultFolderRow(vault: vault, folder: folder),
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

  testWidgets('renders the folder name and closed folder icon', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.byIcon(Icons.folder_rounded), findsOneWidget);
  });

  testWidgets('shows the recipe count and created date in the metadata line',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    // "2 recipes · Created 5 Jan 2026"
    expect(find.textContaining('2 recipes'), findsOneWidget);
    expect(find.textContaining('5 Jan 2026'), findsOneWidget);
  });

  testWidgets('expanding reveals the recipe rows and the open folder icon',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.folder_open_rounded), findsOneWidget);
    expect(find.text('Pancakes'), findsOneWidget);
    expect(find.text('Omelette'), findsOneWidget);
  });

  testWidgets('expanding an empty folder shows the empty message',
      (tester) async {
    await tester.pumpWidget(host(folderRecipes: const []));
    await tester.pumpAndSettle();

    // Metadata reads "0 recipes ..."; expand to see the empty body.
    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();

    expect(find.text('No recipes in this folder yet.'), findsOneWidget);
  });
}