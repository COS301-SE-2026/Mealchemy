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

//single favourite as its own card
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.push('/recipe/${fav.recipeId}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: RecipeNetworkImage(
                      photoUrl: fav.recipe.photoUrl,
                      placeholder: const DecoratedBox(
                        decoration: BoxDecoration(gradient: AppColors.brand),
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: AppColors.textDark,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fav.recipe.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: mutationsEnabled ? () => _remove(ref) : null,
                  tooltip: mutationsEnabled
                      ? 'Remove from favourites'
                      : 'Unavailable offline',
                  icon: Icon(
                    Icons.favorite,
                    size: 18,
                    color:
                        mutationsEnabled ? AppColors.error : AppColors.textMuted,
                  ),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}