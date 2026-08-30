//category option returned by GET /api/categories
class IngredientCategory {
  const IngredientCategory({
    required this.categoryId,
    required this.name,
  });

  final int categoryId;
  final String name;

  factory IngredientCategory.fromJson(Map<String, dynamic> json) {
    return IngredientCategory(
      categoryId: _readRequiredInt(json['category_id']),
      name: json['name']?.toString() ?? '',
    );
  }
}

//handles either JSON number or numeric string
int _readRequiredInt(dynamic value) {
  if (value is int) {
    return value;
  }

  final parsedValue = int.tryParse(value?.toString() ?? '');

  if (parsedValue == null) {
    throw const FormatException('Ingredient category requires category_id.');
  }

  return parsedValue;
}
