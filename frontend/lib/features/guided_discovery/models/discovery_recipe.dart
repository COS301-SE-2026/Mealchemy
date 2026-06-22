class DiscoveryRecipe {
  const DiscoveryRecipe({
    //recipe's info
    required this.id,
    required this.title,
    required this.chefName,
    required this.imageUrl,
    required this.matchPercentage,
    required this.cookTimeMinutes,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.tags,
    required this.ingredients,
  });

  //properties
  final String id;
  final String title;
  final String chefName;
  final String imageUrl;
  final int matchPercentage;
  final int cookTimeMinutes;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final List<String> tags;
  final List<String> ingredients;
}
