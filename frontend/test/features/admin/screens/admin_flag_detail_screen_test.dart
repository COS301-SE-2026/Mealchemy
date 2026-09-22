import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/routes/app_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/admin/providers/admin_moderation_provider.dart';
import 'package:mealchemy/features/admin/models/admin_models.dart';
import 'package:mealchemy/features/admin/providers/admin_access_provider.dart';
import 'package:mealchemy/features/admin/providers/admin_flag_detail_provider.dart';
import 'package:mealchemy/features/admin/screens/admin_flag_detail_screen.dart';
import 'package:mealchemy/features/admin/widgets/admin_flag_card.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';

FlaggedRecipe _flag() => FlaggedRecipe(
      flaggedId: 12,
      recipeId: 87,
      recipeTitle: 'Ramen',
      flaggedByUserId: 4,
      reasonValue: 'SPAM_MISLEADING',
      reasonLabel: 'Spam / misleading',
      status: FlagStatus.pending,
      flaggedAt: DateTime.utc(2026, 9, 19),
    );

AdminFlagReview _review({bool ingredientsFail = false}) => AdminFlagReview(
      detail: FlaggedRecipeDetail(
        flag: _flag(),
        recipe: const Recipe(recipeId: 87, title: 'Ramen'),
      ),
      ingredients: ingredientsFail
          ? AsyncError(Exception('failed'), StackTrace.current)
          : const AsyncData([
              RecipeIngredient(ingId: 1, name: 'Chicken', quantity: 2),
            ]),
      steps: const AsyncData([
        RecipeStep(stepNr: 1, content: 'Cook the chicken.'),
      ]),
    );

const _testSession = (
  userId: 7,
  token: 'test-token',
  restoring: false,
  hasValidCredential: true,
  network: NetworkStatus.online,
);

Widget _host(
  Future<AdminFlagReview> Function() load, {
  AdminAccess access = AdminAccess.allowed,
}) =>
    ProviderScope(
      overrides: [
        adminAccessContextProvider.overrideWithValue(_testSession),
        adminModerationEnabledProvider.overrideWithValue(false),
        adminAccessProvider.overrideWith((ref) async => access),
        adminFlagDetailProvider.overrideWith((ref, id) => load()),
      ],
      child: const MaterialApp(
        home: AdminFlagDetailScreen(flaggedId: 12),
      ),
    );

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.views.first.physicalSize = const Size(800, 1600);
    binding.platformDispatcher.views.first.devicePixelRatio = 1;
  });

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('shows loading and then read-only recipe content',
      (tester) async {
    final pending = Completer<AdminFlagReview>();
    await tester.pumpWidget(_host(() => pending.future));
    await tester.pump();
    await tester.pump();

    expect(find.text('Loading report…'), findsOneWidget);

    pending.complete(_review());
    await tester.pumpAndSettle();

    expect(find.text('Spam / misleading'), findsOneWidget);
    expect(find.text('No description provided.'), findsOneWidget);
    expect(find.textContaining('Chicken'), findsOneWidget);
    expect(find.text('Cook the chicken.'), findsOneWidget);
    expect(find.text('View report'), findsNothing);
    expect(find.text('Dismiss'), findsNothing);
  });

  testWidgets('partial failure retains the successful section', (tester) async {
    await tester.pumpWidget(
      _host(() async => _review(ingredientsFail: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ingredients could not be loaded.'), findsOneWidget);
    expect(find.text('Cook the chicken.'), findsOneWidget);
    expect(
      find.text('No ingredients were returned for this recipe.'),
      findsNothing,
    );
  });

  testWidgets('missing report shows a retryable message', (tester) async {
    await tester.pumpWidget(
      _host(() async {
        final request = RequestOptions(path: '/admin/flags/12');
        throw DioException(
          requestOptions: request,
          response: Response<dynamic>(
            requestOptions: request,
            statusCode: 404,
          ),
          type: DioExceptionType.badResponse,
        );
      }),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('This report or its related content is no longer available.'),
      findsOneWidget,
    );
    expect(find.text('Retry report'), findsOneWidget);
    expect(find.text('Spam / misleading'), findsNothing);
  });

  testWidgets('retry recovers from an initial failure', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _host(() async {
        calls++;
        if (calls == 1) throw Exception('failed');
        return _review();
      }),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Retry report'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Cook the chicken.'), findsOneWidget);
  });

  testWidgets('forbidden access never loads the review', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _host(
        () async {
          calls++;
          return _review();
        },
        access: AdminAccess.forbidden,
      ),
    );
    await tester.pumpAndSettle();

    expect(calls, 0);
    expect(find.text('Spam / misleading'), findsNothing);
    expect(
      find.text('Your account does not have administrator access.'),
      findsOneWidget,
    );
  });

  testWidgets('View report opens the actual detail route using the flag id',
      (tester) async {
    final requestedIds = <int>[];
    final router = GoRouter(
      initialLocation: '/test-report-card',
      routes: [
        GoRoute(
          path: '/test-report-card',
          builder: (_, __) => Scaffold(
            body: SingleChildScrollView(
              child: AdminFlagCard(flag: _flag()),
            ),
          ),
        ),
        ...appRouter.configuration.routes,
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminAccessContextProvider.overrideWithValue(_testSession),
          adminModerationEnabledProvider.overrideWithValue(false),
          adminAccessProvider.overrideWith(
            (ref) async => AdminAccess.allowed,
          ),
          adminFlagDetailProvider.overrideWith((ref, id) async {
            requestedIds.add(id);
            return _review();
          }),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('View report'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminFlagDetailScreen), findsOneWidget);
    expect(requestedIds, [12]);
    expect(find.text('Cook the chicken.'), findsOneWidget);
  });

  testWidgets('invalid direct route does not request report data',
      (tester) async {
    var calls = 0;
    final router = GoRouter(
      initialLocation: AppRoutes.adminFlagDetail.replaceFirst(':id', 'bad'),
      routes: appRouter.configuration.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminAccessContextProvider.overrideWithValue(_testSession),
          adminModerationEnabledProvider.overrideWithValue(false),
          adminFlagDetailProvider.overrideWith((ref, id) async {
            calls++;
            return _review();
          }),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invalid report ID.'), findsOneWidget);
    expect(calls, 0);
  });
}
