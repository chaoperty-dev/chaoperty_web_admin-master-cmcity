// ============================================================================
// areas_report_exporter_web.dart
// ============================================================================
// Web impl (Chrome / Safari / Firefox)
// - dart:html Blob / Anchor (trigger download)
// - excel_dart (deferred)
// - protect    (deferred)
//
// ✅ Deferred: packages load ครั้งแรกตอนกด export (ไม่ block IDE open หรือ page init)
//
// ⚠️ Web quirk: compute() บน web มี overhead มหาศาล (Web Worker spawn +
//    deferred lib load ใน worker context = 30+ วินาที สำหรับงานเล็ก)
//    → รัน xlsx build + encrypt บน main thread แต่ yield ระหว่าง phase
//    → UI freeze แค่ 200-500ms ต่อ phase (ดีกว่ารอ 31s ใน Web Worker)
// ============================================================================

// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:excel_dart/excel_dart.dart' deferred as ed show Excel;
import 'package:protect/protect.dart' deferred as p show Protect;

import 'areas_report_exporter.dart';
import 'areas_report_service.dart';

class _WebExporter implements AreasReportExporter {
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
    required List<AreasReportColumn> cols,
    required List<AreasReportItem> items,
    String? password,
  }) async {
    // ⏱️ Timing — debug/UX: ดูเวลาแต่ละ phase ของ export
    final sw = Stopwatch()..start();
    print(
        '📊 [web export] start: cols=${cols.length} items=${items.length} password=${password != null ? 'yes' : 'no'}');

    await _ensureLibs();
    print('⏱️ [${sw.elapsedMilliseconds}ms] libs loaded');

    // ✅ Yield — ให้ browser render frame ก่อนเริ่ม build
    await Future<void>.delayed(Duration.zero);

    // 1) Build xlsx (main thread — compute() บน web overhead สูง)
    final plainBytes = _buildExcelBytes(cols, items);
    print('⏱️ [${sw.elapsedMilliseconds}ms] xlsx built (${plainBytes.length} bytes)');

    // ✅ Yield — ให้ browser render frame ก่อน encrypt
    await Future<void>.delayed(Duration.zero);

    // 2) Encrypt ถ้ามี password
    final Uint8List bytes;
    if (password != null && password.isNotEmpty) {
      bytes = _encryptBytes(plainBytes, password);
      print('⏱️ [${sw.elapsedMilliseconds}ms] encrypted');
    } else {
      bytes = plainBytes;
    }

    // 3) ตั้งชื่อไฟล์
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final filename = 'areas_report_$ts.xlsx';

    // 4) Trigger browser download ผ่าน Blob + anchor (DOM access — ต้องบน main thread)
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

  /// Build xlsx บน main thread (compute() บน web overhead สูงกว่างานเอง)
  Uint8List _buildExcelBytes(
    List<AreasReportColumn> cols,
    List<AreasReportItem> items,
  ) {
    final excel = ed.Excel.createExcel();
    excel.rename('Sheet1', 'Areas');
    final sheet = excel['Areas'];

    sheet.appendRow(cols.map((c) => c.label).toList());

    for (final item in items) {
      final row = <String>[];
      for (final col in cols) {
        row.add(item.getBy(col.field) ?? '');
      }
      sheet.appendRow(row);
    }

    return Uint8List.fromList(excel.encode()!);
  }

  /// Encrypt ด้วย AES (package:protect)
  Uint8List _encryptBytes(Uint8List plainBytes, String password) {
    try {
      final resp = p.Protect.encryptUint8List(plainBytes, password);
      if (!resp.isDataValid) {
        throw Exception('protect.encrypt returned invalid data');
      }
      print(
          '🔐 Excel encrypted with password (${plainBytes.length} → ${resp.processedBytes?.length} bytes)');
      return resp.processedBytes != null
          ? Uint8List.fromList(resp.processedBytes!)
          : plainBytes;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }
}

AreasReportExporter createExporter() => _WebExporter();