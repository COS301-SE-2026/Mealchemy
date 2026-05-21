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