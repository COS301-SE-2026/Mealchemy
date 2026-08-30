// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_cache_database.dart';

// ignore_for_file: type=lint
class $CachedVaultRowsTable extends CachedVaultRows
    with TableInfo<$CachedVaultRowsTable, CachedVaultRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedVaultRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _viewerUserIdMeta =
      const VerificationMeta('viewerUserId');
  @override
  late final GeneratedColumn<int> viewerUserId = GeneratedColumn<int>(
      'viewer_user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _vaultIdMeta =
      const VerificationMeta('vaultId');
  @override
  late final GeneratedColumn<int> vaultId = GeneratedColumn<int>(
      'vault_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<int> ownerId = GeneratedColumn<int>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _vaultTypeMeta =
      const VerificationMeta('vaultType');
  @override
  late final GeneratedColumn<String> vaultType = GeneratedColumn<String>(
      'vault_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>($CachedVaultRowsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns =>
      [viewerUserId, vaultId, ownerId, vaultType, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_vault_rows';
  @override
  VerificationContext validateIntegrity(Insertable<CachedVaultRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('viewer_user_id')) {
      context.handle(
          _viewerUserIdMeta,
          viewerUserId.isAcceptableOrUnknown(
              data['viewer_user_id']!, _viewerUserIdMeta));
    } else if (isInserting) {
      context.missing(_viewerUserIdMeta);
    }
    if (data.containsKey('vault_id')) {
      context.handle(_vaultIdMeta,
          vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta));
    } else if (isInserting) {
      context.missing(_vaultIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('vault_type')) {
      context.handle(_vaultTypeMeta,
          vaultType.isAcceptableOrUnknown(data['vault_type']!, _vaultTypeMeta));
    } else if (isInserting) {
      context.missing(_vaultTypeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {viewerUserId, vaultId};
  @override
  CachedVaultRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedVaultRow(
      viewerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}viewer_user_id'])!,
      vaultId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vault_id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}owner_id']),
      vaultType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vault_type'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: $CachedVaultRowsTable.$convertercreatedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}created_at'])!),
    );
  }

  @override
  $CachedVaultRowsTable createAlias(String alias) {
    return $CachedVaultRowsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeConverter();
}

class CachedVaultRow extends DataClass implements Insertable<CachedVaultRow> {
  final int viewerUserId;
  final int vaultId;
  final int? ownerId;
  final String vaultType;
  final String name;
  final DateTime createdAt;
  const CachedVaultRow(
      {required this.viewerUserId,
      required this.vaultId,
      this.ownerId,
      required this.vaultType,
      required this.name,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['viewer_user_id'] = Variable<int>(viewerUserId);
    map['vault_id'] = Variable<int>(vaultId);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<int>(ownerId);
    }
    map['vault_type'] = Variable<String>(vaultType);
    map['name'] = Variable<String>(name);
    {
      map['created_at'] = Variable<String>(
          $CachedVaultRowsTable.$convertercreatedAt.toSql(createdAt));
    }
    return map;
  }

