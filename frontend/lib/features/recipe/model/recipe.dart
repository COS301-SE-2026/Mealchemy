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
}