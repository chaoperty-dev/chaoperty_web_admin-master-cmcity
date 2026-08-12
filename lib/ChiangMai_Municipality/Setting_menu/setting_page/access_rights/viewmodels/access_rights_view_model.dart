// ============================================================================
// access_rights_view_model.dart
// ============================================================================
// ViewModel — จัดการ state + business logic ของหน้า "สิทธิ์การเข้าถึง"
// - เรียก Service โหลด users / positions / roles
// - แจ้ง View ผ่าน Stream<AccessRightsEvent>
// - ไม่ผูกกับ Flutter UI ตรงๆ (ใช้ ChangeNotifier เพื่อ rebuild)
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/access_rights_config.dart';
import '../models/access_rights_event.dart';
import '../models/access_rights_position.dart';
import '../models/access_rights_role.dart';
import '../models/access_rights_user.dart';
import '../services/access_rights_service.dart';

class AccessRightsViewModel extends ChangeNotifier {
  AccessRightsViewModel({
    required AccessRightsConfig config,
    AccessRightsService? service,
  })  : _config = config,
        _service = service ?? AccessRightsService() {
    _bootstrap();
  }

  final AccessRightsConfig _config;
  final AccessRightsService _service;

  // ---------- Event channel ----------
  final StreamController<AccessRightsEvent> _eventController =
      StreamController<AccessRightsEvent>.broadcast();
  Stream<AccessRightsEvent> get events => _eventController.stream;

  // ---------- Data ----------
  List<AccessRightsUser> _users = [];
  List<AccessRightsUser> get users => _users;

  // Filtered + sorted view
  List<AccessRightsUser> _filtered = [];
  List<AccessRightsUser> get filtered => _filtered;

  // ---------- Positions / Roles ----------
  List<AccessRightsPosition> _positions = [];
  List<AccessRightsPosition> get positions => _positions;
  List<AccessRightsRole> _roles = [];
  List<AccessRightsRole> get roles => _roles;

  // ---------- Pagination ----------
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  final int _perPage = 50;
  String? _linksNext;
  String? _linksPrev;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  int get perPage => _perPage;
  String? get linksNext => _linksNext;
  String? get linksPrev => _linksPrev;

  // ---------- UI state ----------
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _sortColumn = 'username';
  bool _sortAscending = true;
  String get sortColumn => _sortColumn;
  bool get sortAscending => _sortAscending;

  // ---------- Config getters ----------
  String get title => _config.title;
  bool get readOnly => _config.readOnly;

  // ===============================================================
  // Init
  // ===============================================================
  Future<void> _bootstrap() async {
    if (_config.routeData != null && _config.routeData!.isNotEmpty) {
      _searchQuery = _config.routeData!;
    }
    await Future.wait([
      _loadPositions(),
      _loadRoles(),
    ]);
    await refresh();
  }

  // ===============================================================
  // Loaders
  // ===============================================================
  Future<void> _loadPositions() async {
    try {
      _positions = await _service.fetchPositions();
      notifyListeners();
    } catch (e) {
      _emit(AccessRightsErrorEvent('โหลดตำแหน่งล้มเหลว: $e'));
    }
  }

