import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Provides access to the offline SQLite database backing the application.
class DatabaseProvider {
  DatabaseProvider._internal();

  static final DatabaseProvider instance = DatabaseProvider._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _openDatabase();
    return _database!;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> _openDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDir.path, 'ziso_mobile.db');
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        final schema = await rootBundle.loadString('assets/schema.sql');
        final statements = schema
            .split(';')
            .map((statement) => statement.trim())
            .where((statement) => statement.isNotEmpty);
        for (final statement in statements) {
          await db.execute(statement);
        }
      },
    );
  }
}
