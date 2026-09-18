import 'package:mealchemy/features/recipe/models/recipe.dart';
/// Model class representing a favourite recipe
class Favourite {
  const Favourite({
    required this.favouriteId,
    required this.recipeId,
    required this.createdAt,
    required this.recipe,
  });

  final int favouriteId;
  final int recipeId;
  final DateTime createdAt;
  final Recipe recipe;

  factory Favourite.fromJson(Map<String, dynamic> json) {
    return Favourite(
      favouriteId: json['favourite_id'] as int,
      recipeId: json['recipe_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
    );
  }
}