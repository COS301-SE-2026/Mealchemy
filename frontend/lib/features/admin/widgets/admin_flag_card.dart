import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../recipe/widgets/recipe_network_image.dart';
import '../models/admin_models.dart';
import '../providers/admin_queue_provider.dart';

class AdminFlagCard extends StatelessWidget {
  const AdminFlagCard({
    super.key,
    required this.flag,
    this.showOpenButton = true,
  });

  final FlaggedRecipe flag;
  final bool showOpenButton;

  @override
  Widget build(BuildContext context) {
    final date = flag.flaggedAt.toLocal();
    final localizations = MaterialLocalizations.of(context);
    final dateLabel = localizations.formatMediumDate(date);
    final timeLabel = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(date),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: RecipeNetworkImage(
                    photoUrl: flag.recipePhotoUrl,
                    placeholder: Container(
                      color: AppColors.surfaceMuted,
                      child: const Icon(
                        Icons.restaurant_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flag.recipeTitle,
                      style: AppTextStyles.bodyBold.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Report #${flag.flaggedId} · '
                      '${flagStatusLabel(flag.status)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            flag.reasonLabel,
            style: AppTextStyles.bodyBold.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reported by user #${flag.flaggedByUserId}',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 4),
          Text(
            '$dateLabel · $timeLabel',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          if (showOpenButton) ...[
            const SizedBox(height: 16),
            AppButton.outlined(
              label: 'View report',
              rightIcon: Icons.chevron_right,
              isFullWidth: true,
              onPressed: () => context.push(
                AppRoutes.adminFlagDetail.replaceFirst(
                  ':id',
                  '${flag.flaggedId}',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
