import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/widgets/vault_folder_card.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final folder = VaultFolder(
    folderId: 1,
    vaultId: 1,
    folderName: 'Breakfast',
    createdAt: DateTime(2026, 1, 1),
  );

  const recipes = [
    Recipe(recipeId: 7, title: 'Pancakes', cuisineType: 'american'),
    Recipe(recipeId: 8, title: 'Omelette'),
  ];

  Widget host({List<Recipe> folderRecipes = recipes}) {
    return ProviderScope(
      overrides: [
        folderRecipeDisplayProvider(1).overrideWith((ref) async => folderRecipes),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => Scaffold(body: VaultFolderCard(folder: folder)),
            ),
            GoRoute(
              path: '/recipe/:id',
              builder: (_, __) =>
                  const Scaffold(body: Text('Recipe Detail')),
            ),
          ],
        ),
      ),
    );
  }

  group('VaultFolderCard', () {
    testWidgets('renders the folder name and closed folder icon',
        (tester) async {
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.byIcon(Icons.folder_rounded), findsOneWidget);
    });

    testWidgets('shows the recipe count in the metadata line', (tester) async {
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      // "2 recipes  |  Created 1 Jan 2026"
      expect(find.textContaining('2 recipes'), findsOneWidget);
    });

    testWidgets('expands when tapped, swapping to the open folder icon',
        (tester) async {
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.folder_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.folder_open_rounded), findsOneWidget);
      // Recipe rows are now visible.
      expect(find.text('Pancakes'), findsOneWidget);
      expect(find.text('Omelette'), findsOneWidget);
    });

    testWidgets('shows the empty state when the folder has no recipes',
        (tester) async {
      await tester.pumpWidget(host(folderRecipes: const []));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.folder_rounded));
      await tester.pumpAndSettle();

      expect(find.text('No recipes in this folder yet.'), findsOneWidget);
    });

    testWidgets('tapping a recipe row navigates to recipe detail',
        (tester) async {
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.folder_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pancakes'));
      await tester.pumpAndSettle();

      expect(find.text('Recipe Detail'), findsOneWidget);
    });
  });
}