//Lieghtweight summary of a recipe, for vault

class Recipe {
  final int recipeId;
  final String title;
  final String? description;
  final String? cuisineType;
  final int? prepTimeMins;
  final int? cookingTimeMins;
  final int? servingSize;
  final String? photoUrl;

  const Recipe({
    required this.recipeId,
    required this.title,
    this.description,
    this.cuisineType,
    this.prepTimeMins,
    this.cookingTimeMins,
    this.servingSize,
    this.photoUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeId: json['recipe_id'],
      title: json['title'],
      description: json['description'],
      cuisineType: json['cuisine_type'],
      prepTimeMins: json['prep_time_mins'],
      cookingTimeMins: json['cooking_time_mins'],
      servingSize: json['serving_size'],
      photoUrl: json['photo_url'],
    );
  }
}//mirrors recipes table
//defining shape of recipe data, to check design only details
//ingredients/steps are null in list responses, populated in detail responses
import 'recipe_ingredient.dart';
import 'recipe_step.dart';

class Recipe {
  final int recipeId;
  final int? ownerId;
  final String title;
  final String? description;
  final String? cuisineType;
  final int? prepTimeMins;
  final int? cookingTimeMins;
  final int? servingSize;
  final String? photoUrl;
  final String? videoUrl;
  final bool? isCommunityPublished;

  //populated by GET /recipes/{id}, null on list responses
  final List<RecipeIngredient>? ingredients;
  final List<RecipeStep>? steps;

  //for design-only to match wireframe
  final String? chefName;
  final String? chefAvatarUrl;
  final double? rating;
  final int? ratingCount;

  const Recipe({
    required this.recipeId,
    required this.title,
    this.ownerId,
    this.description,
    this.cuisineType,
    this.prepTimeMins,
    this.cookingTimeMins,
    this.servingSize,
    this.photoUrl,
    this.videoUrl,
    this.isCommunityPublished,
    this.ingredients,
    this.steps,
    this.chefName,
    this.chefAvatarUrl,
    this.rating,
    this.ratingCount,
  });
//convert from json to dart
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeId: json['recipe_id'] as int,
      ownerId: json['owner_id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      cuisineType: json['cuisine_type'] as String?,
      prepTimeMins: json['prep_time_mins'] as int?,
      cookingTimeMins: json['cooking_time_mins'] as int?,
      servingSize: json['serving_size'] as int?,
      photoUrl: json['photo_url'] as String?,
      videoUrl: json['video_url'] as String?,
      isCommunityPublished: json['is_community_published'] as bool?,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List<dynamic>?)
          ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      chefName: json['chef_name'] as String?,
      chefAvatarUrl: json['chef_avatar_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: json['rating_count'] as int?,
    );
  }
}
