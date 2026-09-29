import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/admin/models/admin_models.dart';
import 'package:mealchemy/features/admin/providers/admin_access_provider.dart';
import 'package:mealchemy/features/admin/providers/admin_flag_detail_provider.dart';
import 'package:mealchemy/features/admin/repositories/admin_repository.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_repository.dart';

FlaggedRecipeDetail _detail({String title = 'Ramen'}) => FlaggedRecipeDetail(
      flag: FlaggedRecipe(
        flaggedId: 12,
        recipeId: 87,
        recipeTitle: title,
        flaggedByUserId: 4,
        reasonValue: 'SPAM_MISLEADING',
        reasonLabel: 'Spam / misleading',
        status: FlagStatus.pending,
        flaggedAt: DateTime.utc(2026, 9, 19),
      ),
      recipe: Recipe(recipeId: 87, title: title),
    );

AdminAccessContext _context(int id) => (
      userId: id,
      token: 'token-$id',
      restoring: false,
      hasValidCredential: true,
      network: NetworkStatus.online,
    );

DioException _error(int status) {
  final request = RequestOptions(path: '/test');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: request,
      statusCode: status,
    ),
  );
}

class _AdminRepository implements AdminRepository {
  final ids = <int>[];
  Future<FlaggedRecipeDetail> Function() respond = () async => _detail();

  @override
  Future<FlaggedRecipeDetail> getFlagDetail(int flaggedId) {
    ids.add(flaggedId);
    return respond();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _RecipeRepository implements RecipeRepository {
  final ingredientIds = <int>[];
  final stepIds = <int>[];

  Future<List<RecipeIngredient>> Function() ingredients = () async => [
        const RecipeIngredient(ingId: 2, name: 'Rice', sortOrder: 2),
        const RecipeIngredient(ingId: 1, name: 'Chicken', sortOrder: 1),
      ];

  Future<List<RecipeStep>> Function() steps = () async => [
        const RecipeStep(stepNr: 2, content: 'Cook'),
        const RecipeStep(stepNr: 1, content: 'Prepare'),
      ];

  @override
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) {
    ingredientIds.add(recipeId);
    return ingredients();
  }

  @override
  Future<List<RecipeStep>> getRecipeSteps(int recipeId) {
    stepIds.add(recipeId);
    return steps();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late _AdminRepository admin;
  late _RecipeRepository recipes;
  late StateProvider<AdminAccessContext> session;
  late StateProvider<AdminAccess> access;
  late ProviderContainer container;

  setUp(() {
    admin = _AdminRepository();
    recipes = _RecipeRepository();
    session = StateProvider((ref) => _context(7));
    access = StateProvider((ref) => AdminAccess.allowed);

    container = ProviderContainer(
      overrides: [
        adminRepositoryProvider.overrideWithValue(admin),
        remoteRecipeRepositoryProvider.overrideWithValue(recipes),
        adminAccessContextProvider.overrideWith(
          (ref) => ref.watch(session),
        ),
        adminAccessStateProvider.overrideWith(
          (ref) => ref.watch(access),
        ),
      ],
    );

    addTearDown(container.dispose);
  });

  Future<AdminFlagReview> loadReview() {
    final subscription = container.listen(
      adminFlagDetailProvider(12),
      (_, __) {},
    );
    addTearDown(subscription.close);

    return container.read(adminFlagDetailProvider(12).future);
  }

  test('uses flag id for detail and recipe id for sorted content', () async {
    final review = await loadReview();

    expect(admin.ids, [12]);
    expect(recipes.ingredientIds, [87]);
    expect(recipes.stepIds, [87]);
    expect(review.ingredients.requireValue.first.name, 'Chicken');
    expect(review.steps.requireValue.first.content, 'Prepare');
  });

  test('ingredient failure preserves metadata and successful steps', () async {
    recipes.ingredients = () async => throw _error(500);

    final review = await loadReview();

    expect(review.detail.recipe.title, 'Ramen');
    expect(review.ingredients.hasError, isTrue);
    expect(review.steps.requireValue, hasLength(2));
  });

  test('step failure is distinct from a successful empty ingredient list',
      () async {
    recipes.ingredients = () async => [];
    recipes.steps = () async => throw _error(500);

    final review = await loadReview();

    expect(review.ingredients.requireValue, isEmpty);
    expect(review.steps.hasError, isTrue);
  });

  test('missing report does not request ingredients or steps', () async {
    final failure = _error(404);
    admin.respond = () async => throw failure;
    container.invalidate(adminFlagDetailProvider(12));

    await expectLater(
      loadReview(),
      throwsA(same(failure)),
    );

    expect(recipes.ingredientIds, isEmpty);
    expect(recipes.stepIds, isEmpty);
  });

  for (final status in [401, 403]) {
    test('HTTP $status from a content request hides the whole review',
        () async {
      recipes.ingredients = () async => throw _error(status);

      await expectLater(
        loadReview(),
        throwsA(
          isA<AdminDetailAccessException>().having(
            (error) => error.access,
            'access',
            status == 401 ? AdminAccess.signInRequired : AdminAccess.forbidden,
          ),
        ),
      );
    });
  }

  test('forbidden access does not start another detail request', () async {
    await loadReview();
    final callsBefore = admin.ids.length;

    container.read(access.notifier).state = AdminAccess.forbidden;

    await expectLater(
      loadReview(),
      throwsA(isA<AdminDetailAccessException>()),
    );
    expect(admin.ids, hasLength(callsBefore));
  });

  test('previous session cannot overwrite the current review', () async {
    final oldRequest = Completer<FlaggedRecipeDetail>();
    admin.respond = () => oldRequest.future;
    container.invalidate(adminFlagDetailProvider(12));
    container.read(adminFlagDetailProvider(12));

    admin.respond = () async => _detail(title: 'Current session');
    container.read(session.notifier).state = _context(8);

    final current = await loadReview();
    expect(current.detail.recipe.title, 'Current session');

    oldRequest.complete(_detail(title: 'Old session'));
    await Future<void>.delayed(Duration.zero);

    expect(
      container
          .read(adminFlagDetailProvider(12))
          .requireValue
          .detail
          .recipe
          .title,
      'Current session',
    );
  });
}
