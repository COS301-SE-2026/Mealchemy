import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/dashboard/widgets/recipe_recommendation_card.dart';
import 'package:mealchemy/features/guided_discovery/models/recommendation.dart';
import 'package:mealchemy/features/guided_discovery/models/signal_scores.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

const _signals = SignalScores(
  pantryMatch: 0.9,
  cuisine: 0.8,
  nutrition: 0.5,
  freshness: 0.3,
  novelty: 1.0,
);

Recommendation _rec({
  int id = 1,
  String title = 'Saffron Risotto',
  String cuisine = 'SOUTH_AFRICAN',
  double score = 0.87,
  int gap = 0,
  int? prep,
  int? cook,
  String? photoUrl,
}) =>
    Recommendation(
      recipeId: id,
      cuisineType: cuisine,
      score: score,
      scoreBreakdown: _signals,
      pantryGapCount: gap,
      missingIngredients: const [],
      recipe: Recipe(
        recipeId: id,
        title: title,
        cuisineType: cuisine,
        prepTimeMins: prep,
        cookingTimeMins: cook,
        photoUrl: photoUrl,
      ),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pump(WidgetTester tester, Recommendation data) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            body: SizedBox(
              height: 240,
              child: RecipeRecommendationCard(data: data),
            ),
          ),
        ),
        GoRoute(
          path: '/recipe/:id',
          builder: (_, state) =>
              Scaffold(body: Text('Detail ${state.pathParameters['id']}')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  group('RecipeRecommendationCard', () {
    testWidgets('render the recipe title ', (tester) async {
      await pump(tester, _rec());
      expect(find.text('Saffron Risotto'), findsOneWidget);
    });

    testWidgets('title cases the cuisine tag', (tester) async {
      await pump(tester, _rec(cuisine: 'SOUTH_AFRICAN'));
      expect(find.text('South African'), findsOneWidget);
    });

    testWidgets('sums prep and cooking time', (tester) async {
      await pump(tester, _rec(prep: 10, cook: 25));
      expect(find.text('35 min'), findsOneWidget);
    });

    testWidgets('shows a dash  when there are no times', (tester) async {
      await pump(tester, _rec());
      expect(find.text('--'), findsOneWidget);
    });

    testWidgets('shows Ready to cook when  the panty gap is zero',
        (tester) async {
      await pump(tester, _rec(gap: 0));
      expect(find.text('Ready to cook'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows the buy count when ingredients are missing',
        (tester) async {
      await pump(tester, _rec(gap: 3));
      expect(find.text('3 to buy'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_basket_outlined), findsOneWidget);
    });

    testWidgets('long titles do not overflow ', (tester) async {
      await pump(tester, _rec(
        title: 'Slow Roasted Mediterranean Chickpea and Spinach Stew',
      ));
      expect(tester.takeException(), isNull);
    });
  });
}