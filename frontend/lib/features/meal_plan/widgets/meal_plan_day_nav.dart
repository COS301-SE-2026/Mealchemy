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
    required this.onDateSelected,
  });

  final DateTime day;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final ValueChanged<DateTime> onDateSelected;

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  static String _ordinal(int n) {
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
    static String formatDay(DateTime d) => '${_weekdays[d.weekday - 1]} ${_ordinal(d.day)}';

  bool get _isToday {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: day,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) onDateSelected(picked);
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
            const SizedBox(width: 4),
            InkWell(
              onTap: () => _pickDate(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_weekdays[day.weekday - 1]} ${_ordinal(day.day)}',
                      style: AppTextStyles.heading2.copyWith(
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
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