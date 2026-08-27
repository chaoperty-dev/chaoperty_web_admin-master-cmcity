// ============================================================================
// customers_report_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + export logic
// ✅ SELF-CONTAINED
// ============================================================================

import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // ✅ ใช้เฉพาะบน web (conditional import)
import 'dart:io' show File;

import 'package:excel_dart/excel_dart.dart' as ed;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protect/protect.dart';
import 'package:share_plus/share_plus.dart';

import '../services/customers_report_service.dart';

/// ✅ แสดง event สำหรับ UI
class CustomerReportEvent {}

class CustomersReportViewModel extends ChangeNotifier {
  CustomersReportViewModel({
    CustomersReportService? service,
  }) : _service = service ?? CustomersReportService() {
    _init();
  }

  final CustomersReportService _service;

  // ---------- State ----------
  List<CustomerReportColumn> _columns = [];

  /// ใช้ sortedColumns (จาก _fieldOrder หรือ default) ในการแสดงผล
  List<CustomerReportColumn> get columns => _getSortedColumns();

  List<CustomerReportColumn> _getSortedColumns() {
    if (_fieldOrder.isEmpty) return _columns;
    final byField = {for (final c in _columns) c.field: c};
    final out = <CustomerReportColumn>[];
    for (final f in _fieldOrder) {
      final c = byField[f];
      if (c != null) out.add(c);
    }
    // append columns ใหม่ที่ไม่อยู่ใน order
    for (final c in _columns) {
      if (!_fieldOrder.contains(c.field)) out.add(c);
    }
    return out;
  }

  /// ลำดับ column ที่ผู้ใช้จัดเรียงเอง (สำหรับ export)
  List<String> _fieldOrder = [];

  /// Set ของ field ที่ถูกเลือก (เริ่มต้น: 5 ตัวที่ใช้บ่อย)
  Set<String> _selectedFields = {};
  Set<String> get selectedFields => _selectedFields;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  bool _isLoadingColumns = false;
  bool get isLoadingColumns => _isLoadingColumns;

  bool _isExporting = false;
  bool get isExporting => _isExporting;

  String? _lastExportPath;
  String? get lastExportPath => _lastExportPath;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------- Init ----------
  Future<void> _init() async {
    // ✅ ใช้ default columns (TH labels แปลแล้ว) — ไม่ต้องเรียก API /columns
    _initDefaultColumns();
    notifyListeners();
    // preload items เพื่อให้เห็น total ก่อนกด export
    await preloadItems();
  }

  /// ✅ Initial columns แบบ hard-coded (TH labels)
  void _initDefaultColumns() {
    _columns = CustomersReportService.defaultColumns();

    // ✅ Initial _fieldOrder
    if (_fieldOrder.length != _columns.length) {
      _fieldOrder = _columns.map((c) => c.field).toList();
    }

    // ✅ default selected = 5 ตัวที่ใช้บ่อย
    if (_selectedFields.isEmpty) {
      const defaultFields = {
        'uuid',
        'custno',
        'taxno',
        'scname',
        'sname',
      };
      _selectedFields =
          defaultFields.where((f) => _columns.any((c) => c.field == f)).toSet();
    }
  }

  // ===============================================================
  // Loaders
  // ===============================================================
  /// ✅ ใช้ default columns (TH labels) — ไม่ต้องเรียก API
  /// เก็บ method ไว้สำหรับ refresh/reset
  Future<void> loadColumns({bool forceRefresh = false}) async {
    _initDefaultColumns();
    notifyListeners();
  }

  /// ✅ สลับลำดับ column (drag & drop)
  void reorderColumns(int oldIndex, int newIndex) {
    if (_fieldOrder.isEmpty) {
      _fieldOrder = _columns.map((c) => c.field).toList();
    }
    if (newIndex > oldIndex) newIndex -= 1;
    final field = _fieldOrder.removeAt(oldIndex);
    _fieldOrder.insert(newIndex, field);
    notifyListeners();
  }

