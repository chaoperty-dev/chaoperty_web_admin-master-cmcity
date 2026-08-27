// ============================================================================
// areas_report_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + export logic สำหรับ "รายงานพื้นที่เช่า"
// - โหลด columns (hard-coded TH) — ไม่ต้อง fetch API
// - โหลด /areas/overview — ได้ items
// - เลือก columns + drag & drop reorder + export xlsx
// ============================================================================

import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:io' show File;

import 'package:excel_dart/excel_dart.dart' as ed;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/areas_report_service.dart';

class AreasReportViewModel extends ChangeNotifier {
  AreasReportViewModel({
    AreasReportService? service,
  }) : _service = service ?? AreasReportService() {
    _init();
  }

  final AreasReportService _service;

  // ---------- State ----------
  List<AreasReportColumn> _columns = [];

  List<AreasReportColumn> get columns => _getSortedColumns();

  List<AreasReportColumn> _getSortedColumns() {
    if (_fieldOrder.isEmpty) return _columns;
    final byField = {for (final c in _columns) c.field: c};
    final out = <AreasReportColumn>[];
    for (final f in _fieldOrder) {
      final c = byField[f];
      if (c != null) out.add(c);
    }
    for (final c in _columns) {
      if (!_fieldOrder.contains(c.field)) out.add(c);
    }
    return out;
  }

  List<String> _fieldOrder = [];

  Set<String> _selectedFields = {};
  Set<String> get selectedFields => _selectedFields;

  int _totalArea = 0;
  int? get totalArea => _totalArea > 0 ? _totalArea : null;

  int _totalLeased = 0;
  int? get totalLeased => _totalLeased > 0 ? _totalLeased : null;

  int _totalVacant = 0;
  int? get totalVacant => _totalVacant > 0 ? _totalVacant : null;

  bool _isExporting = false;
  bool get isExporting => _isExporting;

  String? _lastExportPath;
  String? get lastExportPath => _lastExportPath;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------- Init ----------
  Future<void> _init() async {
    _initDefaultColumns();
    notifyListeners();
    await preloadOverview();
  }

  /// ✅ Initial columns แบบ hard-coded (TH labels)
  void _initDefaultColumns() {
    _columns = AreasReportService.defaultColumns();

    if (_fieldOrder.length != _columns.length) {
      _fieldOrder = _columns.map((c) => c.field).toList();
    }

    if (_selectedFields.isEmpty) {
      const defaultFields = {
        'zone',
        'lock',
        'requester',
        'customer_no',
        'ldate',
      };
      _selectedFields = defaultFields
          .where((f) => _columns.any((c) => c.field == f))
          .toSet();
    }
  }

  /// ✅ ใช้ default columns (TH labels) — ไม่ต้องเรียก API
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

  /// ✅ โหลด /areas/overview
  Future<void> preloadOverview({bool forceRefresh = false}) async {
    try {
      final result =
          await _service.fetchOverview(forceRefresh: forceRefresh);
      _totalArea = result.totalArea ?? 0;
      _totalLeased = result.totalLeased ?? 0;
      _totalVacant = result.totalVacant ?? 0;
      notifyListeners();
    } catch (e) {
      print('⚠️ preloadOverview error: $e');
    }
  }

  Future<void> refresh() => preloadOverview(forceRefresh: true);

  // ===============================================================
  // Toggle column
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

  List<AreasReportColumn> get selectedColumnsList {
    return _columns
        .where((c) => _selectedFields.contains(c.field))
        .toList(growable: false);
  }

  // ===============================================================
  // Export to Excel (.xlsx)
  // ===============================================================
  Future<String?> exportToExcel() async {
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
      final result =
          await _service.fetchOverview(forceRefresh: true);
      final items = result.items;
      _totalArea = result.totalArea ?? 0;
      _totalLeased = result.totalLeased ?? 0;
      _totalVacant = result.totalVacant ?? 0;

      final cols = selectedColumnsList;
      final bytes = _buildExcelBytes(cols, items);

      final ts = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final filename = 'areas_report_$ts.xlsx';

      String? savedPath;
      if (kIsWeb) {
        savedPath = _webDownload(bytes, filename);
      } else {
        savedPath = await _nativeSaveAndShare(bytes, filename);
      }

      print('✅ xlsx saved: $savedPath (${bytes.length} bytes, ${items.length} rows)');

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

  /// Web-only: trigger download
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
    Future.delayed(const Duration(seconds: 30), () {
      html.Url.revokeObjectUrl(url);
    });
    return 'web://download/$filename';
  }

  /// Mobile/Desktop: save + share
  Future<String> _nativeSaveAndShare(
      List<int> bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'รายงานพื้นที่เช่า ($filename)',
    );
    return file.path;
  }

  /// ✅ สร้าง bytes ของ .xlsx (native Excel)
  List<int> _buildExcelBytes(
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
        final v = item.getBy(col.field) ?? '';
        row.add(v);
      }
      sheet.appendRow(row);
    }
    return excel.encode()!;
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
