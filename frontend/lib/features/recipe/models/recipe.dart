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
      recipeId: json['recipe_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      cuisineType: json['cuisine_type'] as String?,
      prepTimeMins: json['prep_time_mins'] as int?,
      cookingTimeMins: json['cooking_time_mins'] as int?,
      servingSize: json['serving_size'] as int?,
      photoUrl: json['photo_url'] as String?,
    );
  }
}