import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';

//floating bottom controls used on the shopping list detail screen
class ShoppingBottomActionBar extends StatelessWidget {
  const ShoppingBottomActionBar({
    super.key,
    this.onMicTap,
    this.onAddTap,
    this.onFilterTap,
  });

  final VoidCallback? onMicTap;
  final VoidCallback? onAddTap;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          _RoundActionIcon(
            icon: Icons.mic_none,
            onTap: onMicTap,
          ),
          const Spacer(),
          _MainAddButton(onTap: onAddTap),
          const Spacer(),
          _RoundActionIcon(
            icon: Icons.sort,
            onTap: onFilterTap,
            showCircle: false,
          ),
        ],
      ),
    );
  }
}

//small circular icon button inside bottom action bar
class _RoundActionIcon extends StatelessWidget {
  const _RoundActionIcon({
    required this.icon,
    this.onTap,
    this.showCircle = true,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool showCircle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: showCircle ? AppColors.surfaceWhite : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: AppColors.tertiaryMuted,
            size: 24,
          ),
        ),
      ),
    );
  }
}

//large centre add button in bottom action bar
class _MainAddButton extends StatelessWidget {
  const _MainAddButton({
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? AppColors.surfaceMuted : AppColors.primary,
      shape: const CircleBorder(),
      elevation: onTap == null ? 0 : 8,
      shadowColor: AppColors.primary.withValues(alpha: 0.28),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 70,
          height: 70,
          child: Icon(
            Icons.add,
            color: onTap == null ? AppColors.textMuted : AppColors.textDark,
            size: 34,
          ),
        ),
      ),
    );
  }
}