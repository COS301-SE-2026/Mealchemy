class IngredientCatalogueItem {
  const IngredientCatalogueItem({
    required this.ingId,
    required this.name,
    this.category,
    this.sourceId,
    this.sourceApi,
  });

  final int? ingId;
  final String name;
  final String? category;
  final String? sourceId;
  final String? sourceApi;

  bool get requiresImport => ingId == null;

  bool get isLocalCatalogueItem => ingId != null;

  factory IngredientCatalogueItem.fromJson(Map<String, dynamic> json) {
    return IngredientCatalogueItem(
      ingId: _readInt(json['ing_id']),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString(),
      sourceId: json['source_id']?.toString(),
      sourceApi: json['source_api']?.toString(),
    );
  }
}

//preserves null for external results which have not been imported yet
int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
