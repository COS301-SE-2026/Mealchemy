import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/providers/recipe_image_cache_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('creates one isolated image cache manager per viewer', () {
    final container = ProviderContainer();

    final first = container.read(recipeImageCacheManagerProvider(11));
    final sameViewer = container.read(recipeImageCacheManagerProvider(11));
    final otherViewer = container.read(recipeImageCacheManagerProvider(12));

    expect(first, isA<CacheManager>());
    expect(sameViewer, same(first));
    expect(otherViewer, isNot(same(first)));
  });
}
