import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';
import 'package:mealchemy/features/vault/widgets/folder_menu.dart';
import 'package:mealchemy/features/vault/widgets/vault_folder_list.dart';
import 'package:mealchemy/features/vault/widgets/vault_menu.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final vault = Vault(
    vaultId: 5,
    ownerId: 7,
    vaultType: VaultTypes.shared,
    name: 'Family',
    createdAt: DateTime(2026, 1, 1),
  );

  final folder = VaultFolder(
    folderId: 12,
    vaultId: 5,
    folderName: 'Dinner',
    createdAt: DateTime(2026, 1, 1),
  );

  SharedVaultAccess access(VaultMemberRole role) {
    final member = VaultMember(
      id: role == VaultMemberRole.owner ? null : 44,
      vaultId: 5,
      userId: role == VaultMemberRole.owner ? 7 : 8,
      email: 'user@example.com',
      joinedAt: DateTime(2026, 1, 1),
      role: role,
    );

    return SharedVaultAccess(
      vault: vault,
      currentMember: member,
      members: [member],
    );
  }

  Widget host(
    Widget child, {
    VaultMemberRole role = VaultMemberRole.editor,
    NetworkStatus connection = NetworkStatus.online,
    Future<SharedVaultAccess> Function()? loadAccess,
  }) {
    return ProviderScope(
      overrides: [
        vaultSessionProvider.overrideWithValue((
          userId: role == VaultMemberRole.owner ? 7 : 8,
          token: 'test-token',
          restoring: false,
          hasValidCredential: true,
        )),
        vaultConnectionProvider.overrideWithValue(connection),
        sharedVaultAccessProvider.overrideWith(
          (ref, id) async =>
              loadAccess != null ? await loadAccess() : access(role),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: child),
        ),
      ),
    );
  }

  testWidgets('Editor sees create but no owner-only vault actions',
      (tester) async {
    await tester.pumpWidget(host(VaultMenuButton(vault: vault)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Create folder'), findsOneWidget);
    expect(find.text('Invite member'), findsNothing);
    expect(find.text('Delete vault'), findsNothing);
  });

  testWidgets('Editor sees rename and delete folder actions', (tester) async {
    await tester.pumpWidget(
      host(FolderMenuButton(vault: vault, folder: folder)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Rename folder'), findsOneWidget);
    expect(find.text('Delete folder'), findsOneWidget);
  });

  testWidgets('Viewer cannot open folder mutation actions', (tester) async {
    await tester.pumpWidget(
      host(
        FolderMenuButton(vault: vault, folder: folder),
        role: VaultMemberRole.viewer,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Rename folder'), findsNothing);
    expect(find.text('Delete folder'), findsNothing);
  });

  testWidgets('Editor sees the add-folders button', (tester) async {
    await tester.pumpWidget(
      host(VaultFolderList(vault: vault, folders: const [])),
    );
    await tester.pumpAndSettle();

    expect(find.text('ADD MORE FOLDERS'), findsOneWidget);
  });

  testWidgets('Viewer does not see the add-folders button', (tester) async {
    await tester.pumpWidget(
      host(
        VaultFolderList(vault: vault, folders: const []),
        role: VaultMemberRole.viewer,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No folders in this vault yet.'), findsOneWidget);
    expect(find.text('ADD MORE FOLDERS'), findsNothing);
  });

  for (final connection in [
    NetworkStatus.offline,
    NetworkStatus.checking,
  ]) {
    testWidgets('$connection disables folder actions', (tester) async {
      await tester.pumpWidget(
        host(
          FolderMenuButton(vault: vault, folder: folder),
          connection: connection,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Rename folder'), findsNothing);
      expect(find.text('Delete folder'), findsNothing);
    });
  }

  testWidgets('folder actions remain unavailable while access loads',
      (tester) async {
    final pending = Completer<SharedVaultAccess>();

    await tester.pumpWidget(
      host(
        FolderMenuButton(vault: vault, folder: folder),
        loadAccess: () => pending.future,
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pump();

    expect(find.text('Rename folder'), findsNothing);

    pending.complete(access(VaultMemberRole.editor));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Rename folder'), findsOneWidget);
  });

  testWidgets('failed access checks do not expose folder actions',
      (tester) async {
    await tester.pumpWidget(
      host(
        VaultFolderList(vault: vault, folders: const []),
        loadAccess: () async => throw StateError('Access unavailable'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ADD MORE FOLDERS'), findsNothing);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Create folder'), findsNothing);
  });

  testWidgets('cancelling a folder deletion closes the confirmation',
      (tester) async {
    await tester.pumpWidget(
      host(FolderMenuButton(vault: vault, folder: folder)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete folder'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('The recipes themselves will not be deleted.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Folder'), findsNothing);
  });
}
