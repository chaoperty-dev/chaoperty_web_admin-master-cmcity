// ============================================================================
// areas_report_service.dart
// ============================================================================
// ✅ SELF-CONTAINED — ไม่ depend on ไฟล์อื่นในโปรเจกต์
//
// API:
// - GET {domain_v2}/admin/reports/areas/columns
// - GET {domain_v2}/admin/reports/areas/overview?fields=...
// - Cache TTL 5 นาที
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:http/http.dart' as http;

// ============================================================================
// Models
// ============================================================================

class AreasReportColumn {
  final String field;
  final String label;
  const AreasReportColumn({required this.field, required this.label});

  factory AreasReportColumn.fromJson(Map<String, dynamic> json) {
    return AreasReportColumn(
      field: (json['field'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
    );
  }
}

class AreasReportItem {
  final String? subzone;
  final String? zone;
  final String? lock;
  final String? requester;
  final String? customerNo;
  final String? customerTel;
  final String? sdate;
  final String? ldate;
  final String? status;

  const AreasReportItem({
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

  static AreasReportItem? fromJsonSafe(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      return AreasReportItem(
        subzone: _s(json['subzone']),
        zone: _s(json['zone']),
        lock: _s(json['lock']),
        requester: _s(json['requester']),
        customerNo: _s(json['customer_no']),
        customerTel: _s(json['customer_tel']),
        sdate: _s(json['sdate']),
        ldate: _s(json['ldate']),
        status: _s(json['status']),
      );
    } catch (_) {
      return null;
    }
  }

  String? getBy(String field) {
    switch (field) {
      case 'subzone':
        return subzone;
      case 'zone':
        return zone;
      case 'lock':
        return lock;
      case 'requester':
        return requester;
      case 'customer_no':
        return customerNo;
      case 'customer_tel':
        return customerTel;
      case 'sdate':
        return sdate;
      case 'ldate':
        return ldate;
      case 'status':
        return status;
      default:
        return null;
    }
  }

  static String? _s(dynamic v) {
    if (v == null) return null;
    return v.toString();
  }
}

class AreasReportResult {
  final String? date;
  final String? announcementUuid;
  final int? totalArea;
  final int? totalLeased;
  final int? totalVacant;
  final List<AreasReportItem> items;

  const AreasReportResult({
    this.date,
    this.announcementUuid,
    this.totalArea,
    this.totalLeased,
    this.totalVacant,
    this.items = const [],
  });
}

// ============================================================================
// Service
// ============================================================================
class AreasReportService {
  AreasReportService();

  final http.Client _client = http.Client();
  static const Duration _cacheTtl = Duration(minutes: 5);

  List<AreasReportColumn>? _columnsCache;
  DateTime? _columnsCacheTime;

  AreasReportResult? _itemsCache;
  DateTime? _itemsCacheTime;

  void clearCache() {
    _columnsCache = null;
    _columnsCacheTime = null;
    _itemsCache = null;
    _itemsCacheTime = null;
    print('🗑️ areas cache cleared');
  }

  // ===============================================================
  // GET /areas/columns
  // ===============================================================
  Future<List<AreasReportColumn>> fetchColumns({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _columnsCache != null &&
        _columnsCacheTime != null) {
      final age = DateTime.now().difference(_columnsCacheTime!);
      if (age < _cacheTtl) {
        print('✅ fetchColumns cache hit (${age.inSeconds}s)');
        return _columnsCache!;
      }
    }

    try {
      final url = '${MyConstant().domain_v2}/admin/reports/areas/columns';
      final headers = await _buildHeaders();
      print('🔗 fetchColumns: $url');
      final res = await _client.get(Uri.parse(url), headers: headers);

      if (res.statusCode != 200) {
        return _defaultColumns();
      }

      final jsonRes = json.decode(res.body);
      if (jsonRes is! Map<String, dynamic>) {
        return _defaultColumns();
      }

      final data = jsonRes['data'];
      if (data is! List) {
        return _defaultColumns();
      }

      final cols = data
          .whereType<Map<String, dynamic>>()
          .map((m) => AreasReportColumn.fromJson(m))
          .toList(growable: false);

      _columnsCache = cols;
      _columnsCacheTime = DateTime.now();
      print('✅ fetchColumns parsed: ${cols.length} columns');
      return cols;
    } catch (e) {
      print('❌ fetchColumns error: $e');
      return _defaultColumns();
    }
  }

  /// ✅ Default columns (TH labels) — ไม่ต้อง fetch API
  static List<AreasReportColumn> defaultColumns() {
    return const [
      AreasReportColumn(field: 'subzone', label: 'หมวดโซนพื้นที่'),
      AreasReportColumn(field: 'zone', label: 'โซนพื้นที่'),
      AreasReportColumn(field: 'lock', label: 'ล็อค'),
      AreasReportColumn(field: 'requester', label: 'ผู้เช่า'),
      AreasReportColumn(field: 'customer_no', label: 'เลขที่ลูกค้า'),
      AreasReportColumn(field: 'customer_tel', label: 'โทรศัพท์'),
      AreasReportColumn(field: 'sdate', label: 'วันเริ่มสัญญา'),
      AreasReportColumn(field: 'ldate', label: 'วันสิ้นสุดสัญญา'),
      AreasReportColumn(field: 'status', label: 'สถานะคำขอ'),
    ];
  }

  List<AreasReportColumn> _defaultColumns() => defaultColumns();

  // ===============================================================
  // GET /areas/overview
  // ===============================================================
  static const String _overviewFields =
      'subzone,zone,lock,requester,customer_no,customer_tel,sdate,ldate,status';

  Future<AreasReportResult> fetchOverview({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _itemsCache != null &&
        _itemsCacheTime != null) {
      final age = DateTime.now().difference(_itemsCacheTime!);
      if (age < _cacheTtl) {
        print('✅ fetchOverview cache hit (${age.inSeconds}s)');
        return _itemsCache!;
      }
    }

    try {
      final url =
          '${MyConstant().domain_v2}/admin/reports/areas/overview?fields=$_overviewFields';
      final headers = await _buildHeaders();
      print('🔗 fetchOverview: $url');
      final res = await _client.get(Uri.parse(url), headers: headers);

      if (res.statusCode != 200) {
        return const AreasReportResult();
      }

      final jsonRes = json.decode(res.body);
      if (jsonRes is! Map<String, dynamic>) {
        return const AreasReportResult();
      }

      final data = jsonRes['data'];
      if (data is! Map<String, dynamic>) {
        return const AreasReportResult();
      }

      final itemsRaw = data['items'];
      if (itemsRaw is! List) {
        return const AreasReportResult();
      }

      final items = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map((m) => AreasReportItem.fromJsonSafe(m))
          .whereType<AreasReportItem>()
          .toList(growable: false);

      final result = AreasReportResult(
        date: data['date']?.toString(),
        announcementUuid: data['announcement_uuid']?.toString(),
        totalArea: (data['total_area'] is num)
            ? (data['total_area'] as num).toInt()
            : null,
        totalLeased: (data['total_leased'] is num)
            ? (data['total_leased'] as num).toInt()
            : null,
        totalVacant: (data['total_vacant'] is num)
            ? (data['total_vacant'] as num).toInt()
            : null,
        items: items,
      );

      _itemsCache = result;
      _itemsCacheTime = DateTime.now();
      print('✅ fetchOverview parsed: ${items.length} items');
      return result;
    } catch (e) {
      print('❌ fetchOverview error: $e');
      return const AreasReportResult();
    }
  }

  Future<Map<String, String>> _buildHeaders() async {
    final token = await MyToken.accessToken;
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