  CachedVaultRowsCompanion toCompanion(bool nullToAbsent) {
    return CachedVaultRowsCompanion(
      viewerUserId: Value(viewerUserId),
      vaultId: Value(vaultId),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      vaultType: Value(vaultType),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory CachedVaultRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedVaultRow(
      viewerUserId: serializer.fromJson<int>(json['viewerUserId']),
      vaultId: serializer.fromJson<int>(json['vaultId']),
      ownerId: serializer.fromJson<int?>(json['ownerId']),
      vaultType: serializer.fromJson<String>(json['vaultType']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'viewerUserId': serializer.toJson<int>(viewerUserId),
      'vaultId': serializer.toJson<int>(vaultId),
      'ownerId': serializer.toJson<int?>(ownerId),
      'vaultType': serializer.toJson<String>(vaultType),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CachedVaultRow copyWith(
          {int? viewerUserId,
          int? vaultId,
          Value<int?> ownerId = const Value.absent(),
          String? vaultType,
          String? name,
          DateTime? createdAt}) =>
      CachedVaultRow(
        viewerUserId: viewerUserId ?? this.viewerUserId,
        vaultId: vaultId ?? this.vaultId,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        vaultType: vaultType ?? this.vaultType,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  CachedVaultRow copyWithCompanion(CachedVaultRowsCompanion data) {
    return CachedVaultRow(
      viewerUserId: data.viewerUserId.present
          ? data.viewerUserId.value
          : this.viewerUserId,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      vaultType: data.vaultType.present ? data.vaultType.value : this.vaultType,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedVaultRow(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('vaultId: $vaultId, ')
          ..write('ownerId: $ownerId, ')
          ..write('vaultType: $vaultType, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(viewerUserId, vaultId, ownerId, vaultType, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedVaultRow &&
          other.viewerUserId == this.viewerUserId &&
          other.vaultId == this.vaultId &&
          other.ownerId == this.ownerId &&
          other.vaultType == this.vaultType &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class CachedVaultRowsCompanion extends UpdateCompanion<CachedVaultRow> {
  final Value<int> viewerUserId;
  final Value<int> vaultId;
  final Value<int?> ownerId;
  final Value<String> vaultType;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CachedVaultRowsCompanion({
    this.viewerUserId = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.vaultType = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedVaultRowsCompanion.insert({
    required int viewerUserId,
    required int vaultId,
    this.ownerId = const Value.absent(),
    required String vaultType,
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : viewerUserId = Value(viewerUserId),
        vaultId = Value(vaultId),
        vaultType = Value(vaultType),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<CachedVaultRow> custom({
    Expression<int>? viewerUserId,
    Expression<int>? vaultId,
    Expression<int>? ownerId,
    Expression<String>? vaultType,
    Expression<String>? name,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (viewerUserId != null) 'viewer_user_id': viewerUserId,
      if (vaultId != null) 'vault_id': vaultId,
      if (ownerId != null) 'owner_id': ownerId,
      if (vaultType != null) 'vault_type': vaultType,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedVaultRowsCompanion copyWith(
      {Value<int>? viewerUserId,
      Value<int>? vaultId,
      Value<int?>? ownerId,
      Value<String>? vaultType,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CachedVaultRowsCompanion(
      viewerUserId: viewerUserId ?? this.viewerUserId,
      vaultId: vaultId ?? this.vaultId,
      ownerId: ownerId ?? this.ownerId,
      vaultType: vaultType ?? this.vaultType,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (viewerUserId.present) {
      map['viewer_user_id'] = Variable<int>(viewerUserId.value);
    }
    if (vaultId.present) {
      map['vault_id'] = Variable<int>(vaultId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<int>(ownerId.value);
    }
    if (vaultType.present) {
      map['vault_type'] = Variable<String>(vaultType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $CachedVaultRowsTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedVaultRowsCompanion(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('vaultId: $vaultId, ')
          ..write('ownerId: $ownerId, ')
          ..write('vaultType: $vaultType, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedVaultFolderRowsTable extends CachedVaultFolderRows
    with TableInfo<$CachedVaultFolderRowsTable, CachedVaultFolderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedVaultFolderRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _viewerUserIdMeta =
      const VerificationMeta('viewerUserId');
  @override
  late final GeneratedColumn<int> viewerUserId = GeneratedColumn<int>(
      'viewer_user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _folderIdMeta =
      const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
      'folder_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _vaultIdMeta =
      const VerificationMeta('vaultId');
  @override
  late final GeneratedColumn<int> vaultId = GeneratedColumn<int>(
      'vault_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _folderNameMeta =
      const VerificationMeta('folderName');
  @override
  late final GeneratedColumn<String> folderName = GeneratedColumn<String>(
      'folder_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>(
              $CachedVaultFolderRowsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns =>
      [viewerUserId, folderId, vaultId, folderName, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_vault_folder_rows';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedVaultFolderRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('viewer_user_id')) {
      context.handle(
          _viewerUserIdMeta,
          viewerUserId.isAcceptableOrUnknown(
              data['viewer_user_id']!, _viewerUserIdMeta));
    } else if (isInserting) {
      context.missing(_viewerUserIdMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta,
          folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('vault_id')) {
      context.handle(_vaultIdMeta,
          vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta));
    } else if (isInserting) {
      context.missing(_vaultIdMeta);
    }
    if (data.containsKey('folder_name')) {
      context.handle(
          _folderNameMeta,
          folderName.isAcceptableOrUnknown(
              data['folder_name']!, _folderNameMeta));
    } else if (isInserting) {
      context.missing(_folderNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {viewerUserId, folderId};
  @override
  CachedVaultFolderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedVaultFolderRow(
      viewerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}viewer_user_id'])!,
      folderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}folder_id'])!,
      vaultId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vault_id'])!,
      folderName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}folder_name'])!,
      createdAt: $CachedVaultFolderRowsTable.$convertercreatedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}created_at'])!),
    );
  }

  @override
  $CachedVaultFolderRowsTable createAlias(String alias) {
    return $CachedVaultFolderRowsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeConverter();
}

class CachedVaultFolderRow extends DataClass
    implements Insertable<CachedVaultFolderRow> {
  final int viewerUserId;
  final int folderId;
  final int vaultId;
  final String folderName;
  final DateTime createdAt;
  const CachedVaultFolderRow(
      {required this.viewerUserId,
      required this.folderId,
      required this.vaultId,
      required this.folderName,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['viewer_user_id'] = Variable<int>(viewerUserId);
    map['folder_id'] = Variable<int>(folderId);
    map['vault_id'] = Variable<int>(vaultId);
    map['folder_name'] = Variable<String>(folderName);
    {
      map['created_at'] = Variable<String>(
          $CachedVaultFolderRowsTable.$convertercreatedAt.toSql(createdAt));
    }
    return map;
  }

  CachedVaultFolderRowsCompanion toCompanion(bool nullToAbsent) {
    return CachedVaultFolderRowsCompanion(
      viewerUserId: Value(viewerUserId),
      folderId: Value(folderId),
      vaultId: Value(vaultId),
      folderName: Value(folderName),
      createdAt: Value(createdAt),
    );
  }

  factory CachedVaultFolderRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedVaultFolderRow(
      viewerUserId: serializer.fromJson<int>(json['viewerUserId']),
      folderId: serializer.fromJson<int>(json['folderId']),
      vaultId: serializer.fromJson<int>(json['vaultId']),
      folderName: serializer.fromJson<String>(json['folderName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'viewerUserId': serializer.toJson<int>(viewerUserId),
      'folderId': serializer.toJson<int>(folderId),
      'vaultId': serializer.toJson<int>(vaultId),
      'folderName': serializer.toJson<String>(folderName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CachedVaultFolderRow copyWith(
          {int? viewerUserId,
          int? folderId,
          int? vaultId,
          String? folderName,
          DateTime? createdAt}) =>
      CachedVaultFolderRow(
        viewerUserId: viewerUserId ?? this.viewerUserId,
        folderId: folderId ?? this.folderId,
        vaultId: vaultId ?? this.vaultId,
        folderName: folderName ?? this.folderName,
        createdAt: createdAt ?? this.createdAt,
      );
  CachedVaultFolderRow copyWithCompanion(CachedVaultFolderRowsCompanion data) {
    return CachedVaultFolderRow(
      viewerUserId: data.viewerUserId.present
          ? data.viewerUserId.value
          : this.viewerUserId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
      folderName:
          data.folderName.present ? data.folderName.value : this.folderName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedVaultFolderRow(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('folderId: $folderId, ')
          ..write('vaultId: $vaultId, ')
          ..write('folderName: $folderName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(viewerUserId, folderId, vaultId, folderName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedVaultFolderRow &&
          other.viewerUserId == this.viewerUserId &&
          other.folderId == this.folderId &&
          other.vaultId == this.vaultId &&
          other.folderName == this.folderName &&
          other.createdAt == this.createdAt);
}

class CachedVaultFolderRowsCompanion
    extends UpdateCompanion<CachedVaultFolderRow> {
  final Value<int> viewerUserId;
  final Value<int> folderId;
  final Value<int> vaultId;
  final Value<String> folderName;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CachedVaultFolderRowsCompanion({
    this.viewerUserId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.folderName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedVaultFolderRowsCompanion.insert({
    required int viewerUserId,
    required int folderId,
    required int vaultId,
    required String folderName,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : viewerUserId = Value(viewerUserId),
        folderId = Value(folderId),
        vaultId = Value(vaultId),
        folderName = Value(folderName),
        createdAt = Value(createdAt);
  static Insertable<CachedVaultFolderRow> custom({
    Expression<int>? viewerUserId,
    Expression<int>? folderId,
    Expression<int>? vaultId,
    Expression<String>? folderName,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (viewerUserId != null) 'viewer_user_id': viewerUserId,
      if (folderId != null) 'folder_id': folderId,
      if (vaultId != null) 'vault_id': vaultId,
      if (folderName != null) 'folder_name': folderName,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedVaultFolderRowsCompanion copyWith(
      {Value<int>? viewerUserId,
      Value<int>? folderId,
      Value<int>? vaultId,
      Value<String>? folderName,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CachedVaultFolderRowsCompanion(
      viewerUserId: viewerUserId ?? this.viewerUserId,
      folderId: folderId ?? this.folderId,
      vaultId: vaultId ?? this.vaultId,
      folderName: folderName ?? this.folderName,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (viewerUserId.present) {
      map['viewer_user_id'] = Variable<int>(viewerUserId.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (vaultId.present) {
      map['vault_id'] = Variable<int>(vaultId.value);
    }
    if (folderName.present) {
      map['folder_name'] = Variable<String>(folderName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>($CachedVaultFolderRowsTable
          .$convertercreatedAt
          .toSql(createdAt.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedVaultFolderRowsCompanion(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('folderId: $folderId, ')
          ..write('vaultId: $vaultId, ')
          ..write('folderName: $folderName, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedVaultFolderRecipeRowsTable extends CachedVaultFolderRecipeRows
    with
        TableInfo<$CachedVaultFolderRecipeRowsTable,
            CachedVaultFolderRecipeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedVaultFolderRecipeRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _viewerUserIdMeta =
      const VerificationMeta('viewerUserId');
  @override
  late final GeneratedColumn<int> viewerUserId = GeneratedColumn<int>(
      'viewer_user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _folderRecipeIdMeta =
      const VerificationMeta('folderRecipeId');
  @override
  late final GeneratedColumn<int> folderRecipeId = GeneratedColumn<int>(
      'folder_recipe_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _folderIdMeta =
      const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
      'folder_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
      'recipe_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> addedAt =
      GeneratedColumn<String>('added_at', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>(
              $CachedVaultFolderRecipeRowsTable.$converteraddedAt);
  static const VerificationMeta _addedByUserIdMeta =
      const VerificationMeta('addedByUserId');
  @override
  late final GeneratedColumn<int> addedByUserId = GeneratedColumn<int>(
      'added_by_user_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        viewerUserId,
        folderRecipeId,
        folderId,
        recipeId,
        addedAt,
        addedByUserId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_vault_folder_recipe_rows';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedVaultFolderRecipeRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('viewer_user_id')) {
      context.handle(
          _viewerUserIdMeta,
          viewerUserId.isAcceptableOrUnknown(
              data['viewer_user_id']!, _viewerUserIdMeta));
    } else if (isInserting) {
      context.missing(_viewerUserIdMeta);
    }
    if (data.containsKey('folder_recipe_id')) {
      context.handle(
          _folderRecipeIdMeta,
          folderRecipeId.isAcceptableOrUnknown(
              data['folder_recipe_id']!, _folderRecipeIdMeta));
    } else if (isInserting) {
      context.missing(_folderRecipeIdMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta,
          folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('added_by_user_id')) {
      context.handle(
          _addedByUserIdMeta,
          addedByUserId.isAcceptableOrUnknown(
              data['added_by_user_id']!, _addedByUserIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {viewerUserId, folderRecipeId};
  @override
  CachedVaultFolderRecipeRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedVaultFolderRecipeRow(
      viewerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}viewer_user_id'])!,
      folderRecipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}folder_recipe_id'])!,
      folderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}folder_id'])!,
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recipe_id'])!,
      addedAt: $CachedVaultFolderRecipeRowsTable.$converteraddedAt.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}added_at'])!),
      addedByUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}added_by_user_id']),
    );
  }

  @override
  $CachedVaultFolderRecipeRowsTable createAlias(String alias) {
    return $CachedVaultFolderRecipeRowsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converteraddedAt =
      const UtcDateTimeConverter();
}

class CachedVaultFolderRecipeRow extends DataClass
    implements Insertable<CachedVaultFolderRecipeRow> {
  final int viewerUserId;
  final int folderRecipeId;
  final int folderId;
  final int recipeId;
  final DateTime addedAt;
  final int? addedByUserId;
  const CachedVaultFolderRecipeRow(
      {required this.viewerUserId,
      required this.folderRecipeId,
      required this.folderId,
      required this.recipeId,
      required this.addedAt,
      this.addedByUserId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['viewer_user_id'] = Variable<int>(viewerUserId);
    map['folder_recipe_id'] = Variable<int>(folderRecipeId);
    map['folder_id'] = Variable<int>(folderId);
    map['recipe_id'] = Variable<int>(recipeId);
    {
      map['added_at'] = Variable<String>(
          $CachedVaultFolderRecipeRowsTable.$converteraddedAt.toSql(addedAt));
    }
    if (!nullToAbsent || addedByUserId != null) {
      map['added_by_user_id'] = Variable<int>(addedByUserId);
    }
    return map;
  }

  CachedVaultFolderRecipeRowsCompanion toCompanion(bool nullToAbsent) {
    return CachedVaultFolderRecipeRowsCompanion(
      viewerUserId: Value(viewerUserId),
      folderRecipeId: Value(folderRecipeId),
      folderId: Value(folderId),
      recipeId: Value(recipeId),
      addedAt: Value(addedAt),
      addedByUserId: addedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(addedByUserId),
    );
  }

  factory CachedVaultFolderRecipeRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedVaultFolderRecipeRow(
      viewerUserId: serializer.fromJson<int>(json['viewerUserId']),
      folderRecipeId: serializer.fromJson<int>(json['folderRecipeId']),
      folderId: serializer.fromJson<int>(json['folderId']),
      recipeId: serializer.fromJson<int>(json['recipeId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      addedByUserId: serializer.fromJson<int?>(json['addedByUserId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'viewerUserId': serializer.toJson<int>(viewerUserId),
      'folderRecipeId': serializer.toJson<int>(folderRecipeId),
      'folderId': serializer.toJson<int>(folderId),
      'recipeId': serializer.toJson<int>(recipeId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'addedByUserId': serializer.toJson<int?>(addedByUserId),
    };
  }

  CachedVaultFolderRecipeRow copyWith(
          {int? viewerUserId,
          int? folderRecipeId,
          int? folderId,
          int? recipeId,
          DateTime? addedAt,
          Value<int?> addedByUserId = const Value.absent()}) =>
      CachedVaultFolderRecipeRow(
        viewerUserId: viewerUserId ?? this.viewerUserId,
        folderRecipeId: folderRecipeId ?? this.folderRecipeId,
        folderId: folderId ?? this.folderId,
        recipeId: recipeId ?? this.recipeId,
        addedAt: addedAt ?? this.addedAt,
        addedByUserId:
            addedByUserId.present ? addedByUserId.value : this.addedByUserId,
      );
  CachedVaultFolderRecipeRow copyWithCompanion(
      CachedVaultFolderRecipeRowsCompanion data) {
    return CachedVaultFolderRecipeRow(
      viewerUserId: data.viewerUserId.present
          ? data.viewerUserId.value
          : this.viewerUserId,
      folderRecipeId: data.folderRecipeId.present
          ? data.folderRecipeId.value
          : this.folderRecipeId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      addedByUserId: data.addedByUserId.present
          ? data.addedByUserId.value
          : this.addedByUserId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedVaultFolderRecipeRow(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('folderRecipeId: $folderRecipeId, ')
          ..write('folderId: $folderId, ')
          ..write('recipeId: $recipeId, ')
          ..write('addedAt: $addedAt, ')
          ..write('addedByUserId: $addedByUserId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      viewerUserId, folderRecipeId, folderId, recipeId, addedAt, addedByUserId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedVaultFolderRecipeRow &&
          other.viewerUserId == this.viewerUserId &&
          other.folderRecipeId == this.folderRecipeId &&
          other.folderId == this.folderId &&
          other.recipeId == this.recipeId &&
          other.addedAt == this.addedAt &&
          other.addedByUserId == this.addedByUserId);
}

class CachedVaultFolderRecipeRowsCompanion
    extends UpdateCompanion<CachedVaultFolderRecipeRow> {
  final Value<int> viewerUserId;
  final Value<int> folderRecipeId;
  final Value<int> folderId;
  final Value<int> recipeId;
  final Value<DateTime> addedAt;
  final Value<int?> addedByUserId;
  final Value<int> rowid;
  const CachedVaultFolderRecipeRowsCompanion({
    this.viewerUserId = const Value.absent(),
    this.folderRecipeId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.addedByUserId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedVaultFolderRecipeRowsCompanion.insert({
    required int viewerUserId,
    required int folderRecipeId,
    required int folderId,
    required int recipeId,
    required DateTime addedAt,
    this.addedByUserId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : viewerUserId = Value(viewerUserId),
        folderRecipeId = Value(folderRecipeId),
        folderId = Value(folderId),
        recipeId = Value(recipeId),
        addedAt = Value(addedAt);
  static Insertable<CachedVaultFolderRecipeRow> custom({
    Expression<int>? viewerUserId,
    Expression<int>? folderRecipeId,
    Expression<int>? folderId,
    Expression<int>? recipeId,
    Expression<String>? addedAt,
    Expression<int>? addedByUserId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (viewerUserId != null) 'viewer_user_id': viewerUserId,
      if (folderRecipeId != null) 'folder_recipe_id': folderRecipeId,
      if (folderId != null) 'folder_id': folderId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (addedAt != null) 'added_at': addedAt,
      if (addedByUserId != null) 'added_by_user_id': addedByUserId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedVaultFolderRecipeRowsCompanion copyWith(
      {Value<int>? viewerUserId,
      Value<int>? folderRecipeId,
      Value<int>? folderId,
      Value<int>? recipeId,
      Value<DateTime>? addedAt,
      Value<int?>? addedByUserId,
      Value<int>? rowid}) {
    return CachedVaultFolderRecipeRowsCompanion(
      viewerUserId: viewerUserId ?? this.viewerUserId,
      folderRecipeId: folderRecipeId ?? this.folderRecipeId,
      folderId: folderId ?? this.folderId,
      recipeId: recipeId ?? this.recipeId,
      addedAt: addedAt ?? this.addedAt,
      addedByUserId: addedByUserId ?? this.addedByUserId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (viewerUserId.present) {
      map['viewer_user_id'] = Variable<int>(viewerUserId.value);
    }
    if (folderRecipeId.present) {
      map['folder_recipe_id'] = Variable<int>(folderRecipeId.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<String>($CachedVaultFolderRecipeRowsTable
          .$converteraddedAt
          .toSql(addedAt.value));
    }
    if (addedByUserId.present) {
      map['added_by_user_id'] = Variable<int>(addedByUserId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedVaultFolderRecipeRowsCompanion(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('folderRecipeId: $folderRecipeId, ')
          ..write('folderId: $folderId, ')
          ..write('recipeId: $recipeId, ')
          ..write('addedAt: $addedAt, ')
          ..write('addedByUserId: $addedByUserId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedRecipeRowsTable extends CachedRecipeRows
    with TableInfo<$CachedRecipeRowsTable, CachedRecipeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRecipeRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _viewerUserIdMeta =
      const VerificationMeta('viewerUserId');
  @override
  late final GeneratedColumn<int> viewerUserId = GeneratedColumn<int>(
      'viewer_user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
      'recipe_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<int> ownerId = GeneratedColumn<int>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cuisineTypeMeta =
      const VerificationMeta('cuisineType');
  @override
  late final GeneratedColumn<String> cuisineType = GeneratedColumn<String>(
      'cuisine_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _prepTimeMinsMeta =
      const VerificationMeta('prepTimeMins');
  @override
  late final GeneratedColumn<int> prepTimeMins = GeneratedColumn<int>(
      'prep_time_mins', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _cookingTimeMinsMeta =
      const VerificationMeta('cookingTimeMins');
  @override
  late final GeneratedColumn<int> cookingTimeMins = GeneratedColumn<int>(
      'cooking_time_mins', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _servingSizeMeta =
      const VerificationMeta('servingSize');
  @override
  late final GeneratedColumn<int> servingSize = GeneratedColumn<int>(
      'serving_size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _videoUrlMeta =
      const VerificationMeta('videoUrl');
  @override
  late final GeneratedColumn<String> videoUrl = GeneratedColumn<String>(
      'video_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _externalUrlMeta =
      const VerificationMeta('externalUrl');
  @override
  late final GeneratedColumn<String> externalUrl = GeneratedColumn<String>(
      'external_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCommunityPublishedMeta =
      const VerificationMeta('isCommunityPublished');
  @override
  late final GeneratedColumn<bool> isCommunityPublished = GeneratedColumn<bool>(
      'is_community_published', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_community_published" IN (0, 1))'));
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>(
              $CachedRecipeRowsTable.$convertercreatedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> updatedAt =
      GeneratedColumn<String>('updated_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>(
              $CachedRecipeRowsTable.$converterupdatedAtn);
  static const VerificationMeta _isCompleteMeta =
      const VerificationMeta('isComplete');
  @override
  late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>(
      'is_complete', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_complete" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        viewerUserId,
        recipeId,
        ownerId,
        title,
        description,
        cuisineType,
        prepTimeMins,
        cookingTimeMins,
        servingSize,
        photoUrl,
        videoUrl,
        externalUrl,
        isCommunityPublished,
        createdAt,
        updatedAt,
        isComplete
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_recipe_rows';
  @override
  VerificationContext validateIntegrity(Insertable<CachedRecipeRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('viewer_user_id')) {
      context.handle(
          _viewerUserIdMeta,
          viewerUserId.isAcceptableOrUnknown(
              data['viewer_user_id']!, _viewerUserIdMeta));
    } else if (isInserting) {
      context.missing(_viewerUserIdMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('cuisine_type')) {
      context.handle(
          _cuisineTypeMeta,
          cuisineType.isAcceptableOrUnknown(
              data['cuisine_type']!, _cuisineTypeMeta));
    }
    if (data.containsKey('prep_time_mins')) {
      context.handle(
          _prepTimeMinsMeta,
          prepTimeMins.isAcceptableOrUnknown(
              data['prep_time_mins']!, _prepTimeMinsMeta));
    }
    if (data.containsKey('cooking_time_mins')) {
      context.handle(
          _cookingTimeMinsMeta,
          cookingTimeMins.isAcceptableOrUnknown(
              data['cooking_time_mins']!, _cookingTimeMinsMeta));
    }
    if (data.containsKey('serving_size')) {
      context.handle(
          _servingSizeMeta,
          servingSize.isAcceptableOrUnknown(
              data['serving_size']!, _servingSizeMeta));
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('video_url')) {
      context.handle(_videoUrlMeta,
          videoUrl.isAcceptableOrUnknown(data['video_url']!, _videoUrlMeta));
    }
    if (data.containsKey('external_url')) {
      context.handle(
          _externalUrlMeta,
          externalUrl.isAcceptableOrUnknown(
              data['external_url']!, _externalUrlMeta));
    }
    if (data.containsKey('is_community_published')) {
      context.handle(
          _isCommunityPublishedMeta,
          isCommunityPublished.isAcceptableOrUnknown(
              data['is_community_published']!, _isCommunityPublishedMeta));
    } else if (isInserting) {
      context.missing(_isCommunityPublishedMeta);
    }
    if (data.containsKey('is_complete')) {
      context.handle(
          _isCompleteMeta,
          isComplete.isAcceptableOrUnknown(
              data['is_complete']!, _isCompleteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {viewerUserId, recipeId};
  @override
  CachedRecipeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRecipeRow(
      viewerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}viewer_user_id'])!,
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recipe_id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}owner_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      cuisineType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cuisine_type']),
      prepTimeMins: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prep_time_mins']),
      cookingTimeMins: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cooking_time_mins']),
      servingSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}serving_size']),
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url']),
      videoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_url']),
      externalUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}external_url']),
      isCommunityPublished: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_community_published'])!,
      createdAt: $CachedRecipeRowsTable.$convertercreatedAtn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}created_at'])),
      updatedAt: $CachedRecipeRowsTable.$converterupdatedAtn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])),
      isComplete: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_complete'])!,
    );
  }

  @override
  $CachedRecipeRowsTable createAlias(String alias) {
    return $CachedRecipeRowsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $convertercreatedAtn =
      NullAwareTypeConverter.wrap($convertercreatedAt);
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterupdatedAtn =
      NullAwareTypeConverter.wrap($converterupdatedAt);
}

class CachedRecipeRow extends DataClass implements Insertable<CachedRecipeRow> {
  final int viewerUserId;
  final int recipeId;
  final int? ownerId;
  final String title;
  final String? description;
  final String? cuisineType;
  final int? prepTimeMins;
  final int? cookingTimeMins;
  final int? servingSize;
  final String? photoUrl;
  final String? videoUrl;
  final String? externalUrl;
  final bool isCommunityPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isComplete;
  const CachedRecipeRow(
      {required this.viewerUserId,
      required this.recipeId,
      this.ownerId,
      required this.title,
      this.description,
      this.cuisineType,
      this.prepTimeMins,
      this.cookingTimeMins,
      this.servingSize,
      this.photoUrl,
      this.videoUrl,
      this.externalUrl,
      required this.isCommunityPublished,
      this.createdAt,
      this.updatedAt,
      required this.isComplete});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['viewer_user_id'] = Variable<int>(viewerUserId);
    map['recipe_id'] = Variable<int>(recipeId);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<int>(ownerId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || cuisineType != null) {
      map['cuisine_type'] = Variable<String>(cuisineType);
    }
    if (!nullToAbsent || prepTimeMins != null) {
      map['prep_time_mins'] = Variable<int>(prepTimeMins);
    }
    if (!nullToAbsent || cookingTimeMins != null) {
      map['cooking_time_mins'] = Variable<int>(cookingTimeMins);
    }
    if (!nullToAbsent || servingSize != null) {
      map['serving_size'] = Variable<int>(servingSize);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || videoUrl != null) {
      map['video_url'] = Variable<String>(videoUrl);
    }
    if (!nullToAbsent || externalUrl != null) {
      map['external_url'] = Variable<String>(externalUrl);
    }
    map['is_community_published'] = Variable<bool>(isCommunityPublished);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(
          $CachedRecipeRowsTable.$convertercreatedAtn.toSql(createdAt));
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(
          $CachedRecipeRowsTable.$converterupdatedAtn.toSql(updatedAt));
    }
    map['is_complete'] = Variable<bool>(isComplete);
    return map;
  }

  CachedRecipeRowsCompanion toCompanion(bool nullToAbsent) {
    return CachedRecipeRowsCompanion(
      viewerUserId: Value(viewerUserId),
      recipeId: Value(recipeId),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      cuisineType: cuisineType == null && nullToAbsent
          ? const Value.absent()
          : Value(cuisineType),
      prepTimeMins: prepTimeMins == null && nullToAbsent
          ? const Value.absent()
          : Value(prepTimeMins),
      cookingTimeMins: cookingTimeMins == null && nullToAbsent
          ? const Value.absent()
          : Value(cookingTimeMins),
      servingSize: servingSize == null && nullToAbsent
          ? const Value.absent()
          : Value(servingSize),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      videoUrl: videoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(videoUrl),
      externalUrl: externalUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(externalUrl),
      isCommunityPublished: Value(isCommunityPublished),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isComplete: Value(isComplete),
    );
  }

  factory CachedRecipeRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRecipeRow(
      viewerUserId: serializer.fromJson<int>(json['viewerUserId']),
      recipeId: serializer.fromJson<int>(json['recipeId']),
      ownerId: serializer.fromJson<int?>(json['ownerId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      cuisineType: serializer.fromJson<String?>(json['cuisineType']),
      prepTimeMins: serializer.fromJson<int?>(json['prepTimeMins']),
      cookingTimeMins: serializer.fromJson<int?>(json['cookingTimeMins']),
      servingSize: serializer.fromJson<int?>(json['servingSize']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      videoUrl: serializer.fromJson<String?>(json['videoUrl']),
      externalUrl: serializer.fromJson<String?>(json['externalUrl']),
      isCommunityPublished:
          serializer.fromJson<bool>(json['isCommunityPublished']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isComplete: serializer.fromJson<bool>(json['isComplete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'viewerUserId': serializer.toJson<int>(viewerUserId),
      'recipeId': serializer.toJson<int>(recipeId),
      'ownerId': serializer.toJson<int?>(ownerId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'cuisineType': serializer.toJson<String?>(cuisineType),
      'prepTimeMins': serializer.toJson<int?>(prepTimeMins),
      'cookingTimeMins': serializer.toJson<int?>(cookingTimeMins),
      'servingSize': serializer.toJson<int?>(servingSize),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'videoUrl': serializer.toJson<String?>(videoUrl),
      'externalUrl': serializer.toJson<String?>(externalUrl),
      'isCommunityPublished': serializer.toJson<bool>(isCommunityPublished),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isComplete': serializer.toJson<bool>(isComplete),
    };
  }

  CachedRecipeRow copyWith(
          {int? viewerUserId,
          int? recipeId,
          Value<int?> ownerId = const Value.absent(),
          String? title,
          Value<String?> description = const Value.absent(),
          Value<String?> cuisineType = const Value.absent(),
          Value<int?> prepTimeMins = const Value.absent(),
          Value<int?> cookingTimeMins = const Value.absent(),
          Value<int?> servingSize = const Value.absent(),
          Value<String?> photoUrl = const Value.absent(),
          Value<String?> videoUrl = const Value.absent(),
          Value<String?> externalUrl = const Value.absent(),
          bool? isCommunityPublished,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          bool? isComplete}) =>
      CachedRecipeRow(
        viewerUserId: viewerUserId ?? this.viewerUserId,
        recipeId: recipeId ?? this.recipeId,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        cuisineType: cuisineType.present ? cuisineType.value : this.cuisineType,
        prepTimeMins:
            prepTimeMins.present ? prepTimeMins.value : this.prepTimeMins,
        cookingTimeMins: cookingTimeMins.present
            ? cookingTimeMins.value
            : this.cookingTimeMins,
        servingSize: servingSize.present ? servingSize.value : this.servingSize,
        photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
        videoUrl: videoUrl.present ? videoUrl.value : this.videoUrl,
        externalUrl: externalUrl.present ? externalUrl.value : this.externalUrl,
        isCommunityPublished: isCommunityPublished ?? this.isCommunityPublished,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isComplete: isComplete ?? this.isComplete,
      );
  CachedRecipeRow copyWithCompanion(CachedRecipeRowsCompanion data) {
    return CachedRecipeRow(
      viewerUserId: data.viewerUserId.present
          ? data.viewerUserId.value
          : this.viewerUserId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      cuisineType:
          data.cuisineType.present ? data.cuisineType.value : this.cuisineType,
      prepTimeMins: data.prepTimeMins.present
          ? data.prepTimeMins.value
          : this.prepTimeMins,
      cookingTimeMins: data.cookingTimeMins.present
          ? data.cookingTimeMins.value
          : this.cookingTimeMins,
      servingSize:
          data.servingSize.present ? data.servingSize.value : this.servingSize,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      videoUrl: data.videoUrl.present ? data.videoUrl.value : this.videoUrl,
      externalUrl:
          data.externalUrl.present ? data.externalUrl.value : this.externalUrl,
      isCommunityPublished: data.isCommunityPublished.present
          ? data.isCommunityPublished.value
          : this.isCommunityPublished,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isComplete:
          data.isComplete.present ? data.isComplete.value : this.isComplete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecipeRow(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('recipeId: $recipeId, ')
          ..write('ownerId: $ownerId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('cuisineType: $cuisineType, ')
          ..write('prepTimeMins: $prepTimeMins, ')
          ..write('cookingTimeMins: $cookingTimeMins, ')
          ..write('servingSize: $servingSize, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('externalUrl: $externalUrl, ')
          ..write('isCommunityPublished: $isCommunityPublished, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isComplete: $isComplete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      viewerUserId,
      recipeId,
      ownerId,
      title,
      description,
      cuisineType,
      prepTimeMins,
      cookingTimeMins,
      servingSize,
      photoUrl,
      videoUrl,
      externalUrl,
      isCommunityPublished,
      createdAt,
      updatedAt,
      isComplete);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRecipeRow &&
          other.viewerUserId == this.viewerUserId &&
          other.recipeId == this.recipeId &&
          other.ownerId == this.ownerId &&
          other.title == this.title &&
          other.description == this.description &&
          other.cuisineType == this.cuisineType &&
          other.prepTimeMins == this.prepTimeMins &&
          other.cookingTimeMins == this.cookingTimeMins &&
          other.servingSize == this.servingSize &&
          other.photoUrl == this.photoUrl &&
          other.videoUrl == this.videoUrl &&
          other.externalUrl == this.externalUrl &&
          other.isCommunityPublished == this.isCommunityPublished &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isComplete == this.isComplete);
}

class CachedRecipeRowsCompanion extends UpdateCompanion<CachedRecipeRow> {
  final Value<int> viewerUserId;
  final Value<int> recipeId;
  final Value<int?> ownerId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> cuisineType;
  final Value<int?> prepTimeMins;
  final Value<int?> cookingTimeMins;
  final Value<int?> servingSize;
  final Value<String?> photoUrl;
  final Value<String?> videoUrl;
  final Value<String?> externalUrl;
  final Value<bool> isCommunityPublished;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isComplete;
  final Value<int> rowid;
  const CachedRecipeRowsCompanion({
    this.viewerUserId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.cuisineType = const Value.absent(),
    this.prepTimeMins = const Value.absent(),
    this.cookingTimeMins = const Value.absent(),
    this.servingSize = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.externalUrl = const Value.absent(),
    this.isCommunityPublished = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRecipeRowsCompanion.insert({
    required int viewerUserId,
    required int recipeId,
    this.ownerId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.cuisineType = const Value.absent(),
    this.prepTimeMins = const Value.absent(),
    this.cookingTimeMins = const Value.absent(),
    this.servingSize = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.externalUrl = const Value.absent(),
    required bool isCommunityPublished,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : viewerUserId = Value(viewerUserId),
        recipeId = Value(recipeId),
        title = Value(title),
        isCommunityPublished = Value(isCommunityPublished);
  static Insertable<CachedRecipeRow> custom({
    Expression<int>? viewerUserId,
    Expression<int>? recipeId,
    Expression<int>? ownerId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? cuisineType,
    Expression<int>? prepTimeMins,
    Expression<int>? cookingTimeMins,
    Expression<int>? servingSize,
    Expression<String>? photoUrl,
    Expression<String>? videoUrl,
    Expression<String>? externalUrl,
    Expression<bool>? isCommunityPublished,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<bool>? isComplete,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (viewerUserId != null) 'viewer_user_id': viewerUserId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (ownerId != null) 'owner_id': ownerId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (cuisineType != null) 'cuisine_type': cuisineType,
      if (prepTimeMins != null) 'prep_time_mins': prepTimeMins,
      if (cookingTimeMins != null) 'cooking_time_mins': cookingTimeMins,
      if (servingSize != null) 'serving_size': servingSize,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      if (externalUrl != null) 'external_url': externalUrl,
      if (isCommunityPublished != null)
        'is_community_published': isCommunityPublished,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isComplete != null) 'is_complete': isComplete,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRecipeRowsCompanion copyWith(
      {Value<int>? viewerUserId,
      Value<int>? recipeId,
      Value<int?>? ownerId,
      Value<String>? title,
      Value<String?>? description,
      Value<String?>? cuisineType,
      Value<int?>? prepTimeMins,
      Value<int?>? cookingTimeMins,
      Value<int?>? servingSize,
      Value<String?>? photoUrl,
      Value<String?>? videoUrl,
      Value<String?>? externalUrl,
      Value<bool>? isCommunityPublished,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<bool>? isComplete,
      Value<int>? rowid}) {
    return CachedRecipeRowsCompanion(
      viewerUserId: viewerUserId ?? this.viewerUserId,
      recipeId: recipeId ?? this.recipeId,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      cuisineType: cuisineType ?? this.cuisineType,
      prepTimeMins: prepTimeMins ?? this.prepTimeMins,
      cookingTimeMins: cookingTimeMins ?? this.cookingTimeMins,
      servingSize: servingSize ?? this.servingSize,
      photoUrl: photoUrl ?? this.photoUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      externalUrl: externalUrl ?? this.externalUrl,
      isCommunityPublished: isCommunityPublished ?? this.isCommunityPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isComplete: isComplete ?? this.isComplete,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (viewerUserId.present) {
      map['viewer_user_id'] = Variable<int>(viewerUserId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<int>(ownerId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (cuisineType.present) {
      map['cuisine_type'] = Variable<String>(cuisineType.value);
    }
    if (prepTimeMins.present) {
      map['prep_time_mins'] = Variable<int>(prepTimeMins.value);
    }
    if (cookingTimeMins.present) {
      map['cooking_time_mins'] = Variable<int>(cookingTimeMins.value);
    }
    if (servingSize.present) {
      map['serving_size'] = Variable<int>(servingSize.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (videoUrl.present) {
      map['video_url'] = Variable<String>(videoUrl.value);
    }
    if (externalUrl.present) {
      map['external_url'] = Variable<String>(externalUrl.value);
    }
    if (isCommunityPublished.present) {
      map['is_community_published'] =
          Variable<bool>(isCommunityPublished.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $CachedRecipeRowsTable.$convertercreatedAtn.toSql(createdAt.value));
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
          $CachedRecipeRowsTable.$converterupdatedAtn.toSql(updatedAt.value));
    }
    if (isComplete.present) {
      map['is_complete'] = Variable<bool>(isComplete.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecipeRowsCompanion(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('recipeId: $recipeId, ')
          ..write('ownerId: $ownerId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('cuisineType: $cuisineType, ')
          ..write('prepTimeMins: $prepTimeMins, ')
          ..write('cookingTimeMins: $cookingTimeMins, ')
          ..write('servingSize: $servingSize, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('externalUrl: $externalUrl, ')
          ..write('isCommunityPublished: $isCommunityPublished, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isComplete: $isComplete, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedRecipeIngredientRowsTable extends CachedRecipeIngredientRows
    with
        TableInfo<$CachedRecipeIngredientRowsTable, CachedRecipeIngredientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRecipeIngredientRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _viewerUserIdMeta =
      const VerificationMeta('viewerUserId');
  @override
  late final GeneratedColumn<int> viewerUserId = GeneratedColumn<int>(
      'viewer_user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
      'recipe_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lineIndexMeta =
      const VerificationMeta('lineIndex');
  @override
  late final GeneratedColumn<int> lineIndex = GeneratedColumn<int>(
      'line_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ingredientIdMeta =
      const VerificationMeta('ingredientId');
  @override
  late final GeneratedColumn<int> ingredientId = GeneratedColumn<int>(
      'ingredient_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ingIdMeta = const VerificationMeta('ingId');
  @override
  late final GeneratedColumn<int> ingId = GeneratedColumn<int>(
      'ing_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        viewerUserId,
        recipeId,
        lineIndex,
        ingredientId,
        ingId,
        name,
        quantity,
        unit,
        sortOrder
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_recipe_ingredient_rows';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedRecipeIngredientRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('viewer_user_id')) {
      context.handle(
          _viewerUserIdMeta,
          viewerUserId.isAcceptableOrUnknown(
              data['viewer_user_id']!, _viewerUserIdMeta));
    } else if (isInserting) {
      context.missing(_viewerUserIdMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('line_index')) {
      context.handle(_lineIndexMeta,
          lineIndex.isAcceptableOrUnknown(data['line_index']!, _lineIndexMeta));
    } else if (isInserting) {
      context.missing(_lineIndexMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
          _ingredientIdMeta,
          ingredientId.isAcceptableOrUnknown(
              data['ingredient_id']!, _ingredientIdMeta));
    }
    if (data.containsKey('ing_id')) {
      context.handle(
          _ingIdMeta, ingId.isAcceptableOrUnknown(data['ing_id']!, _ingIdMeta));
    } else if (isInserting) {
      context.missing(_ingIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {viewerUserId, recipeId, lineIndex};
  @override
  CachedRecipeIngredientRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRecipeIngredientRow(
      viewerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}viewer_user_id'])!,
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recipe_id'])!,
      lineIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_index'])!,
      ingredientId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ingredient_id']),
      ingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ing_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity']),
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $CachedRecipeIngredientRowsTable createAlias(String alias) {
    return $CachedRecipeIngredientRowsTable(attachedDatabase, alias);
  }
}

class CachedRecipeIngredientRow extends DataClass
    implements Insertable<CachedRecipeIngredientRow> {
  final int viewerUserId;
  final int recipeId;
  final int lineIndex;
  final int? ingredientId;
  final int ingId;
  final String? name;
  final double? quantity;
  final String? unit;
  final int sortOrder;
  const CachedRecipeIngredientRow(
      {required this.viewerUserId,
      required this.recipeId,
      required this.lineIndex,
      this.ingredientId,
      required this.ingId,
      this.name,
      this.quantity,
      this.unit,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['viewer_user_id'] = Variable<int>(viewerUserId);
    map['recipe_id'] = Variable<int>(recipeId);
    map['line_index'] = Variable<int>(lineIndex);
    if (!nullToAbsent || ingredientId != null) {
      map['ingredient_id'] = Variable<int>(ingredientId);
    }
    map['ing_id'] = Variable<int>(ingId);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CachedRecipeIngredientRowsCompanion toCompanion(bool nullToAbsent) {
    return CachedRecipeIngredientRowsCompanion(
      viewerUserId: Value(viewerUserId),
      recipeId: Value(recipeId),
      lineIndex: Value(lineIndex),
      ingredientId: ingredientId == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientId),
      ingId: Value(ingId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      sortOrder: Value(sortOrder),
    );
  }

  factory CachedRecipeIngredientRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRecipeIngredientRow(
      viewerUserId: serializer.fromJson<int>(json['viewerUserId']),
      recipeId: serializer.fromJson<int>(json['recipeId']),
      lineIndex: serializer.fromJson<int>(json['lineIndex']),
      ingredientId: serializer.fromJson<int?>(json['ingredientId']),
      ingId: serializer.fromJson<int>(json['ingId']),
      name: serializer.fromJson<String?>(json['name']),
      quantity: serializer.fromJson<double?>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'viewerUserId': serializer.toJson<int>(viewerUserId),
      'recipeId': serializer.toJson<int>(recipeId),
      'lineIndex': serializer.toJson<int>(lineIndex),
      'ingredientId': serializer.toJson<int?>(ingredientId),
      'ingId': serializer.toJson<int>(ingId),
      'name': serializer.toJson<String?>(name),
      'quantity': serializer.toJson<double?>(quantity),
      'unit': serializer.toJson<String?>(unit),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CachedRecipeIngredientRow copyWith(
          {int? viewerUserId,
          int? recipeId,
          int? lineIndex,
          Value<int?> ingredientId = const Value.absent(),
          int? ingId,
          Value<String?> name = const Value.absent(),
          Value<double?> quantity = const Value.absent(),
          Value<String?> unit = const Value.absent(),
          int? sortOrder}) =>
      CachedRecipeIngredientRow(
        viewerUserId: viewerUserId ?? this.viewerUserId,
        recipeId: recipeId ?? this.recipeId,
        lineIndex: lineIndex ?? this.lineIndex,
        ingredientId:
            ingredientId.present ? ingredientId.value : this.ingredientId,
        ingId: ingId ?? this.ingId,
        name: name.present ? name.value : this.name,
        quantity: quantity.present ? quantity.value : this.quantity,
        unit: unit.present ? unit.value : this.unit,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  CachedRecipeIngredientRow copyWithCompanion(
      CachedRecipeIngredientRowsCompanion data) {
    return CachedRecipeIngredientRow(
      viewerUserId: data.viewerUserId.present
          ? data.viewerUserId.value
          : this.viewerUserId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      lineIndex: data.lineIndex.present ? data.lineIndex.value : this.lineIndex,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      ingId: data.ingId.present ? data.ingId.value : this.ingId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecipeIngredientRow(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('recipeId: $recipeId, ')
          ..write('lineIndex: $lineIndex, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('ingId: $ingId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(viewerUserId, recipeId, lineIndex,
      ingredientId, ingId, name, quantity, unit, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRecipeIngredientRow &&
          other.viewerUserId == this.viewerUserId &&
          other.recipeId == this.recipeId &&
          other.lineIndex == this.lineIndex &&
          other.ingredientId == this.ingredientId &&
          other.ingId == this.ingId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.sortOrder == this.sortOrder);
}

class CachedRecipeIngredientRowsCompanion
    extends UpdateCompanion<CachedRecipeIngredientRow> {
  final Value<int> viewerUserId;
  final Value<int> recipeId;
  final Value<int> lineIndex;
  final Value<int?> ingredientId;
  final Value<int> ingId;
  final Value<String?> name;
  final Value<double?> quantity;
  final Value<String?> unit;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CachedRecipeIngredientRowsCompanion({
    this.viewerUserId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.lineIndex = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.ingId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRecipeIngredientRowsCompanion.insert({
    required int viewerUserId,
    required int recipeId,
    required int lineIndex,
    this.ingredientId = const Value.absent(),
    required int ingId,
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    required int sortOrder,
    this.rowid = const Value.absent(),
  })  : viewerUserId = Value(viewerUserId),
        recipeId = Value(recipeId),
        lineIndex = Value(lineIndex),
        ingId = Value(ingId),
        sortOrder = Value(sortOrder);
  static Insertable<CachedRecipeIngredientRow> custom({
    Expression<int>? viewerUserId,
    Expression<int>? recipeId,
    Expression<int>? lineIndex,
    Expression<int>? ingredientId,
    Expression<int>? ingId,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (viewerUserId != null) 'viewer_user_id': viewerUserId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (lineIndex != null) 'line_index': lineIndex,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (ingId != null) 'ing_id': ingId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRecipeIngredientRowsCompanion copyWith(
      {Value<int>? viewerUserId,
      Value<int>? recipeId,
      Value<int>? lineIndex,
      Value<int?>? ingredientId,
      Value<int>? ingId,
      Value<String?>? name,
      Value<double?>? quantity,
      Value<String?>? unit,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return CachedRecipeIngredientRowsCompanion(
      viewerUserId: viewerUserId ?? this.viewerUserId,
      recipeId: recipeId ?? this.recipeId,
      lineIndex: lineIndex ?? this.lineIndex,
      ingredientId: ingredientId ?? this.ingredientId,
      ingId: ingId ?? this.ingId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (viewerUserId.present) {
      map['viewer_user_id'] = Variable<int>(viewerUserId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (lineIndex.present) {
      map['line_index'] = Variable<int>(lineIndex.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<int>(ingredientId.value);
    }
    if (ingId.present) {
      map['ing_id'] = Variable<int>(ingId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecipeIngredientRowsCompanion(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('recipeId: $recipeId, ')
          ..write('lineIndex: $lineIndex, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('ingId: $ingId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedRecipeStepRowsTable extends CachedRecipeStepRows
    with TableInfo<$CachedRecipeStepRowsTable, CachedRecipeStepRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRecipeStepRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _viewerUserIdMeta =
      const VerificationMeta('viewerUserId');
  @override
  late final GeneratedColumn<int> viewerUserId = GeneratedColumn<int>(
      'viewer_user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
      'recipe_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lineIndexMeta =
      const VerificationMeta('lineIndex');
  @override
  late final GeneratedColumn<int> lineIndex = GeneratedColumn<int>(
      'line_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _stepIdMeta = const VerificationMeta('stepId');
  @override
  late final GeneratedColumn<int> stepId = GeneratedColumn<int>(
      'step_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _stepNrMeta = const VerificationMeta('stepNr');
  @override
  late final GeneratedColumn<int> stepNr = GeneratedColumn<int>(
      'step_nr', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [viewerUserId, recipeId, lineIndex, stepId, stepNr, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_recipe_step_rows';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedRecipeStepRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('viewer_user_id')) {
      context.handle(
          _viewerUserIdMeta,
          viewerUserId.isAcceptableOrUnknown(
              data['viewer_user_id']!, _viewerUserIdMeta));
    } else if (isInserting) {
      context.missing(_viewerUserIdMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('line_index')) {
      context.handle(_lineIndexMeta,
          lineIndex.isAcceptableOrUnknown(data['line_index']!, _lineIndexMeta));
    } else if (isInserting) {
      context.missing(_lineIndexMeta);
    }
    if (data.containsKey('step_id')) {
      context.handle(_stepIdMeta,
          stepId.isAcceptableOrUnknown(data['step_id']!, _stepIdMeta));
    }
    if (data.containsKey('step_nr')) {
      context.handle(_stepNrMeta,
          stepNr.isAcceptableOrUnknown(data['step_nr']!, _stepNrMeta));
    } else if (isInserting) {
      context.missing(_stepNrMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {viewerUserId, recipeId, lineIndex};
  @override
  CachedRecipeStepRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRecipeStepRow(
      viewerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}viewer_user_id'])!,
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recipe_id'])!,
      lineIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_index'])!,
      stepId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}step_id']),
      stepNr: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}step_nr'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
    );
  }

  @override
  $CachedRecipeStepRowsTable createAlias(String alias) {
    return $CachedRecipeStepRowsTable(attachedDatabase, alias);
  }
}

class CachedRecipeStepRow extends DataClass
    implements Insertable<CachedRecipeStepRow> {
  final int viewerUserId;
  final int recipeId;
  final int lineIndex;
  final int? stepId;
  final int stepNr;
  final String content;
  const CachedRecipeStepRow(
      {required this.viewerUserId,
      required this.recipeId,
      required this.lineIndex,
      this.stepId,
      required this.stepNr,
      required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['viewer_user_id'] = Variable<int>(viewerUserId);
    map['recipe_id'] = Variable<int>(recipeId);
    map['line_index'] = Variable<int>(lineIndex);
    if (!nullToAbsent || stepId != null) {
      map['step_id'] = Variable<int>(stepId);
    }
    map['step_nr'] = Variable<int>(stepNr);
    map['content'] = Variable<String>(content);
    return map;
  }

  CachedRecipeStepRowsCompanion toCompanion(bool nullToAbsent) {
    return CachedRecipeStepRowsCompanion(
      viewerUserId: Value(viewerUserId),
      recipeId: Value(recipeId),
      lineIndex: Value(lineIndex),
      stepId:
          stepId == null && nullToAbsent ? const Value.absent() : Value(stepId),
      stepNr: Value(stepNr),
      content: Value(content),
    );
  }

  factory CachedRecipeStepRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRecipeStepRow(
      viewerUserId: serializer.fromJson<int>(json['viewerUserId']),
      recipeId: serializer.fromJson<int>(json['recipeId']),
      lineIndex: serializer.fromJson<int>(json['lineIndex']),
      stepId: serializer.fromJson<int?>(json['stepId']),
      stepNr: serializer.fromJson<int>(json['stepNr']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'viewerUserId': serializer.toJson<int>(viewerUserId),
      'recipeId': serializer.toJson<int>(recipeId),
      'lineIndex': serializer.toJson<int>(lineIndex),
      'stepId': serializer.toJson<int?>(stepId),
      'stepNr': serializer.toJson<int>(stepNr),
      'content': serializer.toJson<String>(content),
    };
  }

  CachedRecipeStepRow copyWith(
          {int? viewerUserId,
          int? recipeId,
          int? lineIndex,
          Value<int?> stepId = const Value.absent(),
          int? stepNr,
          String? content}) =>
      CachedRecipeStepRow(
        viewerUserId: viewerUserId ?? this.viewerUserId,
        recipeId: recipeId ?? this.recipeId,
        lineIndex: lineIndex ?? this.lineIndex,
        stepId: stepId.present ? stepId.value : this.stepId,
        stepNr: stepNr ?? this.stepNr,
        content: content ?? this.content,
      );
  CachedRecipeStepRow copyWithCompanion(CachedRecipeStepRowsCompanion data) {
    return CachedRecipeStepRow(
      viewerUserId: data.viewerUserId.present
          ? data.viewerUserId.value
          : this.viewerUserId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      lineIndex: data.lineIndex.present ? data.lineIndex.value : this.lineIndex,
      stepId: data.stepId.present ? data.stepId.value : this.stepId,
      stepNr: data.stepNr.present ? data.stepNr.value : this.stepNr,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecipeStepRow(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('recipeId: $recipeId, ')
          ..write('lineIndex: $lineIndex, ')
          ..write('stepId: $stepId, ')
          ..write('stepNr: $stepNr, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(viewerUserId, recipeId, lineIndex, stepId, stepNr, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRecipeStepRow &&
          other.viewerUserId == this.viewerUserId &&
          other.recipeId == this.recipeId &&
          other.lineIndex == this.lineIndex &&
          other.stepId == this.stepId &&
          other.stepNr == this.stepNr &&
          other.content == this.content);
}

class CachedRecipeStepRowsCompanion
    extends UpdateCompanion<CachedRecipeStepRow> {
  final Value<int> viewerUserId;
  final Value<int> recipeId;
  final Value<int> lineIndex;
  final Value<int?> stepId;
  final Value<int> stepNr;
  final Value<String> content;
  final Value<int> rowid;
  const CachedRecipeStepRowsCompanion({
    this.viewerUserId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.lineIndex = const Value.absent(),
    this.stepId = const Value.absent(),
    this.stepNr = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRecipeStepRowsCompanion.insert({
    required int viewerUserId,
    required int recipeId,
    required int lineIndex,
    this.stepId = const Value.absent(),
    required int stepNr,
    required String content,
    this.rowid = const Value.absent(),
  })  : viewerUserId = Value(viewerUserId),
        recipeId = Value(recipeId),
        lineIndex = Value(lineIndex),
        stepNr = Value(stepNr),
        content = Value(content);
  static Insertable<CachedRecipeStepRow> custom({
    Expression<int>? viewerUserId,
    Expression<int>? recipeId,
    Expression<int>? lineIndex,
    Expression<int>? stepId,
    Expression<int>? stepNr,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (viewerUserId != null) 'viewer_user_id': viewerUserId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (lineIndex != null) 'line_index': lineIndex,
      if (stepId != null) 'step_id': stepId,
      if (stepNr != null) 'step_nr': stepNr,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRecipeStepRowsCompanion copyWith(
      {Value<int>? viewerUserId,
      Value<int>? recipeId,
      Value<int>? lineIndex,
      Value<int?>? stepId,
      Value<int>? stepNr,
      Value<String>? content,
      Value<int>? rowid}) {
    return CachedRecipeStepRowsCompanion(
      viewerUserId: viewerUserId ?? this.viewerUserId,
      recipeId: recipeId ?? this.recipeId,
      lineIndex: lineIndex ?? this.lineIndex,
      stepId: stepId ?? this.stepId,
      stepNr: stepNr ?? this.stepNr,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (viewerUserId.present) {
      map['viewer_user_id'] = Variable<int>(viewerUserId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (lineIndex.present) {
      map['line_index'] = Variable<int>(lineIndex.value);
    }
    if (stepId.present) {
      map['step_id'] = Variable<int>(stepId.value);
    }
    if (stepNr.present) {
      map['step_nr'] = Variable<int>(stepNr.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecipeStepRowsCompanion(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('recipeId: $recipeId, ')
          ..write('lineIndex: $lineIndex, ')
          ..write('stepId: $stepId, ')
          ..write('stepNr: $stepNr, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheSyncMetadataRowsTable extends CacheSyncMetadataRows
    with TableInfo<$CacheSyncMetadataRowsTable, CacheSyncMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheSyncMetadataRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _viewerUserIdMeta =
      const VerificationMeta('viewerUserId');
  @override
  late final GeneratedColumn<int> viewerUserId = GeneratedColumn<int>(
      'viewer_user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _collectionMeta =
      const VerificationMeta('collection');
  @override
  late final GeneratedColumn<String> collection = GeneratedColumn<String>(
      'collection', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scopeIdMeta =
      const VerificationMeta('scopeId');
  @override
  late final GeneratedColumn<String> scopeId = GeneratedColumn<String>(
      'scope_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> lastSyncedAt =
      GeneratedColumn<String>('last_synced_at', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>(
              $CacheSyncMetadataRowsTable.$converterlastSyncedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String>
      lastAccessedAt = GeneratedColumn<String>(
              'last_accessed_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>(
              $CacheSyncMetadataRowsTable.$converterlastAccessedAtn);
  @override
  List<GeneratedColumn> get $columns =>
      [viewerUserId, collection, scopeId, lastSyncedAt, lastAccessedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_sync_metadata_rows';
  @override
  VerificationContext validateIntegrity(
      Insertable<CacheSyncMetadataRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('viewer_user_id')) {
      context.handle(
          _viewerUserIdMeta,
          viewerUserId.isAcceptableOrUnknown(
              data['viewer_user_id']!, _viewerUserIdMeta));
    } else if (isInserting) {
      context.missing(_viewerUserIdMeta);
    }
    if (data.containsKey('collection')) {
      context.handle(
          _collectionMeta,
          collection.isAcceptableOrUnknown(
              data['collection']!, _collectionMeta));
    } else if (isInserting) {
      context.missing(_collectionMeta);
    }
    if (data.containsKey('scope_id')) {
      context.handle(_scopeIdMeta,
          scopeId.isAcceptableOrUnknown(data['scope_id']!, _scopeIdMeta));
    } else if (isInserting) {
      context.missing(_scopeIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {viewerUserId, collection, scopeId};
  @override
  CacheSyncMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheSyncMetadataRow(
      viewerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}viewer_user_id'])!,
      collection: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collection'])!,
      scopeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope_id'])!,
      lastSyncedAt: $CacheSyncMetadataRowsTable.$converterlastSyncedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}last_synced_at'])!),
      lastAccessedAt: $CacheSyncMetadataRowsTable.$converterlastAccessedAtn
          .fromSql(attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}last_accessed_at'])),
    );
  }

  @override
  $CacheSyncMetadataRowsTable createAlias(String alias) {
    return $CacheSyncMetadataRowsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterlastSyncedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterlastAccessedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterlastAccessedAtn =
      NullAwareTypeConverter.wrap($converterlastAccessedAt);
}

class CacheSyncMetadataRow extends DataClass
    implements Insertable<CacheSyncMetadataRow> {
  final int viewerUserId;
  final String collection;
  final String scopeId;
  final DateTime lastSyncedAt;
  final DateTime? lastAccessedAt;
  const CacheSyncMetadataRow(
      {required this.viewerUserId,
      required this.collection,
      required this.scopeId,
      required this.lastSyncedAt,
      this.lastAccessedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['viewer_user_id'] = Variable<int>(viewerUserId);
    map['collection'] = Variable<String>(collection);
    map['scope_id'] = Variable<String>(scopeId);
    {
      map['last_synced_at'] = Variable<String>($CacheSyncMetadataRowsTable
          .$converterlastSyncedAt
          .toSql(lastSyncedAt));
    }
    if (!nullToAbsent || lastAccessedAt != null) {
      map['last_accessed_at'] = Variable<String>($CacheSyncMetadataRowsTable
          .$converterlastAccessedAtn
          .toSql(lastAccessedAt));
    }
    return map;
  }

  CacheSyncMetadataRowsCompanion toCompanion(bool nullToAbsent) {
    return CacheSyncMetadataRowsCompanion(
      viewerUserId: Value(viewerUserId),
      collection: Value(collection),
      scopeId: Value(scopeId),
      lastSyncedAt: Value(lastSyncedAt),
      lastAccessedAt: lastAccessedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccessedAt),
    );
  }

  factory CacheSyncMetadataRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheSyncMetadataRow(
      viewerUserId: serializer.fromJson<int>(json['viewerUserId']),
      collection: serializer.fromJson<String>(json['collection']),
      scopeId: serializer.fromJson<String>(json['scopeId']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
      lastAccessedAt: serializer.fromJson<DateTime?>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'viewerUserId': serializer.toJson<int>(viewerUserId),
      'collection': serializer.toJson<String>(collection),
      'scopeId': serializer.toJson<String>(scopeId),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
      'lastAccessedAt': serializer.toJson<DateTime?>(lastAccessedAt),
    };
  }

  CacheSyncMetadataRow copyWith(
          {int? viewerUserId,
          String? collection,
          String? scopeId,
          DateTime? lastSyncedAt,
          Value<DateTime?> lastAccessedAt = const Value.absent()}) =>
      CacheSyncMetadataRow(
        viewerUserId: viewerUserId ?? this.viewerUserId,
        collection: collection ?? this.collection,
        scopeId: scopeId ?? this.scopeId,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        lastAccessedAt:
            lastAccessedAt.present ? lastAccessedAt.value : this.lastAccessedAt,
      );
  CacheSyncMetadataRow copyWithCompanion(CacheSyncMetadataRowsCompanion data) {
    return CacheSyncMetadataRow(
      viewerUserId: data.viewerUserId.present
          ? data.viewerUserId.value
          : this.viewerUserId,
      collection:
          data.collection.present ? data.collection.value : this.collection,
      scopeId: data.scopeId.present ? data.scopeId.value : this.scopeId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheSyncMetadataRow(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('collection: $collection, ')
          ..write('scopeId: $scopeId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      viewerUserId, collection, scopeId, lastSyncedAt, lastAccessedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheSyncMetadataRow &&
          other.viewerUserId == this.viewerUserId &&
          other.collection == this.collection &&
          other.scopeId == this.scopeId &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class CacheSyncMetadataRowsCompanion
    extends UpdateCompanion<CacheSyncMetadataRow> {
  final Value<int> viewerUserId;
  final Value<String> collection;
  final Value<String> scopeId;
  final Value<DateTime> lastSyncedAt;
  final Value<DateTime?> lastAccessedAt;
  final Value<int> rowid;
  const CacheSyncMetadataRowsCompanion({
    this.viewerUserId = const Value.absent(),
    this.collection = const Value.absent(),
    this.scopeId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheSyncMetadataRowsCompanion.insert({
    required int viewerUserId,
    required String collection,
    required String scopeId,
    required DateTime lastSyncedAt,
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : viewerUserId = Value(viewerUserId),
        collection = Value(collection),
        scopeId = Value(scopeId),
        lastSyncedAt = Value(lastSyncedAt);
  static Insertable<CacheSyncMetadataRow> custom({
    Expression<int>? viewerUserId,
    Expression<String>? collection,
    Expression<String>? scopeId,
    Expression<String>? lastSyncedAt,
    Expression<String>? lastAccessedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (viewerUserId != null) 'viewer_user_id': viewerUserId,
      if (collection != null) 'collection': collection,
      if (scopeId != null) 'scope_id': scopeId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheSyncMetadataRowsCompanion copyWith(
      {Value<int>? viewerUserId,
      Value<String>? collection,
      Value<String>? scopeId,
      Value<DateTime>? lastSyncedAt,
      Value<DateTime?>? lastAccessedAt,
      Value<int>? rowid}) {
    return CacheSyncMetadataRowsCompanion(
      viewerUserId: viewerUserId ?? this.viewerUserId,
      collection: collection ?? this.collection,
      scopeId: scopeId ?? this.scopeId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (viewerUserId.present) {
      map['viewer_user_id'] = Variable<int>(viewerUserId.value);
    }
    if (collection.present) {
      map['collection'] = Variable<String>(collection.value);
    }
    if (scopeId.present) {
      map['scope_id'] = Variable<String>(scopeId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<String>($CacheSyncMetadataRowsTable
          .$converterlastSyncedAt
          .toSql(lastSyncedAt.value));
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<String>($CacheSyncMetadataRowsTable
          .$converterlastAccessedAtn
          .toSql(lastAccessedAt.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheSyncMetadataRowsCompanion(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('collection: $collection, ')
          ..write('scopeId: $scopeId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedPantryIngredientRowsTable extends CachedPantryIngredientRows
    with
        TableInfo<$CachedPantryIngredientRowsTable, CachedPantryIngredientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPantryIngredientRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _viewerUserIdMeta =
      const VerificationMeta('viewerUserId');
  @override
  late final GeneratedColumn<int> viewerUserId = GeneratedColumn<int>(
      'viewer_user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rowKeyMeta = const VerificationMeta('rowKey');
  @override
  late final GeneratedColumn<String> rowKey = GeneratedColumn<String>(
      'row_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pantryIngredientIdMeta =
      const VerificationMeta('pantryIngredientId');
  @override
  late final GeneratedColumn<int> pantryIngredientId = GeneratedColumn<int>(
      'pantry_ingredient_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ingIdMeta = const VerificationMeta('ingId');
  @override
  late final GeneratedColumn<int> ingId = GeneratedColumn<int>(
      'ing_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailsMeta =
      const VerificationMeta('details');
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
      'details', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
      'quantity', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        viewerUserId,
        rowKey,
        pantryIngredientId,
        ingId,
        name,
        details,
        category,
        status,
        quantity,
        unit
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_pantry_ingredient_rows';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedPantryIngredientRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('viewer_user_id')) {
      context.handle(
          _viewerUserIdMeta,
          viewerUserId.isAcceptableOrUnknown(
              data['viewer_user_id']!, _viewerUserIdMeta));
    } else if (isInserting) {
      context.missing(_viewerUserIdMeta);
    }
    if (data.containsKey('row_key')) {
      context.handle(_rowKeyMeta,
          rowKey.isAcceptableOrUnknown(data['row_key']!, _rowKeyMeta));
    } else if (isInserting) {
      context.missing(_rowKeyMeta);
    }
    if (data.containsKey('pantry_ingredient_id')) {
      context.handle(
          _pantryIngredientIdMeta,
          pantryIngredientId.isAcceptableOrUnknown(
              data['pantry_ingredient_id']!, _pantryIngredientIdMeta));
    }
    if (data.containsKey('ing_id')) {
      context.handle(
          _ingIdMeta, ingId.isAcceptableOrUnknown(data['ing_id']!, _ingIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('details')) {
      context.handle(_detailsMeta,
          details.isAcceptableOrUnknown(data['details']!, _detailsMeta));
    } else if (isInserting) {
      context.missing(_detailsMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {viewerUserId, rowKey};
  @override
  CachedPantryIngredientRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPantryIngredientRow(
      viewerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}viewer_user_id'])!,
      rowKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}row_key'])!,
      pantryIngredientId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}pantry_ingredient_id']),
      ingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ing_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      details: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantity']),
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit']),
    );
  }

  @override
  $CachedPantryIngredientRowsTable createAlias(String alias) {
    return $CachedPantryIngredientRowsTable(attachedDatabase, alias);
  }
}

class CachedPantryIngredientRow extends DataClass
    implements Insertable<CachedPantryIngredientRow> {
  final int viewerUserId;
  final String rowKey;
  final int? pantryIngredientId;
  final int? ingId;
  final String name;
  final String details;
  final String category;
  final String status;
  final String? quantity;
  final String? unit;
  const CachedPantryIngredientRow(
      {required this.viewerUserId,
      required this.rowKey,
      this.pantryIngredientId,
      this.ingId,
      required this.name,
      required this.details,
      required this.category,
      required this.status,
      this.quantity,
      this.unit});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['viewer_user_id'] = Variable<int>(viewerUserId);
    map['row_key'] = Variable<String>(rowKey);
    if (!nullToAbsent || pantryIngredientId != null) {
      map['pantry_ingredient_id'] = Variable<int>(pantryIngredientId);
    }
    if (!nullToAbsent || ingId != null) {
      map['ing_id'] = Variable<int>(ingId);
    }
    map['name'] = Variable<String>(name);
    map['details'] = Variable<String>(details);
    map['category'] = Variable<String>(category);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<String>(quantity);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    return map;
  }

  CachedPantryIngredientRowsCompanion toCompanion(bool nullToAbsent) {
    return CachedPantryIngredientRowsCompanion(
      viewerUserId: Value(viewerUserId),
      rowKey: Value(rowKey),
      pantryIngredientId: pantryIngredientId == null && nullToAbsent
          ? const Value.absent()
          : Value(pantryIngredientId),
      ingId:
          ingId == null && nullToAbsent ? const Value.absent() : Value(ingId),
      name: Value(name),
      details: Value(details),
      category: Value(category),
      status: Value(status),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
    );
  }

  factory CachedPantryIngredientRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPantryIngredientRow(
      viewerUserId: serializer.fromJson<int>(json['viewerUserId']),
      rowKey: serializer.fromJson<String>(json['rowKey']),
      pantryIngredientId: serializer.fromJson<int?>(json['pantryIngredientId']),
      ingId: serializer.fromJson<int?>(json['ingId']),
      name: serializer.fromJson<String>(json['name']),
      details: serializer.fromJson<String>(json['details']),
      category: serializer.fromJson<String>(json['category']),
      status: serializer.fromJson<String>(json['status']),
      quantity: serializer.fromJson<String?>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'viewerUserId': serializer.toJson<int>(viewerUserId),
      'rowKey': serializer.toJson<String>(rowKey),
      'pantryIngredientId': serializer.toJson<int?>(pantryIngredientId),
      'ingId': serializer.toJson<int?>(ingId),
      'name': serializer.toJson<String>(name),
      'details': serializer.toJson<String>(details),
      'category': serializer.toJson<String>(category),
      'status': serializer.toJson<String>(status),
      'quantity': serializer.toJson<String?>(quantity),
      'unit': serializer.toJson<String?>(unit),
    };
  }

  CachedPantryIngredientRow copyWith(
          {int? viewerUserId,
          String? rowKey,
          Value<int?> pantryIngredientId = const Value.absent(),
          Value<int?> ingId = const Value.absent(),
          String? name,
          String? details,
          String? category,
          String? status,
          Value<String?> quantity = const Value.absent(),
          Value<String?> unit = const Value.absent()}) =>
      CachedPantryIngredientRow(
        viewerUserId: viewerUserId ?? this.viewerUserId,
        rowKey: rowKey ?? this.rowKey,
        pantryIngredientId: pantryIngredientId.present
            ? pantryIngredientId.value
            : this.pantryIngredientId,
        ingId: ingId.present ? ingId.value : this.ingId,
        name: name ?? this.name,
        details: details ?? this.details,
        category: category ?? this.category,
        status: status ?? this.status,
        quantity: quantity.present ? quantity.value : this.quantity,
        unit: unit.present ? unit.value : this.unit,
      );
  CachedPantryIngredientRow copyWithCompanion(
      CachedPantryIngredientRowsCompanion data) {
    return CachedPantryIngredientRow(
      viewerUserId: data.viewerUserId.present
          ? data.viewerUserId.value
          : this.viewerUserId,
      rowKey: data.rowKey.present ? data.rowKey.value : this.rowKey,
      pantryIngredientId: data.pantryIngredientId.present
          ? data.pantryIngredientId.value
          : this.pantryIngredientId,
      ingId: data.ingId.present ? data.ingId.value : this.ingId,
      name: data.name.present ? data.name.value : this.name,
      details: data.details.present ? data.details.value : this.details,
      category: data.category.present ? data.category.value : this.category,
      status: data.status.present ? data.status.value : this.status,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPantryIngredientRow(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('rowKey: $rowKey, ')
          ..write('pantryIngredientId: $pantryIngredientId, ')
          ..write('ingId: $ingId, ')
          ..write('name: $name, ')
          ..write('details: $details, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(viewerUserId, rowKey, pantryIngredientId,
      ingId, name, details, category, status, quantity, unit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPantryIngredientRow &&
          other.viewerUserId == this.viewerUserId &&
          other.rowKey == this.rowKey &&
          other.pantryIngredientId == this.pantryIngredientId &&
          other.ingId == this.ingId &&
          other.name == this.name &&
          other.details == this.details &&
          other.category == this.category &&
          other.status == this.status &&
          other.quantity == this.quantity &&
          other.unit == this.unit);
}

class CachedPantryIngredientRowsCompanion
    extends UpdateCompanion<CachedPantryIngredientRow> {
  final Value<int> viewerUserId;
  final Value<String> rowKey;
  final Value<int?> pantryIngredientId;
  final Value<int?> ingId;
  final Value<String> name;
  final Value<String> details;
  final Value<String> category;
  final Value<String> status;
  final Value<String?> quantity;
  final Value<String?> unit;
  final Value<int> rowid;
  const CachedPantryIngredientRowsCompanion({
    this.viewerUserId = const Value.absent(),
    this.rowKey = const Value.absent(),
    this.pantryIngredientId = const Value.absent(),
    this.ingId = const Value.absent(),
    this.name = const Value.absent(),
    this.details = const Value.absent(),
    this.category = const Value.absent(),
    this.status = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedPantryIngredientRowsCompanion.insert({
    required int viewerUserId,
    required String rowKey,
    this.pantryIngredientId = const Value.absent(),
    this.ingId = const Value.absent(),
    required String name,
    required String details,
    required String category,
    required String status,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : viewerUserId = Value(viewerUserId),
        rowKey = Value(rowKey),
        name = Value(name),
        details = Value(details),
        category = Value(category),
        status = Value(status);
  static Insertable<CachedPantryIngredientRow> custom({
    Expression<int>? viewerUserId,
    Expression<String>? rowKey,
    Expression<int>? pantryIngredientId,
    Expression<int>? ingId,
    Expression<String>? name,
    Expression<String>? details,
    Expression<String>? category,
    Expression<String>? status,
    Expression<String>? quantity,
    Expression<String>? unit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (viewerUserId != null) 'viewer_user_id': viewerUserId,
      if (rowKey != null) 'row_key': rowKey,
      if (pantryIngredientId != null)
        'pantry_ingredient_id': pantryIngredientId,
      if (ingId != null) 'ing_id': ingId,
      if (name != null) 'name': name,
      if (details != null) 'details': details,
      if (category != null) 'category': category,
      if (status != null) 'status': status,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedPantryIngredientRowsCompanion copyWith(
      {Value<int>? viewerUserId,
      Value<String>? rowKey,
      Value<int?>? pantryIngredientId,
      Value<int?>? ingId,
      Value<String>? name,
      Value<String>? details,
      Value<String>? category,
      Value<String>? status,
      Value<String?>? quantity,
      Value<String?>? unit,
      Value<int>? rowid}) {
    return CachedPantryIngredientRowsCompanion(
      viewerUserId: viewerUserId ?? this.viewerUserId,
      rowKey: rowKey ?? this.rowKey,
      pantryIngredientId: pantryIngredientId ?? this.pantryIngredientId,
      ingId: ingId ?? this.ingId,
      name: name ?? this.name,
      details: details ?? this.details,
      category: category ?? this.category,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (viewerUserId.present) {
      map['viewer_user_id'] = Variable<int>(viewerUserId.value);
    }
    if (rowKey.present) {
      map['row_key'] = Variable<String>(rowKey.value);
    }
    if (pantryIngredientId.present) {
      map['pantry_ingredient_id'] = Variable<int>(pantryIngredientId.value);
    }
    if (ingId.present) {
      map['ing_id'] = Variable<int>(ingId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPantryIngredientRowsCompanion(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('rowKey: $rowKey, ')
          ..write('pantryIngredientId: $pantryIngredientId, ')
          ..write('ingId: $ingId, ')
          ..write('name: $name, ')
          ..write('details: $details, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedShoppingListRowsTable extends CachedShoppingListRows
    with TableInfo<$CachedShoppingListRowsTable, CachedShoppingListRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedShoppingListRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _viewerUserIdMeta =
      const VerificationMeta('viewerUserId');
  @override
  late final GeneratedColumn<int> viewerUserId = GeneratedColumn<int>(
      'viewer_user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
      'list_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shoppingListIdMeta =
      const VerificationMeta('shoppingListId');
  @override
  late final GeneratedColumn<int> shoppingListId = GeneratedColumn<int>(
      'shopping_list_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _serverUserIdMeta =
      const VerificationMeta('serverUserId');
  @override
  late final GeneratedColumn<int> serverUserId = GeneratedColumn<int>(
      'server_user_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _numItemsMeta =
      const VerificationMeta('numItems');
  @override
  late final GeneratedColumn<int> numItems = GeneratedColumn<int>(
      'num_items', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subtitleMeta =
      const VerificationMeta('subtitle');
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
      'subtitle', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sectionMeta =
      const VerificationMeta('section');
  @override
  late final GeneratedColumn<String> section = GeneratedColumn<String>(
      'section', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconTypeMeta =
      const VerificationMeta('iconType');
  @override
  late final GeneratedColumn<String> iconType = GeneratedColumn<String>(
      'icon_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>(
              $CachedShoppingListRowsTable.$convertercreatedAtn);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _favouriteMeta =
      const VerificationMeta('favourite');
  @override
  late final GeneratedColumn<bool> favourite = GeneratedColumn<bool>(
      'favourite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("favourite" IN (0, 1))'));
  static const VerificationMeta _isCompleteMeta =
      const VerificationMeta('isComplete');
  @override
  late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>(
      'is_complete', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_complete" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        viewerUserId,
        listId,
        shoppingListId,
        serverUserId,
        numItems,
        title,
        subtitle,
        section,
        iconType,
        status,
        createdAt,
        imageUrl,
        favourite,
        isComplete
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_shopping_list_rows';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedShoppingListRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('viewer_user_id')) {
      context.handle(
          _viewerUserIdMeta,
          viewerUserId.isAcceptableOrUnknown(
              data['viewer_user_id']!, _viewerUserIdMeta));
    } else if (isInserting) {
      context.missing(_viewerUserIdMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(_listIdMeta,
          listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta));
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('shopping_list_id')) {
      context.handle(
          _shoppingListIdMeta,
          shoppingListId.isAcceptableOrUnknown(
              data['shopping_list_id']!, _shoppingListIdMeta));
    }
    if (data.containsKey('server_user_id')) {
      context.handle(
          _serverUserIdMeta,
          serverUserId.isAcceptableOrUnknown(
              data['server_user_id']!, _serverUserIdMeta));
    }
    if (data.containsKey('num_items')) {
      context.handle(_numItemsMeta,
          numItems.isAcceptableOrUnknown(data['num_items']!, _numItemsMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(_subtitleMeta,
          subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta));
    } else if (isInserting) {
      context.missing(_subtitleMeta);
    }
    if (data.containsKey('section')) {
      context.handle(_sectionMeta,
          section.isAcceptableOrUnknown(data['section']!, _sectionMeta));
    } else if (isInserting) {
      context.missing(_sectionMeta);
    }
    if (data.containsKey('icon_type')) {
      context.handle(_iconTypeMeta,
          iconType.isAcceptableOrUnknown(data['icon_type']!, _iconTypeMeta));
    } else if (isInserting) {
      context.missing(_iconTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('favourite')) {
      context.handle(_favouriteMeta,
          favourite.isAcceptableOrUnknown(data['favourite']!, _favouriteMeta));
    } else if (isInserting) {
      context.missing(_favouriteMeta);
    }
    if (data.containsKey('is_complete')) {
      context.handle(
          _isCompleteMeta,
          isComplete.isAcceptableOrUnknown(
              data['is_complete']!, _isCompleteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {viewerUserId, listId};
  @override
  CachedShoppingListRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedShoppingListRow(
      viewerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}viewer_user_id'])!,
      listId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}list_id'])!,
      shoppingListId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}shopping_list_id']),
      serverUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_user_id']),
      numItems: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}num_items']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      subtitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtitle'])!,
      section: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}section'])!,
      iconType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status']),
      createdAt: $CachedShoppingListRowsTable.$convertercreatedAtn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}created_at'])),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      favourite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}favourite'])!,
      isComplete: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_complete'])!,
    );
  }

  @override
  $CachedShoppingListRowsTable createAlias(String alias) {
    return $CachedShoppingListRowsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $convertercreatedAtn =
      NullAwareTypeConverter.wrap($convertercreatedAt);
}

class CachedShoppingListRow extends DataClass
    implements Insertable<CachedShoppingListRow> {
  final int viewerUserId;
  final String listId;
  final int? shoppingListId;
  final int? serverUserId;
  final int? numItems;
  final String title;
  final String subtitle;
  final String section;
  final String iconType;
  final String? status;
  final DateTime? createdAt;
  final String? imageUrl;
  final bool favourite;
  final bool isComplete;
  const CachedShoppingListRow(
      {required this.viewerUserId,
      required this.listId,
      this.shoppingListId,
      this.serverUserId,
      this.numItems,
      required this.title,
      required this.subtitle,
      required this.section,
      required this.iconType,
      this.status,
      this.createdAt,
      this.imageUrl,
      required this.favourite,
      required this.isComplete});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['viewer_user_id'] = Variable<int>(viewerUserId);
    map['list_id'] = Variable<String>(listId);
    if (!nullToAbsent || shoppingListId != null) {
      map['shopping_list_id'] = Variable<int>(shoppingListId);
    }
    if (!nullToAbsent || serverUserId != null) {
      map['server_user_id'] = Variable<int>(serverUserId);
    }
    if (!nullToAbsent || numItems != null) {
      map['num_items'] = Variable<int>(numItems);
    }
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['section'] = Variable<String>(section);
    map['icon_type'] = Variable<String>(iconType);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(
          $CachedShoppingListRowsTable.$convertercreatedAtn.toSql(createdAt));
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['favourite'] = Variable<bool>(favourite);
    map['is_complete'] = Variable<bool>(isComplete);
    return map;
  }

  CachedShoppingListRowsCompanion toCompanion(bool nullToAbsent) {
    return CachedShoppingListRowsCompanion(
      viewerUserId: Value(viewerUserId),
      listId: Value(listId),
      shoppingListId: shoppingListId == null && nullToAbsent
          ? const Value.absent()
          : Value(shoppingListId),
      serverUserId: serverUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUserId),
      numItems: numItems == null && nullToAbsent
          ? const Value.absent()
          : Value(numItems),
      title: Value(title),
      subtitle: Value(subtitle),
      section: Value(section),
      iconType: Value(iconType),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      favourite: Value(favourite),
      isComplete: Value(isComplete),
    );
  }

  factory CachedShoppingListRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedShoppingListRow(
      viewerUserId: serializer.fromJson<int>(json['viewerUserId']),
      listId: serializer.fromJson<String>(json['listId']),
      shoppingListId: serializer.fromJson<int?>(json['shoppingListId']),
      serverUserId: serializer.fromJson<int?>(json['serverUserId']),
      numItems: serializer.fromJson<int?>(json['numItems']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      section: serializer.fromJson<String>(json['section']),
      iconType: serializer.fromJson<String>(json['iconType']),
      status: serializer.fromJson<String?>(json['status']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      favourite: serializer.fromJson<bool>(json['favourite']),
      isComplete: serializer.fromJson<bool>(json['isComplete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'viewerUserId': serializer.toJson<int>(viewerUserId),
      'listId': serializer.toJson<String>(listId),
      'shoppingListId': serializer.toJson<int?>(shoppingListId),
      'serverUserId': serializer.toJson<int?>(serverUserId),
      'numItems': serializer.toJson<int?>(numItems),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'section': serializer.toJson<String>(section),
      'iconType': serializer.toJson<String>(iconType),
      'status': serializer.toJson<String?>(status),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'favourite': serializer.toJson<bool>(favourite),
      'isComplete': serializer.toJson<bool>(isComplete),
    };
  }

  CachedShoppingListRow copyWith(
          {int? viewerUserId,
          String? listId,
          Value<int?> shoppingListId = const Value.absent(),
          Value<int?> serverUserId = const Value.absent(),
          Value<int?> numItems = const Value.absent(),
          String? title,
          String? subtitle,
          String? section,
          String? iconType,
          Value<String?> status = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          bool? favourite,
          bool? isComplete}) =>
      CachedShoppingListRow(
        viewerUserId: viewerUserId ?? this.viewerUserId,
        listId: listId ?? this.listId,
        shoppingListId:
            shoppingListId.present ? shoppingListId.value : this.shoppingListId,
        serverUserId:
            serverUserId.present ? serverUserId.value : this.serverUserId,
        numItems: numItems.present ? numItems.value : this.numItems,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        section: section ?? this.section,
        iconType: iconType ?? this.iconType,
        status: status.present ? status.value : this.status,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        favourite: favourite ?? this.favourite,
        isComplete: isComplete ?? this.isComplete,
      );
  CachedShoppingListRow copyWithCompanion(
      CachedShoppingListRowsCompanion data) {
    return CachedShoppingListRow(
      viewerUserId: data.viewerUserId.present
          ? data.viewerUserId.value
          : this.viewerUserId,
      listId: data.listId.present ? data.listId.value : this.listId,
      shoppingListId: data.shoppingListId.present
          ? data.shoppingListId.value
          : this.shoppingListId,
      serverUserId: data.serverUserId.present
          ? data.serverUserId.value
          : this.serverUserId,
      numItems: data.numItems.present ? data.numItems.value : this.numItems,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      section: data.section.present ? data.section.value : this.section,
      iconType: data.iconType.present ? data.iconType.value : this.iconType,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      favourite: data.favourite.present ? data.favourite.value : this.favourite,
      isComplete:
          data.isComplete.present ? data.isComplete.value : this.isComplete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedShoppingListRow(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('listId: $listId, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('serverUserId: $serverUserId, ')
          ..write('numItems: $numItems, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('section: $section, ')
          ..write('iconType: $iconType, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('favourite: $favourite, ')
          ..write('isComplete: $isComplete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      viewerUserId,
      listId,
      shoppingListId,
      serverUserId,
      numItems,
      title,
      subtitle,
      section,
      iconType,
      status,
      createdAt,
      imageUrl,
      favourite,
      isComplete);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedShoppingListRow &&
          other.viewerUserId == this.viewerUserId &&
          other.listId == this.listId &&
          other.shoppingListId == this.shoppingListId &&
          other.serverUserId == this.serverUserId &&
          other.numItems == this.numItems &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.section == this.section &&
          other.iconType == this.iconType &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.imageUrl == this.imageUrl &&
          other.favourite == this.favourite &&
          other.isComplete == this.isComplete);
}

class CachedShoppingListRowsCompanion
    extends UpdateCompanion<CachedShoppingListRow> {
  final Value<int> viewerUserId;
  final Value<String> listId;
  final Value<int?> shoppingListId;
  final Value<int?> serverUserId;
  final Value<int?> numItems;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<String> section;
  final Value<String> iconType;
  final Value<String?> status;
  final Value<DateTime?> createdAt;
  final Value<String?> imageUrl;
  final Value<bool> favourite;
  final Value<bool> isComplete;
  final Value<int> rowid;
  const CachedShoppingListRowsCompanion({
    this.viewerUserId = const Value.absent(),
    this.listId = const Value.absent(),
    this.shoppingListId = const Value.absent(),
    this.serverUserId = const Value.absent(),
    this.numItems = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.section = const Value.absent(),
    this.iconType = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.favourite = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedShoppingListRowsCompanion.insert({
    required int viewerUserId,
    required String listId,
    this.shoppingListId = const Value.absent(),
    this.serverUserId = const Value.absent(),
    this.numItems = const Value.absent(),
    required String title,
    required String subtitle,
    required String section,
    required String iconType,
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.imageUrl = const Value.absent(),
    required bool favourite,
    this.isComplete = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : viewerUserId = Value(viewerUserId),
        listId = Value(listId),
        title = Value(title),
        subtitle = Value(subtitle),
        section = Value(section),
        iconType = Value(iconType),
        favourite = Value(favourite);
  static Insertable<CachedShoppingListRow> custom({
    Expression<int>? viewerUserId,
    Expression<String>? listId,
    Expression<int>? shoppingListId,
    Expression<int>? serverUserId,
    Expression<int>? numItems,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? section,
    Expression<String>? iconType,
    Expression<String>? status,
    Expression<String>? createdAt,
    Expression<String>? imageUrl,
    Expression<bool>? favourite,
    Expression<bool>? isComplete,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (viewerUserId != null) 'viewer_user_id': viewerUserId,
      if (listId != null) 'list_id': listId,
      if (shoppingListId != null) 'shopping_list_id': shoppingListId,
      if (serverUserId != null) 'server_user_id': serverUserId,
      if (numItems != null) 'num_items': numItems,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (section != null) 'section': section,
      if (iconType != null) 'icon_type': iconType,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (imageUrl != null) 'image_url': imageUrl,
      if (favourite != null) 'favourite': favourite,
      if (isComplete != null) 'is_complete': isComplete,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedShoppingListRowsCompanion copyWith(
      {Value<int>? viewerUserId,
      Value<String>? listId,
      Value<int?>? shoppingListId,
      Value<int?>? serverUserId,
      Value<int?>? numItems,
      Value<String>? title,
      Value<String>? subtitle,
      Value<String>? section,
      Value<String>? iconType,
      Value<String?>? status,
      Value<DateTime?>? createdAt,
      Value<String?>? imageUrl,
      Value<bool>? favourite,
      Value<bool>? isComplete,
      Value<int>? rowid}) {
    return CachedShoppingListRowsCompanion(
      viewerUserId: viewerUserId ?? this.viewerUserId,
      listId: listId ?? this.listId,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      serverUserId: serverUserId ?? this.serverUserId,
      numItems: numItems ?? this.numItems,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      section: section ?? this.section,
      iconType: iconType ?? this.iconType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      favourite: favourite ?? this.favourite,
      isComplete: isComplete ?? this.isComplete,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (viewerUserId.present) {
      map['viewer_user_id'] = Variable<int>(viewerUserId.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (shoppingListId.present) {
      map['shopping_list_id'] = Variable<int>(shoppingListId.value);
    }
    if (serverUserId.present) {
      map['server_user_id'] = Variable<int>(serverUserId.value);
    }
    if (numItems.present) {
      map['num_items'] = Variable<int>(numItems.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (section.present) {
      map['section'] = Variable<String>(section.value);
    }
    if (iconType.present) {
      map['icon_type'] = Variable<String>(iconType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>($CachedShoppingListRowsTable
          .$convertercreatedAtn
          .toSql(createdAt.value));
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (favourite.present) {
      map['favourite'] = Variable<bool>(favourite.value);
    }
    if (isComplete.present) {
      map['is_complete'] = Variable<bool>(isComplete.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedShoppingListRowsCompanion(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('listId: $listId, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('serverUserId: $serverUserId, ')
          ..write('numItems: $numItems, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('section: $section, ')
          ..write('iconType: $iconType, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('favourite: $favourite, ')
          ..write('isComplete: $isComplete, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedShoppingListItemRowsTable extends CachedShoppingListItemRows
    with
        TableInfo<$CachedShoppingListItemRowsTable, CachedShoppingListItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedShoppingListItemRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _viewerUserIdMeta =
      const VerificationMeta('viewerUserId');
  @override
  late final GeneratedColumn<int> viewerUserId = GeneratedColumn<int>(
      'viewer_user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
      'list_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemKeyMeta =
      const VerificationMeta('itemKey');
  @override
  late final GeneratedColumn<String> itemKey = GeneratedColumn<String>(
      'item_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
      'item_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _shoppingListIdMeta =
      const VerificationMeta('shoppingListId');
  @override
  late final GeneratedColumn<int> shoppingListId = GeneratedColumn<int>(
      'shopping_list_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ingIdMeta = const VerificationMeta('ingId');
  @override
  late final GeneratedColumn<int> ingId = GeneratedColumn<int>(
      'ing_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
      'quantity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _checkedMeta =
      const VerificationMeta('checked');
  @override
  late final GeneratedColumn<bool> checked = GeneratedColumn<bool>(
      'checked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("checked" IN (0, 1))'));
  static const VerificationMeta _lineIndexMeta =
      const VerificationMeta('lineIndex');
  @override
  late final GeneratedColumn<int> lineIndex = GeneratedColumn<int>(
      'line_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        viewerUserId,
        listId,
        itemKey,
        itemId,
        shoppingListId,
        ingId,
        name,
        quantity,
        category,
        unit,
        checked,
        lineIndex
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_shopping_list_item_rows';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedShoppingListItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('viewer_user_id')) {
      context.handle(
          _viewerUserIdMeta,
          viewerUserId.isAcceptableOrUnknown(
              data['viewer_user_id']!, _viewerUserIdMeta));
    } else if (isInserting) {
      context.missing(_viewerUserIdMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(_listIdMeta,
          listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta));
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('item_key')) {
      context.handle(_itemKeyMeta,
          itemKey.isAcceptableOrUnknown(data['item_key']!, _itemKeyMeta));
    } else if (isInserting) {
      context.missing(_itemKeyMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    }
    if (data.containsKey('shopping_list_id')) {
      context.handle(
          _shoppingListIdMeta,
          shoppingListId.isAcceptableOrUnknown(
              data['shopping_list_id']!, _shoppingListIdMeta));
    }
    if (data.containsKey('ing_id')) {
      context.handle(
          _ingIdMeta, ingId.isAcceptableOrUnknown(data['ing_id']!, _ingIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('checked')) {
      context.handle(_checkedMeta,
          checked.isAcceptableOrUnknown(data['checked']!, _checkedMeta));
    } else if (isInserting) {
      context.missing(_checkedMeta);
    }
    if (data.containsKey('line_index')) {
      context.handle(_lineIndexMeta,
          lineIndex.isAcceptableOrUnknown(data['line_index']!, _lineIndexMeta));
    } else if (isInserting) {
      context.missing(_lineIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {viewerUserId, listId, itemKey};
  @override
  CachedShoppingListItemRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedShoppingListItemRow(
      viewerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}viewer_user_id'])!,
      listId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}list_id'])!,
      itemKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_key'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_id']),
      shoppingListId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}shopping_list_id']),
      ingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ing_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantity'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit']),
      checked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}checked'])!,
      lineIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_index'])!,
    );
  }

  @override
  $CachedShoppingListItemRowsTable createAlias(String alias) {
    return $CachedShoppingListItemRowsTable(attachedDatabase, alias);
  }
}

class CachedShoppingListItemRow extends DataClass
    implements Insertable<CachedShoppingListItemRow> {
  final int viewerUserId;
  final String listId;
  final String itemKey;
  final int? itemId;
  final int? shoppingListId;
  final int? ingId;
  final String name;
  final String quantity;
  final String category;
  final String? unit;
  final bool checked;
  final int lineIndex;
  const CachedShoppingListItemRow(
      {required this.viewerUserId,
      required this.listId,
      required this.itemKey,
      this.itemId,
      this.shoppingListId,
      this.ingId,
      required this.name,
      required this.quantity,
      required this.category,
      this.unit,
      required this.checked,
      required this.lineIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['viewer_user_id'] = Variable<int>(viewerUserId);
    map['list_id'] = Variable<String>(listId);
    map['item_key'] = Variable<String>(itemKey);
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<int>(itemId);
    }
    if (!nullToAbsent || shoppingListId != null) {
      map['shopping_list_id'] = Variable<int>(shoppingListId);
    }
    if (!nullToAbsent || ingId != null) {
      map['ing_id'] = Variable<int>(ingId);
    }
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<String>(quantity);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['checked'] = Variable<bool>(checked);
    map['line_index'] = Variable<int>(lineIndex);
    return map;
  }

  CachedShoppingListItemRowsCompanion toCompanion(bool nullToAbsent) {
    return CachedShoppingListItemRowsCompanion(
      viewerUserId: Value(viewerUserId),
      listId: Value(listId),
      itemKey: Value(itemKey),
      itemId:
          itemId == null && nullToAbsent ? const Value.absent() : Value(itemId),
      shoppingListId: shoppingListId == null && nullToAbsent
          ? const Value.absent()
          : Value(shoppingListId),
      ingId:
          ingId == null && nullToAbsent ? const Value.absent() : Value(ingId),
      name: Value(name),
      quantity: Value(quantity),
      category: Value(category),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      checked: Value(checked),
      lineIndex: Value(lineIndex),
    );
  }

  factory CachedShoppingListItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedShoppingListItemRow(
      viewerUserId: serializer.fromJson<int>(json['viewerUserId']),
      listId: serializer.fromJson<String>(json['listId']),
      itemKey: serializer.fromJson<String>(json['itemKey']),
      itemId: serializer.fromJson<int?>(json['itemId']),
      shoppingListId: serializer.fromJson<int?>(json['shoppingListId']),
      ingId: serializer.fromJson<int?>(json['ingId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<String>(json['quantity']),
      category: serializer.fromJson<String>(json['category']),
      unit: serializer.fromJson<String?>(json['unit']),
      checked: serializer.fromJson<bool>(json['checked']),
      lineIndex: serializer.fromJson<int>(json['lineIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'viewerUserId': serializer.toJson<int>(viewerUserId),
      'listId': serializer.toJson<String>(listId),
      'itemKey': serializer.toJson<String>(itemKey),
      'itemId': serializer.toJson<int?>(itemId),
      'shoppingListId': serializer.toJson<int?>(shoppingListId),
      'ingId': serializer.toJson<int?>(ingId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<String>(quantity),
      'category': serializer.toJson<String>(category),
      'unit': serializer.toJson<String?>(unit),
      'checked': serializer.toJson<bool>(checked),
      'lineIndex': serializer.toJson<int>(lineIndex),
    };
  }

  CachedShoppingListItemRow copyWith(
          {int? viewerUserId,
          String? listId,
          String? itemKey,
          Value<int?> itemId = const Value.absent(),
          Value<int?> shoppingListId = const Value.absent(),
          Value<int?> ingId = const Value.absent(),
          String? name,
          String? quantity,
          String? category,
          Value<String?> unit = const Value.absent(),
          bool? checked,
          int? lineIndex}) =>
      CachedShoppingListItemRow(
        viewerUserId: viewerUserId ?? this.viewerUserId,
        listId: listId ?? this.listId,
        itemKey: itemKey ?? this.itemKey,
        itemId: itemId.present ? itemId.value : this.itemId,
        shoppingListId:
            shoppingListId.present ? shoppingListId.value : this.shoppingListId,
        ingId: ingId.present ? ingId.value : this.ingId,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        category: category ?? this.category,
        unit: unit.present ? unit.value : this.unit,
        checked: checked ?? this.checked,
        lineIndex: lineIndex ?? this.lineIndex,
      );
  CachedShoppingListItemRow copyWithCompanion(
      CachedShoppingListItemRowsCompanion data) {
    return CachedShoppingListItemRow(
      viewerUserId: data.viewerUserId.present
          ? data.viewerUserId.value
          : this.viewerUserId,
      listId: data.listId.present ? data.listId.value : this.listId,
      itemKey: data.itemKey.present ? data.itemKey.value : this.itemKey,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      shoppingListId: data.shoppingListId.present
          ? data.shoppingListId.value
          : this.shoppingListId,
      ingId: data.ingId.present ? data.ingId.value : this.ingId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      category: data.category.present ? data.category.value : this.category,
      unit: data.unit.present ? data.unit.value : this.unit,
      checked: data.checked.present ? data.checked.value : this.checked,
      lineIndex: data.lineIndex.present ? data.lineIndex.value : this.lineIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedShoppingListItemRow(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('listId: $listId, ')
          ..write('itemKey: $itemKey, ')
          ..write('itemId: $itemId, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('ingId: $ingId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('checked: $checked, ')
          ..write('lineIndex: $lineIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      viewerUserId,
      listId,
      itemKey,
      itemId,
      shoppingListId,
      ingId,
      name,
      quantity,
      category,
      unit,
      checked,
      lineIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedShoppingListItemRow &&
          other.viewerUserId == this.viewerUserId &&
          other.listId == this.listId &&
          other.itemKey == this.itemKey &&
          other.itemId == this.itemId &&
          other.shoppingListId == this.shoppingListId &&
          other.ingId == this.ingId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.category == this.category &&
          other.unit == this.unit &&
          other.checked == this.checked &&
          other.lineIndex == this.lineIndex);
}

class CachedShoppingListItemRowsCompanion
    extends UpdateCompanion<CachedShoppingListItemRow> {
  final Value<int> viewerUserId;
  final Value<String> listId;
  final Value<String> itemKey;
  final Value<int?> itemId;
  final Value<int?> shoppingListId;
  final Value<int?> ingId;
  final Value<String> name;
  final Value<String> quantity;
  final Value<String> category;
  final Value<String?> unit;
  final Value<bool> checked;
  final Value<int> lineIndex;
  final Value<int> rowid;
  const CachedShoppingListItemRowsCompanion({
    this.viewerUserId = const Value.absent(),
    this.listId = const Value.absent(),
    this.itemKey = const Value.absent(),
    this.itemId = const Value.absent(),
    this.shoppingListId = const Value.absent(),
    this.ingId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.category = const Value.absent(),
    this.unit = const Value.absent(),
    this.checked = const Value.absent(),
    this.lineIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedShoppingListItemRowsCompanion.insert({
    required int viewerUserId,
    required String listId,
    required String itemKey,
    this.itemId = const Value.absent(),
    this.shoppingListId = const Value.absent(),
    this.ingId = const Value.absent(),
    required String name,
    required String quantity,
    required String category,
    this.unit = const Value.absent(),
    required bool checked,
    required int lineIndex,
    this.rowid = const Value.absent(),
  })  : viewerUserId = Value(viewerUserId),
        listId = Value(listId),
        itemKey = Value(itemKey),
        name = Value(name),
        quantity = Value(quantity),
        category = Value(category),
        checked = Value(checked),
        lineIndex = Value(lineIndex);
  static Insertable<CachedShoppingListItemRow> custom({
    Expression<int>? viewerUserId,
    Expression<String>? listId,
    Expression<String>? itemKey,
    Expression<int>? itemId,
    Expression<int>? shoppingListId,
    Expression<int>? ingId,
    Expression<String>? name,
    Expression<String>? quantity,
    Expression<String>? category,
    Expression<String>? unit,
    Expression<bool>? checked,
    Expression<int>? lineIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (viewerUserId != null) 'viewer_user_id': viewerUserId,
      if (listId != null) 'list_id': listId,
      if (itemKey != null) 'item_key': itemKey,
      if (itemId != null) 'item_id': itemId,
      if (shoppingListId != null) 'shopping_list_id': shoppingListId,
      if (ingId != null) 'ing_id': ingId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit,
      if (checked != null) 'checked': checked,
      if (lineIndex != null) 'line_index': lineIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedShoppingListItemRowsCompanion copyWith(
      {Value<int>? viewerUserId,
      Value<String>? listId,
      Value<String>? itemKey,
      Value<int?>? itemId,
      Value<int?>? shoppingListId,
      Value<int?>? ingId,
      Value<String>? name,
      Value<String>? quantity,
      Value<String>? category,
      Value<String?>? unit,
      Value<bool>? checked,
      Value<int>? lineIndex,
      Value<int>? rowid}) {
    return CachedShoppingListItemRowsCompanion(
      viewerUserId: viewerUserId ?? this.viewerUserId,
      listId: listId ?? this.listId,
      itemKey: itemKey ?? this.itemKey,
      itemId: itemId ?? this.itemId,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      ingId: ingId ?? this.ingId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      checked: checked ?? this.checked,
      lineIndex: lineIndex ?? this.lineIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (viewerUserId.present) {
      map['viewer_user_id'] = Variable<int>(viewerUserId.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (itemKey.present) {
      map['item_key'] = Variable<String>(itemKey.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (shoppingListId.present) {
      map['shopping_list_id'] = Variable<int>(shoppingListId.value);
    }
    if (ingId.present) {
      map['ing_id'] = Variable<int>(ingId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (checked.present) {
      map['checked'] = Variable<bool>(checked.value);
    }
    if (lineIndex.present) {
      map['line_index'] = Variable<int>(lineIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedShoppingListItemRowsCompanion(')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('listId: $listId, ')
          ..write('itemKey: $itemKey, ')
          ..write('itemId: $itemId, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('ingId: $ingId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('checked: $checked, ')
          ..write('lineIndex: $lineIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$OfflineCacheDatabase extends GeneratedDatabase {
  _$OfflineCacheDatabase(QueryExecutor e) : super(e);
  $OfflineCacheDatabaseManager get managers =>
      $OfflineCacheDatabaseManager(this);
  late final $CachedVaultRowsTable cachedVaultRows =
      $CachedVaultRowsTable(this);
  late final $CachedVaultFolderRowsTable cachedVaultFolderRows =
      $CachedVaultFolderRowsTable(this);
  late final $CachedVaultFolderRecipeRowsTable cachedVaultFolderRecipeRows =
      $CachedVaultFolderRecipeRowsTable(this);
  late final $CachedRecipeRowsTable cachedRecipeRows =
      $CachedRecipeRowsTable(this);
  late final $CachedRecipeIngredientRowsTable cachedRecipeIngredientRows =
      $CachedRecipeIngredientRowsTable(this);
  late final $CachedRecipeStepRowsTable cachedRecipeStepRows =
      $CachedRecipeStepRowsTable(this);
  late final $CacheSyncMetadataRowsTable cacheSyncMetadataRows =
      $CacheSyncMetadataRowsTable(this);
  late final $CachedPantryIngredientRowsTable cachedPantryIngredientRows =
      $CachedPantryIngredientRowsTable(this);
  late final $CachedShoppingListRowsTable cachedShoppingListRows =
      $CachedShoppingListRowsTable(this);
  late final $CachedShoppingListItemRowsTable cachedShoppingListItemRows =
      $CachedShoppingListItemRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        cachedVaultRows,
        cachedVaultFolderRows,
        cachedVaultFolderRecipeRows,
        cachedRecipeRows,
        cachedRecipeIngredientRows,
        cachedRecipeStepRows,
        cacheSyncMetadataRows,
        cachedPantryIngredientRows,
        cachedShoppingListRows,
        cachedShoppingListItemRows
      ];
}

typedef $$CachedVaultRowsTableCreateCompanionBuilder = CachedVaultRowsCompanion
    Function({
  required int viewerUserId,
  required int vaultId,
  Value<int?> ownerId,
  required String vaultType,
  required String name,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CachedVaultRowsTableUpdateCompanionBuilder = CachedVaultRowsCompanion
    Function({
  Value<int> viewerUserId,
  Value<int> vaultId,
  Value<int?> ownerId,
  Value<String> vaultType,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CachedVaultRowsTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedVaultRowsTable> {
  $$CachedVaultRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get vaultId => $composableBuilder(
      column: $table.vaultId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vaultType => $composableBuilder(
      column: $table.vaultType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$CachedVaultRowsTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedVaultRowsTable> {
  $$CachedVaultRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get vaultId => $composableBuilder(
      column: $table.vaultId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vaultType => $composableBuilder(
      column: $table.vaultType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedVaultRowsTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedVaultRowsTable> {
  $$CachedVaultRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => column);

  GeneratedColumn<int> get vaultId =>
      $composableBuilder(column: $table.vaultId, builder: (column) => column);

  GeneratedColumn<int> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get vaultType =>
      $composableBuilder(column: $table.vaultType, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CachedVaultRowsTableTableManager extends RootTableManager<
    _$OfflineCacheDatabase,
    $CachedVaultRowsTable,
    CachedVaultRow,
    $$CachedVaultRowsTableFilterComposer,
    $$CachedVaultRowsTableOrderingComposer,
    $$CachedVaultRowsTableAnnotationComposer,
    $$CachedVaultRowsTableCreateCompanionBuilder,
    $$CachedVaultRowsTableUpdateCompanionBuilder,
    (
      CachedVaultRow,
      BaseReferences<_$OfflineCacheDatabase, $CachedVaultRowsTable,
          CachedVaultRow>
    ),
    CachedVaultRow,
    PrefetchHooks Function()> {
  $$CachedVaultRowsTableTableManager(
      _$OfflineCacheDatabase db, $CachedVaultRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedVaultRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedVaultRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedVaultRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> viewerUserId = const Value.absent(),
            Value<int> vaultId = const Value.absent(),
            Value<int?> ownerId = const Value.absent(),
            Value<String> vaultType = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedVaultRowsCompanion(
            viewerUserId: viewerUserId,
            vaultId: vaultId,
            ownerId: ownerId,
            vaultType: vaultType,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int viewerUserId,
            required int vaultId,
            Value<int?> ownerId = const Value.absent(),
            required String vaultType,
            required String name,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedVaultRowsCompanion.insert(
            viewerUserId: viewerUserId,
            vaultId: vaultId,
            ownerId: ownerId,
            vaultType: vaultType,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedVaultRowsTableProcessedTableManager = ProcessedTableManager<
    _$OfflineCacheDatabase,
    $CachedVaultRowsTable,
    CachedVaultRow,
    $$CachedVaultRowsTableFilterComposer,
    $$CachedVaultRowsTableOrderingComposer,
    $$CachedVaultRowsTableAnnotationComposer,
    $$CachedVaultRowsTableCreateCompanionBuilder,
    $$CachedVaultRowsTableUpdateCompanionBuilder,
    (
      CachedVaultRow,
      BaseReferences<_$OfflineCacheDatabase, $CachedVaultRowsTable,
          CachedVaultRow>
    ),
    CachedVaultRow,
    PrefetchHooks Function()>;
typedef $$CachedVaultFolderRowsTableCreateCompanionBuilder
    = CachedVaultFolderRowsCompanion Function({
  required int viewerUserId,
  required int folderId,
  required int vaultId,
  required String folderName,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CachedVaultFolderRowsTableUpdateCompanionBuilder
    = CachedVaultFolderRowsCompanion Function({
  Value<int> viewerUserId,
  Value<int> folderId,
  Value<int> vaultId,
  Value<String> folderName,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CachedVaultFolderRowsTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedVaultFolderRowsTable> {
  $$CachedVaultFolderRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get vaultId => $composableBuilder(
      column: $table.vaultId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get folderName => $composableBuilder(
      column: $table.folderName, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$CachedVaultFolderRowsTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedVaultFolderRowsTable> {
  $$CachedVaultFolderRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get vaultId => $composableBuilder(
      column: $table.vaultId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get folderName => $composableBuilder(
      column: $table.folderName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedVaultFolderRowsTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedVaultFolderRowsTable> {
  $$CachedVaultFolderRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => column);

  GeneratedColumn<int> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<int> get vaultId =>
      $composableBuilder(column: $table.vaultId, builder: (column) => column);

  GeneratedColumn<String> get folderName => $composableBuilder(
      column: $table.folderName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CachedVaultFolderRowsTableTableManager extends RootTableManager<
    _$OfflineCacheDatabase,
    $CachedVaultFolderRowsTable,
    CachedVaultFolderRow,
    $$CachedVaultFolderRowsTableFilterComposer,
    $$CachedVaultFolderRowsTableOrderingComposer,
    $$CachedVaultFolderRowsTableAnnotationComposer,
    $$CachedVaultFolderRowsTableCreateCompanionBuilder,
    $$CachedVaultFolderRowsTableUpdateCompanionBuilder,
    (
      CachedVaultFolderRow,
      BaseReferences<_$OfflineCacheDatabase, $CachedVaultFolderRowsTable,
          CachedVaultFolderRow>
    ),
    CachedVaultFolderRow,
    PrefetchHooks Function()> {
  $$CachedVaultFolderRowsTableTableManager(
      _$OfflineCacheDatabase db, $CachedVaultFolderRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedVaultFolderRowsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedVaultFolderRowsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedVaultFolderRowsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> viewerUserId = const Value.absent(),
            Value<int> folderId = const Value.absent(),
            Value<int> vaultId = const Value.absent(),
            Value<String> folderName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedVaultFolderRowsCompanion(
            viewerUserId: viewerUserId,
            folderId: folderId,
            vaultId: vaultId,
            folderName: folderName,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int viewerUserId,
            required int folderId,
            required int vaultId,
            required String folderName,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedVaultFolderRowsCompanion.insert(
            viewerUserId: viewerUserId,
            folderId: folderId,
            vaultId: vaultId,
            folderName: folderName,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedVaultFolderRowsTableProcessedTableManager
    = ProcessedTableManager<
        _$OfflineCacheDatabase,
        $CachedVaultFolderRowsTable,
        CachedVaultFolderRow,
        $$CachedVaultFolderRowsTableFilterComposer,
        $$CachedVaultFolderRowsTableOrderingComposer,
        $$CachedVaultFolderRowsTableAnnotationComposer,
        $$CachedVaultFolderRowsTableCreateCompanionBuilder,
        $$CachedVaultFolderRowsTableUpdateCompanionBuilder,
        (
          CachedVaultFolderRow,
          BaseReferences<_$OfflineCacheDatabase, $CachedVaultFolderRowsTable,
              CachedVaultFolderRow>
        ),
        CachedVaultFolderRow,
        PrefetchHooks Function()>;
typedef $$CachedVaultFolderRecipeRowsTableCreateCompanionBuilder
    = CachedVaultFolderRecipeRowsCompanion Function({
  required int viewerUserId,
  required int folderRecipeId,
  required int folderId,
  required int recipeId,
  required DateTime addedAt,
  Value<int?> addedByUserId,
  Value<int> rowid,
});
typedef $$CachedVaultFolderRecipeRowsTableUpdateCompanionBuilder
    = CachedVaultFolderRecipeRowsCompanion Function({
  Value<int> viewerUserId,
  Value<int> folderRecipeId,
  Value<int> folderId,
  Value<int> recipeId,
  Value<DateTime> addedAt,
  Value<int?> addedByUserId,
  Value<int> rowid,
});

class $$CachedVaultFolderRecipeRowsTableFilterComposer extends Composer<
    _$OfflineCacheDatabase, $CachedVaultFolderRecipeRowsTable> {
  $$CachedVaultFolderRecipeRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get folderRecipeId => $composableBuilder(
      column: $table.folderRecipeId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get addedAt =>
      $composableBuilder(
          column: $table.addedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get addedByUserId => $composableBuilder(
      column: $table.addedByUserId, builder: (column) => ColumnFilters(column));
}

class $$CachedVaultFolderRecipeRowsTableOrderingComposer extends Composer<
    _$OfflineCacheDatabase, $CachedVaultFolderRecipeRowsTable> {
  $$CachedVaultFolderRecipeRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get folderRecipeId => $composableBuilder(
      column: $table.folderRecipeId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get addedByUserId => $composableBuilder(
      column: $table.addedByUserId,
      builder: (column) => ColumnOrderings(column));
}

class $$CachedVaultFolderRecipeRowsTableAnnotationComposer extends Composer<
    _$OfflineCacheDatabase, $CachedVaultFolderRecipeRowsTable> {
  $$CachedVaultFolderRecipeRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => column);

  GeneratedColumn<int> get folderRecipeId => $composableBuilder(
      column: $table.folderRecipeId, builder: (column) => column);

  GeneratedColumn<int> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<int> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<int> get addedByUserId => $composableBuilder(
      column: $table.addedByUserId, builder: (column) => column);
}

class $$CachedVaultFolderRecipeRowsTableTableManager extends RootTableManager<
    _$OfflineCacheDatabase,
    $CachedVaultFolderRecipeRowsTable,
    CachedVaultFolderRecipeRow,
    $$CachedVaultFolderRecipeRowsTableFilterComposer,
    $$CachedVaultFolderRecipeRowsTableOrderingComposer,
    $$CachedVaultFolderRecipeRowsTableAnnotationComposer,
    $$CachedVaultFolderRecipeRowsTableCreateCompanionBuilder,
    $$CachedVaultFolderRecipeRowsTableUpdateCompanionBuilder,
    (
      CachedVaultFolderRecipeRow,
      BaseReferences<_$OfflineCacheDatabase, $CachedVaultFolderRecipeRowsTable,
          CachedVaultFolderRecipeRow>
    ),
    CachedVaultFolderRecipeRow,
    PrefetchHooks Function()> {
  $$CachedVaultFolderRecipeRowsTableTableManager(
      _$OfflineCacheDatabase db, $CachedVaultFolderRecipeRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedVaultFolderRecipeRowsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedVaultFolderRecipeRowsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedVaultFolderRecipeRowsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> viewerUserId = const Value.absent(),
            Value<int> folderRecipeId = const Value.absent(),
            Value<int> folderId = const Value.absent(),
            Value<int> recipeId = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<int?> addedByUserId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedVaultFolderRecipeRowsCompanion(
            viewerUserId: viewerUserId,
            folderRecipeId: folderRecipeId,
            folderId: folderId,
            recipeId: recipeId,
            addedAt: addedAt,
            addedByUserId: addedByUserId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int viewerUserId,
            required int folderRecipeId,
            required int folderId,
            required int recipeId,
            required DateTime addedAt,
            Value<int?> addedByUserId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedVaultFolderRecipeRowsCompanion.insert(
            viewerUserId: viewerUserId,
            folderRecipeId: folderRecipeId,
            folderId: folderId,
            recipeId: recipeId,
            addedAt: addedAt,
            addedByUserId: addedByUserId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedVaultFolderRecipeRowsTableProcessedTableManager
    = ProcessedTableManager<
        _$OfflineCacheDatabase,
        $CachedVaultFolderRecipeRowsTable,
        CachedVaultFolderRecipeRow,
        $$CachedVaultFolderRecipeRowsTableFilterComposer,
        $$CachedVaultFolderRecipeRowsTableOrderingComposer,
        $$CachedVaultFolderRecipeRowsTableAnnotationComposer,
        $$CachedVaultFolderRecipeRowsTableCreateCompanionBuilder,
        $$CachedVaultFolderRecipeRowsTableUpdateCompanionBuilder,
        (
          CachedVaultFolderRecipeRow,
          BaseReferences<_$OfflineCacheDatabase,
              $CachedVaultFolderRecipeRowsTable, CachedVaultFolderRecipeRow>
        ),
        CachedVaultFolderRecipeRow,
        PrefetchHooks Function()>;
typedef $$CachedRecipeRowsTableCreateCompanionBuilder
    = CachedRecipeRowsCompanion Function({
  required int viewerUserId,
  required int recipeId,
  Value<int?> ownerId,
  required String title,
  Value<String?> description,
  Value<String?> cuisineType,
  Value<int?> prepTimeMins,
  Value<int?> cookingTimeMins,
  Value<int?> servingSize,
  Value<String?> photoUrl,
  Value<String?> videoUrl,
  Value<String?> externalUrl,
  required bool isCommunityPublished,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isComplete,
  Value<int> rowid,
});
typedef $$CachedRecipeRowsTableUpdateCompanionBuilder
    = CachedRecipeRowsCompanion Function({
  Value<int> viewerUserId,
  Value<int> recipeId,
  Value<int?> ownerId,
  Value<String> title,
  Value<String?> description,
  Value<String?> cuisineType,
  Value<int?> prepTimeMins,
  Value<int?> cookingTimeMins,
  Value<int?> servingSize,
  Value<String?> photoUrl,
  Value<String?> videoUrl,
  Value<String?> externalUrl,
  Value<bool> isCommunityPublished,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isComplete,
  Value<int> rowid,
});

class $$CachedRecipeRowsTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedRecipeRowsTable> {
  $$CachedRecipeRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cuisineType => $composableBuilder(
      column: $table.cuisineType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get prepTimeMins => $composableBuilder(
      column: $table.prepTimeMins, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cookingTimeMins => $composableBuilder(
      column: $table.cookingTimeMins,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get servingSize => $composableBuilder(
      column: $table.servingSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get videoUrl => $composableBuilder(
      column: $table.videoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalUrl => $composableBuilder(
      column: $table.externalUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCommunityPublished => $composableBuilder(
      column: $table.isCommunityPublished,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get updatedAt =>
      $composableBuilder(
          column: $table.updatedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isComplete => $composableBuilder(
      column: $table.isComplete, builder: (column) => ColumnFilters(column));
}

class $$CachedRecipeRowsTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedRecipeRowsTable> {
  $$CachedRecipeRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cuisineType => $composableBuilder(
      column: $table.cuisineType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get prepTimeMins => $composableBuilder(
      column: $table.prepTimeMins,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cookingTimeMins => $composableBuilder(
      column: $table.cookingTimeMins,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get servingSize => $composableBuilder(
      column: $table.servingSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get videoUrl => $composableBuilder(
      column: $table.videoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalUrl => $composableBuilder(
      column: $table.externalUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCommunityPublished => $composableBuilder(
      column: $table.isCommunityPublished,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isComplete => $composableBuilder(
      column: $table.isComplete, builder: (column) => ColumnOrderings(column));
}

class $$CachedRecipeRowsTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedRecipeRowsTable> {
  $$CachedRecipeRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => column);

  GeneratedColumn<int> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<int> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get cuisineType => $composableBuilder(
      column: $table.cuisineType, builder: (column) => column);

  GeneratedColumn<int> get prepTimeMins => $composableBuilder(
      column: $table.prepTimeMins, builder: (column) => column);

  GeneratedColumn<int> get cookingTimeMins => $composableBuilder(
      column: $table.cookingTimeMins, builder: (column) => column);

  GeneratedColumn<int> get servingSize => $composableBuilder(
      column: $table.servingSize, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get videoUrl =>
      $composableBuilder(column: $table.videoUrl, builder: (column) => column);

  GeneratedColumn<String> get externalUrl => $composableBuilder(
      column: $table.externalUrl, builder: (column) => column);

  GeneratedColumn<bool> get isCommunityPublished => $composableBuilder(
      column: $table.isCommunityPublished, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isComplete => $composableBuilder(
      column: $table.isComplete, builder: (column) => column);
}

class $$CachedRecipeRowsTableTableManager extends RootTableManager<
    _$OfflineCacheDatabase,
    $CachedRecipeRowsTable,
    CachedRecipeRow,
    $$CachedRecipeRowsTableFilterComposer,
    $$CachedRecipeRowsTableOrderingComposer,
    $$CachedRecipeRowsTableAnnotationComposer,
    $$CachedRecipeRowsTableCreateCompanionBuilder,
    $$CachedRecipeRowsTableUpdateCompanionBuilder,
    (
      CachedRecipeRow,
      BaseReferences<_$OfflineCacheDatabase, $CachedRecipeRowsTable,
          CachedRecipeRow>
    ),
    CachedRecipeRow,
    PrefetchHooks Function()> {
  $$CachedRecipeRowsTableTableManager(
      _$OfflineCacheDatabase db, $CachedRecipeRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRecipeRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRecipeRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRecipeRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> viewerUserId = const Value.absent(),
            Value<int> recipeId = const Value.absent(),
            Value<int?> ownerId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> cuisineType = const Value.absent(),
            Value<int?> prepTimeMins = const Value.absent(),
            Value<int?> cookingTimeMins = const Value.absent(),
            Value<int?> servingSize = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<String?> videoUrl = const Value.absent(),
            Value<String?> externalUrl = const Value.absent(),
            Value<bool> isCommunityPublished = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isComplete = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRecipeRowsCompanion(
            viewerUserId: viewerUserId,
            recipeId: recipeId,
            ownerId: ownerId,
            title: title,
            description: description,
            cuisineType: cuisineType,
            prepTimeMins: prepTimeMins,
            cookingTimeMins: cookingTimeMins,
            servingSize: servingSize,
            photoUrl: photoUrl,
            videoUrl: videoUrl,
            externalUrl: externalUrl,
            isCommunityPublished: isCommunityPublished,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isComplete: isComplete,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int viewerUserId,
            required int recipeId,
            Value<int?> ownerId = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String?> cuisineType = const Value.absent(),
            Value<int?> prepTimeMins = const Value.absent(),
            Value<int?> cookingTimeMins = const Value.absent(),
            Value<int?> servingSize = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<String?> videoUrl = const Value.absent(),
            Value<String?> externalUrl = const Value.absent(),
            required bool isCommunityPublished,
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isComplete = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRecipeRowsCompanion.insert(
            viewerUserId: viewerUserId,
            recipeId: recipeId,
            ownerId: ownerId,
            title: title,
            description: description,
            cuisineType: cuisineType,
            prepTimeMins: prepTimeMins,
            cookingTimeMins: cookingTimeMins,
            servingSize: servingSize,
            photoUrl: photoUrl,
            videoUrl: videoUrl,
            externalUrl: externalUrl,
            isCommunityPublished: isCommunityPublished,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isComplete: isComplete,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedRecipeRowsTableProcessedTableManager = ProcessedTableManager<
    _$OfflineCacheDatabase,
    $CachedRecipeRowsTable,
    CachedRecipeRow,
    $$CachedRecipeRowsTableFilterComposer,
    $$CachedRecipeRowsTableOrderingComposer,
    $$CachedRecipeRowsTableAnnotationComposer,
    $$CachedRecipeRowsTableCreateCompanionBuilder,
    $$CachedRecipeRowsTableUpdateCompanionBuilder,
    (
      CachedRecipeRow,
      BaseReferences<_$OfflineCacheDatabase, $CachedRecipeRowsTable,
          CachedRecipeRow>
    ),
    CachedRecipeRow,
    PrefetchHooks Function()>;
typedef $$CachedRecipeIngredientRowsTableCreateCompanionBuilder
    = CachedRecipeIngredientRowsCompanion Function({
  required int viewerUserId,
  required int recipeId,
  required int lineIndex,
  Value<int?> ingredientId,
  required int ingId,
  Value<String?> name,
  Value<double?> quantity,
  Value<String?> unit,
  required int sortOrder,
  Value<int> rowid,
});
typedef $$CachedRecipeIngredientRowsTableUpdateCompanionBuilder
    = CachedRecipeIngredientRowsCompanion Function({
  Value<int> viewerUserId,
  Value<int> recipeId,
  Value<int> lineIndex,
  Value<int?> ingredientId,
  Value<int> ingId,
  Value<String?> name,
  Value<double?> quantity,
  Value<String?> unit,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$CachedRecipeIngredientRowsTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedRecipeIngredientRowsTable> {
  $$CachedRecipeIngredientRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineIndex => $composableBuilder(
      column: $table.lineIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ingId => $composableBuilder(
      column: $table.ingId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$CachedRecipeIngredientRowsTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedRecipeIngredientRowsTable> {
  $$CachedRecipeIngredientRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineIndex => $composableBuilder(
      column: $table.lineIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ingredientId => $composableBuilder(
      column: $table.ingredientId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ingId => $composableBuilder(
      column: $table.ingId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$CachedRecipeIngredientRowsTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedRecipeIngredientRowsTable> {
  $$CachedRecipeIngredientRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => column);

  GeneratedColumn<int> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<int> get lineIndex =>
      $composableBuilder(column: $table.lineIndex, builder: (column) => column);

  GeneratedColumn<int> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => column);

  GeneratedColumn<int> get ingId =>
      $composableBuilder(column: $table.ingId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CachedRecipeIngredientRowsTableTableManager extends RootTableManager<
    _$OfflineCacheDatabase,
    $CachedRecipeIngredientRowsTable,
    CachedRecipeIngredientRow,
    $$CachedRecipeIngredientRowsTableFilterComposer,
    $$CachedRecipeIngredientRowsTableOrderingComposer,
    $$CachedRecipeIngredientRowsTableAnnotationComposer,
    $$CachedRecipeIngredientRowsTableCreateCompanionBuilder,
    $$CachedRecipeIngredientRowsTableUpdateCompanionBuilder,
    (
      CachedRecipeIngredientRow,
      BaseReferences<_$OfflineCacheDatabase, $CachedRecipeIngredientRowsTable,
          CachedRecipeIngredientRow>
    ),
    CachedRecipeIngredientRow,
    PrefetchHooks Function()> {
  $$CachedRecipeIngredientRowsTableTableManager(
      _$OfflineCacheDatabase db, $CachedRecipeIngredientRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRecipeIngredientRowsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRecipeIngredientRowsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRecipeIngredientRowsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> viewerUserId = const Value.absent(),
            Value<int> recipeId = const Value.absent(),
            Value<int> lineIndex = const Value.absent(),
            Value<int?> ingredientId = const Value.absent(),
            Value<int> ingId = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<double?> quantity = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRecipeIngredientRowsCompanion(
            viewerUserId: viewerUserId,
            recipeId: recipeId,
            lineIndex: lineIndex,
            ingredientId: ingredientId,
            ingId: ingId,
            name: name,
            quantity: quantity,
            unit: unit,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int viewerUserId,
            required int recipeId,
            required int lineIndex,
            Value<int?> ingredientId = const Value.absent(),
            required int ingId,
            Value<String?> name = const Value.absent(),
            Value<double?> quantity = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            required int sortOrder,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRecipeIngredientRowsCompanion.insert(
            viewerUserId: viewerUserId,
            recipeId: recipeId,
            lineIndex: lineIndex,
            ingredientId: ingredientId,
            ingId: ingId,
            name: name,
            quantity: quantity,
            unit: unit,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedRecipeIngredientRowsTableProcessedTableManager
    = ProcessedTableManager<
        _$OfflineCacheDatabase,
        $CachedRecipeIngredientRowsTable,
        CachedRecipeIngredientRow,
        $$CachedRecipeIngredientRowsTableFilterComposer,
        $$CachedRecipeIngredientRowsTableOrderingComposer,
        $$CachedRecipeIngredientRowsTableAnnotationComposer,
        $$CachedRecipeIngredientRowsTableCreateCompanionBuilder,
        $$CachedRecipeIngredientRowsTableUpdateCompanionBuilder,
        (
          CachedRecipeIngredientRow,
          BaseReferences<_$OfflineCacheDatabase,
              $CachedRecipeIngredientRowsTable, CachedRecipeIngredientRow>
        ),
        CachedRecipeIngredientRow,
        PrefetchHooks Function()>;
typedef $$CachedRecipeStepRowsTableCreateCompanionBuilder
    = CachedRecipeStepRowsCompanion Function({
  required int viewerUserId,
  required int recipeId,
  required int lineIndex,
  Value<int?> stepId,
  required int stepNr,
  required String content,
  Value<int> rowid,
});
typedef $$CachedRecipeStepRowsTableUpdateCompanionBuilder
    = CachedRecipeStepRowsCompanion Function({
  Value<int> viewerUserId,
  Value<int> recipeId,
  Value<int> lineIndex,
  Value<int?> stepId,
  Value<int> stepNr,
  Value<String> content,
  Value<int> rowid,
});

class $$CachedRecipeStepRowsTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedRecipeStepRowsTable> {
  $$CachedRecipeStepRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineIndex => $composableBuilder(
      column: $table.lineIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stepId => $composableBuilder(
      column: $table.stepId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stepNr => $composableBuilder(
      column: $table.stepNr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));
}

class $$CachedRecipeStepRowsTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedRecipeStepRowsTable> {
  $$CachedRecipeStepRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineIndex => $composableBuilder(
      column: $table.lineIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stepId => $composableBuilder(
      column: $table.stepId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stepNr => $composableBuilder(
      column: $table.stepNr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));
}

class $$CachedRecipeStepRowsTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedRecipeStepRowsTable> {
  $$CachedRecipeStepRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => column);

  GeneratedColumn<int> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<int> get lineIndex =>
      $composableBuilder(column: $table.lineIndex, builder: (column) => column);

  GeneratedColumn<int> get stepId =>
      $composableBuilder(column: $table.stepId, builder: (column) => column);

  GeneratedColumn<int> get stepNr =>
      $composableBuilder(column: $table.stepNr, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$CachedRecipeStepRowsTableTableManager extends RootTableManager<
    _$OfflineCacheDatabase,
    $CachedRecipeStepRowsTable,
    CachedRecipeStepRow,
    $$CachedRecipeStepRowsTableFilterComposer,
    $$CachedRecipeStepRowsTableOrderingComposer,
    $$CachedRecipeStepRowsTableAnnotationComposer,
    $$CachedRecipeStepRowsTableCreateCompanionBuilder,
    $$CachedRecipeStepRowsTableUpdateCompanionBuilder,
    (
      CachedRecipeStepRow,
      BaseReferences<_$OfflineCacheDatabase, $CachedRecipeStepRowsTable,
          CachedRecipeStepRow>
    ),
    CachedRecipeStepRow,
    PrefetchHooks Function()> {
  $$CachedRecipeStepRowsTableTableManager(
      _$OfflineCacheDatabase db, $CachedRecipeStepRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRecipeStepRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRecipeStepRowsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRecipeStepRowsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> viewerUserId = const Value.absent(),
            Value<int> recipeId = const Value.absent(),
            Value<int> lineIndex = const Value.absent(),
            Value<int?> stepId = const Value.absent(),
            Value<int> stepNr = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRecipeStepRowsCompanion(
            viewerUserId: viewerUserId,
            recipeId: recipeId,
            lineIndex: lineIndex,
            stepId: stepId,
            stepNr: stepNr,
            content: content,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int viewerUserId,
            required int recipeId,
            required int lineIndex,
            Value<int?> stepId = const Value.absent(),
            required int stepNr,
            required String content,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRecipeStepRowsCompanion.insert(
            viewerUserId: viewerUserId,
            recipeId: recipeId,
            lineIndex: lineIndex,
            stepId: stepId,
            stepNr: stepNr,
            content: content,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedRecipeStepRowsTableProcessedTableManager
    = ProcessedTableManager<
        _$OfflineCacheDatabase,
        $CachedRecipeStepRowsTable,
        CachedRecipeStepRow,
        $$CachedRecipeStepRowsTableFilterComposer,
        $$CachedRecipeStepRowsTableOrderingComposer,
        $$CachedRecipeStepRowsTableAnnotationComposer,
        $$CachedRecipeStepRowsTableCreateCompanionBuilder,
        $$CachedRecipeStepRowsTableUpdateCompanionBuilder,
        (
          CachedRecipeStepRow,
          BaseReferences<_$OfflineCacheDatabase, $CachedRecipeStepRowsTable,
              CachedRecipeStepRow>
        ),
        CachedRecipeStepRow,
        PrefetchHooks Function()>;
typedef $$CacheSyncMetadataRowsTableCreateCompanionBuilder
    = CacheSyncMetadataRowsCompanion Function({
  required int viewerUserId,
  required String collection,
  required String scopeId,
  required DateTime lastSyncedAt,
  Value<DateTime?> lastAccessedAt,
  Value<int> rowid,
});
typedef $$CacheSyncMetadataRowsTableUpdateCompanionBuilder
    = CacheSyncMetadataRowsCompanion Function({
  Value<int> viewerUserId,
  Value<String> collection,
  Value<String> scopeId,
  Value<DateTime> lastSyncedAt,
  Value<DateTime?> lastAccessedAt,
  Value<int> rowid,
});

class $$CacheSyncMetadataRowsTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CacheSyncMetadataRowsTable> {
  $$CacheSyncMetadataRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collection => $composableBuilder(
      column: $table.collection, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scopeId => $composableBuilder(
      column: $table.scopeId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get lastSyncedAt =>
      $composableBuilder(
          column: $table.lastSyncedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
      get lastAccessedAt => $composableBuilder(
          column: $table.lastAccessedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$CacheSyncMetadataRowsTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CacheSyncMetadataRowsTable> {
  $$CacheSyncMetadataRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collection => $composableBuilder(
      column: $table.collection, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scopeId => $composableBuilder(
      column: $table.scopeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$CacheSyncMetadataRowsTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CacheSyncMetadataRowsTable> {
  $$CacheSyncMetadataRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => column);

  GeneratedColumn<String> get collection => $composableBuilder(
      column: $table.collection, builder: (column) => column);

  GeneratedColumn<String> get scopeId =>
      $composableBuilder(column: $table.scopeId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get lastSyncedAt =>
      $composableBuilder(
          column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get lastAccessedAt =>
      $composableBuilder(
          column: $table.lastAccessedAt, builder: (column) => column);
}

class $$CacheSyncMetadataRowsTableTableManager extends RootTableManager<
    _$OfflineCacheDatabase,
    $CacheSyncMetadataRowsTable,
    CacheSyncMetadataRow,
    $$CacheSyncMetadataRowsTableFilterComposer,
    $$CacheSyncMetadataRowsTableOrderingComposer,
    $$CacheSyncMetadataRowsTableAnnotationComposer,
    $$CacheSyncMetadataRowsTableCreateCompanionBuilder,
    $$CacheSyncMetadataRowsTableUpdateCompanionBuilder,
    (
      CacheSyncMetadataRow,
      BaseReferences<_$OfflineCacheDatabase, $CacheSyncMetadataRowsTable,
          CacheSyncMetadataRow>
    ),
    CacheSyncMetadataRow,
    PrefetchHooks Function()> {
  $$CacheSyncMetadataRowsTableTableManager(
      _$OfflineCacheDatabase db, $CacheSyncMetadataRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheSyncMetadataRowsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheSyncMetadataRowsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheSyncMetadataRowsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> viewerUserId = const Value.absent(),
            Value<String> collection = const Value.absent(),
            Value<String> scopeId = const Value.absent(),
            Value<DateTime> lastSyncedAt = const Value.absent(),
            Value<DateTime?> lastAccessedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CacheSyncMetadataRowsCompanion(
            viewerUserId: viewerUserId,
            collection: collection,
            scopeId: scopeId,
            lastSyncedAt: lastSyncedAt,
            lastAccessedAt: lastAccessedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int viewerUserId,
            required String collection,
            required String scopeId,
            required DateTime lastSyncedAt,
            Value<DateTime?> lastAccessedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CacheSyncMetadataRowsCompanion.insert(
            viewerUserId: viewerUserId,
            collection: collection,
            scopeId: scopeId,
            lastSyncedAt: lastSyncedAt,
            lastAccessedAt: lastAccessedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CacheSyncMetadataRowsTableProcessedTableManager
    = ProcessedTableManager<
        _$OfflineCacheDatabase,
        $CacheSyncMetadataRowsTable,
        CacheSyncMetadataRow,
        $$CacheSyncMetadataRowsTableFilterComposer,
        $$CacheSyncMetadataRowsTableOrderingComposer,
        $$CacheSyncMetadataRowsTableAnnotationComposer,
        $$CacheSyncMetadataRowsTableCreateCompanionBuilder,
        $$CacheSyncMetadataRowsTableUpdateCompanionBuilder,
        (
          CacheSyncMetadataRow,
          BaseReferences<_$OfflineCacheDatabase, $CacheSyncMetadataRowsTable,
              CacheSyncMetadataRow>
        ),
        CacheSyncMetadataRow,
        PrefetchHooks Function()>;
typedef $$CachedPantryIngredientRowsTableCreateCompanionBuilder
    = CachedPantryIngredientRowsCompanion Function({
  required int viewerUserId,
  required String rowKey,
  Value<int?> pantryIngredientId,
  Value<int?> ingId,
  required String name,
  required String details,
  required String category,
  required String status,
  Value<String?> quantity,
  Value<String?> unit,
  Value<int> rowid,
});
typedef $$CachedPantryIngredientRowsTableUpdateCompanionBuilder
    = CachedPantryIngredientRowsCompanion Function({
  Value<int> viewerUserId,
  Value<String> rowKey,
  Value<int?> pantryIngredientId,
  Value<int?> ingId,
  Value<String> name,
  Value<String> details,
  Value<String> category,
  Value<String> status,
  Value<String?> quantity,
  Value<String?> unit,
  Value<int> rowid,
});

class $$CachedPantryIngredientRowsTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedPantryIngredientRowsTable> {
  $$CachedPantryIngredientRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rowKey => $composableBuilder(
      column: $table.rowKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pantryIngredientId => $composableBuilder(
      column: $table.pantryIngredientId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ingId => $composableBuilder(
      column: $table.ingId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));
}

class $$CachedPantryIngredientRowsTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedPantryIngredientRowsTable> {
  $$CachedPantryIngredientRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rowKey => $composableBuilder(
      column: $table.rowKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pantryIngredientId => $composableBuilder(
      column: $table.pantryIngredientId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ingId => $composableBuilder(
      column: $table.ingId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));
}

class $$CachedPantryIngredientRowsTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedPantryIngredientRowsTable> {
  $$CachedPantryIngredientRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => column);

  GeneratedColumn<String> get rowKey =>
      $composableBuilder(column: $table.rowKey, builder: (column) => column);

  GeneratedColumn<int> get pantryIngredientId => $composableBuilder(
      column: $table.pantryIngredientId, builder: (column) => column);

  GeneratedColumn<int> get ingId =>
      $composableBuilder(column: $table.ingId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);
}

class $$CachedPantryIngredientRowsTableTableManager extends RootTableManager<
    _$OfflineCacheDatabase,
    $CachedPantryIngredientRowsTable,
    CachedPantryIngredientRow,
    $$CachedPantryIngredientRowsTableFilterComposer,
    $$CachedPantryIngredientRowsTableOrderingComposer,
    $$CachedPantryIngredientRowsTableAnnotationComposer,
    $$CachedPantryIngredientRowsTableCreateCompanionBuilder,
    $$CachedPantryIngredientRowsTableUpdateCompanionBuilder,
    (
      CachedPantryIngredientRow,
      BaseReferences<_$OfflineCacheDatabase, $CachedPantryIngredientRowsTable,
          CachedPantryIngredientRow>
    ),
    CachedPantryIngredientRow,
    PrefetchHooks Function()> {
  $$CachedPantryIngredientRowsTableTableManager(
      _$OfflineCacheDatabase db, $CachedPantryIngredientRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPantryIngredientRowsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedPantryIngredientRowsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedPantryIngredientRowsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> viewerUserId = const Value.absent(),
            Value<String> rowKey = const Value.absent(),
            Value<int?> pantryIngredientId = const Value.absent(),
            Value<int?> ingId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> details = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> quantity = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedPantryIngredientRowsCompanion(
            viewerUserId: viewerUserId,
            rowKey: rowKey,
            pantryIngredientId: pantryIngredientId,
            ingId: ingId,
            name: name,
            details: details,
            category: category,
            status: status,
            quantity: quantity,
            unit: unit,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int viewerUserId,
            required String rowKey,
            Value<int?> pantryIngredientId = const Value.absent(),
            Value<int?> ingId = const Value.absent(),
            required String name,
            required String details,
            required String category,
            required String status,
            Value<String?> quantity = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedPantryIngredientRowsCompanion.insert(
            viewerUserId: viewerUserId,
            rowKey: rowKey,
            pantryIngredientId: pantryIngredientId,
            ingId: ingId,
            name: name,
            details: details,
            category: category,
            status: status,
            quantity: quantity,
            unit: unit,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedPantryIngredientRowsTableProcessedTableManager
    = ProcessedTableManager<
        _$OfflineCacheDatabase,
        $CachedPantryIngredientRowsTable,
        CachedPantryIngredientRow,
        $$CachedPantryIngredientRowsTableFilterComposer,
        $$CachedPantryIngredientRowsTableOrderingComposer,
        $$CachedPantryIngredientRowsTableAnnotationComposer,
        $$CachedPantryIngredientRowsTableCreateCompanionBuilder,
        $$CachedPantryIngredientRowsTableUpdateCompanionBuilder,
        (
          CachedPantryIngredientRow,
          BaseReferences<_$OfflineCacheDatabase,
              $CachedPantryIngredientRowsTable, CachedPantryIngredientRow>
        ),
        CachedPantryIngredientRow,
        PrefetchHooks Function()>;
typedef $$CachedShoppingListRowsTableCreateCompanionBuilder
    = CachedShoppingListRowsCompanion Function({
  required int viewerUserId,
  required String listId,
  Value<int?> shoppingListId,
  Value<int?> serverUserId,
  Value<int?> numItems,
  required String title,
  required String subtitle,
  required String section,
  required String iconType,
  Value<String?> status,
  Value<DateTime?> createdAt,
  Value<String?> imageUrl,
  required bool favourite,
  Value<bool> isComplete,
  Value<int> rowid,
});
typedef $$CachedShoppingListRowsTableUpdateCompanionBuilder
    = CachedShoppingListRowsCompanion Function({
  Value<int> viewerUserId,
  Value<String> listId,
  Value<int?> shoppingListId,
  Value<int?> serverUserId,
  Value<int?> numItems,
  Value<String> title,
  Value<String> subtitle,
  Value<String> section,
  Value<String> iconType,
  Value<String?> status,
  Value<DateTime?> createdAt,
  Value<String?> imageUrl,
  Value<bool> favourite,
  Value<bool> isComplete,
  Value<int> rowid,
});

class $$CachedShoppingListRowsTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedShoppingListRowsTable> {
  $$CachedShoppingListRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverUserId => $composableBuilder(
      column: $table.serverUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numItems => $composableBuilder(
      column: $table.numItems, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get section => $composableBuilder(
      column: $table.section, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconType => $composableBuilder(
      column: $table.iconType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get favourite => $composableBuilder(
      column: $table.favourite, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isComplete => $composableBuilder(
      column: $table.isComplete, builder: (column) => ColumnFilters(column));
}

class $$CachedShoppingListRowsTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedShoppingListRowsTable> {
  $$CachedShoppingListRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverUserId => $composableBuilder(
      column: $table.serverUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numItems => $composableBuilder(
      column: $table.numItems, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get section => $composableBuilder(
      column: $table.section, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconType => $composableBuilder(
      column: $table.iconType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get favourite => $composableBuilder(
      column: $table.favourite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isComplete => $composableBuilder(
      column: $table.isComplete, builder: (column) => ColumnOrderings(column));
}

class $$CachedShoppingListRowsTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedShoppingListRowsTable> {
  $$CachedShoppingListRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => column);

  GeneratedColumn<String> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<int> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId, builder: (column) => column);

  GeneratedColumn<int> get serverUserId => $composableBuilder(
      column: $table.serverUserId, builder: (column) => column);

  GeneratedColumn<int> get numItems =>
      $composableBuilder(column: $table.numItems, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get section =>
      $composableBuilder(column: $table.section, builder: (column) => column);

  GeneratedColumn<String> get iconType =>
      $composableBuilder(column: $table.iconType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<bool> get favourite =>
      $composableBuilder(column: $table.favourite, builder: (column) => column);

  GeneratedColumn<bool> get isComplete => $composableBuilder(
      column: $table.isComplete, builder: (column) => column);
}

class $$CachedShoppingListRowsTableTableManager extends RootTableManager<
    _$OfflineCacheDatabase,
    $CachedShoppingListRowsTable,
    CachedShoppingListRow,
    $$CachedShoppingListRowsTableFilterComposer,
    $$CachedShoppingListRowsTableOrderingComposer,
    $$CachedShoppingListRowsTableAnnotationComposer,
    $$CachedShoppingListRowsTableCreateCompanionBuilder,
    $$CachedShoppingListRowsTableUpdateCompanionBuilder,
    (
      CachedShoppingListRow,
      BaseReferences<_$OfflineCacheDatabase, $CachedShoppingListRowsTable,
          CachedShoppingListRow>
    ),
    CachedShoppingListRow,
    PrefetchHooks Function()> {
  $$CachedShoppingListRowsTableTableManager(
      _$OfflineCacheDatabase db, $CachedShoppingListRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedShoppingListRowsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedShoppingListRowsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedShoppingListRowsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> viewerUserId = const Value.absent(),
            Value<String> listId = const Value.absent(),
            Value<int?> shoppingListId = const Value.absent(),
            Value<int?> serverUserId = const Value.absent(),
            Value<int?> numItems = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> subtitle = const Value.absent(),
            Value<String> section = const Value.absent(),
            Value<String> iconType = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<bool> favourite = const Value.absent(),
            Value<bool> isComplete = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedShoppingListRowsCompanion(
            viewerUserId: viewerUserId,
            listId: listId,
            shoppingListId: shoppingListId,
            serverUserId: serverUserId,
            numItems: numItems,
            title: title,
            subtitle: subtitle,
            section: section,
            iconType: iconType,
            status: status,
            createdAt: createdAt,
            imageUrl: imageUrl,
            favourite: favourite,
            isComplete: isComplete,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int viewerUserId,
            required String listId,
            Value<int?> shoppingListId = const Value.absent(),
            Value<int?> serverUserId = const Value.absent(),
            Value<int?> numItems = const Value.absent(),
            required String title,
            required String subtitle,
            required String section,
            required String iconType,
            Value<String?> status = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            required bool favourite,
            Value<bool> isComplete = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedShoppingListRowsCompanion.insert(
            viewerUserId: viewerUserId,
            listId: listId,
            shoppingListId: shoppingListId,
            serverUserId: serverUserId,
            numItems: numItems,
            title: title,
            subtitle: subtitle,
            section: section,
            iconType: iconType,
            status: status,
            createdAt: createdAt,
            imageUrl: imageUrl,
            favourite: favourite,
            isComplete: isComplete,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedShoppingListRowsTableProcessedTableManager
    = ProcessedTableManager<
        _$OfflineCacheDatabase,
        $CachedShoppingListRowsTable,
        CachedShoppingListRow,
        $$CachedShoppingListRowsTableFilterComposer,
        $$CachedShoppingListRowsTableOrderingComposer,
        $$CachedShoppingListRowsTableAnnotationComposer,
        $$CachedShoppingListRowsTableCreateCompanionBuilder,
        $$CachedShoppingListRowsTableUpdateCompanionBuilder,
        (
          CachedShoppingListRow,
          BaseReferences<_$OfflineCacheDatabase, $CachedShoppingListRowsTable,
              CachedShoppingListRow>
        ),
        CachedShoppingListRow,
        PrefetchHooks Function()>;
typedef $$CachedShoppingListItemRowsTableCreateCompanionBuilder
    = CachedShoppingListItemRowsCompanion Function({
  required int viewerUserId,
  required String listId,
  required String itemKey,
  Value<int?> itemId,
  Value<int?> shoppingListId,
  Value<int?> ingId,
  required String name,
  required String quantity,
  required String category,
  Value<String?> unit,
  required bool checked,
  required int lineIndex,
  Value<int> rowid,
});
typedef $$CachedShoppingListItemRowsTableUpdateCompanionBuilder
    = CachedShoppingListItemRowsCompanion Function({
  Value<int> viewerUserId,
  Value<String> listId,
  Value<String> itemKey,
  Value<int?> itemId,
  Value<int?> shoppingListId,
  Value<int?> ingId,
  Value<String> name,
  Value<String> quantity,
  Value<String> category,
  Value<String?> unit,
  Value<bool> checked,
  Value<int> lineIndex,
  Value<int> rowid,
});

class $$CachedShoppingListItemRowsTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedShoppingListItemRowsTable> {
  $$CachedShoppingListItemRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemKey => $composableBuilder(
      column: $table.itemKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ingId => $composableBuilder(
      column: $table.ingId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get checked => $composableBuilder(
      column: $table.checked, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineIndex => $composableBuilder(
      column: $table.lineIndex, builder: (column) => ColumnFilters(column));
}

class $$CachedShoppingListItemRowsTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedShoppingListItemRowsTable> {
  $$CachedShoppingListItemRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemKey => $composableBuilder(
      column: $table.itemKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ingId => $composableBuilder(
      column: $table.ingId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get checked => $composableBuilder(
      column: $table.checked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineIndex => $composableBuilder(
      column: $table.lineIndex, builder: (column) => ColumnOrderings(column));
}

class $$CachedShoppingListItemRowsTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedShoppingListItemRowsTable> {
  $$CachedShoppingListItemRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get viewerUserId => $composableBuilder(
      column: $table.viewerUserId, builder: (column) => column);

  GeneratedColumn<String> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<String> get itemKey =>
      $composableBuilder(column: $table.itemKey, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId, builder: (column) => column);

  GeneratedColumn<int> get ingId =>
      $composableBuilder(column: $table.ingId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<bool> get checked =>
      $composableBuilder(column: $table.checked, builder: (column) => column);

  GeneratedColumn<int> get lineIndex =>
      $composableBuilder(column: $table.lineIndex, builder: (column) => column);
}

class $$CachedShoppingListItemRowsTableTableManager extends RootTableManager<
    _$OfflineCacheDatabase,
    $CachedShoppingListItemRowsTable,
    CachedShoppingListItemRow,
    $$CachedShoppingListItemRowsTableFilterComposer,
    $$CachedShoppingListItemRowsTableOrderingComposer,
    $$CachedShoppingListItemRowsTableAnnotationComposer,
    $$CachedShoppingListItemRowsTableCreateCompanionBuilder,
    $$CachedShoppingListItemRowsTableUpdateCompanionBuilder,
    (
      CachedShoppingListItemRow,
      BaseReferences<_$OfflineCacheDatabase, $CachedShoppingListItemRowsTable,
          CachedShoppingListItemRow>
    ),
    CachedShoppingListItemRow,
    PrefetchHooks Function()> {
  $$CachedShoppingListItemRowsTableTableManager(
      _$OfflineCacheDatabase db, $CachedShoppingListItemRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedShoppingListItemRowsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedShoppingListItemRowsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedShoppingListItemRowsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> viewerUserId = const Value.absent(),
            Value<String> listId = const Value.absent(),
            Value<String> itemKey = const Value.absent(),
            Value<int?> itemId = const Value.absent(),
            Value<int?> shoppingListId = const Value.absent(),
            Value<int?> ingId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> quantity = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<bool> checked = const Value.absent(),
            Value<int> lineIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedShoppingListItemRowsCompanion(
            viewerUserId: viewerUserId,
            listId: listId,
            itemKey: itemKey,
            itemId: itemId,
            shoppingListId: shoppingListId,
            ingId: ingId,
            name: name,
            quantity: quantity,
            category: category,
            unit: unit,
            checked: checked,
            lineIndex: lineIndex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int viewerUserId,
            required String listId,
            required String itemKey,
            Value<int?> itemId = const Value.absent(),
            Value<int?> shoppingListId = const Value.absent(),
            Value<int?> ingId = const Value.absent(),
            required String name,
            required String quantity,
            required String category,
            Value<String?> unit = const Value.absent(),
            required bool checked,
            required int lineIndex,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedShoppingListItemRowsCompanion.insert(
            viewerUserId: viewerUserId,
            listId: listId,
            itemKey: itemKey,
            itemId: itemId,
            shoppingListId: shoppingListId,
            ingId: ingId,
            name: name,
            quantity: quantity,
            category: category,
            unit: unit,
            checked: checked,
            lineIndex: lineIndex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedShoppingListItemRowsTableProcessedTableManager
    = ProcessedTableManager<
        _$OfflineCacheDatabase,
        $CachedShoppingListItemRowsTable,
        CachedShoppingListItemRow,
        $$CachedShoppingListItemRowsTableFilterComposer,
        $$CachedShoppingListItemRowsTableOrderingComposer,
        $$CachedShoppingListItemRowsTableAnnotationComposer,
        $$CachedShoppingListItemRowsTableCreateCompanionBuilder,
        $$CachedShoppingListItemRowsTableUpdateCompanionBuilder,
        (
          CachedShoppingListItemRow,
          BaseReferences<_$OfflineCacheDatabase,
              $CachedShoppingListItemRowsTable, CachedShoppingListItemRow>
        ),
        CachedShoppingListItemRow,
        PrefetchHooks Function()>;

class $OfflineCacheDatabaseManager {
  final _$OfflineCacheDatabase _db;
  $OfflineCacheDatabaseManager(this._db);
  $$CachedVaultRowsTableTableManager get cachedVaultRows =>
      $$CachedVaultRowsTableTableManager(_db, _db.cachedVaultRows);
  $$CachedVaultFolderRowsTableTableManager get cachedVaultFolderRows =>
      $$CachedVaultFolderRowsTableTableManager(_db, _db.cachedVaultFolderRows);
  $$CachedVaultFolderRecipeRowsTableTableManager
      get cachedVaultFolderRecipeRows =>
          $$CachedVaultFolderRecipeRowsTableTableManager(
              _db, _db.cachedVaultFolderRecipeRows);
  $$CachedRecipeRowsTableTableManager get cachedRecipeRows =>
      $$CachedRecipeRowsTableTableManager(_db, _db.cachedRecipeRows);
  $$CachedRecipeIngredientRowsTableTableManager
      get cachedRecipeIngredientRows =>
          $$CachedRecipeIngredientRowsTableTableManager(
              _db, _db.cachedRecipeIngredientRows);
  $$CachedRecipeStepRowsTableTableManager get cachedRecipeStepRows =>
      $$CachedRecipeStepRowsTableTableManager(_db, _db.cachedRecipeStepRows);
  $$CacheSyncMetadataRowsTableTableManager get cacheSyncMetadataRows =>
      $$CacheSyncMetadataRowsTableTableManager(_db, _db.cacheSyncMetadataRows);
  $$CachedPantryIngredientRowsTableTableManager
      get cachedPantryIngredientRows =>
          $$CachedPantryIngredientRowsTableTableManager(
              _db, _db.cachedPantryIngredientRows);
  $$CachedShoppingListRowsTableTableManager get cachedShoppingListRows =>
      $$CachedShoppingListRowsTableTableManager(
          _db, _db.cachedShoppingListRows);
  $$CachedShoppingListItemRowsTableTableManager
      get cachedShoppingListItemRows =>
          $$CachedShoppingListItemRowsTableTableManager(
              _db, _db.cachedShoppingListItemRows);
}
