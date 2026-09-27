
import 'package:flutter/material.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_icon_button.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';

class MealPlanDayNav extends StatelessWidget {
  const MealPlanDayNav({
    super.key,
    required this.day,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final DateTime day;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  bool get _isToday {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIconButton.ghost(
              icon: Icons.chevron_left,
              onPressed: onPrevious,
              customColor: AppColors.textMuted,
              size: 36,
            ),
            const SizedBox(width: 8),
            Text(
              '${_weekdays[day.weekday - 1]} ${_ordinal(day.day)}',
              style: AppTextStyles.heading2.copyWith(
                fontSize: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            AppIconButton.ghost(
              icon: Icons.chevron_right,
              onPressed: onNext,
              customColor: AppColors.textMuted,
              size: 36,
            ),
          ],
        ),
        if (!_isToday)
          GestureDetector(
            onTap: onToday,
            child: Text(
              'BACK TO TODAY',
              style: AppTextStyles.label.copyWith(
                color: AppColors.accentMuted,
                letterSpacing: 1,
              ),
            ),
          ),
      ],
    );
  }
}