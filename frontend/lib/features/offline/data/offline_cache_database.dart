import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'offline_cache_database.g.dart';

class UtcDateTimeConverter extends TypeConverter<DateTime, String> {
  const UtcDateTimeConverter();

  @override
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb).toUtc();

  @override
  String toSql(DateTime value) => value.toUtc().toIso8601String();
}

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

@DriftDatabase(
  tables: [
    CachedVaultRows,
    CachedVaultFolderRows,
    CachedVaultFolderRecipeRows,
    CachedRecipeRows,
    CachedRecipeIngredientRows,
    CachedRecipeStepRows,
    CacheSyncMetadataRows,
  ],
)
class OfflineCacheDatabase extends _$OfflineCacheDatabase {
  OfflineCacheDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(
      () async => driftDatabase(name: 'mealchemy_offline_cache'),
    );
  }
}
