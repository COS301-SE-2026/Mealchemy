import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_edit_lock.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/recipe/providers/recipe_edit_lock_provider.dart';
import 'package:mealchemy/features/recipe/providers/recipe_lock_repository_provider.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/providers/shared_recipe_edit_provider.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_lock_repository.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_repository.dart';
import 'package:mealchemy/features/recipe/screens/add_recipe_screen.dart';
import 'package:mealchemy/features/recipe/screens/shared_recipe_edit_screen.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_repository_provider.dart';
import 'package:mealchemy/features/vault/repositories/vault_repository.dart';
import 'package:mealchemy/features/recipe/models/equipment.dart';
import 'package:mealchemy/features/profile/providers/profile_provider.dart';

const _target = (
  vaultId: 2,
  folderId: 4,
  recipeId: 99,
);

const VaultSession _session = (
  userId: 1,
  token: 'test-token',
  restoring: false,
  hasValidCredential: true,
);

DioException _httpError(int status) {
  final request = RequestOptions(path: '/recipes/99/lock');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: request,
      statusCode: status,
    ),
  );
}

class _Locks implements RecipeLockRepository {
  _Locks(this.events, this.now);

  final List<String> events;
  final DateTime Function() now;

  RecipeEditLock? current;
  Completer<RecipeEditLock>? pending;
  int? failure;
  int acquisitions = 0;
  int releases = 0;

  RecipeEditLock ownLock() {
    final previous = current;
    final instant = now();

    return RecipeEditLock(
      recipeId: 99,
      lockedByUserId: 1,
      lockedByEmail: 'sofia@example.com',
      acquiredAt: previous != null &&
              previous.lockedByUserId == 1 &&
              previous.expiresAt.isAfter(instant)
          ? previous.acquiredAt
          : instant,
      expiresAt: instant.add(const Duration(seconds: 90)),
    );
  }

  @override
  Future<RecipeEditLock> acquireLock(int recipeId) async {
    events.add('acquire');
    acquisitions++;

    if (failure != null) throw _httpError(failure!);

    final request = pending;
    if (request != null) {
      current = await request.future;
    } else {
      current = ownLock();
    }

    return current!;
  }

  @override
  Future<RecipeEditLock?> getLock(int recipeId) async => current;

  @override
  Future<void> releaseLock(int recipeId) async {
    events.add('release');
    releases++;
    current = null;
  }
}

class _Recipes implements RecipeRepository {
  _Recipes(this.events);

  final List<String> events;
  String title = 'Shared pasta';
  int updates = 0;
  Completer<Recipe>? pendingSave;
  Recipe? lastSubmittedRecipe;

  @override
  Future<List<Equipment>> getRecipeEquipment(int recipeId) async => const [
        Equipment(
          id: 3,
          value: 'OVEN',
          label: 'Oven',
        ),
      ];

  Recipe get recipe => Recipe(
        recipeId: 99,
        ownerId: 1,
        title: title,
        cuisineType: 'italian',
        prepTimeMins: 10,
        cookingTimeMins: 20,
        servingSize: 2,
        ingredients: const [],
        steps: const [],
      );

  @override
  Future<Recipe> getRecipeById(int recipeId) async {
    events.add('load');
    return recipe;
  }

