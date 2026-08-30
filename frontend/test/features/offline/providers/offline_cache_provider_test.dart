import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/offline/data/offline_cache_database.dart';
import 'package:mealchemy/features/offline/data/offline_cache_store.dart';
import 'package:mealchemy/features/offline/providers/offline_cache_provider.dart';

void main() {
  late OfflineCacheDatabase database;

  setUp(() {
    database = OfflineCacheDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('constructs collection stores from the shared database', () {
    final container = ProviderContainer(
      overrides: [
        offlineCacheDatabaseProvider.overrideWithValue(database),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(offlineCacheStoreProvider), isA<OfflineCacheStore>());
    expect(container.read(pantryCacheStoreProvider), isNotNull);
    expect(container.read(shoppingListCacheStoreProvider), isNotNull);
  });

  test('metadata keys use collection and scope for equality', () {
    const first = CacheMetadataKey(collection: 'recipes', scopeId: 'all');
    const same = CacheMetadataKey(collection: 'recipes', scopeId: 'all');
    const different = CacheMetadataKey(collection: 'recipes', scopeId: '7');

    expect(first, same);
    expect(first.hashCode, same.hashCode);
    expect(first, isNot(different));
    expect(first, isNot('recipes:all'));
  });

  test('streams metadata for the active viewer and requested scope', () async {
    final store = OfflineCacheStore(database);
    final syncedAt = DateTime.utc(2026, 8, 30, 10);
    await store.writeSyncMetadata(
      viewerUserId: 11,
      collection: CacheCollection.recipes,
      scopeId: CacheScope.all,
      syncedAt: syncedAt,
    );
    final container = ProviderContainer(
      overrides: [
        activeIdentityProvider.overrideWithValue(11),
        offlineCacheDatabaseProvider.overrideWithValue(database),
      ],
    );
    addTearDown(container.dispose);

    final metadata = await container.read(
      cacheSyncMetadataProvider(
        const CacheMetadataKey(
          collection: CacheCollection.recipes,
          scopeId: CacheScope.all,
        ),
      ).future,
    );

    expect(metadata?.viewerUserId, 11);
    expect(metadata?.lastSyncedAt, syncedAt);
  });
}
