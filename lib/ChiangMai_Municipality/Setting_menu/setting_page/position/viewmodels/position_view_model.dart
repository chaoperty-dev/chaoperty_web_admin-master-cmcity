// ============================================================================
// position_view_model.dart
// ============================================================================
// ViewModel — state + logic ของหน้า "จัดการตำแหน่ง"
// - โหลด matrix จาก GET /admin/role-positions/matrix
// - toggle สิทธิ์แบบ optimistic (POST /admin/role-positions) — fail แล้ว rollback
// - ค้นหาทั้งชื่อตำแหน่งและชื่อสิทธิ์
// ============================================================================

import 'package:flutter/foundation.dart';

import '../models/position_matrix_model.dart';
import '../services/position_service.dart';

class PositionViewModel extends ChangeNotifier {
  PositionViewModel({PositionService? service})
      : _service = service ?? PositionService() {
    refresh();
  }

  final PositionService _service;

  List<PositionMatrixModel> _positions = [];
  List<PositionMatrixModel> get positions => _positions;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// ข้อความ error ล่าสุด (view ใช้โชว์ snack แล้วเคลียร์ผ่าน clearError)
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// id ของ role ที่กำลังบันทึกอยู่ (positionId:roleId) — ใช้ disabled checkbox
  final Set<String> _savingKeys = {};
  bool isSaving(String positionId, String roleId) =>
      _savingKeys.contains('$positionId:$roleId');

  /// กรองตามชื่อ/โค้ดตำแหน่ง หรือชื่อ/โค้ดสิทธิ์ที่เปิดอยู่
  List<PositionMatrixModel> get filtered {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _positions;
    return _positions.where((p) {
      final matchPos = p.displayName.toLowerCase().contains(q) ||
          p.code.toLowerCase().contains(q);
      if (matchPos) return true;
      return p.roles.any((r) =>
          r.nameTh.toLowerCase().contains(q) ||
          r.code.toLowerCase().contains(q));
    }).toList();
  }

  void setSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    _positions = await _service.fetchMatrix();
    _isLoading = false;
    if (_positions.isEmpty) {
      _errorMessage = 'โหลดข้อมูลตำแหน่งไม่สำเร็จ';
    }
    notifyListeners();
  }

  /// toggle สิทธิ์ของตำแหน่ง (optimistic + rollback เมื่อ fail)
  Future<void> toggleRole(
      PositionMatrixModel position, PositionRoleAssignment role) async {
    final key = '${position.id}:${role.roleId}';
    if (_savingKeys.contains(key)) return;

    final oldValue = role.enabled;
    role.enabled = !oldValue;
    _savingKeys.add(key);
    notifyListeners();

    final ok = await _service.setRoleActive(
      positionId: position.id,
      roleId: role.roleId,
      active: role.enabled,
    );

    _savingKeys.remove(key);
    if (!ok) {
      role.enabled = oldValue; // rollback
      _errorMessage =
          'บันทึกไม่สำเร็จ — สิทธิ์ "${role.nameTh}" ของตำแหน่ง "${position.displayName}"';
    }
    notifyListeners();
  }
}
