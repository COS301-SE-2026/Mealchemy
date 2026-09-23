import 'package:flutter/material.dart';

import '../../../core/shared_widgets/atoms/app_chip.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

enum DiscoveryTab { discover, sizzles }

//header section for Discovery page (add button, tabs, filter button)
class DiscoveryHeader extends StatelessWidget {
  const DiscoveryHeader({
    super.key,
    required this.selectedFilter,
    required this.filters,
    required this.onFilterSelected,
    this.selectedTab = DiscoveryTab.discover,
    this.onTabSelected,
  });

  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String> onFilterSelected;
  final DiscoveryTab selectedTab;
  final ValueChanged<DiscoveryTab>? onTabSelected;

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
                    children: [
                      _DiscoveryTab(
                        label: 'Discover',
                        selected: selectedTab == DiscoveryTab.discover,
                        onTap: () => onTabSelected?.call(DiscoveryTab.discover),
                      ),
                      const SizedBox(width: 24),
                      _DiscoveryTab(
                        label: 'Sizzles',
                        selected: selectedTab == DiscoveryTab.sizzles,
                        onTap: () => onTabSelected?.call(DiscoveryTab.sizzles),
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
          if (selectedTab == DiscoveryTab.discover) ...[
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
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }
}