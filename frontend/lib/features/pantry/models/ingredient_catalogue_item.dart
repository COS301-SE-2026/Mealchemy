//one ingredient option from backend ingredient catalogue
class IngredientCatalogueItem {
  const IngredientCatalogueItem({
    required this.ingId,
    required this.name,
    required this.category,
  });

  final int ingId;
  final String name;
  final String category;

  factory IngredientCatalogueItem.fromJson(Map<String, dynamic> json) {
    return IngredientCatalogueItem(
      ingId: _readInt(json['ing_id']) ?? 0,
      name: json['name']?.toString() ?? 'Unknown ingredient',
      category: json['category']?.toString() ?? 'Other',
    );
  }
}

//helper function
int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
