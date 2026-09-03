//nutrition values already calculated by the backend
class NutritionValues {
  const NutritionValues({
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fibreG,
    required this.sodiumMg,
  });

  final double caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fibreG;
  final double sodiumMg;

  factory NutritionValues.fromJson(Map<String, dynamic> json) {
    return NutritionValues(
      caloriesKcal: _readDouble(json['calories_kcal']),
      proteinG: _readDouble(json['protein_g']),
      carbsG: _readDouble(json['carbs_g']),
      fatG: _readDouble(json['fat_g']),
      fibreG: _readDouble(json['fibre_g']),
      sodiumMg: _readDouble(json['sodium_mg']),
    );
  }
}

//nutrition contribution made by one recipe ingredient
class IngredientNutrition {
  const IngredientNutrition({
    required this.ingredientId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.values,
    required this.percentOfRecipeCalories,
  });

  final int ingredientId;
  final String name;
  final double quantity;
  final String unit;
  final NutritionValues values;

  //calculated from ingredient calories and whole-recipe calories
  final double percentOfRecipeCalories;

  factory IngredientNutrition.fromJson(
    Map<String, dynamic> json, {
    required double totalRecipeCalories,
  }) {
    final values = NutritionValues.fromJson(json);

    return IngredientNutrition(
      ingredientId: _readInt(json['ing_id']),
      name: json['name']?.toString() ?? 'Unknown ingredient',
      quantity: _readDouble(json['quantity']),
      unit: json['unit']?.toString() ?? '',
      values: values,
      percentOfRecipeCalories: _calculateCaloriePercentage(
        ingredientCalories: values.caloriesKcal,
        totalRecipeCalories: totalRecipeCalories,
      ),
    );
  }
}

//complete calculator response for one recipe
class RecipeNutrition {
  const RecipeNutrition({
    required this.recipeId,
    required this.servings,
    required this.totals,
    required this.perServing,
    required this.ingredients,
  });

  final int recipeId;
  final int servings;
  final NutritionValues totals;
  final NutritionValues perServing;
  final List<IngredientNutrition> ingredients;

  factory RecipeNutrition.fromJson(Map<String, dynamic> json) {
    final totals = NutritionValues.fromJson(
      json['totals'] as Map<String, dynamic>? ?? const {},
    );

    final perServing = NutritionValues.fromJson(
      json['per_serving'] as Map<String, dynamic>? ?? const {},
    );

    final ingredientsJson = json['ingredients'] as List<dynamic>? ?? const [];

    return RecipeNutrition(
      recipeId: _readInt(json['recipe_id']),
      servings: _readInt(json['servings']),
      totals: totals,
      perServing: perServing,
      ingredients: ingredientsJson
          .map(
            (ingredient) => IngredientNutrition.fromJson(
              ingredient as Map<String, dynamic>,
              totalRecipeCalories: totals.caloriesKcal,
            ),
          )
          .toList(),
    );
  }
}

double _calculateCaloriePercentage({
  required double ingredientCalories,
  required double totalRecipeCalories,
}) {
  if (totalRecipeCalories <= 0) return 0;

  return ingredientCalories / totalRecipeCalories * 100;
}

//API numbers can be integers, decimals or numeric strings
double _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
