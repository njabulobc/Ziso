import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/entities.dart';

class ExportService {
  Future<Directory> _ensureExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(directory.path, 'exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  Future<File> exportToPdf({
    required String filename,
    required Iterable<BaseEntity> entities,
    required List<String> columns,
    required List<List<String>> rows,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text(filename, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(headers: columns, data: rows),
        ],
      ),
    );
    final directory = await _ensureExportDirectory();
    final file = File(p.join(directory.path, '$filename.pdf'));
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<File> exportToExcel({
    required String filename,
    required Iterable<BaseEntity> entities,
    required List<String> columns,
    required List<List<String>> rows,
  }) async {
    final workbook = Excel.createExcel();
    final sheet = workbook[workbook.getDefaultSheet()!];
    sheet.appendRow(columns);
    for (final row in rows) {
      sheet.appendRow(row);
    }
    final directory = await _ensureExportDirectory();
    final file = File(p.join(directory.path, '$filename.xlsx'));
    final bytes = workbook.save();
    await file.writeAsBytes(bytes!);
    return file;
  }

  List<List<String>> buildRowsFromEntities(Iterable<BaseEntity> entities) {
    return entities.map((entity) {
      final map = entity.toMap();
      return map.values.map((value) => value?.toString() ?? '').toList();
    }).toList();
  }
}
