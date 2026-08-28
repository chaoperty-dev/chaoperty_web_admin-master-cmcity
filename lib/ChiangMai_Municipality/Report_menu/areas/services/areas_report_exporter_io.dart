// ============================================================================
// areas_report_exporter_io.dart
// ============================================================================
// Native impl (Android / iOS / Windows / macOS / Linux)
// - dart:io File
// - path_provider (deferred)
// - share_plus  (deferred)
// - excel_dart  (deferred) — load ใน isolate ด้วย
// - protect     (deferred) — load ใน isolate ด้วย
//
// ✅ Deferred: packages load ครั้งแรกตอนกด export (ไม่ block IDE open หรือ page init)
// ✅ compute(): xlsx build + encryption รันใน background isolate
//    ลด UI freeze 1-3s ตอน export ไฟล์ใหญ่
// ============================================================================

// ignore: avoid_web_libraries_in_flutter
import 'dart:io' show Directory, File;
import 'dart:typed_data';

import 'package:excel_dart/excel_dart.dart' deferred as ed show Excel;
import 'package:flutter/foundation.dart' show compute;
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
    // ✅ Parallel load — saves ~100-300ms on first export
    await Future.wait([
      ed.loadLibrary(),
      p.loadLibrary(),
      sp.loadLibrary(),
      pp.loadLibrary(),
    ]);
    _libsLoaded = true;
  }

  @override
  Future<String?> export({
    required List<AreasReportColumn> cols,
    required List<AreasReportItem> items,
    String? password,
  }) async {
    await _ensureLibs();

    // 1) ✅ Serialize input → ส่งไป isolate
    final input = _ExcelBuildInput(
      colLabels: cols.map((c) => c.label).toList(growable: false),
      rows: items
          .map((item) =>
              cols.map((c) => item.getBy(col.field) ?? '').toList(growable: false))
          .toList(growable: false),
      password: password,
    );

    // 2) ตั้งชื่อไฟล์
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final filename = 'areas_report_$ts.xlsx';

    // 3) ✅ Build xlsx + encrypt ใน background isolate
    //    parallel กับ getTemporaryDirectory — ทั้งสองเป็น async ops อิสระกัน
    final results = await Future.wait([
      compute(_buildExcelBytesIsolate, input),
      pp.getTemporaryDirectory(),
    ]);
    final bytes = results[0] as List<int>;
    final dir = results[1] as Directory;

    // 4) Save → temp dir
    final file = File('${dir.path}/$filename');
    // ✅ Drop flush:true — saves 50-300ms on Android by skipping fsync.
    // File is in temp dir (not critical data); share dialog reads immediately.
    await file.writeAsBytes(bytes);

    // 5) เปิด Share dialog
    await sp.Share.shareXFiles(
      [sp.XFile(file.path)],
      text: 'รายงานพื้นที่เช่า ($filename)',
    );

    print(
        '✅ xlsx saved: ${file.path} (${bytes.length} bytes, ${items.length} rows)');
    return file.path;
  }
}

// ============================================================================
// Isolate-bound helpers
// ============================================================================

/// Input สำหรับ `_buildExcelBytesIsolate`
/// ต้องเป็น immutable + sendable (final fields only)
class _ExcelBuildInput {
  final List<List<String>> colLabels;
  final List<List<String>> rows;
  final String? password;

  const _ExcelBuildInput({
    required this.colLabels,
    required this.rows,
    required this.password,
  });
}

/// ✅ Top-level function — required by `compute()`
/// รันใน background isolate → UI ไม่ค้างตอน build/encrypt
Future<List<int>> _buildExcelBytesIsolate(_ExcelBuildInput input) async {
  // ✅ โหลด deferred libs ใน isolate นี้ (compute() spawn isolate ใหม่)
  await Future.wait([
    ed.loadLibrary(),
    p.loadLibrary(),
  ]);

  // 1) Build xlsx
  final excel = ed.Excel.createExcel();
  excel.rename('Sheet1', 'Areas');
  final sheet = excel['Areas'];

  // Header
  sheet.appendRow(input.colLabels);

  // Data rows
  for (final row in input.rows) {
    sheet.appendRow(row);
  }

  final plainBytes = excel.encode()!;

  // 2) Encrypt ด้วย AES (package:protect) — optional
  final password = input.password;
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

AreasReportExporter createExporter() => _IoExporter();
