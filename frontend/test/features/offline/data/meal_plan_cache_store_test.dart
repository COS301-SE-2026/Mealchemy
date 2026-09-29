import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan_entry.dart';
import 'package:mealchemy/features/meal_plan/models/meal_slot.dart';
import 'package:mealchemy/features/offline/data/meal_plan_cache_store.dart';
import 'package:mealchemy/features/offline/data/offline_cache_database.dart';
import 'package:mealchemy/features/offline/data/offline_cache_store.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

void main() {
  late OfflineCacheDatabase database;
  late OfflineCacheStore metadataStore;
  late MealPlanCacheStore store;

  setUp(() {
    database = OfflineCacheDatabase(NativeDatabase.memory());
    metadataStore = OfflineCacheStore(database);
    store = MealPlanCacheStore(database, metadataStore);
  });

  tearDown(() => database.close());

  test('plan and complete week round trip with recipe card data', () async {
    final monday = DateTime(2026, 9, 28);
    final plan = MealPlan(planId: 11, vaultId: 7);
    final entry = MealPlanEntry(
      entryId: 21,
      planId: 11,
      recipeId: 42,
      entryDate: monday,
      mealSlot: MealSlot.dinner,
      mealTime: const TimeOfDay(hour: 18, minute: 30),
      note: 'Family dinner',
      recipe: const Recipe(
        recipeId: 42,
        title: 'Garlic vegetable fried rice',
        photoUrl: 'https://example.test/recipe.jpg',
      ),
    );

    await store.storePlan(viewerUserId: 1, plan: plan);
    await store.replaceWeekFromCompleteFetch(
      viewerUserId: 1,
      vaultId: 7,
      weekStart: monday,
      entries: [entry],
      syncedAt: DateTime.utc(2026, 9, 29),
    );

    final cachedPlan = await store.readPlan(viewerUserId: 1, vaultId: 7);
    final cachedWeek = await store.readWeek(
      viewerUserId: 1,
      vaultId: 7,
      weekStart: monday,
    );

    expect(cachedPlan?.planId, 11);
    expect(cachedWeek, hasLength(1));
    expect(cachedWeek!.single.recipe?.title, 'Garlic vegetable fried rice');
    expect(
        cachedWeek.single.recipe?.photoUrl, 'https://example.test/recipe.jpg');
    expect(cachedWeek.single.note, 'Family dinner');
    expect(cachedWeek.single.mealTime, const TimeOfDay(hour: 18, minute: 30));
  });

  test('cached empty week is distinct from a week that was never fetched',
      () async {
    final monday = DateTime(2026, 9, 28);
    await store.replaceWeekFromCompleteFetch(
      viewerUserId: 1,
      vaultId: 7,
      weekStart: monday,
      entries: const [],
      syncedAt: DateTime.utc(2026, 9, 29),
    );

    expect(
      await store.readWeek(
        viewerUserId: 1,
        vaultId: 7,
        weekStart: monday,
      ),
      isEmpty,
    );
    expect(
      await store.readWeek(
        viewerUserId: 1,
        vaultId: 7,
        weekStart: monday.add(const Duration(days: 7)),
      ),
      isNull,
    );
  });

  test('meal-plan rows are isolated by viewer', () async {
    final monday = DateTime(2026, 9, 28);
    await store.replaceWeekFromCompleteFetch(
      viewerUserId: 1,
      vaultId: 7,
      weekStart: monday,
      entries: [_entry('Viewer one meal')],
      syncedAt: DateTime.utc(2026, 9, 29),
    );

    expect(
      await store.readWeek(
        viewerUserId: 2,
        vaultId: 7,
        weekStart: monday,
      ),
      isNull,
    );
  });
}

MealPlanEntry _entry(String title) => MealPlanEntry(
      entryId: 21,
      planId: 11,
      recipeId: 42,
      entryDate: DateTime(2026, 9, 28),
      mealSlot: MealSlot.dinner,
      mealTime: const TimeOfDay(hour: 18, minute: 30),
      recipe: Recipe(recipeId: 42, title: title),
    );