  Future<void> preloadItems({bool forceRefresh = false}) async {
    try {
      final result = await _service.fetchItems(forceRefresh: forceRefresh);
      _totalItems = result.total;
      notifyListeners();
    } catch (e) {
      print('⚠️ preloadItems error: $e');
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadColumns(forceRefresh: true),
      preloadItems(forceRefresh: true),
    ]);
  }

  // ===============================================================
  // Column toggle
  // ===============================================================
  void toggleColumn(String field) {
    if (_selectedFields.contains(field)) {
      _selectedFields.remove(field);
    } else {
      _selectedFields.add(field);
    }
    notifyListeners();
  }

  void selectAllColumns() {
    _selectedFields = _columns.map((c) => c.field).toSet();
    notifyListeners();
  }

  void deselectAllColumns() {
    _selectedFields = {};
    notifyListeners();
  }

  bool isSelected(String field) => _selectedFields.contains(field);

  int get selectedCount => _selectedFields.length;

  /// Columns ที่จะใช้ export (เฉพาะ field ที่เลือก)
  List<CustomerReportColumn> get selectedColumnsList {
    return _columns
        .where((c) => _selectedFields.contains(c.field))
        .toList(growable: false);
  }

  // ===============================================================
  // Export to Excel
  // ===============================================================
  /// สร้างไฟล์ .xlsx และ:
  /// - **Web:** trigger download ผ่าน browser
  /// - **Mobile/Desktop:** บันทึกลง temp แล้วเปิด Share dialog
  ///
  /// [password] ถ้าไม่ว่าง → encrypt ไฟล์ (AES ผ่าน `package:protect`)
  /// ผู้รับต้องกรอก password ก่อนเปิดใน Excel
  /// คืน path/url ของไฟล์ที่ export สำเร็จ (null = ล้มเหลว)
  Future<String?> exportToExcel({String? password}) async {
    if (_isExporting) return null;
    if (_selectedFields.isEmpty) {
      _errorMessage = 'กรุณาเลือกอย่างน้อย 1 column';
      notifyListeners();
      return null;
    }

    _isExporting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1) โหลด items (force refresh)
      final result = await _service.fetchItems(forceRefresh: true);
      final items = result.items;
      _totalItems = result.total;

      // 2) สร้าง xlsx bytes (encrypt with password ถ้ามี)
      final cols = selectedColumnsList;
      final bytes = _buildExcelBytes(cols, items, password: password);

      // 3) บันทึกชื่อไฟล์ (encrypt แล้ว — ไม่ต้อง hint ในชื่อ)
      final ts = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final filename = 'customers_report_$ts.xlsx';

      String? savedPath;
      if (kIsWeb) {
        // ─── Web: trigger download ผ่าน browser ───
        savedPath = _webDownload(bytes, filename);
      } else {
        // ─── Mobile/Desktop: save + share ───
        savedPath = await _nativeSaveAndShare(bytes, filename);
      }

      print(
          '✅ CSV saved: $savedPath (${bytes.length} bytes, ${items.length} rows)');

      _lastExportPath = savedPath;
      _isExporting = false;
      notifyListeners();
      return savedPath;
    } catch (e, st) {
      print('❌ exportToExcel error: $e\n$st');
      _errorMessage = 'Export ล้มเหลว: $e';
      _isExporting = false;
      notifyListeners();
      return null;
    }
  }

  /// Web-only: trigger download ผ่าน browser
  /// ignore: avoid_web_libraries_in_flutter
  String _webDownload(List<int> bytes, String filename) {
    // ignore: avoid_web_libraries_in_flutter
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

    return 'web://download/$filename';
  }

  /// Mobile/Desktop: save + share
  Future<String> _nativeSaveAndShare(List<int> bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'รายงานลูกค้า ($filename)',
    );
    return file.path;
  }

  /// สร้าง bytes ของ .xlsx (encrypt ด้วย password ถ้ามี)
  /// ใช้ `excel_dart` สร้าง workbook → encode เป็น .xlsx bytes
  /// ถ้ามี [password] → encrypt ด้วย `package:protect` (AES)
  /// ✅ ผู้รับต้องกรอก password ก่อนเปิดใน Excel
  List<int> _buildExcelBytes(
    List<CustomerReportColumn> cols,
    List<CustomerReportItem> items, {
    String? password,
  }) {
    // 1) สร้าง workbook
    final excel = ed.Excel.createExcel();
    excel.rename('Sheet1', 'Customers');
    final sheet = excel['Customers'];

    // Header row (ภาษาไทย)
    sheet.appendRow(cols.map((c) => c.label).toList());

    // Data rows
    for (final item in items) {
      final row = <String>[];
      for (final col in cols) {
        final v = item.getBy(col.field) ?? '';
        row.add(v);
      }
      sheet.appendRow(row);
    }

    final plainBytes = excel.encode()!;

    // 2) ถ้ามี password → encrypt ด้วย package:protect (AES)
    if (password != null && password.isNotEmpty) {
      try {
        final resp = Protect.encryptUint8List(
          Uint8List.fromList(plainBytes),
          password,
        );
        if (!resp.isDataValid) {
          throw Exception('protect.encrypt returned invalid data');
        }
        print(
            '🔐 Excel encrypted with password (${plainBytes.length} → ${resp.processedBytes?.length} bytes)');
        return resp.processedBytes ?? plainBytes;
      } catch (e, st) {
        print('❌ encrypt error: $e\n$st');
        throw Exception('Encryption failed: $e');
      }
    }

    return plainBytes;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.clearCache();
    super.dispose();
  }
}
