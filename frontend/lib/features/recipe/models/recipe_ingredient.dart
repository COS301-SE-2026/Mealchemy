//one ingredient line in a recipe, mirrors recipe_ingredients table the new update database table
class RecipeIngredient {
  final int ingredientId;
  final int recipeId;
  final int ingId;
  final String? name;
  final double? quantity;
  final String? unit;
  final int sortOrder;

  const RecipeIngredient({
    required this.ingredientId,
    required this.recipeId,
    required this.ingId,
    this.name,
    this.quantity,
    this.unit,
    this.sortOrder = 0,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      ingredientId: json['ingredient_id'] as int,
      recipeId: json['recipe_id'] as int,
      ingId: json['ing_id'] as int,
      name: json['ingName'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      sortOrder: (json['sort_order'] as int?) ?? 0,
    );
  }
  Map<String, dynamic> toJson() => {
        'ingId': ingId,
        'quantity': quantity,
        'unit': unit,
        'sortOrder': sortOrder,
      };
}
