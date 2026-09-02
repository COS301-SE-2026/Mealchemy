import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/offline/data/offline_cache_database.dart';

void main() {
  test('UTC converter normalizes values in both directions', () {
    const converter = UtcDateTimeConverter();
    final local = DateTime.parse('2026-08-30T12:00:00+02:00');

    expect(converter.toSql(local), '2026-08-30T10:00:00.000Z');
    expect(converter.fromSql('2026-08-30T12:00:00+02:00').isUtc, isTrue);
  });

  test('runtime schema contains every cache table and scoped key', () async {
    final database = OfflineCacheDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    expect(database.schemaVersion, 2);
    expect(database.allTables, hasLength(10));
    expect(
      database.allTables.map((table) => table.actualTableName).toSet(),
      {
        'cached_vault_rows',
        'cached_vault_folder_rows',
        'cached_vault_folder_recipe_rows',
        'cached_recipe_rows',
        'cached_recipe_ingredient_rows',
        'cached_recipe_step_rows',
        'cache_sync_metadata_rows',
        'cached_pantry_ingredient_rows',
        'cached_shopping_list_rows',
        'cached_shopping_list_item_rows',
      },
    );
    for (final table in database.allTables) {
      expect(
        table.$primaryKey,
        isNotEmpty,
        reason: '${table.actualTableName} must have a scoped primary key',
      );
    }
  });
}
