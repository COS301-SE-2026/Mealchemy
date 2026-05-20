import 'pantry_ingredient.dart';

//summaries at the top of pantry page (freshness, categories, etc)
class PantrySummary {
  const PantrySummary({
    required this.totalItems,
    required this.freshnessPercent,
    required this.categoryCount,
    required this.optimizationPercent,
  });

  final int totalItems;
  final int freshnessPercent;
  final int categoryCount;
  final int optimizationPercent;
}

//filtering
class PantryFilter {
  const PantryFilter({
    required this.label,
    required this.count,
  });

  final String label;
  final int count;
}

//editable pantry state
class PantryState {
  const PantryState({
    required this.summary,
    required this.filters,
    required this.ingredients,
    required this.categories,
    this.selectedFilter = 'All',
    this.searchQuery = '',
  });

  final PantrySummary summary;
  final List<PantryFilter> filters;
  final List<PantryIngredient> ingredients;
  final List<String> categories;
  final String selectedFilter;
  final String searchQuery;

  //pantry updates unchangeable
  PantryState copyWith({
    PantrySummary? summary,
    List<PantryFilter>? filters,
    List<PantryIngredient>? ingredients,
    List<String>? categories,
    String? selectedFilter,
    String? searchQuery,
  }) {
    return PantryState(
      summary: summary ?? this.summary,
      filters: filters ?? this.filters,
      ingredients: ingredients ?? this.ingredients,
      categories: categories ?? this.categories,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}