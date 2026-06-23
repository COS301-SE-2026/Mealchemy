import 'package:mealchemy/features/recipe/models/recipe.dart';

class DashboardRecipeCardData {
  const DashboardRecipeCardData({
    required this.recipe,
    required this.matchPercent,
    required this.tag,
    required this.rating,
  });
 
  final Recipe recipe;
  final int matchPercent;
  final String tag;
  final double rating;
}