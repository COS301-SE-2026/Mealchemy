import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/organisms/app_navbar.dart';
import '../../../core/theme/app_colours.dart';
import '../providers/guided_discovery_provider.dart';
import '../widgets/discovery_complete_state.dart';
import '../widgets/discovery_header.dart';
import '../widgets/discovery_recipe_card.dart';
import '../widgets/swipe_action_button.dart';

//main Guided Discovery screen
//browse recommended recipes, like or dislike by swiping right or left
class GuidedDiscoveryScreen extends ConsumerWidget {
  const GuidedDiscoveryScreen({super.key});

  //recipe  filters
  static const List<String> _filters = [
    'All',
    'Quick Meals',
    'High Protein',
    'Vegetarian',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoveryState = ref.watch(guidedDiscoveryProvider);
    final notifier = ref.read(guidedDiscoveryProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Container(
              color: AppColors.bgLight,
              child: SafeArea(
                top: true,
                bottom: false,
                child: Column(
                  children: [
                    Expanded(
                      child: discoveryState.when(
                        //loading when recipes are being fetched
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        //error id recipe can't be retrieved
                        error: (error, stackTrace) => Center(
                          child: Text(error.toString()),
                        ),
                        data: (state) {
                          return Column(
                            children: [
                              DiscoveryHeader(
                                selectedFilter: state.selectedFilter,
                                filters: _filters,
                                onFilterSelected: notifier.selectFilter,
                              ),
                              Expanded(
                                child: state.isComplete
                                    //summary once all recipes have been reviewed
                                    ? DiscoveryCompleteState(
                                        likedCount: state.likedRecipeIds.length,
                                        dislikedCount:
                                            state.dislikedRecipeIds.length,
                                        onReset: notifier.resetDiscovery,
                                      )
                                    : Column(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 30,
                                              ),
                                              child: Center(
                                                //current recipe recommendation
                                                child: DiscoveryRecipeCard(
                                                  recipe: state.currentRecipe!,
                                                  currentIndex:
                                                      state.currentIndex,
                                                  totalRecipes:
                                                      state.recipes.length,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              54,
                                              12,
                                              54,
                                              18,
                                            ),
                                            //interaction controls (liking, viewing, etc)
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SwipeActionButton(
                                                  icon: Icons.close,
                                                  foregroundColor:
                                                      AppColors.accentMuted,
                                                  backgroundColor:
                                                      AppColors.surfaceWhite,
                                                  borderColor: AppColors.accent,
                                                  size: 62,
                                                  onTap: notifier
                                                      .dislikeCurrentRecipe,
                                                ),
                                                SwipeActionButton(
                                                  icon: Icons.restaurant,
                                                  foregroundColor:
                                                      AppColors.textDark,
                                                  backgroundColor:
                                                      AppColors.primary,
                                                  size: 78,
                                                  onTap: () {},
                                                ),
                                                SwipeActionButton(
                                                  icon: Icons.favorite,
                                                  foregroundColor:
                                                      AppColors.error,
                                                  backgroundColor:
                                                      AppColors.surfaceWhite,
                                                  size: 62,
                                                  onTap:
                                                      notifier.likeCurrentRecipe,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    AppNavbar(
                      currentRoute: AppRoutes.guidedDiscovery,
                      onRouteSelected: (route) {
                        if (route == AppRoutes.guidedDiscovery) return;
                        context.go(route);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}