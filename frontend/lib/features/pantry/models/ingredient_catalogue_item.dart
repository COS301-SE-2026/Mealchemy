//one local or external ingredient option returned by catalogue search
class IngredientCatalogueItem {
  const IngredientCatalogueItem({
    required this.ingId,
    required this.name,
    required this.category,
    this.sourceId,
    this.sourceApi,
  });

  //null means this external result has not been saved locally yet
  final int? ingId;

  final String name;

  //USDA search results do not contain a Mealchemy category yet
  final String? category;

  //external provider fields are null for existing local catalogue items
  final String? sourceId;
  final String? sourceApi;

  bool get requiresImport => ingId == null;

  bool get isLocalCatalogueItem => ingId != null;

  factory IngredientCatalogueItem.fromJson(Map<String, dynamic> json) {
    return IngredientCatalogueItem(
      ingId: _readInt(json['ing_id']),
      name: json['name']?.toString() ?? 'Unknown ingredient',
      category: json['category']?.toString(),
      sourceId: json['source_id']?.toString(),
      sourceApi: json['source_api']?.toString(),
    );
  }
}

//backend IDs may occasionally be decoded from numeric strings in tests/caches
int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
