// ============================================================================
// area_menu_service.dart
// ============================================================================
// SELF-CONTAINED — ไม่ depend on ไฟล์อื่นในโปรเจกต์
// ทุกอย่าง (model, HTTP, parsing) อยู่ในไฟล์นี้ทั้งหมด
//
// API ที่ใช้:
// - GET {domain_v2}/admin/areas/overview
//     params: zser, subzoneser, q, status, sort_by, sort_dir, per_page=50, page
//     SERVER-DRIVEN — filter/search/status/sort/pagination ที่ฝั่ง API ทั้งหมด
//     (Bearer token)
// - GET {domain}/GC_zone.php / GC_zone_sub.php — dropdown โซน (legacy, ser+zn)
// - Cache overview 1 นาที ต่อ 1 query key (query ใหม่ = ยิง API ใหม่เสมอ)
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// Internal Models
// ============================================================================

/// 1 row จาก items[] ของ API areas/overview
class AreaItem {
  final String? aser; // id จริงของ area
  final String? zser;
  final String? subzone;
  final String? zone;
  final String? lock;
  final String? requester;
  final String? customerNo;
  final String? customerTel;
  final String? sdate;
  final String? ldate;
  final String? status;

  const AreaItem({
    this.aser,
    this.zser,
    this.subzone,
    this.zone,
    this.lock,
    this.requester,
    this.customerNo,
    this.customerTel,
    this.sdate,
    this.ldate,
    this.status,
  });

  static String? _asStr(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  factory AreaItem.fromJsonSafe(Map<String, dynamic> j) {
    return AreaItem(
      aser: _asStr(j['aser']),
      zser: _asStr(j['zser']),
      subzone: _asStr(j['subzone']),
      zone: _asStr(j['zone']),
      lock: _asStr(j['lock']),
      requester: _asStr(j['requester']),
      customerNo: _asStr(j['customer_no']),
      customerTel: _asStr(j['customer_tel']),
      sdate: _asStr(j['sdate']),
      ldate: _asStr(j['ldate']),
      status: _asStr(j['status']),
    );
  }

  Map<String, dynamic> toJson() => {
        'aser': aser,
        'zser': zser,
        'subzone': subzone,
        'zone': zone,
        'lock': lock,
        'requester': requester,
        'customer_no': customerNo,
        'customer_tel': customerTel,
        'sdate': sdate,
        'ldate': ldate,
        'status': status,
      };

  /// key ไม่ซ้ำต่อ row — ใช้ aser จริงถ้ามี
  String get compositeKey => (aser != null && aser!.isNotEmpty)
      ? 'aser:$aser'
      : '${subzone ?? ''}|${zone ?? ''}|${lock ?? ''}';
}

/// Wrapper ของ response.data (1 หน้า — server-driven)
class AreaOverviewResult {
  final String? date;
  final String? announcementUuid;
  final int? totalArea;
  final int? totalLeased;
  final int? totalVacant;
  final int? duplicateLeases;
  final List<AreaItem> items;
  // server pagination
  final int currentPage;
  final int perPage;
  final int totalRows;
  final int lastPage;

  const AreaOverviewResult({
    this.date,
    this.announcementUuid,
    this.totalArea,
    this.totalLeased,
    this.totalVacant,
    this.duplicateLeases,
    this.items = const [],
    this.currentPage = 1,
    this.perPage = 50,
    this.totalRows = 0,
    this.lastPage = 1,
  });
}

// ============================================================================
// Service
// ============================================================================
class AreaMenuService {
  AreaMenuService();

  static const String _allLabel = 'ทั้งหมด';
  static const Duration _overviewCacheTtl = Duration(minutes: 1);

  // ---------- Cache ----------
  AreaOverviewResult? _overviewCache;
  DateTime? _overviewCacheTime;
  String? _overviewCacheKey;
  final Map<String, dynamic> _zoneCache = {};

  void clearOverviewCache() {
    _overviewCache = null;
    _overviewCacheTime = null;
    _overviewCacheKey = null;
  }

  // ---------- Helpers ----------
  static String? _asStr(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  Future<Map<String, String>> _buildHeaders() async {
    final token = await MyToken.accessToken;
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// ren จาก SharedPreferences (fallback '195') — ใช้กับ legacy zone API
  Future<String> _getRen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('ren');
      return (ren == null || ren.isEmpty) ? '195' : ren;
    } catch (_) {
      return '195';
    }
  }

