import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_step.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_hero.dart';
import '../widgets/recipe_ingredient_row.dart';
import '../widgets/recipe_nutrition_tab.dart';
import '../widgets/recipe_stat_card.dart';
import '../widgets/recipe_step_row.dart';
import '../widgets/recipe_tab_bar.dart';

//tabs need controller with animation support
class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final int recipeId;

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

//4 tabs are overview, ingredients, steops and nutrition
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeState = ref.watch(recipeDetailProvider(widget.recipeId));

    return recipeState.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: AppColors.bgLight,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: _RecipeDetailError(message: '$error'),
      ),
      data: (recipe) => _RecipeDetailContent(
        recipe: recipe,
        tabController: _tabController,
      ),
    );
  }
}

class _RecipeDetailContent extends StatelessWidget {
  const _RecipeDetailContent({
    required this.recipe,
    required this.tabController,
  });

  final Recipe recipe;
  final TabController tabController;

//ingredients and steps are null on endpoint
//sorted* guards against null
  @override
  Widget build(BuildContext context) {
    final ingredients = _sortedIngredients(recipe.ingredients);
    final steps = _sortedSteps(recipe.steps);
    //to make hero stay fixed at top, while scroll
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          RecipeHero(recipe: recipe),
          RecipeTabBar(controller: tabController),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _OverviewTab(
                    recipe: recipe, ingredients: ingredients, steps: steps),
                _IngredientsTab(ingredients: ingredients),
                _StepsTab(steps: steps),
                RecipeNutritionTab(
                  recipeId: recipe.recipeId,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: AppButton.primary(
            label: 'Start Cooking',
            onPressed: () {},
            leftIcon: Icons.restaurant_menu_outlined,
            isFullWidth: true,
            size: ButtonSize.large,
          ),
        ),
      ),
    );
  }
} //simulate to start cooking, to still be implemented

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.recipe,
    required this.ingredients,
    required this.steps,
  });

  final Recipe recipe;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      children: [
        _StatRow(recipe: recipe),
        const SizedBox(height: 26),
        const _SectionTitle(title: 'Ingredients'),
        const SizedBox(height: 12),
        ...ingredients.map((ing) => RecipeIngredientRow(ingredient: ing)),
        const SizedBox(height: 28),
        const _SectionTitle(title: 'Preparation'),
        const SizedBox(height: 12),
        ...steps.map((step) => RecipeStepRow(step: step)),
        const SizedBox(height: 22),
      ],
    );
  }
}

class _IngredientsTab extends StatelessWidget {
  const _IngredientsTab({required this.ingredients});

  final List<RecipeIngredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      children: [
        const _SectionTitle(title: 'Ingredients'),
        const SizedBox(height: 12),
        ...ingredients.map((ing) => RecipeIngredientRow(ingredient: ing)),
      ],
    );
  }
}

class _StepsTab extends StatelessWidget {
  const _StepsTab({required this.steps});

  final List<RecipeStep> steps;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      children: [
        const _SectionTitle(title: 'Preparation'),
        const SizedBox(height: 12),
        ...steps.map((step) => RecipeStepRow(step: step)),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RecipeStatCard(
            icon: Icons.local_fire_department_outlined,
            value: recipe.cookingTimeMins != null
                ? '${recipe.cookingTimeMins}m'
                : '-',
            label: 'Cook time',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RecipeStatCard(
            icon: Icons.access_time,
            value:
                recipe.prepTimeMins != null ? '${recipe.prepTimeMins}m' : '-',
            label: 'Prep time',
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.heading2.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RecipeDetailError extends StatelessWidget {
  const _RecipeDetailError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Unable to load recipe.',
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
    );
  }
}

List<RecipeIngredient> _sortedIngredients(List<RecipeIngredient>? items) {
  if (items == null || items.isEmpty) return const [];
  final copy = [...items]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return copy;
}

List<RecipeStep> _sortedSteps(List<RecipeStep>? items) {
  if (items == null || items.isEmpty) return const [];
  final copy = [...items]..sort((a, b) => a.stepNr.compareTo(b.stepNr));
  return copy;
}
