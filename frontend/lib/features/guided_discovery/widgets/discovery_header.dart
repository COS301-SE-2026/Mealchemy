import 'package:flutter/material.dart';

import '../../../core/shared_widgets/atoms/app_chip.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

//header section for Discovery page (add button, tabs, filter button)
class DiscoveryHeader extends StatelessWidget {
  const DiscoveryHeader({
    super.key,
    required this.selectedFilter,
    required this.filters,
    required this.onFilterSelected,
  });

  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
      child: Column(
        children: [
          //top nav row
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.add,
                  color: AppColors.textLight,
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _DiscoveryTab(
                        label: 'Discover',
                        selected: true,
                      ),
                      SizedBox(width: 24),
                      _DiscoveryTab(
                        label: 'Sizzles',
                        selected: false,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.tune,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = filters[index];

                return AppChip(
                  label: filter,
                  selected: selectedFilter == filter,
                  onTap: () => onFilterSelected(filter),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//tab widget in top nav row
//handles selected/unselected + underlining
class _DiscoveryTab extends StatelessWidget {
  const _DiscoveryTab({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          maxLines: 1,
          style: AppTextStyles.heading2.copyWith(
            color: selected ? AppColors.textLight : AppColors.textMuted,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 3,
          width: selected ? 92 : 0,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ],
    );
  }
}