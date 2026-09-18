import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/feedback_provider.dart';
import '../../../core/shared_widgets/atoms/app_toast.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_network_image.dart';
import '../models/favourite.dart';
import '../providers/fav_provider.dart';

class FavRow extends ConsumerWidget {
  const FavRow({
    super.key,
    required this.fav,
    this.mutationsEnabled = true,
  });

  final Favourite fav;
  final bool mutationsEnabled;

  String get _subtitle {
    final recipe = fav.recipe;
    final total = (recipe.prepTimeMins ?? 0) + (recipe.cookingTimeMins ?? 0);
    final parts = <String>[
      if (total > 0) '$total mins',
      if (recipe.cuisineType != null && recipe.cuisineType!.isNotEmpty)
        recipe.cuisineType![0].toUpperCase() + recipe.cuisineType!.substring(1),
    ];
    return parts.join(' · ');
  }

  Future<void> _remove(WidgetRef ref) async {
    final feedback = ref.read(feedbackProvider.notifier);
    try {
      await ref.read(favsProvider.notifier).removeFav(fav.recipeId);
      feedback.showShort(
        'Removed from favourites',
        kind: ToastKind.success,
        icon: Icons.check_circle_outline,
      );
    } catch (_) {
      feedback.showShort(
        'Could not remove from favourites. Try again.',
        kind: ToastKind.error,
        icon: Icons.error_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 40,
              height: 40,
              child: RecipeNetworkImage(
                photoUrl: fav.recipe.photoUrl,
                placeholder: const DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.brand),
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: AppColors.textDark,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/recipe/${fav.recipeId}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fav.recipe.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.tertiaryMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (mutationsEnabled)
            IconButton(
              icon: const Icon(Icons.favorite, size: 18),
              color: AppColors.error,
              onPressed: () => _remove(ref),
            ),
        ],
      ),
    );
  }
}