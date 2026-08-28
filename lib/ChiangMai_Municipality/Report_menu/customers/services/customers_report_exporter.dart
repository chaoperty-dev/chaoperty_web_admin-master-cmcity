// ============================================================================
// customers_report_exporter.dart
// ============================================================================
// Interface + factory — เลือก implementation ตาม platform
// - Web    → customers_report_exporter_web.dart (dart:html)
// - Native → customers_report_exporter_io.dart  (dart:io)
//
// ✅ ไฟล์นี้ lightweight: ไม่ import excel_dart / protect / share_plus / path_provider
// ✅ Heavy packages ถูก `deferred as` ใน impl ไฟล์ — load เฉพาะตอนกด export
// ============================================================================

import 'customers_report_service.dart';
import 'customers_report_exporter_io.dart'
    if (dart.library.html) 'customers_report_exporter_web.dart' as platform;

abstract class CustomersReportExporter {
  /// สร้าง .xlsx bytes + บันทึก/แชร์
  /// คืน path/url ของไฟล์ที่ export สำเร็จ, null = ล้มเหลว
  Future<String?> export({
    required List<CustomerReportColumn> cols,
    required List<CustomerReportItem> items,
    String? password,
  });
}

/// สร้าง exporter ตาม platform (compile-time resolution)
CustomersReportExporter buildExporter() => platform.createExporter();