import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_section_header.dart';
import 'package:mealchemy/features/dashboard/providers/dashboard_provider.dart';
import 'package:mealchemy/features/dashboard/widgets/recipe_recommendation_card.dart';

class RecommendedRecipesSection extends ConsumerWidget {
  const RecommendedRecipesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(dashboardProvider).recommendedRecipes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppSectionHeader(
            title: 'Recommended for You',
            trailing: 'View all',
          ),
        ),

        const SizedBox(height: 16),

        if (recipes.isEmpty)
          const SizedBox(height: 200)
        else
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: recipes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return RecipeRecommendationCard(data: recipes[index]);
              },
            ),
          ),
      ],
    );
  }
}