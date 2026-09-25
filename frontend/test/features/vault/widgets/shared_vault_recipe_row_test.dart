import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';
import 'package:mealchemy/features/vault/widgets/shared_vault_recipe_row.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> showRow(
    WidgetTester tester, {
    required VaultMemberRole role,
    int recipeOwnerId = 9,
  }) async {
    final userId = role == VaultMemberRole.owner ? 7 : 8;

    final member = VaultMember(
      id: role == VaultMemberRole.owner ? null : 44,
      vaultId: 5,
      userId: userId,
      email: 'user@example.com',
      joinedAt: DateTime(2026, 1, 1),
      role: role,
    );

    final access = SharedVaultAccess(
      vault: Vault(
        vaultId: 5,
        ownerId: 7,
        vaultType: VaultTypes.shared,
        name: 'Family',
        createdAt: DateTime(2026, 1, 1),
      ),
      currentMember: member,
      members: [member],
    );

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            body: SharedVaultRecipeRow(
              vaultId: 5,
              folderId: 12,
              recipe: Recipe(
                recipeId: 99,
                ownerId: recipeOwnerId,
                title: 'Shared copy',
              ),
              onDeleteConfirmed: () {},
            ),
          ),
        ),
        GoRoute(
          path: '/edit-recipe/:id',
          builder: (_, state) => Scaffold(
            body: Text(
              'Editing ${state.pathParameters['id']} '
              'in ${state.uri.queryParameters['vaultId']} '
              'folder ${state.uri.queryParameters['folderId']}',
            ),
          ),
        ),
        GoRoute(
          path: '/recipe/:id',
          builder: (_, state) => Scaffold(
            body: Text('Viewing ${state.pathParameters['id']}'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vaultSessionProvider.overrideWithValue((
            userId: userId,
            token: 'preview-token',
            restoring: false,
            hasValidCredential: true,
          )),
          vaultConnectionProvider.overrideWithValue(NetworkStatus.online),
          sharedVaultAccessProvider.overrideWith((ref, id) async => access),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('Editor opens the copied recipe with vault context',
      (tester) async {
    await showRow(tester, role: VaultMemberRole.editor);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Editing 99 in 5 folder 12'), findsOneWidget);
  });

  testWidgets('vault Owner sees edit controls', (tester) async {
    await showRow(tester, role: VaultMemberRole.owner);

    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
  });

  testWidgets('Viewer sees edit controls for their own copy', (tester) async {
    await showRow(
      tester,
      role: VaultMemberRole.viewer,
      recipeOwnerId: 8,
    );

    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
  });

  testWidgets('Viewer cannot edit or delete someone else’s copy',
      (tester) async {
    await showRow(tester, role: VaultMemberRole.viewer);

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);

    await tester.tap(find.text('Shared copy'));
    await tester.pumpAndSettle();

    expect(find.text('Viewing 99'), findsOneWidget);
  });
}
