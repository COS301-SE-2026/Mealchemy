import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/discovery/models/discovery_category.dart';
import 'package:mealchemy/features/discovery/models/explore_item.dart';
import 'package:mealchemy/features/discovery/providers/discovery_provider.dart';
import 'package:mealchemy/features/discovery/repositories/discovery_repository.dart';
import 'package:mealchemy/features/discovery/repositories/mock_discovery_repository.dart';

class _ThrowingDiscoveryRepo implements DiscoveryRepository {
  @override
  Future<List<DiscoveryCategory>> getCategories() async =>
      throw Exception('network error');

  @override
  Future<List<ExploreItem>> getExploreItems() async =>
      throw Exception('network error');
}

class _FakeDiscoveryRepo implements DiscoveryRepository {
  @override
  Future<List<DiscoveryCategory>> getCategories() async => const [
        DiscoveryCategory(id: 1, name: 'Italian', imageUrl: ''),
        DiscoveryCategory(id: 2, name: 'Japanese', imageUrl: ''),
      ];

  @override
  Future<List<ExploreItem>> getExploreItems() async => const [
        ExploreItem(id: 1, title: 'Chef Special', imageUrl: '', isVideo: true),
        ExploreItem(id: 2, title: 'Beet Salad', imageUrl: '', matchPercent: 85),
      ];
}

void main() {
  group('discoveryRepositoryProvider', () {
    test('returns MockDiscoveryRepository  when useMockData is true ', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        container.read(discoveryRepositoryProvider),
        isA<MockDiscoveryRepository>(),
      );
    });
  });

  group('DiscoveryState defaults', () {
    test('all fields starts at their zero values', () {
      const state = DiscoveryState();
      expect(state.isLoading, false);
      expect(state.categories, isEmpty);
      expect(state.selectedCategoryId, isNull);
      expect(state.exploreItems, isEmpty);
      expect(state.errorMessage, isNull);
    });
  });

  group('DiscoveryState.copyWith', () {
    test('preserves categories and exploreItems when not overridden', () {
      const state = DiscoveryState(
        categories: [DiscoveryCategory(id: 1, name: 'Italian', imageUrl: '')],
        exploreItems: [
          ExploreItem(id: 1, title: 'Test', imageUrl: '', isVideo: true)
        ],
      );

      final next = state.copyWith(isLoading: true);
      expect(next.categories, hasLength(1));
      expect(next.exploreItems, hasLength(1));
    });
  });

  group('DiscoveryNotifier.loadDiscovery', () {
    test('populates categories  and auto selects first on success ', () async {
      final container = ProviderContainer(
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(_FakeDiscoveryRepo()),
        ],
      );

      addTearDown(container.dispose);
      await container.read(discoveryProvider.notifier).loadDiscovery();
      final state = container.read(discoveryProvider);
      expect(state.categories, hasLength(2));
      expect(state.selectedCategoryId, 1);
      expect(state.errorMessage, isNull);
    });

    test('populates exploreItems on success', () async {
      final container = ProviderContainer(
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(_FakeDiscoveryRepo()),
        ],
      );
      addTearDown(container.dispose);
      await container.read(discoveryProvider.notifier).loadDiscovery();
      expect(container.read(discoveryProvider).exploreItems, hasLength(2));
    });

    test('sets errorMessage and leaves lists empty when repository throws',
        () async {
      final container = ProviderContainer(
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(
            _ThrowingDiscoveryRepo(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(discoveryProvider.notifier).loadDiscovery();

      final state = container.read(discoveryProvider);
      expect(state.errorMessage, isNotNull);
      expect(state.isLoading, false);
      expect(state.categories, isEmpty);
      expect(state.exploreItems, isEmpty);
    });
  });

  group('DiscoveryNotifier.selectCategory', () {
    test('updates selectedCategoryId without clearing other state', () async {
      final container = ProviderContainer(
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(_FakeDiscoveryRepo()),
        ],
      );
      addTearDown(container.dispose);
      await container.read(discoveryProvider.notifier).loadDiscovery();
      container.read(discoveryProvider.notifier).selectCategory(2);
      final state = container.read(discoveryProvider);
      expect(state.selectedCategoryId, 2);
      expect(state.categories, isNotEmpty);
      expect(state.exploreItems, isNotEmpty);
    });
  });
}