  /// legacy zone rows → [{'ser','zn'}...] + 'ทั้งหมด' (ser='0') นำหน้า
  List<Map<String, dynamic>> _withAllEntry(List raw) {
    final out = <Map<String, dynamic>>[
      {'ser': '0', 'zn': _allLabel},
    ];
    for (final row in raw) {
      if (row is! Map) continue;
      final ser = _asStr(row['ser']);
      final zn = _asStr(row['zn']);
      if (zn == null) continue;
      out.add({'ser': ser ?? '', 'zn': zn});
    }
    return out;
  }

  // ===============================================================
  // Overview — GET /admin/areas/overview (1 หน้าต่อ 1 call)
  // ===============================================================
  /// สร้าง query string — param ที่ null/ว่าง/'0' จะไม่ถูกส่ง (= ทั้งหมด)
  static String _buildQueryKey({
    String? zoneSer,
    String? subzoneSer,
    String? q,
    String? status,
    String? sortBy,
    String? sortDir,
    int page = 1,
  }) {
    final parts = <String>[];
    if (zoneSer != null && zoneSer.isNotEmpty && zoneSer != '0') {
      parts.add('zser=${Uri.encodeQueryComponent(zoneSer)}');
    }
    if (subzoneSer != null && subzoneSer.isNotEmpty && subzoneSer != '0') {
      parts.add('subzoneser=${Uri.encodeQueryComponent(subzoneSer)}');
    }
    if (q != null && q.trim().isNotEmpty) {
      parts.add('q=${Uri.encodeQueryComponent(q.trim())}');
    }
    if (status != null && status.isNotEmpty) {
      parts.add('status=${Uri.encodeQueryComponent(status)}');
    }
    parts.add('sort_by=${Uri.encodeQueryComponent(sortBy ?? 'lock')}');
    parts.add('sort_dir=${Uri.encodeQueryComponent(sortDir ?? 'asc')}');
    parts.add('per_page=50');
    parts.add('page=$page');
    return parts.join('&');
  }

  Future<AreaOverviewResult> fetchAreasOverview({
    bool forceRefresh = false,
    String? zoneSer,
    String? subzoneSer,
    String? q,
    String? status,
    String? sortBy = 'lock',
    String? sortDir = 'asc',
    int page = 1,
  }) async {
    final queryKey = _buildQueryKey(
      zoneSer: zoneSer,
      subzoneSer: subzoneSer,
      q: q,
      status: status,
      sortBy: sortBy,
      sortDir: sortDir,
      page: page,
    );

    // Cache hit (query เดิม เดิม page ภายใน 1 นาที)
    if (!forceRefresh &&
        _overviewCache != null &&
        _overviewCacheTime != null &&
        _overviewCacheKey == queryKey) {
      final age = DateTime.now().difference(_overviewCacheTime!);
      if (age < _overviewCacheTtl) {
        print(
            '[Area] overview cache hit ($queryKey, ${age.inSeconds}s, ${_overviewCache!.items.length} rows)');
        return _overviewCache!;
      }
    }

    try {
      final headers = await _buildHeaders();
      final url = '${MyConstant().domain_v2}/admin/areas/overview?$queryKey';
      print('╔══════════════════════════════════════════════════════════════');
      print('║ [fetchAreasOverview] GET →$url');
      print(
          '║   • zser / subzoneser: ${zoneSer ?? 'null'} / ${subzoneSer ?? 'null'}');
      print('║   • q               : "${q ?? 'null'}"');
      print('║   • status          : ${status ?? 'null'}');
      print(
          '║   • sort            : ${sortBy ?? 'lock'} / ${sortDir ?? 'asc'}');
      print('║   • perPage         : 50');
      print('║   • page            : $page');
      print('╚══════════════════════════════════════════════════════════════');
      final res = await http.get(Uri.parse(url), headers: headers);
      print('[Area] status ${res.statusCode} bodyLen ${res.body.length}');

      if (res.statusCode != 200) {
        print(
            '[Area] error body: ${res.body.length > 300 ? res.body.substring(0, 300) : res.body}');
        return const AreaOverviewResult();
      }

      final jsonRes = json.decode(res.body);
      if (jsonRes is! Map<String, dynamic>) return const AreaOverviewResult();
      final data = jsonRes['data'];
      if (data is! Map<String, dynamic>) return const AreaOverviewResult();

      final itemsRaw = data['items'];
      final items = (itemsRaw is List)
          ? itemsRaw
              .whereType<Map<String, dynamic>>()
              .map((m) => AreaItem.fromJsonSafe(m))
              .whereType<AreaItem>()
              .toList(growable: false)
          : <AreaItem>[];

      // pagination block
      int currentPage = page;
      int perPage = 50;
      int totalRows = items.length;
      int lastPage = 1;
      final pag = data['pagination'];
      if (pag is Map<String, dynamic>) {
        currentPage = _asInt(pag['current_page']) ?? page;
        perPage = _asInt(pag['per_page']) ?? 50;
        totalRows = _asInt(pag['total']) ?? items.length;
        lastPage = _asInt(pag['last_page']) ?? 1;
      }

      final result = AreaOverviewResult(
        date: _asStr(data['date']),
        announcementUuid: _asStr(data['announcement_uuid']),
        totalArea: _asInt(data['total_area']),
        totalLeased: _asInt(data['total_leased']),
        totalVacant: _asInt(data['total_vacant']),
        duplicateLeases: _asInt(data['duplicate_leases']),
        items: items,
        currentPage: currentPage,
        perPage: perPage,
        totalRows: totalRows,
        lastPage: lastPage,
      );

      print('[Area] parsed ${items.length} rows '
          '(page $currentPage/$lastPage, total $totalRows)');

      _overviewCache = result;
      _overviewCacheTime = DateTime.now();
      _overviewCacheKey = queryKey;
      return result;
    } catch (e, st) {
      print('[Area] fetchAreasOverview error: $e\n$st');
      return const AreaOverviewResult();
    }
  }

