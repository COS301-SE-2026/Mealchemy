import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_badge.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_icon_button.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_page_filter.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_refresh.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_section_header.dart';
import 'package:mealchemy/features/discovery/widgets/popular_categories_section.dart';
import 'package:mealchemy/features/discovery/providers/discovery_provider.dart';
import 'package:mealchemy/features/discovery/widgets/explore_section.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  int _selectedFilterIndex = 0;
  static const _filters = [
    PageFilterOption(label: 'Favourites', icon: Icons.favorite_outline),
    PageFilterOption(label: 'History', icon: Icons.history),
    PageFilterOption(label: 'Following', icon: Icons.person_outline),
    PageFilterOption(label: 'Trending'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(discoveryProvider.notifier).loadDiscovery(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(shoppingListCountProvider);
    return AppRefresh(
      onRefresh: () => ref.read(discoveryProvider.notifier).loadDiscovery(),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AppSectionHeader(
                        title: 'Discover',
                        size: SectionHeaderSize.large,
                        weight: SectionHeaderWeight.bold,
                      ),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AppIconButton.ghost(
                          icon: Icons.shopping_cart_outlined,
                          onPressed: () =>
                              context.push(AppRoutes.shoppingLists),
                          customColor: AppColors.textLight,
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: AppBadge(count: cartCount),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppPageFilter(
                  options: _filters,
                  selectedIndex: _selectedFilterIndex,
                  onSelected: (i) => setState(() => _selectedFilterIndex = i),
                ),
              ),
              const SizedBox(height: 28),
              const PopularCategoriesSection(),
              const SizedBox(height: 28),
              const ExploreSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}