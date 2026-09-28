import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/dashboard/providers/dashboard_provider.dart';
import 'package:mealchemy/features/dashboard/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/dashboard/repositories/dashboard_repository.dart';
import 'package:mealchemy/features/dashboard/widgets/recommended_recipes_section.dart';
import 'package:mealchemy/features/dashboard/widgets/smart_suggestion_card.dart';
import 'package:mealchemy/features/guided_discovery/models/recommendation.dart';
import 'package:mealchemy/features/guided_discovery/models/signal_scores.dart';
import 'package:mealchemy/features/guided_discovery/models/swipe.dart';
import 'package:mealchemy/features/guided_discovery/providers/guided_discovery_provider.dart';
import 'package:mealchemy/features/guided_discovery/repositories/guided_discovery_repository.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan_entry.dart';
import 'package:mealchemy/features/meal_plan/models/meal_slot.dart';
import 'package:mealchemy/features/meal_plan/providers/meal_plan_provider.dart';
import 'package:mealchemy/features/meal_plan/repositories/meal_plan_repository.dart';
import 'package:mealchemy/features/meal_plan/widgets/meal_plan_section.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list.dart';
import 'package:mealchemy/features/vault/models/vault.dart';
import 'package:mealchemy/features/vault/providers/vault_folder_management_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';

const _signals = SignalScores(
  pantryMatch: 0.9,
  cuisine: 0.8,
  nutrition: 0.5,
  freshness: 0.3,
  novelty: 1.0,
);

Recommendation _rec(int id, String title) => Recommendation(
      recipeId: id,
      cuisineType: 'ITALIAN',
      score: 0.9,
      scoreBreakdown: _signals,
      pantryGapCount: 0,
      missingIngredients: const [],
      recipe: Recipe(recipeId: id, title: title),
    );

class _FakeDashboardRepo implements DashboardRepository {
  @override
  Future<String> getDisplayName() async => 'Mutombo';

  @override
  Future<int> getPantryItemCount() async => 42;

  @override
  Future<int> getSmartSuggestionItemsAway() async => 3;

  @override
  Future<int> getSmartSuggestionRecipeCount() async => 10;

}

class _FakeGuidedDiscoveryRepo implements GuidedDiscoveryRepository {
  @override
  Future<List<Recommendation>> getRecommendations({
    int batchSize = 10,
    List<int> excludeRecipeIds = const [],
  }) async =>
      [
        _rec(1, 'Saffron Risotto'),
        _rec(2, 'Butter Chicken'),
      ];

  @override
  Future<SwipeResponse> recordSwipe(SwipeRequest request) async =>
      throw UnimplementedError();
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

final _vault = Vault(
  vaultId: 5,
  ownerId: 7,
  vaultType: VaultTypes.private,
  name: 'Private',
  createdAt: DateTime(2026, 1, 1),
);

const _plan = MealPlan(planId: 1, vaultId: 5);

MealPlanEntry _entry({required int id, required String title}) => MealPlanEntry(
      entryId: id,
      planId: 1,
      recipeId: id,
      entryDate: DateTime.now(),
      mealSlot: MealSlot.dinner,
      mealTime: const TimeOfDay(hour: 19, minute: 0),
      title: title,
    );

class _FakeMealPlanRepo extends Fake implements MealPlanRepository {
  _FakeMealPlanRepo({this.entries = const [], this.planFuture, this.error});

  final List<MealPlanEntry> entries;
  final Future<MealPlan>? planFuture;
  final Object? error;

  @override
Future<MealPlan> getOrCreatePlan(int vaultId) async {
  if (error != null) throw error!;
  return planFuture != null ? await planFuture! : _plan;
}

