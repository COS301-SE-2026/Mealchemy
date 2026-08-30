import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/connectivity/network_status_provider.dart';
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
import '../models/ingredient_catalogue_item.dart';
import '../../offline/data/offline_cache_store.dart';
import '../../offline/widgets/cache_freshness_label.dart';

const List<String> _unitOptions = [
  'g',
  'kg',
  'ml',
  'L',
  'cups',
  'tbsp',
  'tsp',
  'oz',
  'pcs',
];

//change from stateless widget to consumer widget
class PantryScreen extends ConsumerWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantryState = ref.watch(pantryStateProvider);
    final isReadOnly = ref.watch(offlineReadOnlyProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Pantry'),
        actions: [
          IconButton(
            onPressed: isReadOnly ? null : () {},
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
        tooltip: 'Add Pantry Ingredient',
        onPressed:
            isReadOnly ? null : () => context.push(AppRoutes.addIngredient),
        backgroundColor:
            isReadOnly ? AppColors.surfaceMuted : AppColors.primary,
        foregroundColor: AppColors.textDark,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: pantryState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _PantryError(message: '$error'),
          data: (state) => _PantryContent(
            pantryState: state,
            isReadOnly: isReadOnly,
          ),
        ),
      ),
    );
  }
}

class _PantryContent extends ConsumerWidget {
  const _PantryContent({
    required this.pantryState,
    required this.isReadOnly,
  });

