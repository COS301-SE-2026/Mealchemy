import 'package:mealchemy/features/recipe/models/recipe.dart';

enum TrendType { trendingNow, editorsChoice }

class TrendingRecipeData {
  const TrendingRecipeData({
    required this.recipe,
    required this.trendType,
    required this.subtitle,
  });

  final Recipe recipe;
  final TrendType trendType;
  final String subtitle;
}