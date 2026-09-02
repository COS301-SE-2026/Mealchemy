import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/dashboard/models/dashboard_recipe_card_data.dart';
import 'package:mealchemy/features/dashboard/models/trending_recipe_data.dart';
import 'package:mealchemy/features/dashboard/providers/dashboard_provider.dart';
import 'package:mealchemy/features/dashboard/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/dashboard/repositories/dashboard_repository.dart';
import 'package:mealchemy/features/dashboard/widgets/smart_suggestion_card.dart';
import 'package:mealchemy/features/dashboard/widgets/trending_recipes_section.dart';
import 'package:mealchemy/features/dashboard/widgets/recommended_recipes_section.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list.dart';

class _FakeDashboardRepo implements DashboardRepository {
  @override
  Future<String> getDisplayName() async => 'Mutombo';
  @override
  Future<int> getPantryItemCount() async => 42;
  @override
  Future<int> getSmartSuggestionItemsAway() async => 3;
  @override
  Future<int> getSmartSuggestionRecipeCount() async => 10;
  @override

  Future<List<DashboardRecipeCardData>> getRecommendedRecipes() async {
    return const [
      DashboardRecipeCardData(
        recipe: Recipe(recipeId: 1, title: 'Saffron Risotto'),
        matchPercent: 92,
        tag: 'HIGH PROTEIN',
        rating: 4.9,
      ),

      DashboardRecipeCardData(
        recipe: Recipe(recipeId: 2, title: 'Butter Chicken'),
        matchPercent: 85,
        tag: 'COMFORT FOOD',
        rating: 4.7,
      ),
    ];
  }

  @override
  Future<List<TrendingRecipeData>> getTrendingRecipes() async {
    return const [
      TrendingRecipeData(
        recipe: Recipe(recipeId: 3, title: 'Avocado & Kale Superbowl'),
        trendType: TrendType.trendingNow,
        subtitle: '4.2k saves this week',

      ),

      TrendingRecipeData(
        recipe: Recipe(recipeId: 5, title: 'Dark Chocolate & Gold Ganache'),
        trendType: TrendType.editorsChoice,
        subtitle: 'New seasonal favourite',

      ),
    ];
  }
}

ShoppingList _list({required String title, required int count}) => ShoppingList(
      id: 't',
      title: title,
      subtitle: '',
      section: 'OTHER LISTS',
      iconType: 'list',
      numItems: count,
      items: const [],
    );

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host( Widget child, DashboardRepository repo, {
    List<Override> extra = const [],
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(body: child),
        ),
        GoRoute(
          path: '/pantry/add',
          builder: (_, __) => const Scaffold(body: Text('Add Ingredient')),
        ),
        GoRoute(
          path: '/recipe/:id',
          builder: (_, __) => const Scaffold(body: Text('Recipe Detail')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [dashboardRepositoryProvider.overrideWithValue(repo), ...extra,],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    List<Override> extra = const [],
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(host(child, _FakeDashboardRepo(), extra: extra));
  }

  group('SmartSuggestionCard', () {
    testWidgets('renders SMART SUGGESTION label ', (tester) async {
      await pump( tester, const SmartSuggestionCard(),
        extra: [newListProvider.overrideWithValue(null)],
      );
      await tester.pump();
      expect(find.text('SMART SUGGESTION'), findsOneWidget);

    });

    testWidgets('renders the item-count message for the newest list',
        (tester) async {
      await pump(
        tester,
        const SmartSuggestionCard(),
        extra: [
          newListProvider.overrideWithValue(
            _list(title: 'Weekend Cooking', count: 8),
          ),
        ],
      );
      await tester.pump();

      expect(
        find.text("You've got 8 items to buy on Weekend Cooking."),
        findsOneWidget,
      );
    });

    testWidgets('shows the create prompt when there are no lists',
        (tester) async {
      await pump(
        tester,
        const SmartSuggestionCard(),
        extra: [newListProvider.overrideWithValue(null)],
      );
      await tester.pump();

      expect(find.text('Create your first list'), findsOneWidget);
    });

    testWidgets('renders lightbulb icon', (tester) async {
      await pump( tester, const SmartSuggestionCard(), extra: [newListProvider.overrideWithValue(null)], );
      await tester.pump();

      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });
  });

  group('RecommendedRecipesSection', () {
    testWidgets('renders section header', (tester) async {
      await pump(tester, const RecommendedRecipesSection());
      await tester.pump();

      expect(find.text('Recommended for You'), findsOneWidget);
    });

    testWidgets('renders recipe titles after data loads', (tester) async {
      await pump(tester, const RecommendedRecipesSection());

      final container = ProviderScope.containerOf(
        tester.element(find.byType(RecommendedRecipesSection)),
      );
      await container.read(dashboardProvider.notifier).loadDashboard();
      await tester.pump();

      expect(find.text('Saffron Risotto'), findsOneWidget);
      expect(find.text('Butter Chicken'), findsOneWidget);
    });

    testWidgets('renders View all trailing label', (tester) async {
      await pump(tester, const RecommendedRecipesSection());
      await tester.pump();

      expect(find.text('View all'), findsOneWidget);
    });
  });

  group('TrendingRecipesSection', () {
    testWidgets('renders nothing before data loads', (tester) async {
      await pump(tester, const TrendingRecipesSection());
      await tester.pump();

      expect(find.text('Trending Recipes'), findsNothing);
    });

    testWidgets('renders section header after data loads', (tester) async {
      await pump(tester, const TrendingRecipesSection());

      final container = ProviderScope.containerOf(
        tester.element(find.byType(TrendingRecipesSection)),
      );
      await container.read(dashboardProvider.notifier).loadDashboard();
      await tester.pump();

      expect(find.text('Trending Recipes'), findsOneWidget);
    });


    testWidgets('renders trending recipe titles after data loads', (tester) async {
      await pump(tester, const TrendingRecipesSection());

      final container = ProviderScope.containerOf(
        tester.element(find.byType(TrendingRecipesSection)),
      );
      await container.read(dashboardProvider.notifier).loadDashboard();
      await tester.pump();

      expect(find.text('Avocado & Kale Superbowl'), findsOneWidget);
      expect(find.text('Dark Chocolate & Gold Ganache'), findsOneWidget);
    });

    testWidgets('renders trending subtitles after data loads', (tester) async {
      await pump(tester, const TrendingRecipesSection());

      final container = ProviderScope.containerOf(
        tester.element(find.byType(TrendingRecipesSection)),
      );
      await container.read(dashboardProvider.notifier).loadDashboard();
      await tester.pump();

      expect(find.text('4.2k saves this week'), findsOneWidget);
      expect(find.text('New seasonal favourite'), findsOneWidget);
    });

    testWidgets('renders TRENDING NOW badge label', (tester) async {
      await pump(tester, const TrendingRecipesSection());

      final container = ProviderScope.containerOf(
        tester.element(find.byType(TrendingRecipesSection)),
      );
      await container.read(dashboardProvider.notifier).loadDashboard();
      await tester.pump();

      expect(find.text('TRENDING NOW'), findsOneWidget);
    });

    testWidgets("renders EDITOR'S CHOICE badge label", (tester) async {
      await pump(tester, const TrendingRecipesSection());

      final container = ProviderScope.containerOf(
        tester.element(find.byType(TrendingRecipesSection)),
      );
      await container.read(dashboardProvider.notifier).loadDashboard();
      await tester.pump();

      expect(find.text("EDITOR'S CHOICE"), findsOneWidget);
    });
  });
}