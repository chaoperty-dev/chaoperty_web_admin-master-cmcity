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
      final res = await _client.get(Uri.parse(url), headers: headers);

      if (res.statusCode != 200) {
        print('❌ fetchColumns status: ${res.statusCode}');
        return _defaultColumns();
      }

      final jsonRes = json.decode(res.body);
      if (jsonRes is! Map<String, dynamic>) {
        print('⚠️ fetchColumns body is not a Map');
        return _defaultColumns();
      }

      final data = jsonRes['data'];
      if (data is! List) {
        print('⚠️ fetchColumns data is not a List');
        return _defaultColumns();
      }

      final cols = data
          .whereType<Map<String, dynamic>>()
          .map((m) => CustomerReportColumn.fromJson(m))
          .toList(growable: false);

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
      final res = await _client.get(Uri.parse(url), headers: headers);

      if (res.statusCode != 200) {
        print('❌ fetchItems status: ${res.statusCode}');
        return const CustomerReportResult(total: 0, items: []);
      }

      final jsonRes = json.decode(res.body);
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
        _itemsCache =
            CustomerReportResult(total: total, items: const []);
        _itemsCacheTime = DateTime.now();
        return _itemsCache!;
      }

      final items = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map((m) => CustomerReportItem.fromJsonSafe(m))
          .whereType<CustomerReportItem>()
          .toList(growable: false);

      final result = CustomerReportResult(total: total, items: items);
      _itemsCache = result;
      _itemsCacheTime = DateTime.now();
      print('✅ fetchItems parsed: ${items.length} items (total=$total)');
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
