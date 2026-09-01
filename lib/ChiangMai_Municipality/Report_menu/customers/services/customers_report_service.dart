// ============================================================================
// customers_report_service.dart
// ============================================================================
// ✅ SELF-CONTAINED — ไม่ depend on ไฟล์อื่นในโปรเจกต์
//
// API:
// - GET {domain_v2}/admin/reports/customers/columns
// - GET {domain_v2}/admin/reports/customers
// - Cache TTL 5 นาที
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:http/http.dart' as http;

// ============================================================================
// Models
// ============================================================================

/// 1 column จาก /customers/columns
class CustomerReportColumn {
  final String field;
  final String label;
  const CustomerReportColumn({required this.field, required this.label});

  factory CustomerReportColumn.fromJson(Map<String, dynamic> json) {
    return CustomerReportColumn(
      field: (json['field'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
    );
  }
}

/// 1 row จาก /customers.items[]
class CustomerReportItem {
  final String? uuid;
  final String? custno;
  final String? taxno;
  final String? scname;
  final String? sname;
  final String? cname;
  final String? branch;
  final String? attn;
  final String? addr1;
  final String? addr2;
  final String? zip;
  final String? tel;
  final String? tax;
  final String? fax;
  final String? email;
  final String? lineid;
  final String? status;
  final int? st;
  final String? birth;
  final String? national;
  final String? religion;

  const CustomerReportItem({
    this.uuid,
    this.custno,
    this.taxno,
    this.scname,
    this.sname,
    this.cname,
    this.branch,
    this.attn,
    this.addr1,
    this.addr2,
    this.zip,
    this.tel,
    this.tax,
    this.fax,
    this.email,
    this.lineid,
    this.status,
    this.st,
    this.birth,
    this.national,
    this.religion,
  });

  /// Parse แบบ defensive
  static CustomerReportItem? fromJsonSafe(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      return CustomerReportItem(
        uuid: _s(json['uuid']),
        custno: _s(json['custno']),
        taxno: _s(json['taxno']),
        scname: _s(json['scname']),
        sname: _s(json['sname']),
        cname: _s(json['cname']),
        branch: _s(json['branch']),
        attn: _s(json['attn']),
        addr1: _s(json['addr_1']),
        addr2: _s(json['addr_2']),
        zip: _s(json['zip']),
        tel: _s(json['tel']),
        tax: _s(json['tax']),
        fax: _s(json['fax']),
        email: _s(json['email']),
        lineid: _s(json['lineid']),
        status: _s(json['status']),
        st: _i(json['st']),
        birth: _s(json['birth']),
        national: _s(json['national']),
        religion: _s(json['religion']),
      );
    } catch (_) {
      return null;
    }
  }

  /// Helper สำหรับ getter field value ตามชื่อ field
  String? getBy(String field) {
    switch (field) {
      case 'uuid':
        return uuid;
      case 'custno':
        return custno;
      case 'taxno':
        return taxno;
      case 'scname':
        return scname;
      case 'sname':
        return sname;
      case 'cname':
        return cname;
      case 'branch':
        return branch;
      case 'attn':
        return attn;
      case 'addr_1':
        return addr1;
      case 'addr_2':
        return addr2;
      case 'zip':
        return zip;
      case 'tel':
        return tel;
      case 'tax':
        return tax;
      case 'fax':
        return fax;
      case 'email':
        return email;
      case 'lineid':
        return lineid;
      case 'status':
        return status;
      case 'st':
        return st?.toString();
      case 'birth':
        return birth;
      case 'national':
        return national;
      case 'religion':
        return religion;
      default:
        return null;
    }
  }

  static String? _s(dynamic v) {
    if (v == null) return null;
    return v.toString();
  }

  static int? _i(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}

/// Wrapper ของ /customers response
class CustomerReportResult {
  final int total;
  final List<CustomerReportItem> items;
  const CustomerReportResult({required this.total, required this.items});
}

// ============================================================================
// Service
// ============================================================================
class CustomersReportService {
  CustomersReportService();

  final http.Client _client = http.Client();

  /// Cache TTL 5 นาที — ข้อมูลลูกค้าเปลี่ยนไม่บ่อย
  static const Duration _cacheTtl = Duration(minutes: 5);

  // ---------- Columns cache ----------
  List<CustomerReportColumn>? _columnsCache;
  DateTime? _columnsCacheTime;

  // ---------- Items cache ----------
  CustomerReportResult? _itemsCache;
  DateTime? _itemsCacheTime;

  // ===============================================================
  // GET /customers/columns
  // ===============================================================
  Future<List<CustomerReportColumn>> fetchColumns({
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
      final url = '${MyConstant().domain_v2}/admin/reports/customers/columns';
      final headers = await _buildHeaders();
      print('🔗 fetchColumns: $url');
      final res = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (res.statusCode != 200) {
        print('❌ fetchColumns status: ${res.statusCode}');
        return _defaultColumns();
      }

      // ✅ Parse JSON ใน background isolate — ไม่ block UI
      final cols = await compute(_parseCustomersColumnsIsolate, res.body);

      _columnsCache = cols;
      _columnsCacheTime = DateTime.now();
      print('✅ fetchColumns parsed: ${cols.length} columns');
      return cols;
    } catch (e, st) {
      print('❌ fetchColumns error: $e\n$st');
      return _defaultColumns();
    }
  }

  /// ✅ Default columns (TH labels — ไม่ต้อง fetch API)
  /// ใช้กรณีไม่ต้องการเรียก /columns endpoint
  static List<CustomerReportColumn> defaultColumns() {
    return const [
      CustomerReportColumn(field: 'uuid', label: 'รหัส UUID'),
      CustomerReportColumn(field: 'custno', label: 'เลขที่ลูกค้า'),
      CustomerReportColumn(field: 'taxno', label: 'เลขประจำตัวผู้เสียภาษี'),
      CustomerReportColumn(field: 'scname', label: 'ชื่อค้นหา'),
      CustomerReportColumn(field: 'sname', label: 'ชื่อย่อ'),
      CustomerReportColumn(field: 'cname', label: 'ชื่อ-นามสกุล'),
      CustomerReportColumn(field: 'branch', label: 'สาขา'),
      CustomerReportColumn(field: 'attn', label: 'ผู้ติดต่อ'),
      CustomerReportColumn(field: 'addr_1', label: 'ที่อยู่'),
      CustomerReportColumn(field: 'addr_2', label: 'ที่อยู่ 2'),
      CustomerReportColumn(field: 'zip', label: 'รหัสไปรษณีย์'),
      CustomerReportColumn(field: 'tel', label: 'โทรศัพท์'),
      CustomerReportColumn(field: 'tax', label: 'เลขประจำตัวผู้เสียภาษี'),
      CustomerReportColumn(field: 'fax', label: 'แฟกซ์'),
      CustomerReportColumn(field: 'email', label: 'อีเมล'),
      CustomerReportColumn(field: 'lineid', label: 'Line ID'),
      CustomerReportColumn(field: 'status', label: 'สถานะ'),
      CustomerReportColumn(field: 'st', label: 'ใช้งาน'),
      CustomerReportColumn(field: 'birth', label: 'วันเกิด'),
      CustomerReportColumn(field: 'national', label: 'สัญชาติ'),
      CustomerReportColumn(field: 'religion', label: 'ศาสนา'),
    ];
  }

  /// Fallback — เก็บไว้เผื่อ API error
  List<CustomerReportColumn> _defaultColumns() => defaultColumns();

  // ===============================================================
  // GET /customers
  // ===============================================================
  Future<CustomerReportResult> fetchItems({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _itemsCache != null &&
        _itemsCacheTime != null) {
      final age = DateTime.now().difference(_itemsCacheTime!);
      if (age < _cacheTtl) {
        print('✅ fetchItems cache hit (${age.inSeconds}s)');
        return _itemsCache!;
      }
    }

    try {
      final url = '${MyConstant().domain_v2}/admin/reports/customers';
      final headers = await _buildHeaders();
      print('🔗 fetchItems: $url');
      final res = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 60));

      if (res.statusCode != 200) {
        print('❌ fetchItems status: ${res.statusCode}');
        return const CustomerReportResult(total: 0, items: []);
      }

      // ✅ Parse JSON ใน background isolate — ไม่ block UI
      final result = await compute(_parseCustomersItemsIsolate, res.body);
      _itemsCache = result;
      _itemsCacheTime = DateTime.now();
      print('✅ fetchItems parsed: ${result.items.length} items (total=${result.total})');
      return result;
    } catch (e, st) {
      print('❌ fetchItems error: $e\n$st');
      return const CustomerReportResult(total: 0, items: []);
    }
  }

