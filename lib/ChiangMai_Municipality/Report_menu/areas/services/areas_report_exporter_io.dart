// ============================================================================
// areas_report_exporter_io.dart
// ============================================================================
// Native impl (Android / iOS / Windows / macOS / Linux)
// - dart:io File
// - path_provider (deferred)
// - share_plus  (deferred)
// - excel_dart  (deferred)
// - protect     (deferred)
//
// ✅ Deferred: packages load ครั้งแรกตอนกด export (ไม่ block IDE open หรือ page init)
// ============================================================================

// ignore: avoid_web_libraries_in_flutter
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:excel_dart/excel_dart.dart' deferred as ed show Excel;
import 'package:path_provider/path_provider.dart' deferred as pp
    show getTemporaryDirectory;
import 'package:protect/protect.dart' deferred as p show Protect;
import 'package:share_plus/share_plus.dart' deferred as sp show Share, XFile;

import 'areas_report_exporter.dart';
import 'areas_report_service.dart';

class _IoExporter implements AreasReportExporter {
  bool _libsLoaded = false;

  Future<void> _ensureLibs() async {
    if (_libsLoaded) return;
    await ed.loadLibrary();
    await p.loadLibrary();
    await sp.loadLibrary();
    await pp.loadLibrary();
    _libsLoaded = true;
  }

  @override
  Future<String?> export({
    required List<AreasReportColumn> cols,
    required List<AreasReportItem> items,
    String? password,
  }) async {
    await _ensureLibs();

    // 1) สร้าง xlsx bytes (encrypt ถ้ามี)
    final bytes = _buildExcelBytes(cols, items, password: password);

    // 2) ตั้งชื่อไฟล์
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final filename = 'areas_report_$ts.xlsx';

    // 3) Save → temp dir
    final dir = await pp.getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);

    // 4) เปิด Share dialog
    await sp.Share.shareXFiles(
      [sp.XFile(file.path)],
      text: 'รายงานพื้นที่เช่า ($filename)',
    );

    print(
        '✅ xlsx saved: ${file.path} (${bytes.length} bytes, ${items.length} rows)');
    return file.path;
  }

  List<int> _buildExcelBytes(
    List<AreasReportColumn> cols,
    List<AreasReportItem> items, {
    String? password,
  }) {
    final excel = ed.Excel.createExcel();
    excel.rename('Sheet1', 'Areas');
    final sheet = excel['Areas'];

    // Header
    sheet.appendRow(cols.map((c) => c.label).toList());

    // Data rows
    for (final item in items) {
      final row = <String>[];
      for (final col in cols) {
        row.add(item.getBy(col.field) ?? '');
      }
      sheet.appendRow(row);
    }

    final plainBytes = excel.encode()!;

    // Encrypt ด้วย AES (package:protect) — optional
    if (password != null && password.isNotEmpty) {
      try {
        final resp = p.Protect.encryptUint8List(
          Uint8List.fromList(plainBytes),
          password,
        );
        if (!resp.isDataValid) {
          throw Exception('protect.encrypt returned invalid data');
        }
        print(
            '🔐 Excel encrypted with password (${plainBytes.length} → ${resp.processedBytes?.length} bytes)');
        return resp.processedBytes ?? plainBytes;
      } catch (e) {
        throw Exception('Encryption failed: $e');
      }
    }

    return plainBytes;
  }
}

AreasReportExporter createExporter() => _IoExporter();