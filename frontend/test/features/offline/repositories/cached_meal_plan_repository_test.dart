import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan_entry.dart';
import 'package:mealchemy/features/meal_plan/models/meal_slot.dart';
import 'package:mealchemy/features/meal_plan/repositories/meal_plan_repository.dart';
import 'package:mealchemy/features/offline/data/meal_plan_cache_store.dart';
import 'package:mealchemy/features/offline/data/offline_cache_database.dart';
import 'package:mealchemy/features/offline/data/offline_cache_store.dart';
import 'package:mealchemy/features/offline/repositories/cached_meal_plan_repository.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

class _RemoteMealPlanRepository implements MealPlanRepository {
  bool offline = false;
  final monday = DateTime(2026, 9, 28);

  Never _throwOffline() {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/meal-plans'),
      type: DioExceptionType.connectionError,
      error: Exception('offline'),
    );
  }

  @override
  Future<MealPlan> getOrCreatePlan(int vaultId) async {
    if (offline) _throwOffline();
    return MealPlan(planId: 11, vaultId: vaultId);
  }

  @override
  Future<List<MealPlanEntry>> getEntries(
    int vaultId,
    DateTime start,
    DateTime end,
  ) async {
    if (offline) _throwOffline();
    return [
      MealPlanEntry(
        entryId: 21,
        planId: 11,
        recipeId: 42,
        entryDate: monday,
        mealSlot: MealSlot.dinner,
        mealTime: const TimeOfDay(hour: 18, minute: 30),
        recipe: const Recipe(recipeId: 42, title: 'Cached dinner'),
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late OfflineCacheDatabase database;
  late _RemoteMealPlanRepository remote;
  late CachedMealPlanRepository repository;

  setUp(() {
    database = OfflineCacheDatabase(NativeDatabase.memory());
    remote = _RemoteMealPlanRepository();
    repository = CachedMealPlanRepository(
      remote: remote,
      cache: MealPlanCacheStore(database, OfflineCacheStore(database)),
      viewerUserId: 1,
    );
  });

  tearDown(() => database.close());

  test('falls back to a previously loaded complete week offline', () async {
    final monday = remote.monday;
    final sunday = monday.add(const Duration(days: 6));

    await repository.getOrCreatePlan(7);
    await repository.getEntries(7, monday, sunday);
    remote.offline = true;

    final plan = await repository.getOrCreatePlan(7);
    final entries = await repository.getEntries(7, monday, sunday);

    expect(plan.planId, 11);
    expect(entries.single.recipe?.title, 'Cached dinner');
  });

  test('does not treat an uncached offline week as an empty week', () async {
    remote.offline = true;

    await expectLater(
        repository.getOrCreatePlan(7), throwsA(isA<DioException>()));
  });
}
