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
import 'package:mealchemy/features/recipe/models/recipe_edit_lock.dart';
import 'package:mealchemy/features/recipe/providers/shared_recipe_lock_provider.dart';
import 'package:mealchemy/features/recipe/providers/shared_recipe_edit_provider.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<GoRouter> showRow(
    WidgetTester tester, {
    required VaultMemberRole role,
    int recipeOwnerId = 9,
    RecipeEditLock? lock,
    Future<bool> Function()? checkDeleteAccess,
    VoidCallback? onDelete,
    VoidCallback? onAccessLoad,
    VoidCallback? onLockLoad,
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
              onDeleteConfirmed: onDelete ?? () {},
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
          sharedRecipeLockProvider.overrideWith((ref, target) async {
            onLockLoad?.call();
            return lock;
          }),
          sharedRecipeEditAccessProvider.overrideWith((ref, target) async {
            return await (checkDeleteAccess?.call() ??
                Future<bool>.value(true));
          }),
          vaultSessionProvider.overrideWithValue((
            userId: userId,
            token: 'preview-token',
            restoring: false,
            hasValidCredential: true,
          )),
          vaultConnectionProvider.overrideWithValue(NetworkStatus.online),
          sharedVaultAccessProvider.overrideWith((ref, id) async {
            onAccessLoad?.call();
            return access;
          }),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
    return router;
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

  testWidgets('another holder disables Edit and shows their identity',
      (tester) async {
    await showRow(
      tester,
      role: VaultMemberRole.editor,
      lock: RecipeEditLock(
        recipeId: 99,
        lockedByUserId: 10,
        lockedByEmail: 'gabriela@example.com',
        acquiredAt: DateTime.utc(2026, 9, 27),
        expiresAt: DateTime.utc(2026, 9, 27, 0, 1, 30),
      ),
    );

    final editButton = find.ancestor(
      of: find.byIcon(Icons.edit_outlined),
      matching: find.byType(IconButton),
    );

    expect(tester.widget<IconButton>(editButton).onPressed, isNull);
    expect(
      find.text('Being edited by gabriela@example.com.'),
      findsOneWidget,
    );
  });

  testWidgets('returning from editing refreshes access and lock status',
      (tester) async {
    var accessLoads = 0;
    var lockLoads = 0;

    final router = await showRow(
      tester,
      role: VaultMemberRole.editor,
      onAccessLoad: () => accessLoads++,
      onLockLoad: () => lockLoads++,
    );

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Editing 99 in 5 folder 12'), findsOneWidget);

    final accessLoadsBeforeReturn = accessLoads;
    final lockLoadsBeforeReturn = lockLoads;

    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('Shared copy'), findsOneWidget);
    expect(accessLoads, greaterThan(accessLoadsBeforeReturn));
    expect(lockLoads, greaterThan(lockLoadsBeforeReturn));
  });

  testWidgets('confirmed deletion checks current access before deleting',
      (tester) async {
    final calls = <String>[];

    await showRow(
      tester,
      role: VaultMemberRole.editor,
      checkDeleteAccess: () async {
        calls.add('check access');
        return true;
      },
      onDelete: () => calls.add('delete'),
    );

    await tester.tap(find.byTooltip('Delete recipe'));
    await tester.pumpAndSettle();

    // Opening the confirmation must not delete or check mutation access.
    expect(calls, isEmpty);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(calls, ['check access', 'delete']);
    expect(
      find.text('Could not verify permission to delete this recipe.'),
      findsNothing,
    );
  });

  testWidgets('cancelled deletion performs no permission check or mutation',
      (tester) async {
    var checks = 0;
    var deletions = 0;

    await showRow(
      tester,
      role: VaultMemberRole.editor,
      checkDeleteAccess: () async {
        checks++;
        return true;
      },
      onDelete: () => deletions++,
    );

    await tester.tap(find.byTooltip('Delete recipe'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(checks, 0);
    expect(deletions, 0);
    expect(find.text('Shared copy'), findsOneWidget);
  });

  testWidgets('revoked deletion permission blocks the callback',
      (tester) async {
    var checks = 0;
    var deletions = 0;

    await showRow(
      tester,
      role: VaultMemberRole.editor,
      checkDeleteAccess: () async {
        checks++;
        return false;
      },
      onDelete: () => deletions++,
    );

    await tester.tap(find.byTooltip('Delete recipe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(checks, 1);
    expect(deletions, 0);
    expect(
      find.text('Could not verify permission to delete this recipe.'),
      findsOneWidget,
    );
  });

  testWidgets('failed deletion access lookup shows an error without deleting',
      (tester) async {
    var deletions = 0;

    await showRow(
      tester,
      role: VaultMemberRole.editor,
      checkDeleteAccess: () async {
        throw StateError('Access lookup unavailable');
      },
      onDelete: () => deletions++,
    );

    await tester.tap(find.byTooltip('Delete recipe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(deletions, 0);
    expect(
      find.text('Could not verify permission to delete this recipe.'),
      findsOneWidget,
    );
  });
}
