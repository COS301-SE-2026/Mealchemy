import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/sizzles/providers/sizzles_provider.dart';
import 'package:mealchemy/features/sizzles/repositories/sizzles_repository.dart';

void main() {
  test('loads global recipes and tracks the visible page', () async {
    final repository = _FakeSizzlesRepository([
      _recipe(1, 'Pasta'),
      _recipe(2, 'Curry'),
    ]);
    final container = _container(repository);
    final subscription = _keepAlive(container);
    addTearDown(subscription.close);

    final loaded = await container.read(sizzlesProvider.future);

    expect(loaded.items, hasLength(2));
    expect(loaded.currentIndex, 0);

    container.read(sizzlesProvider.notifier).onPageChanged(1);

    expect(container.read(sizzlesProvider).requireValue.currentIndex, 1);
  });

  test('reset reloads the global feed', () async {
    final repository = _FakeSizzlesRepository([_recipe(1, 'Pasta')]);
    final container = _container(repository);
    final subscription = _keepAlive(container);
    addTearDown(subscription.close);
    await container.read(sizzlesProvider.future);
    repository.items = [_recipe(2, 'Curry')];

    await container.read(sizzlesProvider.notifier).reset();

    final loaded = container.read(sizzlesProvider).requireValue;
    expect(repository.calls, 2);
    expect(loaded.items.single.title, 'Curry');
  });

  test('exposes repository failures as an async error', () async {
    final repository = _FakeSizzlesRepository(
      const [],
      error: StateError('backend unavailable'),
    );
    final container = _container(repository);
    final subscription = _keepAlive(container);
    addTearDown(subscription.close);

    await expectLater(
      container.read(sizzlesProvider.future),
      throwsA(isA<StateError>()),
    );

    expect(container.read(sizzlesProvider), isA<AsyncError<SizzlesState>>());
  });
}

ProviderContainer _container(SizzlesRepository repository) {
  final container = ProviderContainer(
    overrides: [
      sizzlesRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

ProviderSubscription<AsyncValue<SizzlesState>> _keepAlive(
  ProviderContainer container,
) {
  return container.listen(sizzlesProvider, (_, __) {}, fireImmediately: true);
}

Recipe _recipe(int id, String title) {
  return Recipe(
    recipeId: id,
    title: title,
    videoUrl: 'https://cdn.test/$id.mp4',
    isCommunityPublished: true,
  );
}

class _FakeSizzlesRepository implements SizzlesRepository {
  _FakeSizzlesRepository(this.items, {this.error});

  List<Recipe> items;
  final Object? error;
  int calls = 0;

  @override
  Future<List<Recipe>> getSizzles() async {
    calls++;
    if (error != null) throw error!;
    return items;
  }
}
