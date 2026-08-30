import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'offline_cache_database.g.dart';

class UtcDateTimeConverter extends TypeConverter<DateTime, String> {
  const UtcDateTimeConverter();

  @override
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb).toUtc();

  @override
  String toSql(DateTime value) => value.toUtc().toIso8601String();
}

// Drift reads these declarations during code generation. Their column getters deliberately throw if invoked directly at runtime, so they are not unit-test coverage targets; the generated schema is exercised through the database.
// coverage:ignore-start
class CachedVaultRows extends Table {
  IntColumn get viewerUserId => integer()();
  IntColumn get vaultId => integer()();
  IntColumn get ownerId => integer().nullable()();
  TextColumn get vaultType => text()();
  TextColumn get name => text()();
  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();

  @override
  Set<Column<Object>> get primaryKey => {viewerUserId, vaultId};
}

class CachedVaultFolderRows extends Table {
  IntColumn get viewerUserId => integer()();
  IntColumn get folderId => integer()();
  IntColumn get vaultId => integer()();
  TextColumn get folderName => text()();
  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();

  @override
  Set<Column<Object>> get primaryKey => {viewerUserId, folderId};
}

class CachedVaultFolderRecipeRows extends Table {
  IntColumn get viewerUserId => integer()();
  IntColumn get folderRecipeId => integer()();
  IntColumn get folderId => integer()();
  IntColumn get recipeId => integer()();
  TextColumn get addedAt => text().map(const UtcDateTimeConverter())();
  IntColumn get addedByUserId => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {viewerUserId, folderRecipeId};
}

class CachedRecipeRows extends Table {
  IntColumn get viewerUserId => integer()();
  IntColumn get recipeId => integer()();
  IntColumn get ownerId => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get cuisineType => text().nullable()();
  IntColumn get prepTimeMins => integer().nullable()();
  IntColumn get cookingTimeMins => integer().nullable()();
  IntColumn get servingSize => integer().nullable()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get videoUrl => text().nullable()();
  TextColumn get externalUrl => text().nullable()();
  BoolColumn get isCommunityPublished => boolean()();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeConverter()).nullable()();
  TextColumn get updatedAt =>
      text().map(const UtcDateTimeConverter()).nullable()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {viewerUserId, recipeId};
}

class CachedRecipeIngredientRows extends Table {
  IntColumn get viewerUserId => integer()();
  IntColumn get recipeId => integer()();
  IntColumn get lineIndex => integer()();
  IntColumn get ingredientId => integer().nullable()();
  IntColumn get ingId => integer()();
  TextColumn get name => text().nullable()();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {
        viewerUserId,
        recipeId,
        lineIndex,
      };
}

class CachedRecipeStepRows extends Table {
  IntColumn get viewerUserId => integer()();
  IntColumn get recipeId => integer()();
  IntColumn get lineIndex => integer()();
  IntColumn get stepId => integer().nullable()();
  IntColumn get stepNr => integer()();
  TextColumn get content => text()();

  @override
  Set<Column<Object>> get primaryKey => {
        viewerUserId,
        recipeId,
        lineIndex,
      };
}

class CacheSyncMetadataRows extends Table {
  IntColumn get viewerUserId => integer()();
  TextColumn get collection => text()();
  TextColumn get scopeId => text()();
  TextColumn get lastSyncedAt => text().map(const UtcDateTimeConverter())();
  TextColumn get lastAccessedAt =>
      text().map(const UtcDateTimeConverter()).nullable()();

  @override
  Set<Column<Object>> get primaryKey => {
        viewerUserId,
        collection,
        scopeId,
      };
}

class CachedPantryIngredientRows extends Table {
  IntColumn get viewerUserId => integer()();
  TextColumn get rowKey => text()();
  IntColumn get pantryIngredientId => integer().nullable()();
  IntColumn get ingId => integer().nullable()();
  TextColumn get name => text()();
  TextColumn get details => text()();
  TextColumn get category => text()();
  TextColumn get status => text()();
  TextColumn get quantity => text().nullable()();
  TextColumn get unit => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {viewerUserId, rowKey};
}

class CachedShoppingListRows extends Table {
  IntColumn get viewerUserId => integer()();
  TextColumn get listId => text()();
  IntColumn get shoppingListId => integer().nullable()();
  IntColumn get serverUserId => integer().nullable()();
  IntColumn get numItems => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get subtitle => text()();
  TextColumn get section => text()();
  TextColumn get iconType => text()();
  TextColumn get status => text().nullable()();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeConverter()).nullable()();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get favourite => boolean()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {viewerUserId, listId};
}

class CachedShoppingListItemRows extends Table {
  IntColumn get viewerUserId => integer()();
  TextColumn get listId => text()();
  TextColumn get itemKey => text()();
  IntColumn get itemId => integer().nullable()();
  IntColumn get shoppingListId => integer().nullable()();
  IntColumn get ingId => integer().nullable()();
  TextColumn get name => text()();
  TextColumn get quantity => text()();
  TextColumn get category => text()();
  TextColumn get unit => text().nullable()();
  BoolColumn get checked => boolean()();
  IntColumn get lineIndex => integer()();

  @override
  Set<Column<Object>> get primaryKey => {viewerUserId, listId, itemKey};
}
// coverage:ignore-end

@DriftDatabase(
  tables: [
    CachedVaultRows,
    CachedVaultFolderRows,
    CachedVaultFolderRecipeRows,
    CachedRecipeRows,
    CachedRecipeIngredientRows,
    CachedRecipeStepRows,
    CacheSyncMetadataRows,
    CachedPantryIngredientRows,
    CachedShoppingListRows,
    CachedShoppingListItemRows,
  ],
)
class OfflineCacheDatabase extends _$OfflineCacheDatabase {
  OfflineCacheDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(cachedPantryIngredientRows);
            await migrator.createTable(cachedShoppingListRows);
            await migrator.createTable(cachedShoppingListItemRows);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(
      () async {
        await _migrateLegacyDatabaseToCache();
        return driftDatabase(
          name: 'mealchemy_offline_cache',
          native: DriftNativeOptions(
            databaseDirectory: getApplicationCacheDirectory,
          ),
        );
      },
    );
  }

  static Future<void> _migrateLegacyDatabaseToCache() async {
    final documents = await getApplicationDocumentsDirectory();
    final cache = await getApplicationCacheDirectory();
    const fileName = 'mealchemy_offline_cache.sqlite';
    final oldDatabase = File('${documents.path}/$fileName');
    final newDatabase = File('${cache.path}/$fileName');
    if (!await oldDatabase.exists() || await newDatabase.exists()) return;

    await cache.create(recursive: true);
    await _moveFile(oldDatabase, newDatabase);
    await _moveFile(
      File('${oldDatabase.path}-wal'),
      File('${newDatabase.path}-wal'),
    );
    await _moveFile(
      File('${oldDatabase.path}-shm'),
      File('${newDatabase.path}-shm'),
    );
  }

  static Future<void> _moveFile(File source, File destination) async {
    if (!await source.exists()) return;
    try {
      await source.rename(destination.path);
    } on FileSystemException {
      await source.copy(destination.path);
      await source.delete();
    }
  }
}
