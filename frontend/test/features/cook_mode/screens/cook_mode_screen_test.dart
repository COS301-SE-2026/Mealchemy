import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/cook_mode/models/cook_session.dart';
import 'package:mealchemy/features/cook_mode/providers/cook_session_provider.dart';
import 'package:mealchemy/features/cook_mode/screens/cook_mode_screen.dart';
import 'package:mealchemy/features/cook_mode/providers/cook_narration_provider.dart';
import 'package:mealchemy/features/cook_mode/services/cook_narration_service.dart';
import 'package:mealchemy/features/cook_mode/services/screen_awake_service.dart';
import 'package:mealchemy/features/cook_mode/services/cook_session_store.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';

const _recipe = Recipe(
  recipeId: 7,
  title: 'Weeknight Pasta',
  steps: [
    RecipeStep(stepNr: 2, content: 'Toss with the sauce.'),
    RecipeStep(stepNr: 1, content: 'Boil the pasta.'),
  ],
);

class _FakeScreenAwakeService implements ScreenAwakeService {
  int enableCalls = 0;
  int disableCalls = 0;

  @override
  Future<void> enable() async => enableCalls++;

  @override
  Future<void> disable() async => disableCalls++;
}

class _FakeNarrationService implements CookNarrationService {
  CookNarrationCallbacks? callbacks;
  final List<String> spoken = [];
  int stopCalls = 0;
  Object? initializeError;

  @override
  Future<int> initialize(CookNarrationCallbacks callbacks) async {
    if (initializeError != null) throw initializeError!;
    this.callbacks = callbacks;
    return 3000;
  }

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
    callbacks?.onStart();
  }

  @override
  Future<void> stop() async => stopCalls++;

  @override
  Future<void> dispose() async {}
}

class _FakeSessionStore implements CookSessionStore {
  final Map<String, CookSession> sessions = {};
  bool failRead = false;
  bool failSave = false;

  String _key(int userId, int recipeId) => '$userId:$recipeId';

  @override
  Future<CookSession?> read(int userId, int recipeId) async {
    if (failRead) throw StateError('unreadable');
    return sessions[_key(userId, recipeId)];
  }

  @override
  Future<CookSession?> latest(int userId) async => null;

  @override
  Future<void> save(int userId, CookSession session) async {
    if (failSave) throw StateError('unwritable');
    sessions[_key(userId, session.recipeId)] = session;
  }

  @override
  Future<void> remove(int userId, int recipeId) async {
    sessions.remove(_key(userId, recipeId));
  }
}

Widget _host(
  Recipe recipe,
  _FakeScreenAwakeService screenAwake, {
  _FakeNarrationService? narration,
  _FakeSessionStore? sessions,
  int? userId,
}) {
  return ProviderScope(
    overrides: [
      activeIdentityProvider.overrideWithValue(userId),
      recipeDetailProvider(recipe.recipeId).overrideWith((ref) async => recipe),
      screenAwakeServiceProvider.overrideWithValue(screenAwake),
      cookSessionStoreProvider.overrideWithValue(
        sessions ?? _FakeSessionStore(),
      ),
      cookNarrationServiceProvider.overrideWithValue(
        narration ?? _FakeNarrationService(),
      ),
    ],
    child: MaterialApp(home: CookModeScreen(recipeId: recipe.recipeId)),
  );
}

