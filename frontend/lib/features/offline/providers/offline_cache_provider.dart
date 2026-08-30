import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/offline_cache_database.dart';
import '../data/offline_cache_store.dart';
import '../data/pantry_cache_store.dart';
import '../data/shopping_list_cache_store.dart';
import '../../auth/providers/auth_provider.dart';

final offlineCacheDatabaseProvider = Provider<OfflineCacheDatabase>((ref) {
  final database = OfflineCacheDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final offlineCacheStoreProvider = Provider<OfflineCacheStore>((ref) {
  return OfflineCacheStore(ref.watch(offlineCacheDatabaseProvider));
});

final pantryCacheStoreProvider = Provider<PantryCacheStore>((ref) {
  return PantryCacheStore(
    ref.watch(offlineCacheDatabaseProvider),
    ref.watch(offlineCacheStoreProvider),
  );
});

final shoppingListCacheStoreProvider = Provider<ShoppingListCacheStore>((ref) {
  return ShoppingListCacheStore(
    ref.watch(offlineCacheDatabaseProvider),
    ref.watch(offlineCacheStoreProvider),
  );
});

class CacheMetadataKey {
  const CacheMetadataKey({required this.collection, required this.scopeId});

  final String collection;
  final String scopeId;

  @override
  bool operator ==(Object other) =>
      other is CacheMetadataKey &&
      other.collection == collection &&
      other.scopeId == scopeId;

  @override
  int get hashCode => Object.hash(collection, scopeId);
}

final cacheSyncMetadataProvider = StreamProvider.autoDispose
    .family<CacheSyncMetadataRow?, CacheMetadataKey>((ref, key) {
  final viewerUserId = ref.watch(activeIdentityProvider);
  if (viewerUserId == null) {
    return const Stream<CacheSyncMetadataRow?>.empty();
  }
  return ref.watch(offlineCacheStoreProvider).watchSyncMetadata(
        viewerUserId: viewerUserId,
        collection: key.collection,
        scopeId: key.scopeId,
      );
});
