import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/guided_discovery/models/recommendation.dart';
import 'package:mealchemy/features/guided_discovery/models/signal_scores.dart';
import 'package:mealchemy/features/guided_discovery/models/swipe.dart';
import 'package:mealchemy/features/guided_discovery/providers/guided_discovery_provider.dart';
import 'package:mealchemy/features/guided_discovery/repositories/guided_discovery_repository.dart';
import 'package:mealchemy/features/guided_discovery/screens/guided_discovery_screen.dart';

const _signals = SignalScores(
  pantryMatch: 0.9,
  cuisine: 0.8,
  nutrition: 0.5,
  freshness: 0.3,
  novelty: 1.0,
);

Recommendation _rec({required int id, required String title}) => Recommendation(
      recipeId: id,
      cuisineType: 'ITALIAN',
      score: 0.90,
      scoreBreakdown: _signals,
      pantryGapCount: 0,
      missingIngredients: const [],
      recipe: Recipe(
        recipeId: id,
        title: title,
        cuisineType: 'ITALIAN',
        prepTimeMins: 10,
        cookingTimeMins: 20,
        servingSize: 2,
        isCommunityPublished: true,
      ),
    );

// Serves a fixed two card deck once then reports the pool empty so prefetch stops.
class _TestRepo implements GuidedDiscoveryRepository {
  bool _served = false;

  @override
  Future<List<Recommendation>> getRecommendations({
    int batchSize = 10,
    List<int> excludeRecipeIds = const [],
  }) async {
    if (_served) throw const EmptyRecommendationPool();
    _served = true;
    return [
      _rec(id: 1, title: 'Test Pasta'),
      _rec(id: 2, title: 'Test Salmon'),
    ];
  }

  @override
  Future<SwipeResponse> recordSwipe(SwipeRequest request) async {
    return SwipeResponse(
      swipeId: 1,
      recipeId: request.recipeId,
      cuisineValue: request.cuisineValue,
      action: request.action,
      swipedAt: DateTime.now(),
    );
  }
}

class _FailingRepo implements GuidedDiscoveryRepository {
  @override
  Future<List<Recommendation>> getRecommendations({
    int batchSize = 10,
    List<int> excludeRecipeIds = const [],
  }) {
    throw Exception('Discovery failure');
  }

  @override
  Future<SwipeResponse> recordSwipe(SwipeRequest request) {
    throw Exception('Discovery failure');
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(GuidedDiscoveryRepository repository) {
    return ProviderScope(
      overrides: [
        guidedDiscoveryRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: Scaffold(body: GuidedDiscoveryScreen()),
      ),
    );
  }

  testWidgets('renders the first recommendation card', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(host(_TestRepo()));
    await tester.pumpAndSettle();

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Sizzles'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Test Pasta'), findsOneWidget);
    expect(find.text('90% Match'), findsOneWidget);
    expect(find.text('View Full Recipe ->'), findsOneWidget);
  });

  testWidgets('like button advances to the next card', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(host(_TestRepo()));
    await tester.pumpAndSettle();
    expect(find.text('Test Pasta'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    expect(find.text('Test Pasta'), findsNothing);
    expect(find.text('Test Salmon'), findsOneWidget);
  });

  testWidgets('dislike button advances to the next card', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(host(_TestRepo()));
    await tester.pumpAndSettle();
    expect(find.text('Test Pasta'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Test Pasta'), findsNothing);
    expect(find.text('Test Salmon'), findsOneWidget);
  });

  testWidgets('skip button advances to the next card', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(host(_TestRepo()));
    await tester.pumpAndSettle();
    expect(find.text('Test Pasta'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pumpAndSettle();

    expect(find.text('Test Pasta'), findsNothing);
    expect(find.text('Test Salmon'), findsOneWidget);
  });

  testWidgets('renders the error state on failure', (tester) async {
    await tester.pumpWidget(host(_FailingRepo()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Discovery failure'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('swiping right advances to the next card', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(host(_TestRepo()));
    await tester.pumpAndSettle();
    expect(find.text('Test Pasta'), findsOneWidget);

    await tester.drag(find.text('Test Pasta'), const Offset(250, 0));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Test Pasta'), findsNothing);
    expect(find.text('Test Salmon'), findsOneWidget);
  });
}