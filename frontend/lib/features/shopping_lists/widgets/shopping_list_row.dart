import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/shopping_list.dart';

//single shopping list row shown on Shopping Lists overview
class ShoppingListRow extends StatelessWidget {
  const ShoppingListRow({
    super.key,
    required this.list,
    this.onTap,
    this.onMoreTap,
  });

  final ShoppingList list;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              _ListAvatar(list: list),
              const SizedBox(width: 16),
              Expanded(
                child: _ListText(list: list),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.inputBorder.withValues(alpha: 0.95),
                ),
                color: AppColors.bgLight,
                onSelected: (value) async {
                  if (value == 'delete-list') {
                    onMoreTap?.call();
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 'delete-list',
                      child: Text(
                        'Delete list',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//leading icon/image for a shopping list row
class _ListAvatar extends StatelessWidget {
  const _ListAvatar({
    required this.list,
  });

  final ShoppingList list;

  @override
  Widget build(BuildContext context) {
    if (list.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          list.imageUrl!,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _IconAvatar(
              icon: Icons.restaurant_menu,
              backgroundColor: AppColors.surfaceMuted,
              foregroundColor: AppColors.accent,
            );
          },
        ),
      );
    }

    if (list.iconType == 'star') {
      return const _IconAvatar(
        icon: Icons.star,
        backgroundColor: Color(0xFFFFD96B),
        foregroundColor: AppColors.accentMuted,
      );
    }

    return const _IconAvatar(
      icon: Icons.list_alt,
      backgroundColor: AppColors.surfaceMuted,
      foregroundColor: AppColors.accent,
    );
  }
}

//plain icon avatar used when a row has no recipe image
class _IconAvatar extends StatelessWidget {
  const _IconAvatar({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: foregroundColor,
        size: 24,
      ),
    );
  }
}

//title and subtitle text for a shopping list row
class _ListText extends StatelessWidget {
  const _ListText({
    required this.list,
  });

  final ShoppingList list;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          list.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.title.copyWith(
            color: AppColors.textLight,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          //dynamic subtitles
          list.displaySubtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.tertiaryMuted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