  void clearCache() {
    _columnsCache = null;
    _columnsCacheTime = null;
    _itemsCache = null;
    _itemsCacheTime = null;
    print('🗑️ cache cleared');
  }

  // ===============================================================
  // GET /v1/admin/c-customers (Laravel paginated)
  // - ใช้สำหรับเมนู "ทะเบียนผู้เช่า"
  // - response shape: { data: [...], meta: { current_page, last_page,
  //     per_page, total, from, to }, links: { first, last, prev, next } }
  // - addr_2 ตอนนี้เป็น **object** ไม่ใช่ string — encode กลับเป็น JSON
  //   string เพื่อให้ code เดิม (registration_edit_page.dart) ใช้ต่อได้
  // ===============================================================
  Future<List<CustomerReportItem>> fetchCCustomersAll({
    int perPage = 50,
    bool forceRefresh = false,
  }) async {
    // Cache (หน้าเดียว) — full list ขึ้นกับ TTL
    if (!forceRefresh &&
        _itemsCache != null &&
        _itemsCacheTime != null) {
      final age = DateTime.now().difference(_itemsCacheTime!);
      if (age < _cacheTtl) {
        return _itemsCache!.items;
      }
    }

    try {
      final headers = await _buildHeaders();
      final aggregated = <CustomerReportItem>[];
      int currentPage = 1;
      int? lastPage;
      int total = 0;

      while (true) {
        final url = '${MyConstant().domain_v1}/admin/c-customers'
            '?page=$currentPage&per_page=$perPage';
        print('🔗 fetchCCustomersAll: $url');
        final res = await _client
            .get(Uri.parse(url), headers: headers)
            .timeout(const Duration(seconds: 30));

        if (res.statusCode != 200) {
          print('❌ fetchCCustomersAll status: ${res.statusCode}');
          break;
        }

        final result =
            await compute(_parseCCustomersPageIsolate, res.body);
        if (result.items.isEmpty && currentPage == 1) {
          // empty list
          break;
        }
        aggregated.addAll(result.items);
        total = result.total;
        lastPage = result.lastPage;

        print(
            '✅ fetchCCustomersAll page $currentPage/${lastPage ?? "?"} — '
            '+${result.items.length} (total so far: ${aggregated.length})');

        if (lastPage == null || currentPage >= lastPage) break;
        currentPage++;
        if (currentPage > 200) {
          // safety — กัน loop ไม่จบ
          print('⚠️ fetchCCustomersAll: reached page guard 200, stop');
          break;
        }
      }

      // อัปเดต itemsCache (เก็บเป็น CustomerReportResult เดิม)
      _itemsCache = CustomerReportResult(total: total, items: aggregated);
      _itemsCacheTime = DateTime.now();
      print(
          '✅ fetchCCustomersAll done: ${aggregated.length} items (total=$total)');
      return aggregated;
    } catch (e, st) {
      print('❌ fetchCCustomersAll error: $e\n$st');
      return const <CustomerReportItem>[];
    }
  }

