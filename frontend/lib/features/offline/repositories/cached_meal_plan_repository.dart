import '../../meal_plan/models/meal_plan.dart';
import '../../meal_plan/models/meal_plan_entry.dart';
import '../../meal_plan/models/meal_slot.dart';
import '../../meal_plan/repositories/meal_plan_repository.dart';
import '../data/meal_plan_cache_store.dart';
import '../data/offline_cache_policy.dart';

class CachedMealPlanRepository implements MealPlanRepository {
  CachedMealPlanRepository({
    required MealPlanRepository remote,
    required MealPlanCacheStore cache,
    required int viewerUserId,
  })  : _remote = remote,
        _cache = cache,
        _viewerUserId = viewerUserId;

  final MealPlanRepository _remote;
  final MealPlanCacheStore _cache;
  final int _viewerUserId;
  final Map<int, int> _vaultIdsByPlanId = {};

  @override
  Future<MealPlan> getOrCreatePlan(int vaultId) async {
    try {
      final plan = await _remote.getOrCreatePlan(vaultId);
      _vaultIdsByPlanId[plan.planId] = vaultId;
      await _cache.storePlan(viewerUserId: _viewerUserId, plan: plan);
      return plan;
    } catch (error) {
      if (!isOfflineTransportFailure(error)) rethrow;
      final cached = await _cache.readPlan(
        viewerUserId: _viewerUserId,
        vaultId: vaultId,
      );
      if (cached == null) rethrow;
      _vaultIdsByPlanId[cached.planId] = vaultId;
      return cached;
    }
  }

  @override
  Future<List<MealPlanEntry>> getEntries(
    int vaultId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final entries = await _remote.getEntries(vaultId, start, end);
      if (_isCompleteWeek(start, end)) {
        await _cache.replaceWeekFromCompleteFetch(
          viewerUserId: _viewerUserId,
          vaultId: vaultId,
          weekStart: start,
          entries: entries,
          syncedAt: DateTime.now().toUtc(),
        );
      }
      return entries;
    } catch (error) {
      if (!isOfflineTransportFailure(error) || !_isCompleteWeek(start, end)) {
        rethrow;
      }
      final cached = await _cache.readWeek(
        viewerUserId: _viewerUserId,
        vaultId: vaultId,
        weekStart: start,
      );
      if (cached == null) rethrow;
      return cached;
    }
  }

  @override
  Future<MealPlanEntry> addEntry(int planId, MealPlanEntry entry) async {
    final saved = await _remote.addEntry(planId, entry);
    await _storeSavedEntry(planId, saved);
    return saved;
  }

  @override
  Future<MealPlanEntry> updateEntry(int planId, MealPlanEntry entry) async {
    final saved = await _remote.updateEntry(planId, entry);
    final vaultId = _vaultIdsByPlanId[planId];
    if (vaultId != null && saved.entryId != null) {
      await _cache.removeEntry(
        viewerUserId: _viewerUserId,
        vaultId: vaultId,
        entryId: saved.entryId!,
      );
    }
    await _storeSavedEntry(planId, saved);
    return saved;
  }

  @override
  Future<void> deleteEntry(int planId, int entryId) async {
    await _remote.deleteEntry(planId, entryId);
    final vaultId = _vaultIdsByPlanId[planId];
    if (vaultId == null) return;
    await _cache.removeEntry(
      viewerUserId: _viewerUserId,
      vaultId: vaultId,
      entryId: entryId,
    );
  }

  @override
  Future<List<MealSuggestion>> previewRecommendations(
    int planId,
    DateTime date,
    MealSlot slot,
  ) {
    return _remote.previewRecommendations(planId, date, slot);
  }

  @override
  Future<MealPlanEntry> acceptRecommendation(
    int planId,
    MealPlanEntry entry,
    MealSuggestion suggestion,
  ) async {
    final saved = await _remote.acceptRecommendation(planId, entry, suggestion);
    await _storeSavedEntry(planId, saved);
    return saved;
  }

  Future<void> _storeSavedEntry(int planId, MealPlanEntry entry) async {
    final vaultId = _vaultIdsByPlanId[planId];
    if (vaultId == null) return;
    await _cache.upsertEntryIfWeekCached(
      viewerUserId: _viewerUserId,
      vaultId: vaultId,
      entry: entry,
      syncedAt: DateTime.now().toUtc(),
    );
  }

  bool _isCompleteWeek(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    return normalizedStart.weekday == DateTime.monday &&
        normalizedEnd.difference(normalizedStart).inDays == 6;
  }
}
