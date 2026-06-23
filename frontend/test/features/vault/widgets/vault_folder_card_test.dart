import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/vault/widgets/vault_folder_card.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/repositories/mock_vault_repository.dart';

void main() {
  final mockFolder = VaultFolder(
    folderId: 1,
    vaultId: 1,
    name: 'Breakfast',
    createdAt: DateTime(2026, 1, 1),
  );

  Widget buildWidget() {
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
                body: VaultFolderCard(folder: mockFolder),
              ),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) => const Scaffold(body: Text('Login')),
            ),
            GoRoute(
              path: '/recipe/:id',
              builder: (context, state) => const Scaffold(body: Text('Recipe Detail')),
            ),
          ],
        ),
      ),
    );
  }

  group('VaultFolderCard', () {
    // Testing rendering
    //folder name rendering
    testWidgets('renders folder name', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Breakfast'), findsOneWidget);
    });

    //folder icon rendering
    testWidgets('renders folder icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.folder_rounded), findsOneWidget);
    });

    //Testing folder expansion
    //tapping to expand
    testWidgets('expands when tapped', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byType(InkWell).first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byIcon(Icons.folder_open_rounded), findsOneWidget);
    });

    //Tapping a recipe row inside an expanded folder navigates to recipe detail
    testWidgets('tapping a recipe row navigates to recipe detail', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      // expand the folder first
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();
      // tap the first recipe row (index 1, index 0 is the folder header)
      await tester.tap(find.byType(InkWell).at(1));
      await tester.pumpAndSettle();
      expect(find.text('Recipe Detail'), findsOneWidget);
    });
  });
}