  Future<void> _loadRoles() async {
    try {
      _roles = await _service.fetchRoles();
      notifyListeners();
    } catch (e) {
      _emit(AccessRightsErrorEvent('โหลดสิทธิ์ล้มเหลว: $e'));
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    try {
      _users = await _service.fetchUsers();
      _total = _users.length;
      _lastPage = _users.isEmpty ? 1 : 1; // local-only — backend ไม่ส่ง paginate
      _currentPage = 1;
      _applyFilter();
    } catch (e) {
      _emit(AccessRightsErrorEvent('โหลดผู้ใช้ล้มเหลว: $e'));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===============================================================
  // Search
  // ===============================================================
  void setSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void executeSearch() {
    _applyFilter();
    notifyListeners();
  }

  // ===============================================================
  // Sort
  // ===============================================================
  void onSort(String column) {
    if (_sortColumn == column) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumn = column;
      _sortAscending = true;
    }
    _applyFilter();
    notifyListeners();
  }

  // ===============================================================
  // CRUD
  // ===============================================================
  Future<bool> createUser({
    required Uint8List fileData,
    required String username,
    required String email,
    required String password,
    required String prefix,
    required String firstName,
    required String lastName,
    required String citizenId,
    required String phone,
    required String prepostion,
    required int positionId,
    required List<int> roleIds,
  }) async {
    final code = await _service.createUser(
      fileData: fileData,
      username: username,
      email: email,
      password: password,
      prefix: prefix,
      firstName: firstName,
      lastName: lastName,
      citizenId: citizenId,
      phone: phone,
      prepostion: prepostion,
      positionId: positionId,
      roleIds: roleIds,
    );
    final ok = code == 200 || code == 201;
    if (ok) {
      _emit(const AccessRightsSuccessEvent('เพิ่มผู้ใช้สำเร็จ'));
      await refresh();
    } else {
      _emit(AccessRightsErrorEvent('เพิ่มผู้ใช้ล้มเหลว (HTTP $code)'));
    }
    return ok;
  }

  Future<bool> updateUser({
    required String userUuid,
    required String username,
    required String email,
    required String password,
    required String prefix,
    required String firstName,
    required String lastName,
    required String citizenId,
    required String phone,
    required String prepostion,
    required int positionId,
    required List<int> roleIds,
  }) async {
    final code = await _service.updateUser(
      userUuid: userUuid,
      username: username,
      email: email,
      password: password,
      prefix: prefix,
      firstName: firstName,
      lastName: lastName,
      citizenId: citizenId,
      phone: phone,
      prepostion: prepostion,
      positionId: positionId,
      roleIds: roleIds,
    );
    final ok = code == 200 || code == 201;
    if (ok) {
      _emit(const AccessRightsSuccessEvent('แก้ไขผู้ใช้สำเร็จ'));
      await refresh();
    } else {
      _emit(AccessRightsErrorEvent('แก้ไขผู้ใช้ล้มเหลว (HTTP $code)'));
    }
    return ok;
  }

  Future<bool> uploadSignature({
    required String userUuid,
    required Uint8List fileData,
  }) async {
    final code = await _service.uploadSignature(
      userUuid: userUuid,
      fileData: fileData,
    );
    final ok = code == 200 || code == 201;
    if (ok) {
      _emit(const AccessRightsSuccessEvent('อัปโหลดลายเซ็นสำเร็จ'));
      await refresh();
    } else {
      _emit(AccessRightsErrorEvent('อัปโหลดลายเซ็นล้มเหลว (HTTP $code)'));
    }
    return ok;
  }

  Future<Uint8List?> loadSignatureImage(String signatureUuid) {
    return _service.fetchSignatureImage(signatureUuid);
  }

  // ===============================================================
  // UI actions
  // ===============================================================
  void onCreate() => _emit(const AccessRightsOpenCreateEvent());
  void onEdit(String uuid) => _emit(AccessRightsOpenEditEvent(uuid));
  void onSignature(String uuid) => _emit(AccessRightsOpenSignatureEvent(uuid));

  // ===============================================================
  // Helpers
  // ===============================================================
  void _emit(AccessRightsEvent e) {
    if (_eventController.isClosed) return;
    _eventController.add(e);
  }

  void _applyFilter() {
    final q = _searchQuery.trim().toLowerCase();
    Iterable<AccessRightsUser> list = _users;
    if (q.isNotEmpty) {
      list = list.where((u) {
        return u.username.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.fullName.toLowerCase().contains(q) ||
            u.positionName.toLowerCase().contains(q) ||
            u.roles.any((r) => r.nameTh.toLowerCase().contains(q));
      });
    }
    final arr = list.toList();
    arr.sort((a, b) {
      final av = _valueForSort(a, _sortColumn);
      final bv = _valueForSort(b, _sortColumn);
      final cmp = av.compareTo(bv);
      return _sortAscending ? cmp : -cmp;
    });
    _filtered = arr;
  }

  String _valueForSort(AccessRightsUser u, String col) {
    switch (col) {
      case 'username':
        return u.username.toLowerCase();
      case 'email':
        return u.email.toLowerCase();
      case 'position':
        return u.positionName.toLowerCase();
      case 'roles':
        return u.roles.isEmpty
            ? ''
            : u.roles.map((r) => r.nameTh).join(', ').toLowerCase();
      case 'level':
        return u.primaryRoleLevel.toString().padLeft(5, '0');
      case 'name':
      default:
        return u.fullName.toLowerCase();
    }
  }

  // ===============================================================
  // Lifecycle
  // ===============================================================
  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
