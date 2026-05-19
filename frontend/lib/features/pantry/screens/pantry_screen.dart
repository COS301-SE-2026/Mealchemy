import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/Molecules/app_search_bar.dart';
import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../../core/shared_widgets/Organisms/app_filter_bar.dart';
import '../../../core/shared_widgets/Organisms/app_navbar.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../widgets/pantry_item_card.dart';
import '../widgets/pantry_summary_card.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //temp mock data until pantry API connected
    final filterOptions = [
      const AppFilterOption(label: 'All', count: 42),
      const AppFilterOption(label: 'Proteins', count: 2),
      const AppFilterOption(label: 'Vegetables', count: 2),
      const AppFilterOption(label: 'Dairy', count: 2),
    ];

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
        child: ListView(
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
              options: filterOptions,
              selectedIndex: 0,
              onSelected: (_) {},
            ),
            const SizedBox(height: 22),
            const PantrySummaryCard(
              totalItems: 42,
              freshnessPercent: 84,
              categoryCount: 6,
              optimizationPercent: 72,
            ),
            const SizedBox(height: 26),
            const AppSectionHeader(
              title: 'Items',
              trailing: '42 ITEMS',
              showAccentLine: false,
            ),
            const SizedBox(height: 18),
            const AppSectionHeader(
              title: 'Proteins',
              trailing: '2 ITEMS',
              showAccentLine: false,
            ),
            const SizedBox(height: 10),
            PantryItemCard(
              name: 'Chicken Breast',
              details: '800g • Refrigerated',
              status: PantryItemStatus.fresh,
              onEdit: () {},
            ),
            const SizedBox(height: 12),
            PantryItemCard(
              name: 'Salmon Fillet',
              details: '150g • Use by tomorrow',
              status: PantryItemStatus.low,
              onEdit: () {},
            ),
            const SizedBox(height: 22),
            const AppSectionHeader(
              title: 'Vegetables',
              trailing: '2 ITEMS',
              showAccentLine: false,
            ),
            const SizedBox(height: 10),
            PantryItemCard(
              name: 'Cherry Tomatoes',
              details: '~10 pcs • Pantry',
              status: PantryItemStatus.low,
              onEdit: () {},
            ),
            const SizedBox(height: 12),
            PantryItemCard(
              name: 'Baby Spinach',
              details: '200g • Expired 2 days ago',
              status: PantryItemStatus.expired,
              onDelete: () {},
            ),
            const SizedBox(height: 22),
            const AppSectionHeader(
              title: 'Dairy',
              trailing: '2 ITEMS',
              showAccentLine: false,
            ),
            const SizedBox(height: 10),
            PantryItemCard(
              name: 'Parmesan Cheese',
              details: '150g • Wedge',
              status: PantryItemStatus.fresh,
              onEdit: () {},
            ),
            const SizedBox(height: 12),
            PantryItemCard(
              name: 'Full Cream Milk',
              details: '1L • Carton',
              status: PantryItemStatus.low,
              onEdit: () {},
            ),
          ],
        ),
      ),
    );
  }
}