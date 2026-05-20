import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

//tab bar used in the recipe detail screen
class RecipeTabBar extends StatelessWidget {
  const RecipeTabBar({super.key, required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgLight,
      child: TabBar(
        controller: controller,
        isScrollable: false,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.divider.withValues(alpha: 0.5),
        labelStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTextStyles.bodySmall,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Ingredients'),
          Tab(text: 'Steps'),
          Tab(text: 'Nutrition'),
        ],
      ),
    );
  }
}
