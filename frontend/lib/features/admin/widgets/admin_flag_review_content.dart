import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../recipe/utils/serving_scaler.dart';
import '../../recipe/widgets/recipe_network_image.dart';
import '../../recipe/widgets/recipe_step_row.dart';
import '../providers/admin_flag_detail_provider.dart';
import 'admin_flag_card.dart';

class AdminFlagReviewContent extends StatelessWidget {
  const AdminFlagReviewContent({
    super.key,
    required this.review,
    required this.onRetry,
  });

  final AdminFlagReview review;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final recipe = review.detail.recipe;
    final description = recipe.description?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminFlagCard(
          flag: review.detail.flag,
          showOpenButton: false,
        ),
        const SizedBox(height: 24),
        if (recipe.photoUrl?.trim().isNotEmpty == true) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: RecipeNetworkImage(
                photoUrl: recipe.photoUrl,
                placeholder: Container(
                  color: AppColors.surfaceMuted,
                  child: const Icon(
                    Icons.restaurant_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          recipe.title,
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description == null || description.isEmpty
              ? 'No description provided.'
              : description,
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 16),
        Text(
          recipe.isCommunityPublished
              ? 'Currently published in the community'
              : 'Not currently published in the community',
          style: AppTextStyles.bodyBold,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            if (recipe.ownerId != null)
              Text('Owner #${recipe.ownerId}', style: AppTextStyles.body),
            if (recipe.cuisineType?.trim().isNotEmpty == true)
              Text(
                recipe.cuisineType!.replaceAll('_', ' '),
                style: AppTextStyles.body,
              ),
            if (recipe.prepTimeMins != null)
              Text(
                'Prep: ${recipe.prepTimeMins} min',
                style: AppTextStyles.body,
              ),
            if (recipe.cookingTimeMins != null)
              Text(
                'Cook: ${recipe.cookingTimeMins} min',
                style: AppTextStyles.body,
              ),
            if (recipe.servingSize != null)
              Text(
                'Servings: ${recipe.servingSize}',
                style: AppTextStyles.body,
              ),
          ],
        ),
        if (recipe.externalUrl?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 16),
          Text('Source URL', style: AppTextStyles.bodyBold),
          SelectableText(recipe.externalUrl!, style: AppTextStyles.body),
        ],
        if (recipe.videoUrl?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 16),
          Text('Video URL', style: AppTextStyles.bodyBold),
          SelectableText(recipe.videoUrl!, style: AppTextStyles.body),
        ],
        const SizedBox(height: 28),
        _ReviewSection(
          title: 'Ingredients',
          value: review.ingredients,
          emptyMessage: 'No ingredients were returned for this recipe.',
          onRetry: onRetry,
          itemBuilder: (ingredient) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              [
                ingredient.name ?? 'Ingredient #${ingredient.ingId}',
                if (ingredient.quantity != null)
                  formatScaledQuantity(
                    quantity: ingredient.quantity!,
                    unit: ingredient.unit,
                    factor: 1,
                  )
                else if (ingredient.unit?.isNotEmpty == true)
                  ingredient.unit!,
              ].join(' · '),
              style: AppTextStyles.body,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _ReviewSection(
          title: 'Steps',
          value: review.steps,
          emptyMessage: 'No steps were returned for this recipe.',
          onRetry: onRetry,
          itemBuilder: (step) => RecipeStepRow(step: step),
        ),
      ],
    );
  }
}

class _ReviewSection<T> extends StatelessWidget {
  const _ReviewSection({
    required this.title,
    required this.value,
    required this.emptyMessage,
    required this.onRetry,
    required this.itemBuilder,
  });

  final String title;
  final AsyncValue<List<T>> value;
  final String emptyMessage;
  final VoidCallback onRetry;
  final Widget Function(T) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        if (value.hasError) ...[
          Text(
            '$title could not be loaded.',
            style: AppTextStyles.bodyBold,
          ),
          const SizedBox(height: 8),
          Text(
            adminDetailErrorMessage(value.error!),
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 12),
          AppButton.outlined(
            label: 'Retry $title',
            onPressed: onRetry,
          ),
        ] else if (value.isLoading)
          const CircularProgressIndicator()
        else if (value.requireValue.isEmpty)
          Text(emptyMessage, style: AppTextStyles.body)
        else
          for (final item in value.requireValue) itemBuilder(item),
      ],
    );
  }
}
