import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/offline/data/offline_cache_database.dart';
import 'package:mealchemy/features/offline/data/offline_cache_store.dart';
import 'package:mealchemy/features/offline/data/pantry_cache_store.dart';
import 'package:mealchemy/features/offline/repositories/cached_pantry_repository.dart';
import 'package:mealchemy/features/pantry/models/pantry_ingredient.dart';
import 'package:mealchemy/features/pantry/repositories/mock_pantry_repository.dart';
import 'package:mealchemy/features/pantry/widgets/pantry_item_card.dart';

void main() {
  late OfflineCacheDatabase database;
  late PantryCacheStore cache;

  setUp(() {
    database = OfflineCacheDatabase(NativeDatabase.memory());
    cache = PantryCacheStore(database, OfflineCacheStore(database));
  });

  tearDown(() => database.close());

  test('successful fetch refreshes only the viewer cache', () async {
    final remote = _PantryRemote([_ingredient('Fresh API milk')]);
    final repository = CachedPantryRepository(
      remote: remote,
      cache: cache,
      viewerUserId: 11,
    );

    final result = await repository.getPantryIngredients();

    expect(result.single.name, 'Fresh API milk');
    expect(
      (await cache.readIngredients(viewerUserId: 11)).single.name,
      'Fresh API milk',
    );
    expect(await cache.readIngredients(viewerUserId: 12), isEmpty);
  });

  test('transport failure returns the viewer cache', () async {
    await cache.replaceFromCompleteFetch(
      viewerUserId: 11,
      ingredients: [_ingredient('Cached milk')],
      syncedAt: DateTime.now().toUtc(),
    );
    final remote = _PantryRemote(const [], error: _connectionError());
    final repository = CachedPantryRepository(
      remote: remote,
      cache: cache,
      viewerUserId: 11,
    );

    final result = await repository.getPantryIngredients();

    expect(result.single.name, 'Cached milk');
  });

  test('HTTP errors propagate instead of returning stale pantry data',
      () async {
    await cache.replaceFromCompleteFetch(
      viewerUserId: 11,
      ingredients: [_ingredient('Must not be returned')],
      syncedAt: DateTime.now().toUtc(),
    );
    final error = _httpError(401);
    final repository = CachedPantryRepository(
      remote: _PantryRemote(const [], error: error),
      cache: cache,
      viewerUserId: 11,
    );

    await expectLater(repository.getPantryIngredients(), throwsA(same(error)));
  });

  test('derives summary filters and sorted categories from one fetch',
      () async {
    final remote = _PantryRemote([
      _ingredient('Milk', category: 'Dairy'),
      _ingredient(
        'Old cheese',
        category: 'Dairy',
        status: PantryItemStatus.expired,
        id: 6,
      ),
      _ingredient('Apple', category: 'Fruit', id: 7),
    ]);
    final repository = CachedPantryRepository(
      remote: remote,
      cache: cache,
      viewerUserId: 11,
    );

    final summary = await repository.getPantrySummary();
    final filters = await repository.getPantryFilters();
    final categories = await repository.getIngredientCategories();

    expect(summary.totalItems, 3);
    expect(summary.freshnessPercent, 67);
    expect(summary.categoryCount, 2);
    expect(filters.map((filter) => '${filter.label}:${filter.count}'), [
      'All:3',
      'Dairy:2',
      'Fruit:1',
    ]);
    expect(categories, ['Dairy', 'Fruit']);
    expect(remote.fetchCalls, 1);
  });

  test('successful mutations invalidate the memoized ingredient fetch',
      () async {
    final remote = _PantryRemote([_ingredient('Milk')]);
    final repository = CachedPantryRepository(
      remote: remote,
      cache: cache,
      viewerUserId: 11,
    );

    await repository.getPantryIngredients();
    await repository.addPantryIngredient(ingId: 8, quantity: '1', unit: 'L');
    await repository.getPantryIngredients();
    await repository.updatePantryIngredient(
      pIngredientId: 5,
      ingId: 8,
      quantity: '2',
      unit: 'L',
    );
    await repository.getPantryIngredients();
    await repository.deletePantryIngredient(5);
    await repository.getPantryIngredients();

    expect(remote.fetchCalls, 4);
  });
}

PantryIngredient _ingredient(
  String name, {
  String category = 'Dairy',
  PantryItemStatus status = PantryItemStatus.fresh,
  int id = 5,
}) {
  return PantryIngredient(
    pIngredientId: id,
    ingId: 8,
    name: name,
    details: '1L - Pantry',
    category: category,
    status: status,
    quantity: '1',
    unit: 'L',
  );
}

class _PantryRemote extends MockPantryRepository {
  _PantryRemote(this.ingredients, {this.error});

  final List<PantryIngredient> ingredients;
  final Object? error;
  int fetchCalls = 0;

  @override
  Future<List<PantryIngredient>> getPantryIngredients() async {
    fetchCalls++;
    if (error case final error?) throw error;
    return ingredients;
  }
}

DioException _connectionError() => DioException(
      requestOptions: RequestOptions(path: '/pantry/ingredients'),
      type: DioExceptionType.connectionError,
    );

DioException _httpError(int statusCode) => DioException.badResponse(
      statusCode: statusCode,
      requestOptions: RequestOptions(path: '/pantry/ingredients'),
      response: Response<void>(
        requestOptions: RequestOptions(path: '/pantry/ingredients'),
        statusCode: statusCode,
      ),
    );
