import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../meal_plan/models/meal_plan.dart';
import '../../meal_plan/models/meal_plan_entry.dart';
import '../../meal_plan/models/meal_slot.dart';
import '../../recipe/models/recipe.dart';
import 'offline_cache_database.dart';
import 'offline_cache_store.dart';

DateTime mealPlanWeekStart(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

String mealPlanWeekScope(int vaultId, DateTime date) {
  return '$vaultId:${_dateKey(mealPlanWeekStart(date))}';
}

String _dateKey(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
}

class MealPlanCacheStore {
  MealPlanCacheStore(this._database, this._metadataStore);

  final OfflineCacheDatabase _database;
  final OfflineCacheStore _metadataStore;

  Future<MealPlan?> readPlan({
    required int viewerUserId,
    required int vaultId,
  }) async {
    final row = await (_database.select(_database.cachedMealPlanRows)
          ..where(
            (row) =>
                row.viewerUserId.equals(viewerUserId) &
                row.vaultId.equals(vaultId),
          ))
        .getSingleOrNull();
    if (row == null) return null;
    return MealPlan(planId: row.planId, vaultId: row.vaultId);
  }

  Future<void> storePlan({
    required int viewerUserId,
    required MealPlan plan,
  }) {
    return _database.into(_database.cachedMealPlanRows).insertOnConflictUpdate(
          CachedMealPlanRowsCompanion.insert(
            viewerUserId: viewerUserId,
            vaultId: plan.vaultId,
            planId: plan.planId,
          ),
        );
  }

  Future<List<MealPlanEntry>?> readWeek({
    required int viewerUserId,
    required int vaultId,
    required DateTime weekStart,
  }) async {
    final normalizedStart = mealPlanWeekStart(weekStart);
    final scopeId = mealPlanWeekScope(vaultId, normalizedStart);
    final metadata = await _metadataStore.readSyncMetadata(
      viewerUserId: viewerUserId,
      collection: CacheCollection.mealPlanWeek,
      scopeId: scopeId,
    );
    if (metadata == null) return null;

    final rows = await (_database.select(_database.cachedMealPlanEntryRows)
          ..where(
            (row) =>
                row.viewerUserId.equals(viewerUserId) &
                row.vaultId.equals(vaultId) &
                row.weekStart.equals(_dateKey(normalizedStart)),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.lineIndex)]))
        .get();
    await _metadataStore.markSyncMetadataAccess(
      viewerUserId: viewerUserId,
      collection: CacheCollection.mealPlanWeek,
      scopeId: scopeId,
    );
    return rows.map(_entryFromRow).toList();
  }

  Future<void> replaceWeekFromCompleteFetch({
    required int viewerUserId,
    required int vaultId,
    required DateTime weekStart,
    required List<MealPlanEntry> entries,
    required DateTime syncedAt,
  }) {
    final normalizedStart = mealPlanWeekStart(weekStart);
    final weekKey = _dateKey(normalizedStart);
    return _database.transaction(() async {
      await (_database.delete(_database.cachedMealPlanEntryRows)
            ..where(
              (row) =>
                  row.viewerUserId.equals(viewerUserId) &
                  row.vaultId.equals(vaultId) &
                  row.weekStart.equals(weekKey),
            ))
          .go();
      if (entries.isNotEmpty) {
        await _database.batch((batch) {
          batch.insertAll(
            _database.cachedMealPlanEntryRows,
            [
              for (var index = 0; index < entries.length; index++)
                _entryCompanion(
                  viewerUserId: viewerUserId,
                  vaultId: vaultId,
                  weekKey: weekKey,
                  lineIndex: index,
                  entry: entries[index],
                ),
            ],
          );
        });
      }
      await _metadataStore.writeSyncMetadata(
        viewerUserId: viewerUserId,
        collection: CacheCollection.mealPlanWeek,
        scopeId: mealPlanWeekScope(vaultId, normalizedStart),
        syncedAt: syncedAt,
      );
    });
  }

  Future<void> upsertEntryIfWeekCached({
    required int viewerUserId,
    required int vaultId,
    required MealPlanEntry entry,
    required DateTime syncedAt,
  }) async {
    final start = mealPlanWeekStart(entry.entryDate);
    final entries = await readWeek(
      viewerUserId: viewerUserId,
      vaultId: vaultId,
      weekStart: start,
    );
    if (entries == null) return;
    final updated = [
      for (final cached in entries)
        if (entry.entryId == null || cached.entryId != entry.entryId) cached,
      entry,
    ];
    await replaceWeekFromCompleteFetch(
      viewerUserId: viewerUserId,
      vaultId: vaultId,
      weekStart: start,
      entries: updated,
      syncedAt: syncedAt,
    );
  }

  Future<void> removeEntry({
    required int viewerUserId,
    required int vaultId,
    required int entryId,
  }) {
    return (_database.delete(_database.cachedMealPlanEntryRows)
          ..where(
            (row) =>
                row.viewerUserId.equals(viewerUserId) &
                row.vaultId.equals(vaultId) &
                row.entryId.equals(entryId),
          ))
        .go();
  }

  CachedMealPlanEntryRowsCompanion _entryCompanion({
    required int viewerUserId,
    required int vaultId,
    required String weekKey,
    required int lineIndex,
    required MealPlanEntry entry,
  }) {
    return CachedMealPlanEntryRowsCompanion.insert(
      viewerUserId: viewerUserId,
      vaultId: vaultId,
      weekStart: weekKey,
      lineIndex: lineIndex,
      entryId: Value(entry.entryId),
      planId: Value(entry.planId),
      recipeId: entry.recipeId,
      entryDate: _dateKey(entry.entryDate),
      mealSlot: entry.mealSlot.name,
      mealTimeMinutes: entry.mealTime.hour * 60 + entry.mealTime.minute,
      title: Value(entry.title),
      note: Value(entry.note),
      source: entry.source.name,
      addedBy: Value(entry.addedBy),
      recipeTitle: Value(entry.recipe?.title),
      recipePhotoUrl: Value(entry.recipe?.photoUrl),
    );
  }

  MealPlanEntry _entryFromRow(CachedMealPlanEntryRow row) {
    final recipe = row.recipeTitle == null
        ? null
        : Recipe(
            recipeId: row.recipeId,
            title: row.recipeTitle!,
            photoUrl: row.recipePhotoUrl,
          );
    return MealPlanEntry(
      entryId: row.entryId,
      planId: row.planId,
      recipeId: row.recipeId,
      entryDate: DateTime.parse(row.entryDate),
      mealSlot: MealSlot.values.byName(row.mealSlot),
      mealTime: TimeOfDay(
        hour: row.mealTimeMinutes ~/ 60,
        minute: row.mealTimeMinutes % 60,
      ),
      title: row.title,
      note: row.note,
      source: MealEntrySource.values.byName(row.source),
      addedBy: row.addedBy,
      recipe: recipe,
    );
  }
}
