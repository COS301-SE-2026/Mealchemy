import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_section_header.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/dashboard/models/trending_recipe_data.dart';
import 'package:mealchemy/features/dashboard/providers/dashboard_provider.dart';

class TrendingRecipesSection extends ConsumerWidget {
  const TrendingRecipesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(dashboardProvider).trendingRecipes;

    if (trending.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppSectionHeader(
            title: 'Trending Recipes',
            trailing: 'View all',
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: List.generate(trending.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < trending.length - 1 ? 12 : 0,
                ),
                child: _TrendingTile(data: trending[index]),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _TrendingTile extends StatelessWidget {
  const _TrendingTile({required this.data});
  final TrendingRecipeData data;

  String get _badgeLabel {
    switch (data.trendType) {
      case TrendType.trendingNow:
        return 'TRENDING NOW';
      case TrendType.editorsChoice:
        return "EDITOR'S CHOICE";
    }
  }

  IconData get _badgeIcon {
    switch (data.trendType) {
      case TrendType.trendingNow:
        return Icons.trending_up;

      case TrendType.editorsChoice:
        return Icons.workspace_premium_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.recipeDetail.replaceFirst(':id', '${data.recipe.recipeId}'),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 72,
                child: _ThumbnailImage(photoUrl: data.recipe.photoUrl),
              ),
            ),
            const SizedBox(width: 12),

            //text contet
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Badge
                  Row(
                    children: [
                      Icon(
                        _badgeIcon,
                        size: 11,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _badgeLabel,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.accent,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),


                  //the recipe tittle 
                  Text(
                    data.recipe.title,
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.textLight,

                    ),
                    maxLines: 2,

                     overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),
                  //subtitle
                  Text(
                    data.subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
               color: AppColors.textMuted,
               size: 20,
            ),

          ],
        ),
      ),
    );
  }
}

class _ThumbnailImage extends StatelessWidget {
  const _ThumbnailImage({this.photoUrl});
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return Container(
        decoration: const BoxDecoration(gradient: AppColors.brand),
        child: const Icon(
          Icons.soup_kitchen_outlined,

          color: AppColors.textDark,
          size: 28,
        ),
      );
    }

    return Image.network(
      photoUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        decoration: const BoxDecoration(gradient: AppColors.brand),
      ),
      
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(color: AppColors.surfaceLight);
      },
    );
  }
}
