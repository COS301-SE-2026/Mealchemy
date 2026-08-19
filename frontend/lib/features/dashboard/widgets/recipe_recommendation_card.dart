import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_match_badge.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/dashboard/models/dashboard_recipe_card_data.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_network_image.dart';

class RecipeRecommendationCard extends StatelessWidget {
  const RecipeRecommendationCard({
    super.key,
    required this.data,
  });

  final DashboardRecipeCardData data;
  //total time label
  String get _timeLabel {
    final total =
        (data.recipe.prepTimeMins ?? 0) + (data.recipe.cookingTimeMins ?? 0);

    return total > 0 ? '$total min' : '--';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.recipeDetail.replaceFirst(':id', '${data.recipe.recipeId}'),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              //image of the recipe
              _RecipeImage(photoUrl: data.recipe.photoUrl),
              //dark gradent overlay to make text more readable
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xCC000000),
                    ],
                    stops: [0.4, 1.0],
                  ),
                ),
              ),

              //Content layered over the image
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Match badge top left
                    Align(
                      alignment: Alignment.topRight,
                      child: AppMatchBadge(
                        percent: data.matchPercent,
                        size: BadgeSize.small,
                      ),
                    ),

                    const Spacer(),
                    //Category tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data.tag,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textDark,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    //recipe title
                    Text(
                      data.recipe.title,
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    //time and rating row
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textDark.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _timeLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textDark.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.star,
                          size: 12,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${data.rating}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textDark.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeImage extends StatelessWidget {
  const _RecipeImage({this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return RecipeNetworkImage(
      photoUrl: photoUrl,
      fit: BoxFit.cover,
      placeholder: Container(color: AppColors.primaryLight),
    );
  }
}