  @override
  Future<List<MealPlanEntry>> getEntries(
          int vaultId, DateTime start, DateTime end) async =>
      entries;
}

List<Override> _mealPlanOverrides({
  required MealPlanRepository repo,
  bool canManage = true,
}) =>
    [
      mealPlanRepositoryProvider.overrideWithValue(repo),
      vaultsProvider.overrideWith((ref) async => [_vault]),
      canManageVaultFoldersProvider.overrideWith((ref, v) => canManage),
    ];

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(
    Widget child, {
    DashboardRepository? repo,
    GuidedDiscoveryRepository? discoveryRepo,
    List<Override> extra = const [],
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(body: SingleChildScrollView(child: child)),
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
      overrides: [
        dashboardRepositoryProvider
            .overrideWithValue(repo ?? _FakeDashboardRepo()),
        guidedDiscoveryRepositoryProvider
            .overrideWithValue(discoveryRepo ?? _FakeGuidedDiscoveryRepo()),
        ...extra,
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    DashboardRepository? repo,
    GuidedDiscoveryRepository? discoveryRepo,
    List<Override> extra = const [],
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      host(
        child,
        repo: repo,
        discoveryRepo: discoveryRepo,
        extra: extra,
      ),
    );
  }

  group('SmartSuggestionCard', () {
    testWidgets('renders SMART SUGGESTION label', (tester) async {
      await pump(
        tester,
        const SmartSuggestionCard(),
        extra: [newListProvider.overrideWithValue(null)],
      );
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      expect(find.text('Create your first list'), findsOneWidget);
    });

    testWidgets('renders lightbulb icon', (tester) async {
      await pump(
        tester,
        const SmartSuggestionCard(),
        extra: [newListProvider.overrideWithValue(null)],
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });
  });

  group('RecommendedRecipesSection', () {
    testWidgets('renders section header', (tester) async {
      await pump(tester, const RecommendedRecipesSection());
      await tester.pumpAndSettle();

      expect(find.text('Recommended for You'), findsOneWidget);
    });

  });

  group('MealPlanSection', () {
    Future<void> pumpSection(
      WidgetTester tester, {
      MealPlanRepository? repo,
      bool canManage = true,
      bool canEdit = true,
      bool settle = true,
    }) async {
      await pump(
        tester,
        MealPlanSection(vaultId: _vault.vaultId, canEdit: canEdit),
        extra: _mealPlanOverrides(
          repo: repo ?? _FakeMealPlanRepo(),
          canManage: canManage,
        ),
      );
      settle ? await tester.pumpAndSettle() : await tester.pump();
    }

    testWidgets('renders the header and private plan name', (tester) async {
      await pumpSection(tester);
      expect(find.text('Meal Plan'), findsOneWidget);
      expect(find.text('My Plan'), findsOneWidget);
    });

    testWidgets('editor sees an add row for each main slot on an empty day',
        (tester) async {
      await pumpSection(tester);
      expect(find.text('Add'), findsNWidgets(3));
      expect(find.text('VIEW ONLY'), findsNothing);
    });

    testWidgets('viewer sees the read-only empty state', (tester) async {
      await pumpSection(tester, canManage: false);
      expect(find.text('Nothing planned yet'), findsOneWidget);
      expect(find.text('VIEW ONLY'), findsOneWidget);
      expect(find.text('Add'), findsNothing);
    });

    testWidgets('canEdit: false forces view-only even for a manager',
        (tester) async {
      await pumpSection(tester, canEdit: false);
      expect(find.text('VIEW ONLY'), findsOneWidget);
      expect(find.text('Add'), findsNothing);
    });

    testWidgets('shows planned meals and hides the empty state',
        (tester) async {
      await pumpSection(
        tester,
        repo: _FakeMealPlanRepo(
          entries: [_entry(id: 1, title: 'Saffron Risotto')],
        ),
      );

      expect(find.text('Saffron Risotto'), findsOneWidget);
      expect(find.text('Nothing planned yet'), findsNothing);
    });

    testWidgets('an editor with a dinner planned can still add another meal ',
        (tester) async {
      await pumpSection(
        tester,
        repo: _FakeMealPlanRepo(
          entries: [_entry(id: 1, title: 'Saffron Risotto')],
        ),
      );
      expect(find.text('ANOTHER MEAL'), findsOneWidget);
    });

    testWidgets('shows loading placeholders, then the day once loaded',
        (tester) async {
      final pending = Completer<MealPlan>();
      await pumpSection(
        tester,
        repo: _FakeMealPlanRepo(planFuture: pending.future),
        settle: false,
      );

      expect(find.text('Add'), findsNothing);
      expect(find.text('Nothing planned yet'), findsNothing);
      pending.complete(_plan);
      await tester.pumpAndSettle();
      expect(find.text('Add'), findsNWidgets(3));
    });

    testWidgets('shows the error message with a retry button', (tester) async {
      await pumpSection(
        tester,
        repo: _FakeMealPlanRepo(error: StateError('Plan unavailable')),
      );
      expect(find.text('Plan unavailable'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('menu offers Add meal but not Clear day on an empty day',
        (tester) async {
      await pumpSection(tester);
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text('Add meal'), findsOneWidget);
      expect(find.text('Generate shopping list'), findsOneWidget);
      expect(find.text('Clear day'), findsNothing);
    });
  }
  );
}