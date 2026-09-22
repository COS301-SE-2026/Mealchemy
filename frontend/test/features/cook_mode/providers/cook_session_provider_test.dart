import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/cook_mode/models/cook_session.dart';
import 'package:mealchemy/features/cook_mode/providers/cook_session_provider.dart';
import 'package:mealchemy/features/cook_mode/services/cook_session_store.dart';

class _MemoryStore implements CookSessionStore {
  final Map<int, Map<int, CookSession>> sessions = {};

  @override
  Future<CookSession?> read(int userId, int recipeId) async =>
      sessions[userId]?[recipeId];

  @override
  Future<CookSession?> latest(int userId) async {
    final values = sessions[userId]?.values.toList() ?? [];
    values.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return values.isEmpty ? null : values.first;
  }

  @override
  Future<void> save(int userId, CookSession session) async {
    sessions.putIfAbsent(userId, () => {})[session.recipeId] = session;
  }

  @override
  Future<void> remove(int userId, int recipeId) async {
    sessions[userId]?.remove(recipeId);
  }
}

void main() {
  test('read providers update after save and removal', () async {
    final store = _MemoryStore();
    final container = ProviderContainer(overrides: [
      activeIdentityProvider.overrideWithValue(42),
      cookSessionStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(container.dispose);
    final session = CookSession(
      recipeId: 7,
      recipeTitle: 'Pasta',
      stepIndex: 1,
      stepNumber: 2,
      stepText: 'Add sauce.',
      stepCount: 2,
      savedAt: DateTime.utc(2026, 9, 13),
    );

    expect(
        await container.read(cookSessionForRecipeProvider(7).future), isNull);
    await container
        .read(cookSessionControllerProvider.notifier)
        .save(42, session);
    expect(
      (await container.read(cookSessionForRecipeProvider(7).future))?.stepIndex,
      1,
    );
    expect(
        (await container.read(latestCookSessionProvider.future))?.recipeId, 7);

    await container.read(cookSessionControllerProvider.notifier).remove(42, 7);
    expect(
        await container.read(cookSessionForRecipeProvider(7).future), isNull);
    expect(await container.read(latestCookSessionProvider.future), isNull);
  });

  test('anonymous users cannot read another identity\'s progress', () async {
    final store = _MemoryStore();
    final container = ProviderContainer(overrides: [
      activeIdentityProvider.overrideWithValue(null),
      cookSessionStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(container.dispose);

    expect(await container.read(latestCookSessionProvider.future), isNull);
    expect(
        await container.read(cookSessionForRecipeProvider(7).future), isNull);
  });
}
