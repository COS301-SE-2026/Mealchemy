import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/discovery/repositories/mock_discovery_repository.dart';

void main() {
  group('MockDiscoveryRepository.getCategories', () {
    test('returns the coret numbers of  categores ', () async {
      final repository = MockDiscoveryRepository();
      final categories = await repository.getCategories();
      expect(categories, hasLength(11));
    });
    test('first category is  Italian with id 1 ', () async {
      final repository = MockDiscoveryRepository();
      final categories = await repository.getCategories();
      expect(categories.first.id, 1);
      expect(categories.first.name, 'Italian');
    });

    test('last category is South African with id 11', () async {
      final repository = MockDiscoveryRepository();
      final categories = await repository.getCategories();

      expect(categories.last.id, 11);
      expect(categories.last.name, 'South African');
    });


    test('every category has a non-empty name ', () async {
      final repository = MockDiscoveryRepository();
      final categories = await repository.getCategories();

      for (final category in categories) {
        expect(category.name, isNotEmpty);
      }

    });

    test('every category  has a unique id ', () async {
      final repository = MockDiscoveryRepository();
      final categories = await repository.getCategories();
      final ids = categories.map((c) => c.id).toSet();

      expect(ids.length, categories.length);
    });
  });

  group('MockDiscoveryRepository.getExploreItems', () {
    test('return 10 explore items', () async {
      final repository = MockDiscoveryRepository();
      final items = await repository.getExploreItems();

      expect(items, hasLength(10));
    });

    test('contains exactly 2 video items', () async {
      final repository = MockDiscoveryRepository();
      final items = await repository.getExploreItems();
      final videos = items.where((i) => i.isVideo).toList();

      expect(videos, hasLength(2));
    });

    test('contains exactly 8 recipe items', () async {
      final repository = MockDiscoveryRepository();
      final items = await repository.getExploreItems();
      final recipes = items.where((i) => !i.isVideo).toList();
      expect(recipes, hasLength(8));
    });

    test('first  item is a video', () async {
      final repository = MockDiscoveryRepository();
      final items = await repository.getExploreItems();
      expect(items.first.isVideo, true);
    });

    test('last item is a video', () async {
      final repository = MockDiscoveryRepository();
      final items = await repository.getExploreItems();

      expect(items.last.isVideo, true);
    });

    test('all  recipe items have a matchPercent', () async {
      final repository = MockDiscoveryRepository();
      final items = await repository.getExploreItems();
      final recipes = items.where((i) => !i.isVideo).toList();

      for (final recipe in recipes) {
        expect(recipe.matchPercent, isNotNull);
      }
    });

    test('video item do not have a matchPercent', () async {
      final repository = MockDiscoveryRepository();
      final items = await repository.getExploreItems();
      final videos = items.where((i) => i.isVideo).toList();

      for (final video in videos) {
        expect(video.matchPercent, isNull);
      }
    });

    test('every item has a  non-empty title', () async {
      final repository = MockDiscoveryRepository();
      final items = await repository.getExploreItems();

      for (final item in items) {
        expect(item.title, isNotEmpty);
      }
    });

    test('every item has a unique id', () async {
      final repository = MockDiscoveryRepository();
      final items = await repository.getExploreItems();
      final ids = items.map((i) => i.id).toSet();


      expect(ids.length, items.length);
    });
  });
}
