//one ingredient line in a recipe, mirrors recipe_ingredients table (V12)
class RecipeIngredient {
  final int ingredientId;
  final int recipeId;
  final String nameRaw;
  final double? quantity;
  final String? unit;
  final int sortOrder;

  const RecipeIngredient({
    required this.ingredientId,
    required this.recipeId,
    required this.nameRaw,
    this.quantity,
    this.unit,
    this.sortOrder = 0,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      ingredientId: json['ingredient_id'] as int,
      recipeId: json['recipe_id'] as int,
      nameRaw: json['name_raw'] as String,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      sortOrder: (json['sort_order'] as int?) ?? 0,
    );
  }
}
