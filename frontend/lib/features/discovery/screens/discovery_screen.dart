import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_badge.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_icon_button.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_search_bar.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_refresh.dart';import 'package:mealchemy/features/discovery/widgets/popular_categories_section.dart';
import 'package:mealchemy/features/discovery/providers/discovery_provider.dart';
import 'package:mealchemy/features/discovery/widgets/explore_section.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(discoveryProvider.notifier).loadDiscovery(),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
                padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: AppSearchBar(
                        controller: _searchCtrl,
                        hint: 'Search recipes...',
                        onChanged: (v) => setState(() => _query = v),
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
              const SizedBox(height: 16),
              const PopularCategoriesSection(),
              const SizedBox(height: 20),
              ExploreSection(query: _query),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}