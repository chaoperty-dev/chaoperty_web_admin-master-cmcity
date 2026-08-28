// ============================================================================
// customers_report_exporter_web.dart
// ============================================================================
// Web impl (Chrome / Safari / Firefox)
// - dart:html Blob / Anchor (trigger download)
// - excel_dart (deferred)
// - protect    (deferred)
//
// ✅ Deferred: packages load ครั้งแรกตอนกด export (ไม่ block IDE open หรือ page init)
// ✅ compute(): xlsx build + encrypt รันใน Web Worker isolate
//    ลด UI freeze 1-3s ตอน build xlsx + encrypt (single-threaded JS เดิม block ทุก event)
// ============================================================================

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:excel_dart/excel_dart.dart' deferred as ed show Excel;
import 'package:flutter/foundation.dart' show compute;
import 'package:protect/protect.dart' deferred as p show Protect;

import 'customers_report_exporter.dart';
import 'customers_report_service.dart';

class _WebExporter implements CustomersReportExporter {
  bool _libsLoaded = false;

  @override
  Future<void> preload() async {
    // ✅ Fire-and-forget ตอน VM init — ลด first-export cost
    await _ensureLibs();
  }

  Future<void> _ensureLibs() async {
    if (_libsLoaded) return;
    await ed.loadLibrary();
    await p.loadLibrary();
    _libsLoaded = true;
  }

  @override
  Future<String?> export({
    required List<CustomerReportColumn> cols,
    required List<CustomerReportItem> items,
    String? password,
  }) async {
    // ⏱️ Timing — debug/UX: ดูเวลาแต่ละ phase ของ export
    final sw = Stopwatch()..start();
    print(
        '📊 [web export] start: cols=${cols.length} items=${items.length} password=${password != null ? 'yes' : 'no'}');

    await _ensureLibs();
    print('⏱️ [${sw.elapsedMilliseconds}ms] libs loaded');

    // 1) ✅ Build xlsx + encrypt ใน Web Worker isolate (compute)
    //    เดิม build บน UI thread = freeze ทุก event 1-3s ตอน xlsx build + AES
    final input = _WebExcelBuildInput(
      sheetName: 'Customers',
      colLabels: cols.map((c) => c.label).toList(growable: false),
      rows: items
          .map((item) => cols
              .map((c) => item.getBy(c.field) ?? '')
              .toList(growable: false))
          .toList(growable: false),
      password: password,
    );
    final bytes = await compute(_buildExcelBytesWebIsolate, input);
    print(
        '⏱️ [${sw.elapsedMilliseconds}ms] xlsx built (${bytes.length} bytes) in Web Worker');

    // 2) ตั้งชื่อไฟล์
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final filename = 'customers_report_$ts.xlsx';

    // 3) Trigger browser download ผ่าน Blob + anchor (DOM access — ต้องบน main thread)
    final blob = html.Blob(
      [bytes],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = filename
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    // Revoke URL หลัง 30 วินาที (browser cleanup)
    Future.delayed(const Duration(seconds: 30), () {
      html.Url.revokeObjectUrl(url);
    });

    sw.stop();
    print(
        '✅ [web export] done in ${sw.elapsedMilliseconds}ms (${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s) — ${bytes.length} bytes, ${items.length} rows, ${cols.length} cols');
    return 'web://download/$filename';
  }
}

// ============================================================================
// Isolate-bound helpers (Web Worker)
// ============================================================================

/// ✅ Input สำหรับ `_buildExcelBytesWebIsolate`
/// ต้องเป็น immutable + sendable (final fields only)
class _WebExcelBuildInput {
  final String sheetName;
  final List<String> colLabels;
  final List<List<String>> rows;
  final String? password;

  const _WebExcelBuildInput({
    required this.sheetName,
    required this.colLabels,
    required this.rows,
    required this.password,
  });
}

/// ✅ Top-level function — required by `compute()`
/// รันใน Web Worker isolate → UI ไม่ค้างตอน build/encrypt
/// Single-threaded JS เดิม block ทุก event ขณะ build xlsx + encrypt
Future<Uint8List> _buildExcelBytesWebIsolate(_WebExcelBuildInput input) async {
  await ed.loadLibrary();

  // 1) Build xlsx
  final excel = ed.Excel.createExcel();
  excel.rename('Sheet1', input.sheetName);
  final sheet = excel[input.sheetName];

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
    await p.loadLibrary();
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
      return resp.processedBytes != null
          ? Uint8List.fromList(resp.processedBytes!)
          : Uint8List.fromList(plainBytes);
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  return Uint8List.fromList(plainBytes);
}

CustomersReportExporter createExporter() => _WebExporter();