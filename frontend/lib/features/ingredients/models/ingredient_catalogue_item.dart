class IngredientCatalogueItem {
  final int ingId;
  final String name;
  final String? category;

  const IngredientCatalogueItem({
    required this.ingId,
    required this.name,
    this.category,
  });

  factory IngredientCatalogueItem.fromJson(Map<String, dynamic> json) {
    return IngredientCatalogueItem(
      ingId: json['ing_id'] as int,
      name: json['name'] as String,
      category: json['category'] as String?,
    );
  }
}