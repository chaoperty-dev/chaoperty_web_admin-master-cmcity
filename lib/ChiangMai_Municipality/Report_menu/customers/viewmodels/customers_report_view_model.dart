// ============================================================================
// customers_report_view_model.dart
// ============================================================================
// ViewModel — state + delegate export ไปยัง platform-specific exporter
//
// ✅ LIGHTWEIGHT: ไม่ import excel_dart / protect / share_plus / path_provider
// ✅ Heavy packages ถูก load ผ่าน exporter (deferred) — เฉพาะตอนกด export
// ✅ ไม่มี dart:html / dart:io (แก้บั๊ก conflict บน mobile build)
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/customers_report_exporter.dart';
import '../services/customers_report_service.dart';

class CustomersReportViewModel extends ChangeNotifier {
  CustomersReportViewModel({
    CustomersReportService? service,
  }) : _service = service ?? CustomersReportService() {
    _init();
  }

  final CustomersReportService _service;

  /// ✅ Lazy — สร้าง exporter ตอนกด export ครั้งแรก
  /// ทำให้หน้านี้เปิดเร็ว (ไม่ load heavy deps ตอน init)
  CustomersReportExporter? _exporter;

  // ---------- State ----------
  List<CustomerReportColumn> _columns = [];
  List<CustomerReportColumn>? _sortedCache;
  List<CustomerReportColumn> get columns => _sortedCache ??= _computeSorted();

  List<CustomerReportColumn> _computeSorted() {
    if (_fieldOrder.isEmpty) return _columns;
    final byField = {for (final c in _columns) c.field: c};
    final out = <CustomerReportColumn>[];
    for (final f in _fieldOrder) {
      final c = byField[f];
      if (c != null) out.add(c);
    }
    for (final c in _columns) {
      if (!_fieldOrder.contains(c.field)) out.add(c);
    }
    return out;
  }

  void _invalidateSortCache() {
    _sortedCache = null;
  }

  List<String> _fieldOrder = [];
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
    _initDefaultColumns();
    notifyListeners();
    // ✅ Fire-and-forget — ไม่ block render ครั้งแรก
    // หน้าโชว์ tile ทันที, total count จะ update ทีหลังเมื่อ API ตอบ
    unawaited(preloadItems());
  }

  void _initDefaultColumns() {
    _columns = CustomersReportService.defaultColumns();
    if (_fieldOrder.length != _columns.length) {
      _fieldOrder = _columns.map((c) => c.field).toList();
    }
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
    _invalidateSortCache();
  }

  Future<void> loadColumns({bool forceRefresh = false}) async {
    _initDefaultColumns();
    notifyListeners();
  }

  void reorderColumns(int oldIndex, int newIndex) {
    if (_fieldOrder.isEmpty) {
      _fieldOrder = _columns.map((c) => c.field).toList();
    }
    if (newIndex > oldIndex) newIndex -= 1;
    final field = _fieldOrder.removeAt(oldIndex);
    _fieldOrder.insert(newIndex, field);
    _invalidateSortCache();
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

  List<CustomerReportColumn> get selectedColumnsList {
    return _columns
        .where((c) => _selectedFields.contains(c.field))
        .toList(growable: false);
  }

  // ===============================================================
  // Export — delegate ให้ platform-specific exporter
  // ===============================================================
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
      // 1) โหลด items (ใช้ cache ถ้ายังสด — ไม่ force refresh เพื่อลด network round-trip)
      final result = await _service.fetchItems();
      _totalItems = result.total;

      // 2) Lazy create exporter (ครั้งแรกจะ load heavy packages)
      _exporter ??= buildExporter();

      // 3) ส่งให้ platform-specific exporter
      final saved = await _exporter!.export(
        cols: selectedColumnsList,
        items: result.items,
        password: password,
      );

      _lastExportPath = saved;
      _isExporting = false;
      notifyListeners();
      return saved;
    } catch (e, st) {
      print('❌ exportToExcel error: $e\n$st');
      _errorMessage = 'Export ล้มเหลว: $e';
      _isExporting = false;
      notifyListeners();
      return null;
    }
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