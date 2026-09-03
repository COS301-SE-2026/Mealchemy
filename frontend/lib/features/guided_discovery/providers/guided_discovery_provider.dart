import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/providers/api_service_provider.dart';
import '../models/recommendation.dart';
import '../models/swipe.dart';
import '../repositories/guided_discovery_repository.dart';
import '../repositories/api_guided_discovery_repository.dart';

final guidedDiscoveryRepositoryProvider =
    Provider<GuidedDiscoveryRepository>((ref) {
  return ApiGuidedDiscoveryRepository(ref.read(dioProvider));
});

final guidedDiscoveryProvider =
    AsyncNotifierProvider<GuidedDiscoveryNotifier, GuidedDiscoveryState>(
  GuidedDiscoveryNotifier.new,
);

// Deck state for the swipe screen. `deck` is the running list of cards fetched
class GuidedDiscoveryState {
  const GuidedDiscoveryState({
    this.deck = const [],
    this.currentIndex = 0,
    this.likedCount = 0,
    this.dislikedCount = 0,
    this.skippedCount = 0,
    this.exhausted = false,
    this.isFetchingMore = false,
  });

  final List<Recommendation> deck;
  final int currentIndex;
  final int likedCount;
  final int dislikedCount;
  final int skippedCount;
  final bool exhausted;
  final bool isFetchingMore;

  Recommendation? get currentRecipe =>
      currentIndex < deck.length ? deck[currentIndex] : null;

  // Complete once the pool is exhausted and every fetched card is behind us.
  bool get isComplete => exhausted && currentIndex >= deck.length;

  int get reviewedCount => likedCount + dislikedCount + skippedCount;

  GuidedDiscoveryState copyWith({
    List<Recommendation>? deck,
    int? currentIndex,
    int? likedCount,
    int? dislikedCount,
    int? skippedCount,
    bool? exhausted,
    bool? isFetchingMore,
  }) {
    return GuidedDiscoveryState(
      deck: deck ?? this.deck,
      currentIndex: currentIndex ?? this.currentIndex,
      likedCount: likedCount ?? this.likedCount,
      dislikedCount: dislikedCount ?? this.dislikedCount,
      skippedCount: skippedCount ?? this.skippedCount,
      exhausted: exhausted ?? this.exhausted,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

class GuidedDiscoveryNotifier extends AsyncNotifier<GuidedDiscoveryState> {
  late final GuidedDiscoveryRepository _repository;

  static const _batchSize = 10;
  // Fetch the next batch once only this many cards remain ahead of the user.
  static const _prefetchThreshold = 3;

  @override
  Future<GuidedDiscoveryState> build() async {
    _repository = ref.watch(guidedDiscoveryRepositoryProvider);
    return _loadInitial();
  }

  Future<GuidedDiscoveryState> _loadInitial() async {
    try {
      final batch = await _repository.getRecommendations(batchSize: _batchSize);
      return GuidedDiscoveryState(deck: batch);
    } on EmptyRecommendationPool {
      return const GuidedDiscoveryState(exhausted: true);
    }
  }

  void likeCurrentRecipe() => _advance(SwipeAction.liked);
  void dislikeCurrentRecipe() => _advance(SwipeAction.disliked);
  void skipCurrentRecipe() => _advance(SwipeAction.skipped);

  // Advance the deck immediately, then record the swipe in the bacground so the card never waits on the network.
  void _advance(SwipeAction action) {
    final current = state.valueOrNull;
    final card = current?.currentRecipe;

    if (current == null || card == null) return;

    state = AsyncData(
      current.copyWith(
      currentIndex: current.currentIndex + 1,
      likedCount: action == SwipeAction.liked ? current.likedCount + 1 : null,
      dislikedCount: action == SwipeAction.disliked ? current.dislikedCount + 1 : null,
      skippedCount: action == SwipeAction.skipped ? current.skippedCount + 1 : null,
    ));

    _postSwipe(card, action);
    _maybePrefetch();
  }

  Future<void> _postSwipe(Recommendation card, SwipeAction action) async {
    try {
      await _repository.recordSwipe(SwipeRequest(
        recipeId: card.recipeId,
        cuisineValue: card.cuisineType,
        action: action,
        signalScores: card.scoreBreakdown,
      ));
    } catch (e) {
      debugPrint('swipe post faled for recipe ${card.recipeId}: $e');
    }
  }

  Future<void> _maybePrefetch() async {
    final current = state.valueOrNull;
    if (current == null || current.isFetchingMore || current.exhausted) return;
    if (current.deck.length - current.currentIndex > _prefetchThreshold) return;

    state = AsyncData(current.copyWith(isFetchingMore: true));
    final seen = current.deck.map((r) => r.recipeId).toList();

    try {
      final more = await _repository.getRecommendations(
        batchSize: _batchSize,
        excludeRecipeIds: seen,
      );
      final latest = state.valueOrNull ?? current;
      state = AsyncData(latest.copyWith(
        deck: [...latest.deck, ...more],
        isFetchingMore: false,
      ));
    } on EmptyRecommendationPool {
      final latest = state.valueOrNull ?? current;
      state =
          AsyncData(latest.copyWith(exhausted: true, isFetchingMore: false));
    } catch (e) {
      debugPrint('prefetch failed: $e');
      final latest = state.valueOrNull ?? current;
      state = AsyncData(latest.copyWith(isFetchingMore: false));
    }
  }

  Future<void> resetDiscovery() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadInitial);
  }
}
