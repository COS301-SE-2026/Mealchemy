import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recipeImageCacheManagerProvider =
    Provider.family<CacheManager, int>((ref, viewerUserId) {
  final manager = CacheManager(
    Config('mealchemy_recipe_images_user_$viewerUserId'),
  );
  ref.onDispose(() => unawaited(manager.dispose()));
  return manager;
});
