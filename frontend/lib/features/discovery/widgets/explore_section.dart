import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_section_header.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_match_badge.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/discovery/models/explore_item.dart';
import 'package:mealchemy/features/discovery/providers/discovery_provider.dart';

const double _cellHeight = 130.0;
const double _gap = 2;

class ExploreSection extends ConsumerWidget {
  const ExploreSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoveryProvider);
    final items = state.exploreItems;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final selectdCategory = state.categories
        .where((c) => c.id == state.selectedCategoryId)
        .firstOrNull;

    final title =
        selectdCategory != null ? 'Explore ${selectdCategory.name}' : 'Explore';

    final List<List<ExploreItem>> blocks = [];

    for (int i = 0; i < items.length; i += 5) {
      blocks.add(items.sublist(i, (i + 5).clamp(0, items.length)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppSectionHeader(
            title: title,
            trailing: 'VIEW ALL',
            onTrailingTap: () {},
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(blocks.length, (blockIndex) {
            return _ExploreBlock(
              block: blocks[blockIndex],
              videoOnLeft: blockIndex.isEven,
            );
          }),
        ),
      ],
    );
  }
}

class _ExploreBlock extends StatelessWidget {
  const _ExploreBlock({
    required this.block,
    required this.videoOnLeft,
  });

  final List<ExploreItem> block;
  final bool videoOnLeft;

  @override
  Widget build(BuildContext context) {
    final video = block.firstWhere(
      (item) => item.isVideo,
      orElse: () => block.first,
    );
    final recipes = block.where((item) => !item.isVideo).toList();

    final recipeGrid = SizedBox(
      height: _cellHeight * 2 + _gap,
      child: Column(
        children: [
          Row(
            children: [
              if (recipes.isNotEmpty)
                Expanded(child: _RecipeCell(item: recipes[0])),
              const SizedBox(width: _gap),

              if (recipes.length > 1)
                Expanded(child: _RecipeCell(item: recipes[1])),
            ],
          ),
          const SizedBox(height: _gap),
          Row(
            children: [
              if (recipes.length > 2)
                Expanded(child: _RecipeCell(item: recipes[2])),
              const SizedBox(width: _gap),
              if (recipes.length > 3)
                Expanded(child: _RecipeCell(item: recipes[3])),
            ],
          ),
        ],
      ),
    );

    final videoCell = SizedBox(
      height: _cellHeight * 2 + _gap,
      child: _VideoCell(item: video),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: _gap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: videoOnLeft
            ? [
                Expanded(child: videoCell),
                const SizedBox(width: _gap),
                Expanded(flex: 2, child: recipeGrid),
              ]
            : [
                Expanded(flex: 2, child: recipeGrid),
                const SizedBox(width: _gap),
                Expanded(child: videoCell),
              ],
      ),
    );
  }
}

class _RecipeCell extends StatelessWidget {
  const _RecipeCell({required this.item});

  final ExploreItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _cellHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _CellImage(imageUrl: item.imageUrl),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ),
          if (item.matchPercent != null)
            Positioned(
              top: 6,
              right: 6,
              child: AppMatchBadge(
                percent: item.matchPercent!,
                size: BadgeSize.small,
              ),
            ),
          if (item.isMissingItems)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 9, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(
                      'Missing',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 6,
            left: 6,
            right: 6,
            child: Text(
              item.title,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoCell extends StatelessWidget {
  const _VideoCell({required this.item});

  final ExploreItem item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _CellImage(imageUrl: item.imageUrl),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0x55000000)),
          ),
        ),
        Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.brand,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.textDark,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

class _CellImage extends StatelessWidget {
  const _CellImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        decoration: const BoxDecoration(gradient: AppColors.brand),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        decoration: const BoxDecoration(gradient: AppColors.brand),
      ),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(color: AppColors.surfaceLight);
      },
    );
  }
}
