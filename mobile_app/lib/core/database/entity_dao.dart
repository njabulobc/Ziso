import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../domain/entities.dart';
import 'database_provider.dart';

typedef EntityFromMap<T extends BaseEntity> = T Function(Map<String, Object?>);

class EntityDao<T extends BaseEntity> {
  EntityDao({
    required this.tableName,
    required this.fromMap,
    required this.primaryKey,
    required this.sortColumns,
  });

  final String tableName;
  final EntityFromMap<T> fromMap;
  final String primaryKey;
  final List<String> sortColumns;

  Future<Database> get _db async => DatabaseProvider.instance.database;

  Future<List<T>> fetchAll({String? searchTerm, List<String>? searchColumns}) async {
    final db = await _db;
    final orderBy = sortColumns.join(', ');
    String? where;
    List<Object?>? whereArgs;
    if (searchTerm != null && searchTerm.isNotEmpty && searchColumns != null) {
      final like = '%${searchTerm.toLowerCase()}%';
      final clauses = searchColumns.map((column) => 'LOWER($column) LIKE ?').toList();
      where = clauses.join(' OR ');
      whereArgs = List<Object?>.filled(searchColumns.length, like);
    }
    final rows = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
    return rows.map(fromMap).toList();
  }

  Future<T?> findById(int id) async {
    final db = await _db;
    final rows = await db.query(
      tableName,
      where: '$primaryKey = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return fromMap(rows.first);
  }

  Future<void> upsert(T entity) async {
    final db = await _db;
    await db.insert(
      tableName,
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete(
      tableName,
      where: '$primaryKey = ?',
      whereArgs: [id],
    );
  }

  Future<int> nextId() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT MAX($primaryKey) as max_id FROM $tableName');
    final maxId = result.first['max_id'] as int?;
    return (maxId ?? 0) + 1;
  }
}

class PivotDao {
  PivotDao({required this.tableName, required this.leftColumn, required this.rightColumn});

  final String tableName;
  final String leftColumn;
  final String rightColumn;

  Future<Database> get _db async => DatabaseProvider.instance.database;

  Future<Set<int>> loadRightIds(int leftId) async {
    final db = await _db;
    final rows = await db.query(
      tableName,
      columns: [rightColumn],
      where: '$leftColumn = ?',
      whereArgs: [leftId],
    );
    return rows.map((row) => row[rightColumn] as int).toSet();
  }

  Future<void> replaceLinks({required int leftId, required Iterable<int> rightIds}) async {
    final db = await _db;
    final batch = db.batch();
    batch.delete(tableName, where: '$leftColumn = ?', whereArgs: [leftId]);
    for (final rightId in rightIds) {
      batch.insert(tableName, {
        leftColumn: leftId,
        rightColumn: rightId,
      });
    }
    await batch.commit(noResult: true);
  }
}
