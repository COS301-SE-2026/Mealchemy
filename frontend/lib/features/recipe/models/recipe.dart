//mirrors the recipes table 
//Lightweight summary shared with vault; ingredients/steps are null on the
//list endpoint and populated on the detail endpoint.
import 'recipe_ingredient.dart';
import 'recipe_step.dart';

class Recipe {
  final int recipeId;
  final String title;
  final String? description;
  final String? cuisineType;
  final int? prepTimeMins;
  final int? cookingTimeMins;
  final int? servingSize;
  final String? photoUrl;

  //populated by GET /recipes/{id}, null on list responses
  final List<RecipeIngredient>? ingredients;
  final List<RecipeStep>? steps;

  const Recipe({
    required this.recipeId,
    required this.title,
    this.description,
    this.cuisineType,
    this.prepTimeMins,
    this.cookingTimeMins,
    this.servingSize,
    this.photoUrl,
    this.ingredients,
    this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeId: json['recipe_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      cuisineType: json['cuisine_type'] as String?,
      prepTimeMins: json['prep_time_mins'] as int?,
      cookingTimeMins: json['cooking_time_mins'] as int?,
      servingSize: json['serving_size'] as int?,
      photoUrl: json['photo_url'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List<dynamic>?)
          ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