  @override
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) async =>
      const [];

  @override
  Future<List<RecipeStep>> getRecipeSteps(int recipeId) async => const [];

  @override
  Future<List<String>> getCuisineTypes() async => ['italian'];

  @override
  Future<List<Recipe>> getRecipes() async => [];

  @override
  Future<Recipe> updateRecipeFull(
    int id,
    Recipe recipe, {
    bool removePhoto = false,
    bool removeVideo = false,
  }) async {
    events.add('save');
    updates++;
    lastSubmittedRecipe = recipe;
    return pendingSave == null ? recipe : await pendingSave!.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Vaults implements VaultRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Fixture {
  final events = <String>[];
  DateTime now = DateTime.utc(2026, 9, 25, 10);
  bool allowed = true;

  late final locks = _Locks(events, () => now);
  late final recipes = _Recipes(events);

  late final container = ProviderContainer(
    overrides: [
      vaultSessionProvider.overrideWithValue(_session),
      vaultConnectionProvider.overrideWithValue(NetworkStatus.online),
      offlineReadOnlyProvider.overrideWithValue(false),
      recipeLockNowProvider.overrideWithValue(() => now),
      recipeLockRepositoryProvider.overrideWithValue(locks),
      remoteRecipeRepositoryProvider.overrideWithValue(recipes),
      recipeRepositoryProvider.overrideWithValue(recipes),
      vaultRepositoryProvider.overrideWithValue(_Vaults()),
      unitOptionsProvider.overrideWithValue([]),
      sharedRecipeEditAccessProvider.overrideWith((ref, target) async {
        events.add('access');
        return allowed;
      }),
      equipmentProvider.overrideWith((ref) async => []),
    ],
  );

  late final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: TextButton(
            onPressed: () => context.push('/edit'),
            child: const Text('Open editor'),
          ),
        ),
      ),
      GoRoute(
        path: '/edit',
        builder: (context, state) =>
            const SharedRecipeEditScreen(target: _target),
      ),
    ],
  );

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
  }

  Future<void> advance(WidgetTester tester, Duration duration) async {
    now = now.add(duration);
    await tester.pump(duration);
    await tester.pump();
  }

  Future<void> close(WidgetTester tester) async {
    // Close explicitly before disposing the whole container so the
    // release still has an active authenticated runtime.
    if (find.byType(SharedRecipeEditScreen).evaluate().isNotEmpty) {
      await container.read(recipeEditLockProvider(99).notifier).close();
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    router.dispose();
    container.dispose();
    await tester.pump();
  }
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('acquires before loading the editable copy', (tester) async {
    final fixture = _Fixture();

    try {
      await fixture.open(tester);

      expect(find.text('Edit Recipe'), findsOneWidget);
      expect(
        fixture.events.indexOf('acquire'),
        lessThan(fixture.events.indexOf('load')),
      );
      expect(
        tester
            .widget<AddRecipeScreen>(find.byType(AddRecipeScreen))
            .initialRecipe!
            .recipeId,
        99,
      );
      final editor =
          tester.widget<AddRecipeScreen>(find.byType(AddRecipeScreen));

      expect(
        editor.initialRecipe!.equipment!.map((item) => item.id).toList(),
        [3],
      );

      await fixture.advance(tester, const Duration(seconds: 30));
      expect(fixture.locks.acquisitions, 2);
    } finally {
      await fixture.close(tester);
    }
  });

  testWidgets('conflict shows holder and does not load the editor',
      (tester) async {
    final fixture = _Fixture();
    fixture.locks.failure = 409;
    fixture.locks.current = RecipeEditLock(
      recipeId: 99,
      lockedByUserId: 2,
      lockedByEmail: 'gabriela@example.com',
      acquiredAt: fixture.now,
      expiresAt: fixture.now.add(const Duration(seconds: 90)),
    );

    try {
      await fixture.open(tester);

      expect(find.textContaining('gabriela@example.com'), findsOneWidget);
      expect(find.byType(AddRecipeScreen), findsNothing);
      expect(fixture.events, isNot(contains('load')));
    } finally {
      await fixture.close(tester);
    }
  });

  testWidgets('denied membership never acquires a lock', (tester) async {
    final fixture = _Fixture()..allowed = false;

    try {
      await fixture.open(tester);

      expect(fixture.locks.acquisitions, 0);
      expect(find.byType(AddRecipeScreen), findsNothing);
    } finally {
      await fixture.close(tester);
    }
  });

  testWidgets('expired session requires confirmation before replacing draft',
      (tester) async {
    final fixture = _Fixture();

    try {
      await fixture.open(tester);

      final originalElement = tester.element(find.byType(AddRecipeScreen));

      fixture.container.read(recipeEditLockProvider(99).notifier).pause();
      await fixture.advance(tester, const Duration(seconds: 95));

      fixture.recipes.title = 'Updated by another member';

      await tester.tap(find.text('Check again'));
      await tester.pumpAndSettle();

      expect(find.text('Reload latest recipe'), findsOneWidget);

      await tester.tap(find.text('Reload latest recipe'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep draft'));
      await tester.pumpAndSettle();

      expect(
        tester.element(
          find.byType(AddRecipeScreen, skipOffstage: false),
        ),
        same(originalElement),
      );
      expect(
        fixture.events.where((event) => event == 'load').length,
        1,
      );

      await tester.tap(find.text('Reload latest recipe'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard draft and reload'));
      await tester.pumpAndSettle();

      final editor =
          tester.widget<AddRecipeScreen>(find.byType(AddRecipeScreen));

      expect(editor.initialRecipe!.title, 'Updated by another member');
      expect(editor.canContinueSave!(), isTrue);
    } finally {
      await fixture.close(tester);
    }
  });

  testWidgets('access is checked again immediately before saving',
      (tester) async {
    final fixture = _Fixture();

    try {
      await fixture.open(tester);

      final editor =
          tester.widget<AddRecipeScreen>(find.byType(AddRecipeScreen));

      fixture.allowed = false;

      expect(await editor.beforeSave!(), isFalse);
      expect(editor.canContinueSave!(), isFalse);
      expect(fixture.recipes.updates, 0);
    } finally {
      await fixture.close(tester);
    }
  });

  testWidgets('save holds lock until response and prevents duplicate submit',
      (tester) async {
    final fixture = _Fixture();
    fixture.recipes.pendingSave = Completer<Recipe>();

    try {
      await fixture.open(tester);

      await tester.scrollUntilVisible(
        find.text('Save Changes'),
        400,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.text('Save Changes'));
      await tester.pump();
      await tester.pump();

      expect(fixture.recipes.updates, 1);
      expect(
        fixture.recipes.lastSubmittedRecipe!.equipment!
            .map((item) => item.id)
            .toList(),
        [3],
      );
      expect(fixture.locks.releases, 0);

      await fixture.advance(tester, const Duration(seconds: 30));
      expect(fixture.locks.acquisitions, greaterThanOrEqualTo(3));
      expect(fixture.recipes.updates, 1);
      expect(fixture.locks.releases, 0);

      fixture.recipes.pendingSave!.complete(fixture.recipes.recipe);
      await tester.pumpAndSettle();

      expect(fixture.locks.releases, 1);
      expect(find.text('Open editor'), findsOneWidget);
      expect(
        fixture.events.indexOf('save'),
        lessThan(fixture.events.indexOf('release')),
      );
    } finally {
      if (!fixture.recipes.pendingSave!.isCompleted) {
        fixture.recipes.pendingSave!.complete(fixture.recipes.recipe);
        await tester.pumpAndSettle();
      }
      await fixture.close(tester);
    }
  });

  testWidgets('leaving editor releases the lock', (tester) async {
    final fixture = _Fixture();

    try {
      await fixture.open(tester);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Open editor'), findsOneWidget);
      expect(fixture.locks.releases, 1);
    } finally {
      await fixture.close(tester);
    }
  });

  testWidgets('background pauses editing and resume checks access',
      (tester) async {
    final fixture = _Fixture();

    void resumeApp() {
      if (tester.binding.lifecycleState == AppLifecycleState.paused) {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.hidden,
        );
      }

      if (tester.binding.lifecycleState == AppLifecycleState.hidden) {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
      }

      if (tester.binding.lifecycleState != AppLifecycleState.resumed) {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
      }
    }

    try {
      resumeApp();
      await fixture.open(tester);

      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.inactive,
      );
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.hidden,
      );
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.paused,
      );

      expect(
        fixture.container.read(recipeEditLockProvider(99).notifier).canSave,
        isFalse,
      );

      await fixture.advance(tester, const Duration(seconds: 20));
      expect(fixture.locks.acquisitions, 1);

      resumeApp();
      await tester.pumpAndSettle();

      expect(fixture.locks.acquisitions, 2);
      expect(find.text('Edit Recipe'), findsOneWidget);
    } finally {
      await fixture.close(tester);
      resumeApp();
      await tester.pump();
    }
  });
}
