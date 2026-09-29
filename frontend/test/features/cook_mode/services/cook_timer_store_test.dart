import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_timer.dart';
import 'package:mealchemy/features/cook_mode/services/cook_timer_store.dart';

CookTimer _timer(int id, int recipeId) {
  final startedAt = DateTime.utc(2026, 9, 15, 12);
  return CookTimer(
    notificationId: id,
    recipeId: recipeId,
    recipeTitle: 'Recipe $recipeId',
    stepIndex: 0,
    stepNumber: 1,
    startedAt: startedAt,
    endsAt: startedAt.add(const Duration(minutes: 10)),
  );
}

void main() {
  late Directory temporaryDirectory;
  late FileCookTimerStore store;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('cook_timers_');
    store = FileCookTimerStore(
      supportDirectory: () async => temporaryDirectory,
    );
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  test('stores multiple timers separately for each user', () async {
    await store.saveAll(1, [_timer(1, 7), _timer(2, 8)]);
    await store.saveAll(2, [_timer(3, 9)]);

    expect((await store.readAll(1)).map((timer) => timer.recipeId), [7, 8]);
    expect((await store.readAll(2)).single.recipeId, 9);
    expect(await store.readAll(3), isEmpty);
  });

  test('serializes rapid replacements and supports an empty timer list',
      () async {
    await Future.wait([
      store.saveAll(1, [_timer(1, 7)]),
      store.saveAll(1, [_timer(2, 8)]),
      store.saveAll(1, const []),
    ]);

    expect(await store.readAll(1), isEmpty);
  });
}