  final PantryState pantryState;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantryNotifier = ref.read(pantryStateProvider.notifier);
    final visibleIngredients = _visibleIngredients(pantryState);
    final groupedIngredients = _groupIngredientsByCategory(visibleIngredients);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      children: [
        AppSearchBar(
          hint: 'Search pantry...',
          onChanged: pantryNotifier.updateSearchQuery,
          onClear: pantryNotifier.clearSearch,
        ),
        const SizedBox(height: 18),
        Text(
          'Pantry',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        const CacheFreshnessLabel(
          collection: CacheCollection.pantry,
          scopeId: CacheScope.all,
        ),
        const SizedBox(height: 16),
        AppFilterBar(
          options: pantryState.filters
              .map(
                (filter) => AppFilterOption(
                  label: filter.label,
                  count: filter.count,
                ),
              )
              .toList(),
          selectedIndex: _selectedFilterIndex(pantryState),
          onSelected: (index) => pantryNotifier.selectFilter(
            pantryState.filters[index].label,
          ),
        ),
        const SizedBox(height: 22),
        PantrySummaryCard(
          totalItems: pantryState.summary.totalItems,
          freshnessPercent: pantryState.summary.freshnessPercent,
          categoryCount: pantryState.summary.categoryCount,
          optimizationPercent: pantryState.summary.optimizationPercent,
        ),
        const SizedBox(height: 26),
        AppSectionHeader(
          title: 'Items',
          trailing: '${visibleIngredients.length} ITEMS',
          showAccentLine: false,
        ),
        const SizedBox(height: 18),
        if (visibleIngredients.isEmpty)
          _EmptyPantryResults(query: pantryState.searchQuery)
        else
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
                    onEdit: isReadOnly ||
                            ingredient.pIngredientId == null ||
                            ingredient.ingId == null
                        ? null
                        : () => _showEditPantryIngredientDialog(
                              context: context,
                              ref: ref,
                              ingredient: ingredient,
                            ),
                    onDelete: isReadOnly || ingredient.pIngredientId == null
                        ? null
                        : () => pantryNotifier.removeIngredient(
                              ingredient.pIngredientId!,
                            ),
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

//category and search filters
List<PantryIngredient> _visibleIngredients(PantryState pantryState) {
  final query = pantryState.searchQuery.toLowerCase();

  return pantryState.ingredients.where((ingredient) {
    final matchesFilter = pantryState.selectedFilter == 'All' ||
        ingredient.category == pantryState.selectedFilter;
    final matchesSearch =
        query.isEmpty || ingredient.name.toLowerCase().contains(query);

    return matchesFilter && matchesSearch;
  }).toList();
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

int _selectedFilterIndex(PantryState pantryState) {
  final index = pantryState.filters.indexWhere(
    (filter) => filter.label == pantryState.selectedFilter,
  );

  return index < 0 ? 0 : index;
}

class _EmptyPantryResults extends StatelessWidget {
  const _EmptyPantryResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final message = query.isEmpty
        ? 'No pantry ingredients found.'
        : 'No ingredients match "$query".';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
      ),
    );
  }
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

Future<void> _showEditPantryIngredientDialog({
  required BuildContext context,
  required WidgetRef ref,
  required PantryIngredient ingredient,
}) async {
  final nameController = TextEditingController(text: ingredient.name);
  final quantityController = TextEditingController(
    text: ingredient.quantity ?? '',
  );

  IngredientCatalogueItem selectedIngredient = IngredientCatalogueItem(
    ingId: ingredient.ingId!,
    name: ingredient.name,
    category: ingredient.category,
  );

  var selectedUnit = ingredient.unit;
  var ingredientOptions = <IngredientCatalogueItem>[];
  var isSearching = false;
  var showValidation = false;
  var isSaving = false;
  String? searchError;
  String? saveError;
  var searchRequestId = 0;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> searchIngredients(String value) async {
            final query = value.trim();
            final requestId = ++searchRequestId;

            setDialogState(() {
              selectedIngredient = IngredientCatalogueItem(
                ingId: ingredient.ingId!,
                name: ingredient.name,
                category: ingredient.category,
              );
              searchError = null;
            });

            if (query.isEmpty) {
              setDialogState(() {
                ingredientOptions = [];
                isSearching = false;
              });
              return;
            }

            setDialogState(() => isSearching = true);

            try {
              final results = await ref
                  .read(ingredientCatalogueRepositoryProvider)
                  .searchIngredients(query);

              if (requestId != searchRequestId) return;

              setDialogState(() {
                ingredientOptions = results;
                isSearching = false;
              });
            } catch (_) {
              if (requestId != searchRequestId) return;

              setDialogState(() {
                ingredientOptions = [];
                isSearching = false;
                searchError = 'Could not search ingredients.';
              });
            }
          }

          Future<void> saveChanges() async {
            final quantity = quantityController.text.trim();
            final unit = selectedUnit?.trim() ?? '';

            if (quantity.isEmpty || unit.isEmpty) {
              setDialogState(() {
                showValidation = true;
                saveError = null;
              });
              return;
            }

            setDialogState(() {
              isSaving = true;
              saveError = null;
            });

            try {
              await ref.read(pantryStateProvider.notifier).updateIngredient(
                    pIngredientId: ingredient.pIngredientId!,
                    ingId: selectedIngredient.ingId,
                    quantity: quantity,
                    unit: unit,
                  );

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            } catch (_) {
              setDialogState(() {
                isSaving = false;
                saveError = 'Could not update ingredient.';
              });
            }
          }

          return AlertDialog(
            backgroundColor: AppColors.bgCream,
            title: Text(
              'Edit Ingredient',
              style: AppTextStyles.title.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredient name',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: searchIngredients,
                  ),
                  if (searchError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        searchError!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  if (isSearching)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: LinearProgressIndicator(),
                    ),
                  if (ingredientOptions.isNotEmpty)
                    ...ingredientOptions.map(
                      (option) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(option.name),
                        subtitle: Text(option.category),
                        onTap: () {
                          setDialogState(() {
                            selectedIngredient = option;
                            nameController.text = option.name;
                            ingredientOptions = [];
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                    ),
                    items: _unitOptions
                        .map(
                          (unit) => DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedUnit = value);
                    },
                  ),
                  if (showValidation)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Quantity and unit are required.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  if (saveError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        saveError!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    isSaving ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isSaving ? null : saveChanges,
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
