import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/Organisms/app_navbar.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/guided_discovery_provider.dart';
import '../widgets/discovery_complete_state.dart';
import '../widgets/discovery_header.dart';
import '../widgets/discovery_recipe_card.dart';
import '../widgets/swipe_action_button.dart';

//main Guided Discovery swipe screen
class GuidedDiscoveryScreen extends ConsumerWidget {
  const GuidedDiscoveryScreen({super.key});

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
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
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
                                    ? DiscoveryCompleteState(
                                      likedCount: state.likedRecipeIds.length,
                                      dislikedCount: state.dislikedRecipeIds.length,
                                      tasteSignals: state.topTasteSignals,
                                      recommendedRecipe: state.recommendedRecipe,
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
                                                child: _SwipeableRecipeCard(
                                                  onSwipeLeft: notifier
                                                      .dislikeCurrentRecipe,
                                                  onSwipeRight: notifier
                                                      .likeCurrentRecipe,
                                                  child: DiscoveryRecipeCard(
                                                    recipe:
                                                        state.currentRecipe!,
                                                    currentIndex:
                                                        state.currentIndex,
                                                    totalRecipes:
                                                        state.totalRecipes,
                                                  ),
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
                                                  onTap: notifier
                                                      .likeCurrentRecipe,
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

//handles left and right swipes on recipe card
class _SwipeableRecipeCard extends StatefulWidget {
  const _SwipeableRecipeCard({
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  final Widget child;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  @override
  State<_SwipeableRecipeCard> createState() => _SwipeableRecipeCardState();
}

class _SwipeableRecipeCardState extends State<_SwipeableRecipeCard> {
  static const double _swipeThreshold = 110;

  Offset _dragOffset = Offset.zero;
  double _rotation = 0;
  bool _isAnimatingOut = false;

  //updates card position while user drags
  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isAnimatingOut) return;

    setState(() {
      _dragOffset += details.delta;
      _rotation = (_dragOffset.dx / 320).clamp(-0.18, 0.18);
    });
  }

  //checks if swipe should count as like/dislike
  Future<void> _handlePanEnd(DragEndDetails details) async {
    if (_isAnimatingOut) return;

    final velocity = details.velocity.pixelsPerSecond.dx;
    final shouldLike = _dragOffset.dx > _swipeThreshold || velocity > 750;
    final shouldSkip = _dragOffset.dx < -_swipeThreshold || velocity < -750;

    if (shouldLike) {
      await _animateCardOut(toRight: true);
      widget.onSwipeRight();
      _resetCard();
      return;
    }

    if (shouldSkip) {
      await _animateCardOut(toRight: false);
      widget.onSwipeLeft();
      _resetCard();
      return;
    }

    _resetCard();
  }

  //animates card off screen after valid swipe
  Future<void> _animateCardOut({required bool toRight}) async {
    setState(() {
      _isAnimatingOut = true;
      _dragOffset = Offset(toRight ? 520 : -520, _dragOffset.dy);
      _rotation = toRight ? 0.22 : -0.22;
    });

    await Future.delayed(const Duration(milliseconds: 180));
  }

  //resets card position for next recipe
  void _resetCard() {
    if (!mounted) return;

    setState(() {
      _dragOffset = Offset.zero;
      _rotation = 0;
      _isAnimatingOut = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final likeOpacity = (_dragOffset.dx / _swipeThreshold).clamp(0.0, 1.0);
    final skipOpacity = (-_dragOffset.dx / _swipeThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: AnimatedContainer(
        duration: Duration(milliseconds: _isAnimatingOut ? 180 : 120),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(_dragOffset.dx, _dragOffset.dy)
          ..rotateZ(_rotation),
        child: Stack(
          children: [
            widget.child,
            Positioned(
              top: 24,
              right: 24,
              child: _SwipeLabel(
                label: 'LIKE',
                color: AppColors.success,
                opacity: likeOpacity,
              ),
            ),
            Positioned(
              top: 24,
              left: 24,
              child: _SwipeLabel(
                label: 'SKIP',
                color: AppColors.error,
                opacity: skipOpacity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//label shown while swiping left or right
class _SwipeLabel extends StatelessWidget {
  const _SwipeLabel({
    required this.label,
    required this.color,
    required this.opacity,
  });

  final String label;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 90),
        opacity: opacity,
        child: Transform.rotate(
          angle: label == 'LIKE' ? 0.14 : -0.14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color, width: 2),
            ),
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: color,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
