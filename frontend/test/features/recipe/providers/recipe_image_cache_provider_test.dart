import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/providers/recipe_image_cache_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.path,
    );
  });

    test('creates one isolated image cache manager per viewer', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final first = container.read(recipeImageCacheManagerProvider(11));
    final sameViewer = container.read(recipeImageCacheManagerProvider(11));
    final otherViewer = container.read(recipeImageCacheManagerProvider(12));
    await first.getFileFromCache('warmup');
    await otherViewer.getFileFromCache('warmup');

    expect(first, isA<CacheManager>());
    expect(sameViewer, same(first));
    expect(otherViewer, isNot(same(first)));
  });
}