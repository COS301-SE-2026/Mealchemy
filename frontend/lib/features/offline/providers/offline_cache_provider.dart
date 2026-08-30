import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/offline_cache_database.dart';
import '../data/offline_cache_store.dart';

final offlineCacheDatabaseProvider = Provider<OfflineCacheDatabase>((ref) {
  final database = OfflineCacheDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final offlineCacheStoreProvider = Provider<OfflineCacheStore>((ref) {
  return OfflineCacheStore(ref.watch(offlineCacheDatabaseProvider));
});
