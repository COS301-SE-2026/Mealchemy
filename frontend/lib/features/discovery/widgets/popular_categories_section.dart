import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_section_header.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/discovery/models/discovery_category.dart';
import 'package:mealchemy/features/discovery/providers/discovery_provider.dart';

class PopularCategoriesSection extends ConsumerWidget {
  const PopularCategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoveryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppSectionHeader(title: 'Popular Categories'),
        ),

        const SizedBox(height: 16),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: state.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              final category = state.categories[index];
              final isSelected = category.id == state.selectedCategoryId;
              return _CategoryItem(
                category: category,
                isSelected: isSelected,
                onTap: () => ref
                    .read(discoveryProvider.notifier)
                    .selectCategory(category.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final DiscoveryCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          //Circle image with optional selected border ring
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2.5)
                  : Border.all(color: Colors.transparent, width: 2.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: Image.network(
                  category.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppColors.surfaceLight),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(color: AppColors.surfaceLight);
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),
          //Category name
          Text(
            category.name,
            style: AppTextStyles.caption.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}