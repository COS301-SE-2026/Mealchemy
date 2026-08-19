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
  final List<(int vaultId, String name)> createdFolders = [];
  bool throwOnSave = false;
  bool throwOnCreate = false;

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
  Future<VaultFolder> createFolder(int vaultId, String name) async {
    if (throwOnCreate) throw Exception('create failed');
    createdFolders.add((vaultId, name));
    return VaultFolder(
      folderId: 20,
      vaultId: vaultId,
      folderName: name,
      createdAt: DateTime(2026, 1, 1),
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

 
  Future<void> tapPickerOption(
    WidgetTester tester, {
    required String hint,
    required String option,
  }) async {
    await tester.tap(find.text(hint));
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  Future<void> pickMyVault(WidgetTester tester) =>
      tapPickerOption(tester, hint: 'Select a vault', option: 'My Vault');

  testWidgets('shows a progress indicator while vaults are loading',
      (tester) async {
    final pending = Completer<List<Vault>>();
    await tester.pumpWidget(hostWithRef(overrides: [
      vaultsProvider.overrideWith((ref) => pending.future),
    ]));
    await openSheet(tester);

    expect(find.text('Save to Vault'), findsOneWidget);
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

    await pickMyVault(tester);

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

    await pickMyVault(tester);

    expect(find.text('No folders in this vault yet'), findsOneWidget);
  });

  testWidgets('shows an error when vaults fail to load', (tester) async {
    await tester.pumpWidget(hostWithRef(overrides: [
      vaultsProvider.overrideWith((ref) async => throw Exception('boom')),
    ]));
    await openSheet(tester);
    await tester.pumpAndSettle();

    expect(find.text('Could not load vaults.'), findsOneWidget);
  });

  testWidgets('shows an error when folders fail to load', (tester) async {
    await tester.pumpWidget(hostWithRef(overrides: [
      vaultsProvider.overrideWith((ref) async => [privateVault]),
      vaultFoldersProvider(1)
          .overrideWith((ref) async => throw Exception('boom')),
    ]));
    await openSheet(tester);
    await tester.pumpAndSettle();

    await pickMyVault(tester);

    expect(find.text('Could not load folders.'), findsOneWidget);
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

    await pickMyVault(tester);
    await tapPickerOption(tester, hint: 'Select a folder', option: 'My Recipes');

    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();

    expect(repo.filed, [(10, 42)]); // folderId 10, recipeId 42
    expect(find.text('Save to Vault'), findsNothing);
  });

  testWidgets('a failed save keeps the sheet open', (tester) async {
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

    await pickMyVault(tester);
    await tapPickerOption(tester, hint: 'Select a folder', option: 'My Recipes');

    await tester.tap(find.text('Save Recipe'));
    await tester.pumpAndSettle();

    expect(repo.filed, isEmpty);
    expect(find.text('Save to Vault'), findsOneWidget);
  });

  testWidgets('creating a folder calls the repo with the entered name',
      (tester) async {
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

    await pickMyVault(tester);

    await tester.tap(find.text('CREATE A FOLDER'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Weeknight Dinners');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(repo.createdFolders, [(1, 'Weeknight Dinners')]);
  });

  testWidgets('a blank folder name is rejected by the dialog', (tester) async {
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

    await pickMyVault(tester);

    await tester.tap(find.text('CREATE A FOLDER'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('This field is required.'), findsOneWidget);
    expect(repo.createdFolders, isEmpty);
  });
}