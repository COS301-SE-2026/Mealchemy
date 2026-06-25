import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_page_filter.dart';
import 'package:mealchemy/core/shared_widgets/Organisms/app_navbar.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_section_header.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/core/routes/app_routes.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.bgLight,
        body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 16),
            Padding(
              padding: const  EdgeInsets.symmetric(horizontal: 20),
              child: AppSectionHeader(
                title: 'Discover',
                size: SectionHeaderSize.large,
                weight: SectionHeaderWeight.bold,
              ),
            ),
            //Fillter bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppPageFilter(
                  options: _filters,
                  selectedIndex: _selectedFilterIndex,
                  onSelected: (i) => _selectedFilterIndex = i),
            ),
          ]),
        ),
        bottomNavigationBar: AppNavbar(
        currentRoute: AppRoutes.discovery,
        onRouteSelected: (route) => context.go(route),
      ),
        );

  }
}
