import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/offline_cache_database.dart';
import '../data/offline_cache_store.dart';
import '../data/pantry_cache_store.dart';
import '../data/shopping_list_cache_store.dart';

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
