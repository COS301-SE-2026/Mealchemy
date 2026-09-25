import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef RecipeImageCacheFactory = CacheManager Function(String cacheKey);

final recipeImageCacheFactoryProvider =
    Provider<RecipeImageCacheFactory>((ref) {
  return (cacheKey) => CacheManager(Config(cacheKey));
});

final recipeImageCacheManagerProvider =
    Provider.family<CacheManager, int>((ref, viewerUserId) {
  final createManager = ref.watch(recipeImageCacheFactoryProvider);

  final manager = createManager(
    'mealchemy_recipe_images_user_$viewerUserId',
  );

  ref.onDispose(() => unawaited(manager.dispose()));
  return manager;
});