void main() {
  testWidgets('renders sorted steps and advances to completion',
      (tester) async {
    final service = _FakeScreenAwakeService();
    final narration = _FakeNarrationService();
    await tester.pumpWidget(_host(_recipe, service, narration: narration));
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 2'), findsOneWidget);
    expect(find.text('Boil the pasta.'), findsOneWidget);
    expect(service.enableCalls, 1);
    expect(narration.spoken, ['Boil the pasta.']);

    await tester.tap(find.byKey(const Key('cook-next-button')));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 2'), findsOneWidget);
    expect(find.text('Toss with the sauce.'), findsOneWidget);
    expect(narration.spoken.last, 'Toss with the sauce.');

    await tester.tap(find.byKey(const Key('cook-next-button')));
    await tester.pumpAndSettle();
    expect(find.text('Ready to serve'), findsOneWidget);
  });

  testWidgets('highlights the active narration range', (tester) async {
    final screenAwake = _FakeScreenAwakeService();
    final narration = _FakeNarrationService();
    await tester.pumpWidget(
      _host(_recipe, screenAwake, narration: narration),
    );
    await tester.pumpAndSettle();

    narration.callbacks?.onProgress(0, 4, 'Boil');
    await tester.pump();

    final text = tester.widget<Text>(find.byKey(const Key('cook-step-text')));
    expect(text.textSpan?.toPlainText(), 'Boil the pasta.');
    final rootSpan = text.textSpan! as TextSpan;
    final highlighted = rootSpan.children![1] as TextSpan;
    expect(highlighted.text, 'Boil');
    expect(highlighted.style?.backgroundColor, isNotNull);
  });

  testWidgets('pause and repeat controls call narration', (tester) async {
    final screenAwake = _FakeScreenAwakeService();
    final narration = _FakeNarrationService();
    await tester.pumpWidget(
      _host(_recipe, screenAwake, narration: narration),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pumpAndSettle();
    expect(find.text('Narration paused'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.replay).first);
    await tester.pumpAndSettle();
    expect(narration.spoken.last, 'Boil the pasta.');
  });

  testWidgets('keeps manual controls available when narration fails',
      (tester) async {
    final screenAwake = _FakeScreenAwakeService();
    final narration = _FakeNarrationService()
      ..initializeError = StateError('No speech engine');
    await tester.pumpWidget(
      _host(_recipe, screenAwake, narration: narration),
    );
    await tester.pumpAndSettle();

    expect(find.text('Narration unavailable'), findsOneWidget);
    expect(find.byKey(const Key('cook-next-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('cook-next-button')));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 2'), findsOneWidget);
  });

  testWidgets('shows an empty state when the recipe has no steps',
      (tester) async {
    final service = _FakeScreenAwakeService();
    const recipe = Recipe(recipeId: 8, title: 'Unfinished', steps: []);

    await tester.pumpWidget(_host(recipe, service));
    await tester.pumpAndSettle();

    expect(find.text('No cooking steps yet'), findsOneWidget);
    expect(service.enableCalls, 0);
  });

  testWidgets('releases wakelock when Cook Mode is removed', (tester) async {
    final service = _FakeScreenAwakeService();
    final narration = _FakeNarrationService();
    await tester.pumpWidget(
      _host(_recipe, service, narration: narration),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(service.disableCalls, 1);
    expect(narration.stopCalls, greaterThan(0));
  });

  testWidgets('restores the saved step before speaking', (tester) async {
    final sessions = _FakeSessionStore();
    sessions.sessions['12:7'] = CookSession(
      recipeId: 7,
      recipeTitle: _recipe.title,
      stepIndex: 1,
      stepNumber: 2,
      stepText: 'Toss with the sauce.',
      stepCount: 2,
      savedAt: DateTime.utc(2026, 9, 13),
    );
    final narration = _FakeNarrationService();
    await tester.pumpWidget(_host(
      _recipe,
      _FakeScreenAwakeService(),
      sessions: sessions,
      narration: narration,
      userId: 12,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 of 2'), findsOneWidget);
    expect(narration.spoken, ['Toss with the sauce.']);
  });

  testWidgets('resets a changed saved step to step one', (tester) async {
    final sessions = _FakeSessionStore();
    sessions.sessions['12:7'] = CookSession(
      recipeId: 7,
      recipeTitle: _recipe.title,
      stepIndex: 1,
      stepNumber: 2,
      stepText: 'Old instruction.',
      stepCount: 2,
      savedAt: DateTime.utc(2026, 9, 13),
    );
    final narration = _FakeNarrationService();
    await tester.pumpWidget(_host(
      _recipe,
      _FakeScreenAwakeService(),
      sessions: sessions,
      narration: narration,
      userId: 12,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 2'), findsOneWidget);
    expect(narration.spoken, ['Boil the pasta.']);
    expect(sessions.sessions['12:7']?.stepIndex, 0);
  });

  testWidgets('keeps manual controls when session storage fails',
      (tester) async {
    final sessions = _FakeSessionStore()
      ..failRead = true
      ..failSave = true;
    await tester.pumpWidget(_host(
      _recipe,
      _FakeScreenAwakeService(),
      sessions: sessions,
      userId: 12,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Cooking progress could not be saved on this device.'),
        findsOneWidget);
    await tester.tap(find.byKey(const Key('cook-next-button')));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 2'), findsOneWidget);
  });

  testWidgets('pauses on background and does not auto-resume speech',
      (tester) async {
    final screenAwake = _FakeScreenAwakeService();
    final narration = _FakeNarrationService();
    await tester.pumpWidget(_host(
      _recipe,
      screenAwake,
      narration: narration,
    ));
    await tester.pumpAndSettle();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();
    expect(find.text('Narration paused'), findsOneWidget);
    expect(screenAwake.disableCalls, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(screenAwake.enableCalls, 2);
    expect(narration.spoken, ['Boil the pasta.']);
  });

  testWidgets('clears only the completed recipe session', (tester) async {
    final sessions = _FakeSessionStore();
    await tester.pumpWidget(_host(
      _recipe,
      _FakeScreenAwakeService(),
      sessions: sessions,
      userId: 12,
    ));
    await tester.pumpAndSettle();
    expect(sessions.sessions['12:7'], isNotNull);

    await tester.tap(find.byKey(const Key('cook-next-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cook-next-button')));
    await tester.pumpAndSettle();
    expect(sessions.sessions['12:7'], isNull);
  });
}
