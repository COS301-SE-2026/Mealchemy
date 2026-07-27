import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/features/recipe/widgets/save_to_vault_sheet.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/models/vault_folder_recipe.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_repository_provider.dart';
import 'package:mealchemy/features/vault/repositories/vault_repository.dart';

class _FakeVaultRepo implements VaultRepository {
  final List<(int folderId, int recipeId)> filed = [];
  bool throwOnSave = false;

  @override
  Future<VaultFolderRecipe> addRecipeToFolder(int folderId, int recipeId) async {
    if (throwOnSave) throw Exception('save failed');
    filed.add((folderId, recipeId));
    return VaultFolderRecipe(
      id: 1,
      folderId: folderId,
      recipeId: recipeId,
      addedAt: DateTime(2026, 1, 1),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final privateVault = Vault(
    vaultId: 1,
    vaultType: VaultTypes.private,
    name: 'My Vault',
    createdAt: DateTime(2026, 1, 1),
  );
  final sharedVault = Vault(
    vaultId: 2,
    vaultType: VaultTypes.shared,
    name: 'Team Vault',
    createdAt: DateTime(2026, 1, 1),
  );

  final recipesFolder = VaultFolder(
    folderId: 10,
    vaultId: 1,
    folderName: 'My Recipes',
    createdAt: DateTime(2026, 1, 1),
  );

  Widget hostWithRef({
    required List<Override> overrides,
    VaultRepository? vaultRepo,
  }) {
    return ProviderScope(
      overrides: [
        vaultRepositoryProvider
            .overrideWithValue(vaultRepo ?? _FakeVaultRepo()),
        ...overrides,
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              return Center(
                child: ElevatedButton(
                  onPressed: () => showSaveToVaultSheet(
                    context: context,
                    ref: ref,
                    recipeId: 42,
                  ),
                  child: const Text('open'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pump(); // build the dialog
  }

  testWidgets('shows a progress indicator while vaults are loading',
      (tester) async {
    final pending = Completer<List<Vault>>();
    await tester.pumpWidget(hostWithRef(overrides: [
      vaultsProvider.overrideWith((ref) => pending.future),
    ]));
    await openSheet(tester);

    expect(find.text('SAVE TO VAULT'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('initial state prompts to pick a vault and disables save',
      (tester) async {
    await tester.pumpWidget(hostWithRef(overrides: [
      vaultsProvider.overrideWith((ref) async => [privateVault, sharedVault]),
    ]));
    await openSheet(tester);
    await tester.pumpAndSettle();

    expect(find.text('Pick a vault first'), findsOneWidget);

    final saveButton = tester.widget<AppButton>(
      find.widgetWithText(AppButton, 'Save Recipe'),
    );
    expect(saveButton.onPressed, isNull); // disabled until a folder is chosen
  });

  testWidgets('picking a vault loads its folders', (tester) async {
    await tester.pumpWidget(hostWithRef(overrides: [
      vaultsProvider.overrideWith((ref) async => [privateVault]),
      vaultFoldersProvider(1).overrideWith((ref) async => [recipesFolder]),
    ]));
    await openSheet(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Vault').last);
    await tester.pumpAndSettle();

    // Folder field replaced the "pick a vault first" placeholder.
    expect(find.text('Pick a vault first'), findsNothing);
    expect(find.text('Select a folder'), findsOneWidget);
  });

  testWidgets('shows an empty-folders message when the vault has none',
      (tester) async {
    await tester.pumpWidget(hostWithRef(overrides: [
      vaultsProvider.overrideWith((ref) async => [privateVault]),
      vaultFoldersProvider(1).overrideWith((ref) async => <VaultFolder>[]),
    ]));
    await openSheet(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Vault').last);
    await tester.pumpAndSettle();

    expect(find.text('No folders in this vault'), findsOneWidget);
  });

  testWidgets('selecting a folder and saving files the recipe', (tester) async {
    final repo = _FakeVaultRepo();
    await tester.pumpWidget(hostWithRef(
      vaultRepo: repo,
      overrides: [
        vaultsProvider.overrideWith((ref) async => [privateVault]),
        vaultFoldersProvider(1).overrideWith((ref) async => [recipesFolder]),
      ],
    ));
    await openSheet(tester);
    await tester.pumpAndSettle();

    // choose vault
    await tester.tap(find.byType(DropdownButtonFormField<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Vault').last);
    await tester.pumpAndSettle();

    // choose folder
    await tester.tap(find.byType(DropdownButtonFormField<int>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Recipes').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();

    expect(repo.filed, [(10, 42)]); // folderId 10, recipeId 42
    expect(find.text('Recipe saved to vault'), findsOneWidget);
  });

  testWidgets('a failed save shows an error and keeps the sheet open',
      (tester) async {
    final repo = _FakeVaultRepo()..throwOnSave = true;
    await tester.pumpWidget(hostWithRef(
      vaultRepo: repo,
      overrides: [
        vaultsProvider.overrideWith((ref) async => [privateVault]),
        vaultFoldersProvider(1).overrideWith((ref) async => [recipesFolder]),
      ],
    ));
    await openSheet(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Vault').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<int>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Recipes').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();

    expect(find.text('Could not save. Try again.'), findsOneWidget);
    expect(find.text('SAVE TO VAULT'), findsOneWidget);
  });
}