import 'package:dio/dio.dart';

import '../models/pantry_ingredient.dart';
import '../models/pantry_summary.dart';
import '../widgets/pantry_item_card.dart';
import 'pantry_repository.dart';

//backend pantry data
class ApiPantryRepository implements PantryRepository {
  ApiPantryRepository(this._dio);

  final Dio _dio;

  List<PantryIngredient>? _cachedIngredients;

  @override
  Future<PantrySummary> getPantrySummary() async {
    final ingredients = await _getCachedIngredients();

    final categories = ingredients.map((item) => item.category).toSet();

    return PantrySummary(
      totalItems: ingredients.length,
      freshnessPercent: _calculateFreshnessPercent(ingredients),
      categoryCount: categories.length,
      optimizationPercent: 72,
    );
  }

  @override
  Future<List<PantryFilter>> getPantryFilters() async {
    final ingredients = await _getCachedIngredients();

    final countsByCategory = <String, int>{};
    for (final ingredient in ingredients) {
      countsByCategory.update(
        ingredient.category,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    return [
      PantryFilter(label: 'All', count: ingredients.length),
      ...countsByCategory.entries.map(
        (entry) => PantryFilter(label: entry.key, count: entry.value),
      ),
    ];
  }

  @override
  Future<List<PantryIngredient>> getPantryIngredients() async {
    return _getCachedIngredients();
  }

  @override
  Future<List<String>> getIngredientCategories() async {
    final ingredients = await _getCachedIngredients();

    return ingredients.map((item) => item.category).toSet().toList()..sort();
  }

  @override
  Future<PantryIngredient> addPantryIngredient({
    required int ingId,
    required String quantity,
    required String unit,
  }) async {
    final cleanedQuantity = quantity.trim();
    final cleanedUnit = unit.trim();

    final parsedQuantity = num.tryParse(cleanedQuantity);
    if (parsedQuantity == null) {
      throw ArgumentError('Quantity must be a valid number.');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/pantry',
      data: {
        'ing_id': ingId,
        'quantity': parsedQuantity,
        'unit': cleanedUnit,
      },
    );

    //new pantry data changed, so the next read should fetch fresh data
    _cachedIngredients = null;

    return _pantryIngredientFromJson(response.data ?? {});
  }

  @override
  Future<void> deletePantryIngredient(int pIngredientId) async {
    await _dio.delete<void>('/api/pantry/$pIngredientId');

    //delete changes the pantry list, so next read should fetch fresh data
    _cachedIngredients = null;
  }

  @override
  Future<PantryIngredient> updatePantryIngredient({
    required int pIngredientId,
    required int ingId,
    required String quantity,
    required String unit,
  }) async {
    final cleanedQuantity = quantity.trim();
    final cleanedUnit = unit.trim();

    final parsedQuantity = num.tryParse(cleanedQuantity);
    if (parsedQuantity == null) {
      throw ArgumentError('Quantity must be a valid number.');
    }

    final response = await _dio.put<Map<String, dynamic>>(
      '/api/pantry/$pIngredientId',
      data: {
        'ing_id': ingId,
        'quantity': parsedQuantity,
        'unit': cleanedUnit,
      },
    );

    //update changes pantry data, so next read should refetch from backend
    _cachedIngredients = null;

    return _pantryIngredientFromJson(response.data ?? {});
  }

  Future<List<PantryIngredient>> _getCachedIngredients() async {
    if (_cachedIngredients != null) {
      return _cachedIngredients!;
    }

    final response = await _dio.get<List<dynamic>>('/api/pantry');
    final data = response.data ?? [];

    _cachedIngredients = data
        .map((item) => _pantryIngredientFromJson(item as Map<String, dynamic>))
        .toList();

    return _cachedIngredients!;
  }

  PantryIngredient _pantryIngredientFromJson(Map<String, dynamic> json) {
    final quantity = json['quantity']?.toString() ?? '';
    final unit = json['unit']?.toString() ?? '';
    final category = json['category']?.toString() ?? 'Other';

    return PantryIngredient(
      //ids for update/delete API calls
      pIngredientId: _readInt(json['p_ingredient_id']),
      ingId: _readInt(json['ing_id']),
      name: json['name']?.toString() ?? 'Unknown ingredient',
      details: '$quantity$unit • Pantry',
      category: _displayCategory(category),
      status: PantryItemStatus.fresh,
      quantity: quantity,
      unit: unit,
    );
  }

  int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  int _calculateFreshnessPercent(List<PantryIngredient> ingredients) {
    if (ingredients.isEmpty) return 100;

    final freshCount = ingredients
        .where((ingredient) => ingredient.status == PantryItemStatus.fresh)
        .length;

    return ((freshCount / ingredients.length) * 100).round();
  }

  String _displayCategory(String category) {
    final normalized = category.toLowerCase();

    if (normalized.contains('meat') ||
        normalized.contains('poultry') ||
        normalized.contains('seafood') ||
        normalized.contains('legume')) {
      return 'Proteins';
    }

    if (normalized.contains('vegetable') ||
        normalized.contains('fruit') ||
        normalized.contains('produce')) {
      return 'Vegetables';
    }

    if (normalized.contains('dairy')) {
      return 'Dairy';
    }

    return category.isEmpty ? 'Other' : category;
  }
}
