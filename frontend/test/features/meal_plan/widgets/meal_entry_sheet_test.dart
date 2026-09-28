import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan_entry.dart';
import 'package:mealchemy/features/meal_plan/models/meal_slot.dart';
import 'package:mealchemy/features/meal_plan/providers/meal_plan_provider.dart';
import 'package:mealchemy/features/meal_plan/repositories/meal_plan_repository.dart';
import 'package:mealchemy/features/meal_plan/widgets/meal_entry_sheet.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';

const _penne = Recipe(recipeId: 1, title: 'Penne Alla Vodka', cuisineType: 'ITALIAN');
const _salmon = Recipe(recipeId: 2, title: 'Lemon Salmon');
const _bowl = Recipe(recipeId: 3, title: 'Burrito Bowl');

DateTime get _today {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

MealPlanEntry _breakfast() => MealPlanEntry(
      entryId: 1,
      planId: 1,
      recipeId: _bowl.recipeId,
      entryDate: _today,
      mealSlot: MealSlot.breakfast,
      mealTime: const TimeOfDay(hour: 8, minute: 0),
      note: 'Meal prepped',
      recipe: _bowl,
    );

class _FakeRepo implements MealPlanRepository {
  _FakeRepo({List<MealPlanEntry>? entries}) : entries = [...?entries];

  final List<MealPlanEntry> entries;
  final added = <MealPlanEntry>[];
  final accepted = <MealPlanEntry>[];
  final updated = <MealPlanEntry>[];
  final deleted = <int>[];
  int _nextId = 100;

  MealPlanEntry _save(MealPlanEntry e, MealEntrySource source) {
    final saved = MealPlanEntry(
      entryId: _nextId++,
      planId: 1,
      recipeId: e.recipeId,
      entryDate: e.entryDate,
      mealSlot: e.mealSlot,
      mealTime: e.mealTime,
      title: e.title,
      note: e.note,
      source: source,
      recipe: e.recipe,
    );
    entries.add(saved);
    return saved;
  }

  @override
  Future<MealPlan> getOrCreatePlan(int vaultId) async => MealPlan(planId: 1, vaultId: vaultId);

  @override
  Future<List<MealPlanEntry>> getEntries(int vaultId, DateTime start, DateTime end) async =>
      List.of(entries);

  @override
  Future<MealPlanEntry> addEntry(int planId, MealPlanEntry entry) async {
    final saved = _save(entry, MealEntrySource.manual);
    added.add(saved);
    return saved;
  }

  @override
  Future<MealPlanEntry> acceptRecommendation(int planId, MealPlanEntry entry) async {
    final saved = _save(entry, MealEntrySource.recommended);
    accepted.add(saved);
    return saved;
  }

  @override
  Future<MealPlanEntry> updateEntry(int planId, MealPlanEntry entry) async {
    updated.add(entry);
    return entry;
  }

  @override
  Future<void> deleteEntry(int planId, int entryId) async {
    deleted.add(entryId);
    entries.removeWhere((e) => e.entryId == entryId);
  }

  @override
  Future<List<Recipe>> previewRecommendations(int planId, DateTime date, MealSlot slot) async =>
      [_salmon];
}

Future<void> _open(
  WidgetTester tester,
  _FakeRepo repo, {
  int vaultId = 1,
  MealPlanEntry? entry,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      mealPlanRepositoryProvider.overrideWithValue(repo),
      vaultsProvider.overrideWith((ref) async => [
            Vault(vaultId: 1, vaultType: VaultTypes.private, name: 'My Vault', createdAt: DateTime(2026)),
            Vault(vaultId: 2, vaultType: VaultTypes.shared, name: 'Family', createdAt: DateTime(2026)),
          ]),
      vaultFoldersProvider.overrideWith((ref, vaultId) async => [
            VaultFolder(folderId: 10, vaultId: vaultId, folderName: 'Dinners', createdAt: DateTime(2026)),
          ]),
      folderRecipeDisplayProvider.overrideWith((ref, folderId) async => [_penne, _bowl]),
      offlineReadOnlyProvider.overrideWith((ref) => false),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showMealEntrySheet(
                context,
                vaultId: vaultId,
                entry: entry,
                slot: entry == null ? MealSlot.lunch : null,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}


Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void main() {
  group('add', () {
    testWidgets('private plan shows suggestions for the slot', (tester) async {
      await _open(tester, _FakeRepo());
      expect(find.text('Add Meal'), findsOneWidget);
      expect(find.text('SUGGESTED FOR LUNCH'), findsOneWidget);
      expect(find.text('Lemon Salmon'), findsOneWidget);
    });

    testWidgets('shared plan has no suggestions', (tester) async {
      await _open(tester, _FakeRepo(), vaultId: 2);

      expect(find.textContaining('SUGGESTED FOR'), findsNothing);
      expect(find.text('Penne Alla Vodka'), findsOneWidget);
    });

    testWidgets('saving without a recipe shows validation', (tester) async {
      final repo = _FakeRepo();
      await _open(tester, repo);
      await tester.tap(find.text('Add to Plan'));
      await tester.pumpAndSettle();
      expect(find.text('Pick a recipe for this meal.'), findsOneWidget);
      expect(repo.added, isEmpty);
    });

    testWidgets('changing the slot resets the time', (tester) async {
      await _open(tester, _FakeRepo());
      expect(find.text('12:30'), findsOneWidget);
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();
      expect(find.text('18:30'), findsOneWidget);
    });

    testWidgets('picking from search saves a manual entry', (tester) async {
      final repo = _FakeRepo();
      await _open(tester, repo);
      await tester.tap(find.text('Penne Alla Vodka'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to Plan'));
      await _settle(tester);
      expect(repo.added, hasLength(1));
      expect(repo.added.single.recipeId, _penne.recipeId);
      expect(repo.added.single.mealSlot, MealSlot.lunch);
      expect(repo.added.single.mealTime, const TimeOfDay(hour: 12, minute: 30));
      expect(repo.accepted, isEmpty);
      expect(find.text('Add Meal'), findsNothing);
    });

    testWidgets('picking a suggestion saves as recommended', (tester) async {
      final repo = _FakeRepo();
      await _open(tester, repo);

      await tester.tap(find.text('Lemon Salmon'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to Plan'));
      await _settle(tester);

      expect(repo.accepted, hasLength(1));
      expect(repo.accepted.single.recipeId, _salmon.recipeId);
      expect(repo.added, isEmpty);
    });
  });

  group('edit', () {
    testWidgets('prefills and saves changes to the same entry', (tester) async {
      final entry = _breakfast();
      final repo = _FakeRepo(entries: [entry]);
      await _open(tester, repo, entry: entry);

      expect(find.text('Edit Meal'), findsOneWidget);
      expect(find.text('Burrito Bowl'), findsWidgets);
      expect(find.text('08:00'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Meal prepped'), 'Leftovers');
      await tester.tap(find.text('Save Changes'));
      await _settle(tester);
      expect(repo.updated, hasLength(1));
      expect(repo.updated.single.entryId, entry.entryId);
      expect(repo.updated.single.note, 'Leftovers');
      expect(repo.updated.single.mealSlot, MealSlot.breakfast);
    });

    testWidgets('remove asks first then delete', (tester) async {
      final entry = _breakfast();
      final repo = _FakeRepo(entries: [entry]);
      await _open(tester, repo, entry: entry);
      await tester.tap(find.text('Remove from plan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await _settle(tester);

      expect(repo.deleted, [entry.entryId]);
      expect(find.text('Edit Meal'), findsNothing);
    });
  });
}