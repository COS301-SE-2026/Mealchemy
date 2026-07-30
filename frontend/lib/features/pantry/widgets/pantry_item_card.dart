import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

enum PantryItemStatus {
  fresh,
  low,
  expired,
}

class PantryItemCard extends StatelessWidget {
  const PantryItemCard({
    super.key,
    required this.name,
    required this.details,
    required this.status,
    this.imageUrl,
    this.onEdit,
    this.onDelete,
  });

  final String name;
  final String details;
  final PantryItemStatus status;
  final String? imageUrl;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  bool get _isExpired => status == PantryItemStatus.expired;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
      PantryItemStatus.fresh => AppColors.success,
      PantryItemStatus.low => AppColors.warning,
      PantryItemStatus.expired => AppColors.error,
    };

    final statusLabel = switch (status) {
      PantryItemStatus.fresh => 'Fresh',
      PantryItemStatus.low => 'Low',
      PantryItemStatus.expired => 'Expired',
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _isExpired
            ? AppColors.error.withValues(alpha: 0.06)
            : AppColors.textDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isExpired
              ? AppColors.error.withValues(alpha: 0.22)
              : AppColors.divider.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textLight.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _IngredientImage(imageUrl: imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.body.copyWith(
                      color: _isExpired ? AppColors.error : AppColors.textLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    details,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _isExpired ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusLabel(label: statusLabel, color: statusColor),
              const SizedBox(height: 8),
              IconButton(
                onPressed: onEdit,
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color:
                      onEdit == null ? AppColors.textMuted : AppColors.primary,
                ),
                tooltip: 'Edit ingredient',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color:
                      onDelete == null ? AppColors.textMuted : AppColors.error,
                ),
                tooltip: 'Delete ingredient',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IngredientImage extends StatelessWidget {
  const _IngredientImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Container(
        width: 58,
        height: 58,
        color: AppColors.surfaceLight,
        child: imageUrl == null
            ? const Icon(
                Icons.restaurant_outlined,
                color: AppColors.primary,
              )
            : Image.network(imageUrl!, fit: BoxFit.cover),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 3.5, backgroundColor: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
