import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_refresh.dart';
import '../models/recommendation.dart';
import '../providers/guided_discovery_provider.dart';
import '../widgets/discovery_complete_state.dart';
import '../widgets/discovery_header.dart';
import '../widgets/discovery_recipe_card.dart';
import '../widgets/swipe_action_button.dart';
import '../widgets/recipe_preview_sheet.dart';

//main Guided Discovery swipe screen
class GuidedDiscoveryScreen extends ConsumerStatefulWidget {
  const GuidedDiscoveryScreen({super.key});

  @override
  ConsumerState<GuidedDiscoveryScreen> createState() =>
      _GuidedDiscoveryScreenState();
}

class _GuidedDiscoveryScreenState extends ConsumerState<GuidedDiscoveryScreen> {
  static const List<String> _filters = [
    'All',
    'Quick Meals',
    'High Protein',
    'Vegetarian',
  ];
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final discoveryState = ref.watch(guidedDiscoveryProvider);
    final notifier = ref.read(guidedDiscoveryProvider.notifier);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Container(
            color: AppColors.bgLight,
            child: SafeArea(
              top: true,
              bottom: false,
              child: discoveryState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => _ErrorState(
                  message: error.toString(),
                  onRetry: notifier.resetDiscovery,
                ),
                data: (state) {
                  return Column(
                    children: [
                      DiscoveryHeader(
                        selectedFilter: _selectedFilter,
                        filters: _filters,
                        onFilterSelected: (f) =>
                            setState(() => _selectedFilter = f),
                      ),
                      Expanded(
                        child: AppRefresh(
                          onRefresh: notifier.resetDiscovery,
                          child: state.isComplete
                              ? DiscoveryCompleteState(
                                  likedCount: state.likedCount,
                                  dislikedCount: state.dislikedCount,
                                  skippedCount: state.skippedCount,
                                  onReset: notifier.resetDiscovery,
                                )
                              : _Deck(
                                  state: state,
                                  notifier: notifier,
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Deck extends StatelessWidget {
  const _Deck({required this.state, required this.notifier});

  final GuidedDiscoveryState state;
  final GuidedDiscoveryNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final card = state.currentRecipe;
    if (card == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: SizedBox(
              height: constraints.maxHeight,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Center(
                        child: _SwipeableRecipeCard(
                          key: ValueKey(card.recipeId),
                          onSwipeLeft: notifier.dislikeCurrentRecipe,
                          onSwipeRight: notifier.likeCurrentRecipe,
                          child: DiscoveryRecipeCard(
                            recommendation: card,
                            currentIndex: state.currentIndex,
                            totalRecipes: state.deck.length,
                            onViewRecipe: () =>
                                _showRecipePreview(context, card),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SwipeActionButton(
                          icon: Icons.close,
                          foregroundColor: AppColors.accentMuted,
                          backgroundColor: AppColors.surfaceWhite,
                          borderColor: AppColors.accent,
                          size: 62,
                          onTap: notifier.dislikeCurrentRecipe,
                        ),
                        SwipeActionButton(
                          icon: Icons.skip_next,
                          foregroundColor: AppColors.textDark,
                          backgroundColor: AppColors.primary,
                          size: 78,
                          onTap: notifier.skipCurrentRecipe,
                        ),
                        SwipeActionButton(
                          icon: Icons.favorite,
                          foregroundColor: AppColors.error,
                          backgroundColor: AppColors.surfaceWhite,
                          size: 62,
                          onTap: notifier.likeCurrentRecipe,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void _showRecipePreview(BuildContext context, Recommendation recommendation) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bgLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.86,
        child: RecipePreviewSheet(recommendation: recommendation),
      );
    },
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.tertiaryMuted),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Try Again',
                style: AppTextStyles.button.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeableRecipeCard extends StatefulWidget {
  const _SwipeableRecipeCard({
    super.key,
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

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isAnimatingOut) return;
    setState(() {
      _dragOffset += details.delta;
      _rotation = (_dragOffset.dx / 320).clamp(-0.18, 0.18);
    });
  }

  Future<void> _handlePanEnd(DragEndDetails details) async {
    if (_isAnimatingOut) return;

    final velocity = details.velocity.pixelsPerSecond.dx;
    final shouldLike = _dragOffset.dx > _swipeThreshold || velocity > 750;
    final shouldSkip = _dragOffset.dx < -_swipeThreshold || velocity < -750;

    if (shouldLike) {
      await _animateCardOut(toRight: true);
      widget.onSwipeRight();
      return;
    }
    if (shouldSkip) {
      await _animateCardOut(toRight: false);
      widget.onSwipeLeft();
      return;
    }
    _resetCard();
  }

  Future<void> _animateCardOut({required bool toRight}) async {
    setState(() {
      _isAnimatingOut = true;
      _dragOffset = Offset(toRight ? 520 : -520, _dragOffset.dy);
      _rotation = toRight ? 0.22 : -0.22;
    });
    await Future.delayed(const Duration(milliseconds: 180));
  }

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
          ..translateByDouble(_dragOffset.dx, _dragOffset.dy, 0, 1)
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
