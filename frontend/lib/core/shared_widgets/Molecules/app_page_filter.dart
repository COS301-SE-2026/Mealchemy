import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';

//Label required and optional icon 

class PageFilterOption {
  const PageFilterOption({
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;
}

class AppPageFilter extends StatelessWidget{

  const AppPageFilter({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<PageFilterOption> options;
  final int selectedIndex;
  final void Function(int) onSelected;

   @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(options.length, (index) {
          final option = options[index];
          final selected = index == selectedIndex;
 
          return Padding(
            padding: EdgeInsets.only(
              right: index == options.length - 1 ? 0 : 8,
            ),
            child: _FilterPill(
              option: option,
              selected: selected,
              onTap: () => onSelected(index),
            ),
          );
        }),
      ),
    );
  }
}
 
class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.option,
    required this.selected,
    required this.onTap,
  });
 
  final PageFilterOption option;
  final bool selected;
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: option.icon != null ? 12 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.brand : null,
          color: selected ? null : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 13,
                color: selected ? AppColors.textDark : AppColors.textMuted,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              option.label,
              style: AppTextStyles.label.copyWith(
                color: selected ? AppColors.textDark : AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}