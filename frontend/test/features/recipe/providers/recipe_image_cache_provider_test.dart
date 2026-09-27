import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/providers/recipe_image_cache_provider.dart';

class _FakeCacheManager extends Fake implements CacheManager {
  int disposeCalls = 0;

  @override
  Future<void> dispose() async {
    disposeCalls++;
  }
}

void main() {
  test('creates one isolated image cache manager per viewer', () {
    final createdKeys = <String>[];
    final managers = <_FakeCacheManager>[];

    final container = ProviderContainer(
      overrides: [
        recipeImageCacheFactoryProvider.overrideWithValue((cacheKey) {
          createdKeys.add(cacheKey);
          final manager = _FakeCacheManager();
          managers.add(manager);
          return manager;
        }),
      ],
    );

    try {
      final first = container.read(recipeImageCacheManagerProvider(11));
      final sameViewer = container.read(recipeImageCacheManagerProvider(11));
      final otherViewer = container.read(recipeImageCacheManagerProvider(12));

      expect(sameViewer, same(first));
      expect(otherViewer, isNot(same(first)));
      expect(managers, hasLength(2));

      expect(createdKeys, [
        'mealchemy_recipe_images_user_11',
        'mealchemy_recipe_images_user_12',
      ]);

      expect(managers.map((manager) => manager.disposeCalls), [0, 0]);
    } finally {
      container.dispose();
    }

    expect(managers.map((manager) => manager.disposeCalls), [1, 1]);
  });
}
