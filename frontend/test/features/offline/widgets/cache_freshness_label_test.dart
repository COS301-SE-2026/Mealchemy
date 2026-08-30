import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/offline/data/offline_cache_database.dart';
import 'package:mealchemy/features/offline/data/offline_cache_store.dart';
import 'package:mealchemy/features/offline/providers/offline_cache_provider.dart';
import 'package:mealchemy/features/offline/widgets/cache_freshness_label.dart';

void main() {
  const metadataKey = CacheMetadataKey(
    collection: CacheCollection.recipes,
    scopeId: CacheScope.all,
  );

  testWidgets('stays hidden while online', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [offlineReadOnlyProvider.overrideWithValue(false)],
        child: const MaterialApp(
          home: CacheFreshnessLabel(
            collection: CacheCollection.recipes,
            scopeId: CacheScope.all,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.history), findsNothing);
  });

  for (final scenario in [
    (age: Duration.zero, text: 'Saved just now'),
    (age: const Duration(minutes: 15), text: 'Saved 15m ago'),
    (age: const Duration(hours: 2), text: 'Saved 2h ago'),
    (age: const Duration(days: 3), text: 'Saved 3d ago'),
  ]) {
    testWidgets('shows ${scenario.text.toLowerCase()} while offline',
        (tester) async {
      final syncedAt = DateTime.now().toUtc().subtract(scenario.age);
      final metadata = CacheSyncMetadataRow(
        viewerUserId: 11,
        collection: CacheCollection.recipes,
        scopeId: CacheScope.all,
        lastSyncedAt: syncedAt,
        lastAccessedAt: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            offlineReadOnlyProvider.overrideWithValue(true),
            cacheSyncMetadataProvider(metadataKey).overrideWith(
              (ref) => Stream.value(metadata),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CacheFreshnessLabel(
                collection: metadataKey.collection,
                scopeId: metadataKey.scopeId,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.text(scenario.text), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
