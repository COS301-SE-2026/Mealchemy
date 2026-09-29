import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/guided_discovery/models/discovery_tag.dart';
import 'package:mealchemy/features/guided_discovery/models/recommendation.dart';
import 'package:mealchemy/features/guided_discovery/models/signal_scores.dart';
import 'package:mealchemy/features/guided_discovery/models/swipe.dart';
import 'package:mealchemy/features/guided_discovery/providers/guided_discovery_provider.dart';
import 'package:mealchemy/features/guided_discovery/repositories/guided_discovery_repository.dart';
import 'package:mealchemy/features/guided_discovery/screens/guided_discovery_screen.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/shopping_lists/repositories/mock_shopping_list_repository.dart';

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
  List<String>? lastDietaryTags;
  int? lastMaxTotalTimeMins;

  @override
  Future<List<Recommendation>> getRecommendations({
    int batchSize = 10,
    List<int> excludeRecipeIds = const [],
    List<String>? dietaryTags,
    int? maxTotalTimeMins,
  }) async {
    lastDietaryTags = dietaryTags;
    lastMaxTotalTimeMins = maxTotalTimeMins;
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

  @override
  Future<List<DiscoveryTag>> getDietaryTags() async => const [
        DiscoveryTag(tagId: 1, tagName: 'VEGETARIAN', isDietary: true),
      ];
}

class _FailingRepo implements GuidedDiscoveryRepository {
  @override
  Future<List<Recommendation>> getRecommendations({
    int batchSize = 10,
    List<int> excludeRecipeIds = const [],
    List<String>? dietaryTags,
    int? maxTotalTimeMins,
  }) {
    throw Exception('Discovery failure');
  }

  @override
  Future<SwipeResponse> recordSwipe(SwipeRequest request) {
    throw Exception('Discovery failure');
  }

  @override
  Future<List<DiscoveryTag>> getDietaryTags() async => const [];
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(
    GuidedDiscoveryRepository repository, {
    bool offline = false,
  }) {
    return ProviderScope(
      overrides: [
        guidedDiscoveryRepositoryProvider.overrideWithValue(repository),
        shoppingListRepositoryProvider
            .overrideWithValue(MockShoppingListRepository()),
        offlineReadOnlyProvider.overrideWith((ref) => offline),
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

  testWidgets('offline replaces the API error with an online-required state',
      (tester) async {
    await tester.pumpWidget(host(_FailingRepo(), offline: true));
    await tester.pumpAndSettle();

    expect(
      find.text('Recipe discovery is available when you are back online.'),
      findsOneWidget,
    );
    expect(find.textContaining('Discovery failure'), findsNothing);
    expect(find.text('Try Again'), findsNothing);
  });

  testWidgets('swiping right advances to the next card', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(host(_TestRepo()));
    await tester.pumpAndSettle();
    expect(find.text('Test Pasta'), findsOneWidget);

    await tester.timedDrag(
      find.text('Test Pasta'),
      const Offset(250, 0),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Pasta'), findsNothing);
    expect(find.text('Test Salmon'), findsOneWidget);
  });

  testWidgets('filter pills come from the dietary tags', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(host(_TestRepo()));
    await tester.pumpAndSettle();
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Quick'), findsOneWidget);
    expect(find.text('Vegetarian'), findsOneWidget);
  });

  testWidgets('picking a pill reloads the deck with that filter',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repo = _TestRepo();
    await tester.pumpWidget(host(repo));
    await tester.pumpAndSettle();

    expect(repo.lastDietaryTags, isNull);
    await tester.tap(find.text('Vegetarian'));
    await tester.pumpAndSettle();
    
    expect(repo.lastDietaryTags, ['VEGETARIAN']);
    expect(repo.lastMaxTotalTimeMins, isNull);
    await tester.tap(find.text('Quick'));
    await tester.pumpAndSettle();
    expect(repo.lastDietaryTags, isNull);
    expect(repo.lastMaxTotalTimeMins, 30);
  });
}
