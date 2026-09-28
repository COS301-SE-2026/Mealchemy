import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan_entry.dart';
import 'package:mealchemy/features/meal_plan/models/meal_slot.dart';
import 'package:mealchemy/features/meal_plan/providers/meal_plan_provider.dart';
import 'package:mealchemy/features/meal_plan/repositories/meal_plan_repository.dart';
import 'package:mealchemy/features/meal_plan/widgets/meal_plan_section.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';

class _FakeRepo implements MealPlanRepository {
  _FakeRepo(this.entries, {this.fail = false});

  final List<MealPlanEntry> entries;
  final bool fail;
  final deleted = <int>[];

  @override
  Future<MealPlan> getOrCreatePlan(int vaultId) async =>
      MealPlan(planId: 1, vaultId: vaultId);

  @override
  Future<List<MealPlanEntry>> getEntries(
      int vaultId, DateTime start, DateTime end) async {
    if (fail) throw Exception('boom');
    return List.of(entries);
  }

  @override
  Future<void> deleteEntry(int planId, int entryId) async {
    deleted.add(entryId);
    entries.removeWhere((e) => e.entryId == entryId);
  }

  @override
  Future<List<Recipe>> previewRecommendations(
          int planId, DateTime date, MealSlot slot) async =>
      [];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

DateTime get _today {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

final _breakfast = MealPlanEntry(
  entryId: 1,
  planId: 1,
  recipeId: 3,
  entryDate: _today,
  mealSlot: MealSlot.breakfast,
  mealTime: const TimeOfDay(hour: 8, minute: 0),
  recipe: const Recipe(recipeId: 3, title: 'Burrito Bowl'),
);

Future<void> _pump(WidgetTester tester, MealPlanRepository repo,
    {bool canEdit = true}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      mealPlanRepositoryProvider.overrideWithValue(repo),
      vaultsProvider.overrideWith((ref) async => [
            Vault(
              vaultId: 1,
              vaultType: VaultTypes.private,
              name: 'My Vault',
              createdAt: DateTime(2026),
            ),
          ]),
      //the add/edit sheet searches the vault and checks offline state
      vaultFoldersProvider.overrideWith((ref, vaultId) async => [
            VaultFolder(
              folderId: 10,
              vaultId: vaultId,
              folderName: 'Dinners',
              createdAt: DateTime(2026),
            ),
          ]),
      folderRecipeDisplayProvider.overrideWith((ref, folderId) async =>
          [const Recipe(recipeId: 3, title: 'Burrito Bowl')]),
      offlineReadOnlyProvider.overrideWith((ref) => false),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MealPlanSection(vaultId: 1, canEdit: canEdit),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('planned meal shows as a card missing slots as add rows',
      (tester) async {
    await _pump(tester, _FakeRepo([_breakfast]));
    expect(find.text('Burrito Bowl'), findsOneWidget);
    expect(find.text('BREAKFAST'), findsOneWidget);
    expect(find.text('LUNCH'), findsOneWidget);
    expect(find.text('DINNER'), findsOneWidget);
    expect(find.text('ANOTHER MEAL'), findsOneWidget);
  });

  testWidgets('empty day shows  the thre slots and no extra row',
      (tester) async {
    await _pump(tester, _FakeRepo([]));
    expect(find.text('BREAKFAST'), findsOneWidget);
    expect(find.text('LUNCH'), findsOneWidget);
    expect(find.text('DINNER'), findsOneWidget);
    expect(find.text('ANOTHER MEAL'), findsNothing);
  });

  testWidgets('read only hides add rows and the pencil', (tester) async {
    await _pump(tester, _FakeRepo([_breakfast]), canEdit: false);

    expect(find.text('Burrito Bowl'), findsOneWidget);
    expect(find.text('LUNCH'), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  testWidgets('read only empty day shows nothing  planed', (tester) async {
    await _pump(tester, _FakeRepo([]), canEdit: false);
    expect(find.text('Nothing planned for this day'), findsOneWidget);
  });

  testWidgets('load failure  shows the error with retry', (tester) async {
    await _pump(tester, _FakeRepo([], fail: true));
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('tapping an empty slot opens the add sheet for that slot',
      (tester) async {
    await _pump(tester, _FakeRepo([]));

    await tester.tap(find.text('LUNCH'));
    await tester.pumpAndSettle();

    expect(find.text('Add Meal'), findsOneWidget);
    expect(find.text('12:30'), findsOneWidget);
  });

  testWidgets('pencil opens the edit sheet', (tester) async {
    await _pump(tester, _FakeRepo([_breakfast]));

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Edit Meal'), findsOneWidget);
  });

  testWidgets('menu shows every action for editors', (tester) async {
    await _pump(tester, _FakeRepo([_breakfast]));

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Add meal'), findsOneWidget);
    expect(find.text('Suggest a meal'), findsOneWidget);
    expect(find.text('Generate shopping list'), findsOneWidget);
    expect(find.text('Clear day'), findsOneWidget);
  });

  testWidgets('read only menu leaves out editing actions', (tester) async {
    await _pump(tester, _FakeRepo([_breakfast]), canEdit: false);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Generate shopping list'), findsOneWidget);
    expect(find.text('Add meal'), findsNothing);
    expect(find.text('Clear day'), findsNothing);
  });

  testWidgets('clear day removes the meals after confirming', (tester) async {
    final repo = _FakeRepo([_breakfast]);
    await _pump(tester, repo);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear day'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    expect(repo.deleted, [1]);
    expect(find.text('Burrito Bowl'), findsNothing);
  });
}