  // ===============================================================
  // Headers (Bearer token)
  // ===============================================================
  Future<Map<String, String>> _buildHeaders() async {
    final token = await MyToken.accessToken;
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

// ============================================================================
// Isolate-bound helpers
// ============================================================================

/// ✅ Top-level function — required by `compute()`
/// รันใน background isolate → UI ไม่ค้างตอน parse JSON
CustomerReportResult _parseCustomersItemsIsolate(String body) {
  final jsonRes = json.decode(body);
  if (jsonRes is! Map<String, dynamic>) {
    print('⚠️ fetchItems body is not a Map');
    return const CustomerReportResult(total: 0, items: []);
  }

  final data = jsonRes['data'];
  if (data is! Map<String, dynamic>) {
    print('⚠️ fetchItems data is not a Map');
    return const CustomerReportResult(total: 0, items: []);
  }

  final total = (data['total'] is num)
      ? (data['total'] as num).toInt()
      : int.tryParse(data['total']?.toString() ?? '') ?? 0;

  final itemsRaw = data['items'];
  if (itemsRaw is! List) {
    return CustomerReportResult(total: total, items: const []);
  }

  final items = itemsRaw
      .whereType<Map<String, dynamic>>()
      .map((m) => CustomerReportItem.fromJsonSafe(m))
      .whereType<CustomerReportItem>()
      .toList(growable: false);

  return CustomerReportResult(total: total, items: items);
}

/// ✅ Top-level function — สำหรับ fetchColumns
/// รันใน background isolate → UI ไม่ค้างตอน parse JSON
List<CustomerReportColumn> _parseCustomersColumnsIsolate(String body) {
  final jsonRes = json.decode(body);
  if (jsonRes is! Map<String, dynamic>) {
    print('⚠️ fetchColumns body is not a Map');
    return CustomersReportService.defaultColumns();
  }

  final data = jsonRes['data'];
  if (data is! List) {
    print('⚠️ fetchColumns data is not a List');
    return CustomersReportService.defaultColumns();
  }

  return data
      .whereType<Map<String, dynamic>>()
      .map((m) => CustomerReportColumn.fromJson(m))
      .toList(growable: false);
}

/// ✅ Parse /v1/admin/c-customers page (Laravel paginated shape)
/// - data: List of items
/// - meta.current_page, meta.last_page, meta.per_page, meta.total
/// - addr_2 (object) → encode กลับเป็น JSON string เพื่อ backward compat
class _CCustomerPage {
  final List<CustomerReportItem> items;
  final int total;
  final int? lastPage;
  const _CCustomerPage({
    required this.items,
    required this.total,
    this.lastPage,
  });
}

_CCustomerPage _parseCCustomersPageIsolate(String body) {
  final jsonRes = json.decode(body);
  if (jsonRes is! Map<String, dynamic>) {
    return const _CCustomerPage(items: [], total: 0, lastPage: null);
  }

  final data = jsonRes['data'];
  if (data is! List) {
    return const _CCustomerPage(items: [], total: 0, lastPage: null);
  }

  final items = data
      .whereType<Map<String, dynamic>>()
      .map((m) {
        // normalize addr_2: object/Map → JSON string
        final raw = m['addr_2'];
        if (raw is Map) {
          m = Map<String, dynamic>.from(m);
          m['addr_2'] = json.encode(raw);
        }
        return CustomerReportItem.fromJsonSafe(m);
      })
      .whereType<CustomerReportItem>()
      .toList(growable: false);

  int? total;
  int? lastPage;
  final meta = jsonRes['meta'];
  if (meta is Map) {
    if (meta['total'] is num) total = (meta['total'] as num).toInt();
    if (meta['last_page'] is num) {
      lastPage = (meta['last_page'] as num).toInt();
    }
  }

  return _CCustomerPage(items: items, total: total ?? 0, lastPage: lastPage);
}
