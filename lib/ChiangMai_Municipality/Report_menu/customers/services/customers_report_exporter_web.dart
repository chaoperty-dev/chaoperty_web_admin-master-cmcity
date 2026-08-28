// ============================================================================
// customers_report_exporter_web.dart
// ============================================================================
// Web impl (Chrome / Safari / Firefox)
// - dart:html Blob / Anchor (trigger download)
// - excel_dart (deferred)
// - protect    (deferred)
//
// ✅ Deferred: packages load ครั้งแรกตอนกด export (ไม่ block IDE open หรือ page init)
// ============================================================================

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:excel_dart/excel_dart.dart' deferred as ed show Excel;
import 'package:protect/protect.dart' deferred as p show Protect;

import 'customers_report_exporter.dart';
import 'customers_report_service.dart';

class _WebExporter implements CustomersReportExporter {
  bool _libsLoaded = false;

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
    await _ensureLibs();

    // 1) สร้าง xlsx bytes (encrypt ถ้ามี)
    final bytes = _buildExcelBytes(cols, items, password: password);

    // 2) ตั้งชื่อไฟล์
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final filename = 'customers_report_$ts.xlsx';

    // 3) Trigger browser download ผ่าน Blob + anchor
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

    print(
        '✅ Web CSV saved: $filename (${bytes.length} bytes, ${items.length} rows)');
    return 'web://download/$filename';
  }

  List<int> _buildExcelBytes(
    List<CustomerReportColumn> cols,
    List<CustomerReportItem> items, {
    String? password,
  }) {
    final excel = ed.Excel.createExcel();
    excel.rename('Sheet1', 'Customers');
    final sheet = excel['Customers'];

    sheet.appendRow(cols.map((c) => c.label).toList());

    for (final item in items) {
      final row = <String>[];
      for (final col in cols) {
        row.add(item.getBy(col.field) ?? '');
      }
      sheet.appendRow(row);
    }

    final plainBytes = excel.encode()!;

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

CustomersReportExporter createExporter() => _WebExporter();