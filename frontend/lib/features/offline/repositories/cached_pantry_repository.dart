import '../../pantry/models/pantry_ingredient.dart';
import '../../pantry/models/pantry_summary.dart';
import '../../pantry/repositories/pantry_repository.dart';
import '../../pantry/widgets/pantry_item_card.dart';
import '../data/offline_cache_policy.dart';
import '../data/pantry_cache_store.dart';

class CachedPantryRepository implements PantryRepository {
  CachedPantryRepository({
    required PantryRepository remote,
    required PantryCacheStore cache,
    required int viewerUserId,
  })  : _remote = remote,
        _cache = cache,
        _viewerUserId = viewerUserId;

  final PantryRepository _remote;
  final PantryCacheStore _cache;
  final int _viewerUserId;
  Future<List<PantryIngredient>>? _ingredients;

  Future<List<PantryIngredient>> _loadIngredients() {
    return _ingredients ??= _fetchIngredients();
  }

  Future<List<PantryIngredient>> _fetchIngredients() async {
    try {
      final ingredients = await _remote.getPantryIngredients();
      await _cache.replaceFromCompleteFetch(
        viewerUserId: _viewerUserId,
        ingredients: ingredients,
        syncedAt: DateTime.now().toUtc(),
      );
      return ingredients;
    } catch (error) {
      if (!isOfflineTransportFailure(error)) rethrow;
      return _cache.readIngredients(viewerUserId: _viewerUserId);
    }
  }

  @override
  Future<List<PantryIngredient>> getPantryIngredients() => _loadIngredients();

  @override
  Future<PantrySummary> getPantrySummary() async {
    final ingredients = await _loadIngredients();
    final categories = ingredients.map((item) => item.category).toSet();
    final fresh = ingredients
        .where((item) => item.status == PantryItemStatus.fresh)
        .length;
    return PantrySummary(
      totalItems: ingredients.length,
      freshnessPercent: ingredients.isEmpty
          ? 100
          : ((fresh / ingredients.length) * 100).round(),
      categoryCount: categories.length,
      optimizationPercent: 72,
    );
  }

  @override
  Future<List<PantryFilter>> getPantryFilters() async {
    final ingredients = await _loadIngredients();
    final counts = <String, int>{};
    for (final ingredient in ingredients) {
      counts.update(
        ingredient.category,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    return [
      PantryFilter(label: 'All', count: ingredients.length),
      ...counts.entries.map(
        (entry) => PantryFilter(label: entry.key, count: entry.value),
      ),
    ];
  }

  @override
  Future<List<String>> getIngredientCategories() async {
    final ingredients = await _loadIngredients();
    return ingredients.map((item) => item.category).toSet().toList()..sort();
  }

  @override
  Future<PantryIngredient> addPantryIngredient({
    required int ingId,
    required String quantity,
    required String unit,
  }) async {
    final result = await _remote.addPantryIngredient(
      ingId: ingId,
      quantity: quantity,
      unit: unit,
    );
    _ingredients = null;
    return result;
  }

  @override
  Future<void> deletePantryIngredient(int pIngredientId) async {
    await _remote.deletePantryIngredient(pIngredientId);
    _ingredients = null;
  }

  @override
  Future<PantryIngredient> updatePantryIngredient({
    required int pIngredientId,
    required int ingId,
    required String quantity,
    required String unit,
  }) async {
    final result = await _remote.updatePantryIngredient(
      pIngredientId: pIngredientId,
      ingId: ingId,
      quantity: quantity,
      unit: unit,
    );
    _ingredients = null;
    return result;
  }
}
