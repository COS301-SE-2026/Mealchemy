import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/Organisms/app_navbar.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/shopping_list.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';
import '../widgets/shopping_list_row.dart';
import '../widgets/shopping_section_header.dart';

//main Shopping Lists overview screen
class ShoppingListsScreen extends ConsumerWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingLists = ref.watch(shoppingListsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: shoppingLists.when(
        data: (state) => _ShoppingListsContent(state: state),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (_, __) => Center(
          child: Text(
            'Unable to load shopping lists.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textDark,
        elevation: 8,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: AppNavbar(
        currentRoute: AppRoutes.shoppingLists,
        onRouteSelected: (route) => context.go(route),
      ),
    );
  }
}

//loaded content for Shopping Lists overview screen
class _ShoppingListsContent extends StatelessWidget {
  const _ShoppingListsContent({
    required this.state,
  });

  final ShoppingListsState state;

  @override
  Widget build(BuildContext context) {
    final groupedLists = state.groupedLists;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 96),
        children: [
          const _ShoppingListsTopBar(),
          const SizedBox(height: 26),
          const _ShoppingListsTitle(),
          const SizedBox(height: 30),
          ShoppingSectionHeader(
            title: 'Lists',
            trailing: '${state.lists.length} lists',
          ),
          const SizedBox(height: 34),
          ..._buildSections(
            context: context,
            groupedLists: groupedLists,
          ),
        ],
      ),
    );
  }

  //builds each grouped shopping list section
  List<Widget> _buildSections({
    required BuildContext context,
    required Map<String, List<ShoppingList>> groupedLists,
  }) {
    final widgets = <Widget>[];

    for (final entry in groupedLists.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            entry.key,
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
        ),
      );

      for (final list in entry.value) {
        widgets.add(
          ShoppingListRow(
            list: list,
            onTap: () {
              if (list.id == 'general-list') {
                context.go('/shopping-lists/${list.id}');
              }
            },
          ),
        );
      }

      widgets.add(const SizedBox(height: 18));
    }

    return widgets;
  }
}

//top icon row for search/add/camera actions
class _ShoppingListsTopBar extends StatelessWidget {
  const _ShoppingListsTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.search,
            color: AppColors.textLight,
            size: 28,
          ),
        ),
        const Spacer(),
        Column(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.add,
                color: AppColors.textLight,
                size: 32,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.textLight,
                size: 26,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

//large title row for Shopping Lists heading
class _ShoppingListsTitle extends StatelessWidget {
  const _ShoppingListsTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Shopping Lists',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
            fontSize: 34,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 52,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ],
    );
  }
}