  // ===============================================================
  // Zones dropdown — legacy API (ser + zn)
  // เดิม derive จาก items — ตอนนี้ server-driven จึงโหลดแยก
  // ===============================================================

  /// หมวดโซน — GC_zone_sub.php → [{'ser','zn'}...] + ทั้งหมด (ser='0')
  Future<List<Map<String, dynamic>>> fetchSubZones() async {
    final ren = await _getRen();
    final cacheKey = 'subzone_$ren';
    final cached = _zoneCache[cacheKey];
    if (cached is List) return _withAllEntry(cached);

    final url = '${MyConstant().domain}/GC_zone_sub.php?isAdd=true&ren=$ren';
    try {
      final res = await http.get(Uri.parse(url));
      final decoded = json.decode(res.body);
      if (decoded is! List) return _withAllEntry(const []);
      _zoneCache[cacheKey] = decoded;
      return _withAllEntry(decoded);
    } catch (e) {
      print('[Area] fetchSubZones error: $e');
      return _withAllEntry(const []);
    }
  }

  /// โซน — GC_zone.php → [{'ser','zn'}...] + ทั้งหมด (ser='0')
  /// กรองตามหมวดโซน (sub_zone == subzoneSer) เหมือน license_request_service
  Future<List<Map<String, dynamic>>> fetchZones({String? subzoneSer}) async {
    final ren = await _getRen();
    final cacheKey = 'zone_$ren';
    List? raw;
    final cached = _zoneCache[cacheKey];
    if (cached is List) {
      raw = cached;
    } else {
      final url = '${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren';
      try {
        final res = await http.get(Uri.parse(url));
        final decoded = json.decode(res.body);
        if (decoded is! List) return _applyZoneFilter(const [], subzoneSer);
        _zoneCache[cacheKey] = decoded;
        raw = decoded;
      } catch (e) {
        print('[Area] fetchZones error: $e');
        return _applyZoneFilter(const [], subzoneSer);
      }
    }
    return _applyZoneFilter(raw, subzoneSer);
  }

  /// เหมือน license _applyZoneFilter — เก็บ 'ทั้งหมด' + zone ที่ sub_zone ตรง
  List<Map<String, dynamic>> _applyZoneFilter(
      List rawList, String? subzoneSer) {
    final out = <Map<String, dynamic>>[
      {'ser': '0', 'zn': _allLabel},
    ];
    for (final row in rawList) {
      if (row is! Map) continue;
      final ser = _asStr(row['ser']);
      final zn = _asStr(row['zn']);
      if (zn == null) continue;
      if (subzoneSer != null &&
          subzoneSer != '0' &&
          _asStr(row['sub_zone']) != subzoneSer) {
        continue;
      }
      out.add({'ser': ser ?? '', 'zn': zn});
    }
    out.sort((a, b) {
      if (a['zn'] == _allLabel) return -1;
      if (b['zn'] == _allLabel) return 1;
      return (a['zn'] ?? '').compareTo(b['zn'] ?? '');
    });
    return out;
  }
}
