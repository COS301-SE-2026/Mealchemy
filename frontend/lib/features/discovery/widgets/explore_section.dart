import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_section_header.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/discovery/providers/discovery_provider.dart';

const double _cellHeight = 130.0;
const double _gap = 2;

class ExploreSection extends ConsumerWidget {
  const ExploreSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoveryProvider);
    final recipes = state.visibleRecipes;

    final title = state.selectedCuisine != null
        ? 'Explore ${_formatCuisine(state.selectedCuisine!)}'
        : 'Explore';

    if (recipes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppSectionHeader(title: title),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('No published recipes yet.'),
          ),
        ],
      );
    }

    // rows of two tiles
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppSectionHeader(title: title),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            for (int i = 0; i < recipes.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: _gap),
                child: Row(
                  children: [
                    Expanded(child: _RecipeCell(recipe: recipes[i])),
                    const SizedBox(width: _gap),
                    Expanded(
                      child: i + 1 < recipes.length
                          ? _RecipeCell(recipe: recipes[i + 1])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RecipeCell extends StatelessWidget {
  const _RecipeCell({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final photoUrl = recipe.photoUrl;

    return GestureDetector(
      onTap: () => context.push('/recipe/${recipe.recipeId}'),
      child: SizedBox(
        height: _cellHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.brand),
            ),
            if (photoUrl != null && photoUrl.isNotEmpty)
              Image.network(
                photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const SizedBox.shrink(),
                errorBuilder: (context, error, stack) =>
                    const SizedBox.shrink(),
              ),
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
            Positioned(
              bottom: 6,
              left: 6,
              right: 6,
              child: Text(
                recipe.title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCuisine(String raw) {
  return raw
      .split('_')
      .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
      .join(' ');
}