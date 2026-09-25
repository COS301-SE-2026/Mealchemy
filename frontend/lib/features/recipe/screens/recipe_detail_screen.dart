import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/Molecules/app_refresh.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../cook_mode/providers/cook_session_provider.dart';
import '../models/equipment.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_step.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_equipment_section.dart';
import '../widgets/recipe_hero.dart';
import '../widgets/recipe_ingredient_row.dart';
import '../widgets/recipe_nutrition_tab.dart';
import '../widgets/recipe_stat_card.dart';
import '../widgets/recipe_servings_section.dart';
import '../widgets/recipe_step_row.dart';
import '../widgets/recipe_tab_bar.dart';
import '../../offline/data/offline_cache_store.dart';
import '../../offline/widgets/cache_freshness_label.dart';

//tabs need controller with animation support
class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    this.allowReporting = false,
  });

  final int recipeId;
  final bool allowReporting;

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

//5 tabs are overview, ingredients, equipment, steops and nutrition
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() =>
      ref.refresh(recipeDetailProvider(widget.recipeId).future);

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
        onRefresh: _refresh,
        allowReporting: widget.allowReporting,
      ),
    );
  }
}

class _RecipeDetailContent extends ConsumerWidget {
  const _RecipeDetailContent({
    required this.recipe,
    required this.tabController,
    required this.onRefresh,
    required this.allowReporting,
  });

  final Recipe recipe;
  final TabController tabController;
  final Future<void> Function() onRefresh;
  final bool allowReporting;

//ingredients and steps are null on endpoint
//sorted* guards against null
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredients = _sortedIngredients(recipe.ingredients);
    final steps = _sortedSteps(recipe.steps);
    final session =
        ref.watch(cookSessionForRecipeProvider(recipe.recipeId)).valueOrNull;
    final resumeIndex = session?.matchingStepIndex(steps);
    //to make hero stay fixed at top, while scroll
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          RecipeHero(
            recipe: recipe,
            allowReporting: allowReporting,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: CacheFreshnessLabel(
              collection: CacheCollection.recipe,
              scopeId: recipe.recipeId.toString(),
            ),
          ),
          RecipeTabBar(controller: tabController),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _OverviewTab(
                  recipe: recipe,
                  ingredients: ingredients,
                  steps: steps,
                  onRefresh: onRefresh,
                ),
                _IngredientsTab(
                  recipe: recipe,
                  ingredients: ingredients,
                  onRefresh: onRefresh,
                ),
                _EquipmentTab(
                  equipment: recipe.equipment ?? const [],
                  onRefresh: onRefresh,
                ),
                _StepsTab(steps: steps, onRefresh: onRefresh),
                AppRefresh(
                  onRefresh: onRefresh,
                  child: RecipeNutritionTab(recipeId: recipe.recipeId),
                )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: AppButton.primary(
            label: resumeIndex == null
                ? 'Start Cooking'
                : 'Resume Step ${resumeIndex + 1}',
            onPressed: steps.isEmpty
                ? null
                : () => context.push('/recipe/${recipe.recipeId}/cook'),
            leftIcon: Icons.restaurant_menu_outlined,
            isFullWidth: true,
            size: ButtonSize.large,
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.recipe,
    required this.ingredients,
    required this.steps,
    required this.onRefresh,
  });

  final Recipe recipe;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppRefresh(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        children: [
          _StatRow(recipe: recipe),
          const SizedBox(height: 12),
          RecipeServingsSection(
            recipeId: recipe.recipeId,
            baseServings: recipe.servingSize ?? 1,
          ),
          if (recipe.equipment?.isNotEmpty ?? false) ...[
            const SizedBox(height: 26),
            const _SectionTitle(title: 'Equipment'),
            const SizedBox(height: 12),
            RecipeEquipmentSection(equipment: recipe.equipment!),
          ],
          const SizedBox(height: 26),
          const _SectionTitle(title: 'Ingredients'),
          const SizedBox(height: 12),
          ...ingredients.map(
            (ing) => RecipeIngredientRow(
              ingredient: ing,
              recipeId: recipe.recipeId,
              baseServings: recipe.servingSize ?? 1,
            ),
          ),
          const SizedBox(height: 28),
          const _SectionTitle(title: 'Preparation'),
          const SizedBox(height: 12),
          ...steps.map((step) => RecipeStepRow(step: step)),
          const SizedBox(height: 22),
        ],
      ),
    );
  }
}

class _IngredientsTab extends StatelessWidget {
  const _IngredientsTab(
      {required this.recipe,
      required this.ingredients,
      required this.onRefresh});
  final Recipe recipe;
  final List<RecipeIngredient> ingredients;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppRefresh(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        children: [
          const _SectionTitle(title: 'Ingredients'),
          const SizedBox(height: 12),
          ...ingredients.map(
            (ing) => RecipeIngredientRow(
              ingredient: ing,
              recipeId: recipe.recipeId,
              baseServings: recipe.servingSize ?? 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentTab extends StatelessWidget {
  const _EquipmentTab({required this.equipment, required this.onRefresh});

  final List<Equipment> equipment;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppRefresh(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        children: [
          const _SectionTitle(title: 'Equipment'),
          const SizedBox(height: 12),
          if (equipment.isEmpty)
            Text(
              'No equipment listed for this recipe.',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            )
          else
            RecipeEquipmentSection(equipment: equipment),
        ],
      ),
    );
  }
}

class _StepsTab extends StatelessWidget {
  const _StepsTab({required this.steps, required this.onRefresh});

  final List<RecipeStep> steps;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppRefresh(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        children: [
          const _SectionTitle(title: 'Preparation'),
          const SizedBox(height: 12),
          ...steps.map((step) => RecipeStepRow(step: step)),
        ],
      ),
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