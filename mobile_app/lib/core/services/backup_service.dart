import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/database_provider.dart';

class BackupService {
  Future<File> exportDatabaseToJson(String filename) async {
    final db = await DatabaseProvider.instance.database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );
    final export = <String, List<Map<String, Object?>>>{};
    for (final table in tables) {
      final name = table['name'] as String;
      final rows = await db.query(name);
      export[name] = rows;
    }
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(directory.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    final file = File(p.join(backupDir.path, '$filename.json'));
    await file.writeAsString(jsonEncode(export));
    return file;
  }

  Future<void> importDatabaseFromJson(File file) async {
    final db = await DatabaseProvider.instance.database;
    final content = await file.readAsString();
    final payload = jsonDecode(content) as Map<String, dynamic>;
    final batch = db.batch();
    payload.forEach((table, records) {
      batch.delete(table);
      for (final row in records as List<dynamic>) {
        batch.insert(table, Map<String, Object?>.from(row as Map));
      }
    });
    await batch.commit(noResult: true);
  }
}
