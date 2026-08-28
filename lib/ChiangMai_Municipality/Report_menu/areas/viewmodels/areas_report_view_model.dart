// ============================================================================
// areas_report_view_model.dart
// ============================================================================
// ViewModel — state + delegate export ไปยัง platform-specific exporter
//
// ✅ LIGHTWEIGHT: ไม่ import excel_dart / protect / share_plus / path_provider
// ✅ Heavy packages ถูก load ผ่าน exporter (deferred) — เฉพาะตอนกด export
// ✅ ไม่มี dart:html / dart:io (แก้บั๊ก conflict บน mobile build)
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/areas_report_exporter.dart';
import '../services/areas_report_service.dart';
import '../../_shared/export_phase.dart';

class AreasReportViewModel extends ChangeNotifier {
  AreasReportViewModel({
    AreasReportService? service,
  }) : _service = service ?? AreasReportService() {
    _init();
  }

  final AreasReportService _service;

  /// ✅ Lazy — สร้าง exporter ตอนกด export ครั้งแรก
  /// ทำให้หน้านี้เปิดเร็ว (ไม่ load heavy deps ตอน init)
  AreasReportExporter? _exporter;

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

  // ✅ ExportPhase — UX: แสดง progress message ตรง phase จริง
  ExportPhase _phase = ExportPhase.idle;
  ExportPhase get phase => _phase;
  String get phaseLabel => _phase.label;

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
    unawaited(preloadOverview());
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
    _phase = ExportPhase.loadingData;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1) โหลด overview (ใช้ cache ถ้ายังสด — ไม่ force refresh เพื่อลด network round-trip)
      final result = await _service.fetchOverview();
      _totalArea = result.totalArea ?? 0;
      _totalLeased = result.totalLeased ?? 0;
      _totalVacant = result.totalVacant ?? 0;

      // 2) ✅ Phase เปลี่ยน → สร้างไฟล์
      _phase = ExportPhase.buildingFile;
      notifyListeners();

      // 3) Lazy create exporter (ครั้งแรกจะ load heavy packages)
      _exporter ??= buildExporter();

      // 4) ส่งให้ platform-specific exporter (build xlsx + encrypt + save + share)
      final saved = await _exporter!.export(
        cols: selectedColumnsList,
        items: result.items,
        password: password,
      );

      _lastExportPath = saved;
      _isExporting = false;
      _phase = ExportPhase.done;
      notifyListeners();

      // ✅ Auto-reset กลับ idle หลัง 1.5s — ให้ผู้ใช้เห็น "เสร็จ" สั้น ๆ
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_phase == ExportPhase.done) {
          _phase = ExportPhase.idle;
          notifyListeners();
        }
      });

      return saved;
    } catch (e, st) {
      print('❌ exportToExcel error: $e\n$st');
      _errorMessage = 'Export ล้มเหลว: $e';
      _isExporting = false;
      _phase = ExportPhase.error;
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