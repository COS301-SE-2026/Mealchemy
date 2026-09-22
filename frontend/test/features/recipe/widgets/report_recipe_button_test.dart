import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/providers/recipe_report_provider.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_report_repository.dart';
import 'package:mealchemy/features/recipe/widgets/report_recipe_button.dart';

const _recipe = Recipe(
  recipeId: 87,
  title: 'Community ramen',
  isCommunityPublished: true,
);

RecipeReportSession _session([int id = 7]) => (
      userId: id,
      token: 'token-$id',
      restoring: false,
      hasValidCredential: true,
    );

const _reasons = [
  RecipeReportReason(value: 'SPAM', label: 'Spam or misleading content'),
  RecipeReportReason(value: 'HARMFUL', label: 'Harmful content'),
];

class _Repository implements RecipeReportRepository {
  int loads = 0;
  final reports = <({int recipeId, String reasonValue})>[];

  Future<List<RecipeReportReason>> Function() load = () async => _reasons;
  Future<void> Function() send = () async {};

  @override
  Future<List<RecipeReportReason>> getReasons() {
    loads++;
    return load();
  }

  @override
  Future<void> reportRecipe({
    required int recipeId,
    required String reasonValue,
  }) {
    reports.add((recipeId: recipeId, reasonValue: reasonValue));
    return send();
  }
}

DioException _httpError(int status) {
  final options = RequestOptions(path: '/recipes/87/flag');

  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: status,
    ),
  );
}

void main() {
  late _Repository repository;
  late ProviderContainer container;
  late StateProvider<RecipeReportSession> session;
  late StateProvider<String?> unavailable;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    repository = _Repository();
    session = StateProvider((ref) => _session());
    unavailable = StateProvider<String?>((ref) => null);

    container = ProviderContainer(
      overrides: [
        recipeReportRepositoryProvider.overrideWithValue(repository),
        recipeReportSessionProvider.overrideWith(
          (ref) => ref.watch(session),
        ),
        recipeReportUnavailableMessageProvider.overrideWith(
          (ref) => ref.watch(unavailable),
        ),
      ],
    );

    addTearDown(container.dispose);
  });

  Future<void> showButton(
    WidgetTester tester, {
    Recipe recipe = _recipe,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: ReportRecipeButton(recipe: recipe),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openReport(WidgetTester tester) async {
    await showButton(tester);
    await tester.tap(find.byTooltip('Report recipe'));
    await tester.pumpAndSettle();
  }

  AppButton submitButton(WidgetTester tester) {
    return tester.widget<AppButton>(
      find.byWidgetPredicate(
        (widget) => widget is AppButton && widget.label == 'Submit report',
      ),
    );
  }

  testWidgets('private recipes have no report button', (tester) async {
    await showButton(
      tester,
      recipe: const Recipe(recipeId: 88, title: 'Private recipe'),
    );

    expect(find.byTooltip('Report recipe'), findsNothing);
    expect(repository.loads, 0);
  });

  testWidgets('opening shows backend reasons and requires a selection',
      (tester) async {
    await openReport(tester);

    expect(find.text('Spam or misleading content'), findsOneWidget);
    expect(find.text('Harmful content'), findsOneWidget);
    expect(submitButton(tester).onPressed, isNull);
    expect(repository.reports, isEmpty);
  });

  testWidgets('submits the chosen value and shows confirmation',
      (tester) async {
    await openReport(tester);
    await tester.tap(find.text('Harmful content'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit report'));
    await tester.pumpAndSettle();

    expect(
      repository.reports,
      [(recipeId: 87, reasonValue: 'HARMFUL')],
    );
    expect(
      find.text('Report submitted. Thank you for helping our community.'),
      findsOneWidget,
    );
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Submit report'), findsNothing);
  });

  testWidgets('closing without submitting creates no report', (tester) async {
    await openReport(tester);
    await tester.tap(find.text('Harmful content'));
    await tester.tap(find.byTooltip('Close report'));
    await tester.pumpAndSettle();

    expect(repository.reports, isEmpty);
    expect(find.byType(ReportRecipeDialog), findsNothing);
  });

  testWidgets('failed reasons can be retried', (tester) async {
    repository.load = () async => throw _httpError(500);

    await openReport(tester);

    expect(find.text('Retry reasons'), findsOneWidget);
    expect(submitButton(tester).onPressed, isNull);

    repository.load = () async => _reasons;
    await tester.tap(find.text('Retry reasons'));
    await tester.pumpAndSettle();

    expect(repository.loads, 2);
    expect(find.text('Harmful content'), findsOneWidget);
  });

  testWidgets('empty reasons cannot be submitted', (tester) async {
    repository.load = () async => [];

    await openReport(tester);

    expect(
      find.text(
        'No report reasons are currently available. Please try again later.',
      ),
      findsOneWidget,
    );
    expect(submitButton(tester).onPressed, isNull);
  });

  testWidgets('unavailable session or connection prevents requests',
      (tester) async {
    container.read(unavailable.notifier).state =
        'Connect to the internet to report this recipe.';

    await openReport(tester);

    expect(repository.loads, 0);
    expect(repository.reports, isEmpty);
    expect(submitButton(tester).onPressed, isNull);
    expect(
      find.text('Connect to the internet to report this recipe.'),
      findsOneWidget,
    );
  });

  testWidgets('duplicate pending report is explained without another submit',
      (tester) async {
    repository.send = () async => throw _httpError(409);

    await openReport(tester);
    await tester.tap(find.text('Harmful content'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit report'));
    await tester.pumpAndSettle();

    expect(
      find.text('You already have a pending report for this recipe.'),
      findsOneWidget,
    );
    expect(find.text('Submit report'), findsNothing);
    expect(repository.reports, hasLength(1));
  });

  testWidgets('missing community recipe shows an explanation', (tester) async {
    repository.send = () async => throw _httpError(404);

    await openReport(tester);
    await tester.tap(find.text('Harmful content'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit report'));
    await tester.pumpAndSettle();

    expect(
      find.text('This recipe is no longer available in the community.'),
      findsOneWidget,
    );
    expect(find.text('Done'), findsNothing);
  });

  testWidgets('in-flight submission cannot be sent twice', (tester) async {
    final pending = Completer<void>();
    repository.send = () => pending.future;

    await openReport(tester);
    await tester.tap(find.text('Harmful content'));
    await tester.pumpAndSettle();

    final submit = submitButton(tester).onPressed!;
    submit();
    submit();
    await tester.pump();

    expect(repository.reports, hasLength(1));
    expect(submitButton(tester).isLoading, isTrue);
    final closeButton = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Close report',
      ),
    );

    expect(closeButton.onPressed, isNull);

    pending.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('changing accounts clears selection and ignores old success',
      (tester) async {
    final pending = Completer<void>();
    repository.send = () => pending.future;

    await openReport(tester);
    await tester.tap(find.text('Harmful content'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit report'));
    await tester.pump();

    container.read(session.notifier).state = _session(8);
    await tester.pumpAndSettle();

    pending.complete();
    await tester.pumpAndSettle();

    expect(
      find.text('Report submitted. Thank you for helping our community.'),
      findsNothing,
    );
    expect(submitButton(tester).onPressed, isNull);
  });

  testWidgets('submit rechecks connectivity after a reason is selected',
      (tester) async {
    await openReport(tester);
    await tester.tap(find.text('Harmful content'));
    await tester.pumpAndSettle();

    final submit = submitButton(tester).onPressed!;
    container.read(unavailable.notifier).state = 'Connection unavailable.';
    submit();
    await tester.pumpAndSettle();

    expect(repository.reports, isEmpty);
  });
}
