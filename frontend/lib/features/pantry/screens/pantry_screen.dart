import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/Molecules/app_search_bar.dart';
import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../../core/shared_widgets/Organisms/app_filter_bar.dart';
import '../../../core/shared_widgets/Organisms/app_navbar.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/pantry_ingredient.dart';
import '../models/pantry_summary.dart';
import '../providers/pantry_provider.dart';
import '../widgets/pantry_item_card.dart';
import '../widgets/pantry_summary_card.dart';

//change from stateless widget to consumer widget
class PantryScreen extends ConsumerWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryState = ref.watch(pantrySummaryProvider);
    final filtersState = ref.watch(pantryFiltersProvider);
    final ingredientsState = ref.watch(pantryIngredientsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Pantry'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.qr_code_scanner_outlined),
            tooltip: 'Scan ingredient',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
          ),
        ],
      ),
      bottomNavigationBar: AppNavbar(
        currentRoute: AppRoutes.pantry,
        onRouteSelected: (route) => context.go(route),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.addIngredient),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textDark,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: summaryState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _PantryError(message: '$error'),
          data: (summary) => filtersState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _PantryError(message: '$error'),
            data: (filters) => ingredientsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _PantryError(message: '$error'),
              data: (ingredients) => _PantryContent(
                summary: summary,
                filters: filters,
                ingredients: ingredients,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PantryContent extends StatelessWidget {
  const _PantryContent({
    required this.summary,
    required this.filters,
    required this.ingredients,
  });

  final PantrySummary summary;
  final List<PantryFilter> filters;
  final List<PantryIngredient> ingredients;

  @override
  Widget build(BuildContext context) {
    final groupedIngredients = _groupIngredientsByCategory(ingredients);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      children: [
        AppSearchBar(
          hint: 'Search pantry...',
          onChanged: (_) {},
          onClear: () {},
        ),
        const SizedBox(height: 18),
        Text(
          'Pantry',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        AppFilterBar(
          options: filters
              .map(
                (filter) => AppFilterOption(
                  label: filter.label,
                  count: filter.count,
                ),
              )
              .toList(),
          selectedIndex: 0,
          onSelected: (_) {},
        ),
        const SizedBox(height: 22),
        PantrySummaryCard(
          totalItems: summary.totalItems,
          freshnessPercent: summary.freshnessPercent,
          categoryCount: summary.categoryCount,
          optimizationPercent: summary.optimizationPercent,
        ),
        const SizedBox(height: 26),
        AppSectionHeader(
          title: 'Items',
          trailing: '${summary.totalItems} ITEMS',
          showAccentLine: false,
        ),
        const SizedBox(height: 18),
        ...groupedIngredients.entries.expand(
          (entry) => [
            AppSectionHeader(
              title: entry.key,
              trailing: '${entry.value.length} ITEMS',
              showAccentLine: false,
            ),
            const SizedBox(height: 10),
            ...entry.value.map(
              (ingredient) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PantryItemCard(
                  name: ingredient.name,
                  details: ingredient.details,
                  status: ingredient.status,
                  onEdit: () {},
                  onDelete: () {},
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ],
    );
  }
}

//pantry rows grouped by categories
Map<String, List<PantryIngredient>> _groupIngredientsByCategory(
  List<PantryIngredient> ingredients,
) {
  final grouped = <String, List<PantryIngredient>>{};

  for (final ingredient in ingredients) {
    grouped.putIfAbsent(ingredient.category, () => []);
    grouped[ingredient.category]!.add(ingredient);
  }

  return grouped;
}

class _PantryError extends StatelessWidget {
  const _PantryError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Unable to load pantry data.',
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
    );
  }
}