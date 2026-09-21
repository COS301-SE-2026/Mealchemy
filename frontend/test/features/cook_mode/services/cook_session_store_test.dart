import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_session.dart';
import 'package:mealchemy/features/cook_mode/services/cook_session_store.dart';

CookSession _session(int recipeId, DateTime savedAt, {int stepIndex = 0}) =>
    CookSession(
      recipeId: recipeId,
      recipeTitle: 'Recipe $recipeId',
      stepIndex: stepIndex,
      stepNumber: stepIndex + 1,
      stepText: 'Step ${stepIndex + 1}',
      stepCount: 2,
      savedAt: savedAt,
    );

void main() {
  late Directory temporaryDirectory;
  late FileCookSessionStore store;

  setUp(() async {
    temporaryDirectory =
        await Directory.systemTemp.createTemp('cook_sessions_');
    store = FileCookSessionStore(
      supportDirectory: () async => temporaryDirectory,
    );
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  test('saves and reads sessions separately for each user and recipe',
      () async {
    final first = _session(7, DateTime.utc(2026, 9, 13));
    final second = _session(8, DateTime.utc(2026, 9, 14));
    await store.save(1, first);
    await store.save(1, second);
    await store.save(2, _session(7, DateTime.utc(2026, 9, 15)));

    expect((await store.read(1, 7))?.recipeTitle, 'Recipe 7');
    expect((await store.latest(1))?.recipeId, 8);
    expect((await store.latest(2))?.recipeId, 7);
    expect(await store.read(3, 7), isNull);
  });

  test('serializes rapid writes and clears only the completed recipe',
      () async {
    final first = _session(7, DateTime.utc(2026, 9, 13));
    final advanced = _session(7, DateTime.utc(2026, 9, 14), stepIndex: 1);
    await Future.wait([
      store.save(1, first),
      store.save(1, advanced),
      store.save(1, _session(8, DateTime.utc(2026, 9, 15))),
    ]);
    expect((await store.read(1, 7))?.stepIndex, 1);

    await store.remove(1, 7);
    expect(await store.read(1, 7), isNull);
    expect((await store.read(1, 8))?.recipeId, 8);
  });
}
