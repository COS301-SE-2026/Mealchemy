//mirrors the recipes table
//Lightweight summary shared with vault; ingredients/steps are null on the
//list endpoint and populated on the detail endpoint.
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';

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
  final String? externalUrl;
  final bool isCommunityPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  //populated by GET /recipes/{id}, null on list responses
  final List<RecipeIngredient>? ingredients;
  final List<RecipeStep>? steps;

  const Recipe({
    required this.recipeId,
    this.ownerId,
    required this.title,
    this.description,
    this.cuisineType,
    this.prepTimeMins,
    this.cookingTimeMins,
    this.servingSize,
    this.photoUrl,
    this.videoUrl,
    this.externalUrl,
    this.isCommunityPublished = false,
    this.createdAt,
    this.updatedAt,
    this.ingredients,
    this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeId: json['recipeId'] as int,
      ownerId: json['ownerId'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      cuisineType: json['cuisineType'] as String?,
      prepTimeMins: json['prepTimeMins'] as int?,
      cookingTimeMins: json['cookingTimeMins'] as int?,
      servingSize: json['servingSize'] as int?,
      photoUrl: json['photoUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      externalUrl: json['externalUrl'] as String?,
      isCommunityPublished: json['isCommunityPublished'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List<dynamic>?)
          ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  Map<String, dynamic> toFullRequestJson({bool removePhoto = false}) => {
        'title': title,
        'description': description ?? '',
        'cuisineType': cuisineType,
        'prepTimeMins': prepTimeMins,
        'cookingTimeMins': cookingTimeMins,
        'servingSize': servingSize,
        'photoUrl': photoUrl,
        'removePhoto': removePhoto,
        'videoUrl': videoUrl,
        'externalUrl': externalUrl,
        'isCommunityPublished': isCommunityPublished,
        'ingredients': ingredients?.map((i) => i.toJson()).toList() ?? [],
        'steps': steps?.map((s) => s.toJson()).toList() ?? [],
      };

//metadata-only body for POST /recipes/create and PUT /recipes/edit/{id}
  Map<String, dynamic> toCreateRequestJson() => {
        'title': title,
        'description': description,
        'cuisineType': cuisineType,
        'prepTimeMins': prepTimeMins,
        'cookingTimeMins': cookingTimeMins,
        'servingSize': servingSize,
        'photoUrl': photoUrl,
        'videoUrl': videoUrl,
        'externalUrl': externalUrl,
        'isCommunityPublished': isCommunityPublished,
      };
      
  Recipe copyWith({
    int? recipeId,
    int? ownerId,
    String? title,
    String? description,
    String? cuisineType,
    int? prepTimeMins,
    int? cookingTimeMins,
    int? servingSize,
    String? photoUrl,
    String? videoUrl,
    String? externalUrl,
    bool? isCommunityPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<RecipeIngredient>? ingredients,
    List<RecipeStep>? steps,
  }) {
    return Recipe(
      recipeId: recipeId ?? this.recipeId,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      cuisineType: cuisineType ?? this.cuisineType,
      prepTimeMins: prepTimeMins ?? this.prepTimeMins,
      cookingTimeMins: cookingTimeMins ?? this.cookingTimeMins,
      servingSize: servingSize ?? this.servingSize,
      photoUrl: photoUrl ?? this.photoUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      externalUrl: externalUrl ?? this.externalUrl,
      isCommunityPublished: isCommunityPublished ?? this.isCommunityPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
    );
  }
}
