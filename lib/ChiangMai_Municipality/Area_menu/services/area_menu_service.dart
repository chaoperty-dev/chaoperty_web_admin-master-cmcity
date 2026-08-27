// ============================================================================
// area_menu_service.dart
// ============================================================================
// ✅ SELF-CONTAINED — ไม่ depend on ไฟล์อื่นในโปรเจกต์
// ทุกอย่าง (model, HTTP, parsing) อยู่ในไฟล์นี้ทั้งหมด
//
// API ที่ใช้:
// - GET {domain_v2}/admin/reports/areas/overview?fields=...
//   (Bearer token)
// - Cache 1 นาที (TTL เดียวกับของเดิม)
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:http/http.dart' as http;

// ============================================================================
// Internal Models — ของตัวเอง ไม่ import จากที่อื่น
// ============================================================================

/// 1 row จาก items[] ของ API areas/overview
class AreaItem {
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

  /// Parse แบบ defensive — ทุก field null-safe
  static AreaItem? fromJsonSafe(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      return AreaItem(
        subzone: _asString(json['subzone']),
        zone: _asString(json['zone']),
        lock: _asString(json['lock']),
        requester: _asString(json['requester']),
        customerNo: _asString(json['customer_no']),
        customerTel: _asString(json['customer_tel']),
        sdate: _asString(json['sdate']),
        ldate: _asString(json['ldate']),
        status: _asString(json['status']),
      );
    } catch (e) {
      print('⚠️ skip malformed area item: $e');
      return null;
    }
  }

  static String? _asString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }

  /// Composite key ใช้แทน UUID (API ใหม่ไม่มี unique id)
  String get compositeKey =>
      '${subzone ?? ''}|${zone ?? ''}|${lock ?? ''}';

  /// Map → JSON สำหรับ ViewModel
  Map<String, dynamic> toJson() => {
        'subzone': subzone,
        'zone': zone,
        'lock': lock,
        'requester': requester,
        'customer_no': customerNo,
        'customer_tel': customerTel,
        'sdate': sdate,
        'ldate': ldate,
        'status': status,
        'key': compositeKey,
      };
}

/// Wrapper ของ response.data
class AreaOverviewResult {
  final String? date;
  final String? announcementUuid;
  final int? totalArea;
  final int? totalLeased;
  final int? totalVacant;
  final List<AreaItem> items;

  const AreaOverviewResult({
    this.date,
    this.announcementUuid,
    this.totalArea,
    this.totalLeased,
    this.totalVacant,
    this.items = const [],
  });
}

// ============================================================================
// Internal helpers
// ============================================================================
// (no isolate helpers — parse ใน main thread พอ เพราะ items ไม่เยอะ)

// ============================================================================
// Service — ของตัวเองทั้งหมด
// ============================================================================
class AreaMenuService {
  AreaMenuService();

  // ---------- Cache ----------
  /// Overview cache (TTL 1 min) — ลด refetch 1000+ rows
  static const Duration _overviewCacheTtl = Duration(minutes: 1);
  AreaOverviewResult? _overviewCache;
  DateTime? _overviewCacheTime;
  String? _overviewCacheKey; // query string ของ cache ปัจจุบัน

  /// บังคับ refresh ทั้งหมด (เรียกจาก pull-to-refresh)
  void clearOverviewCache() {
    _overviewCache = null;
    _overviewCacheTime = null;
    _overviewCacheKey = null;
    print('🗑️ overview cache cleared');
  }

  /// สร้าง query string โดย omit param ที่เป็น null/ว่าง
  /// `fields` มี default ให้ ส่วนอื่นถ้า null/ว่างจะถูกข้าม
  static String _buildQueryKey({
    String? date,
    String? announcementUuid,
    String? zoneSer,
    String? subzoneSer,
    String? fields,
  }) {
    final parts = <String>[];
    if (date != null && date.isNotEmpty) {
      parts.add('date=${Uri.encodeQueryComponent(date)}');
    }
    if (announcementUuid != null && announcementUuid.isNotEmpty) {
      parts.add(
          'announcement_uuid=${Uri.encodeQueryComponent(announcementUuid)}');
    }
    if (zoneSer != null && zoneSer.isNotEmpty) {
      parts.add('zser=${Uri.encodeQueryComponent(zoneSer)}');
    }
    if (subzoneSer != null && subzoneSer.isNotEmpty) {
      parts.add('subzoneser=${Uri.encodeQueryComponent(subzoneSer)}');
    }
    parts.add(
        'fields=${Uri.encodeQueryComponent(fields ?? _defaultFields)}');
    return parts.join('&');
  }

  static const String _defaultFields =
      'subzone,zone,lock,requester,customer_no,customer_tel,sdate,ldate,status';

  // ===============================================================
  // ✅ Main: โหลด "ภาพรวมพื้นที่เช่า" — API เดียวจบ (areas/overview)
  // ===============================================================
  /// Optional params — ถ้า null จะไม่ถูกส่งใน URL
  /// - [date]              e.g. "2026-08-24" (default: today ที่ backend)
  /// - [announcementUuid]  cycle scope
  /// - [zoneSer]           zser (int as string)
  /// - [subzoneSer]        subzoneser (int as string)
  /// - [fields]            comma-separated field list
  Future<AreaOverviewResult> fetchAreasOverview({
    bool forceRefresh = false,
    String? date,
    String? announcementUuid,
    String? zoneSer,
    String? subzoneSer,
    String? fields,
  }) async {
    // ✅ Cache hit (TTL 1 min) — keyed by query string (omit null)
    final queryKey = _buildQueryKey(
      date: date,
      announcementUuid: announcementUuid,
      zoneSer: zoneSer,
      subzoneSer: subzoneSer,
      fields: fields,
    );
    if (!forceRefresh &&
        _overviewCache != null &&
        _overviewCacheTime != null &&
        _overviewCacheKey == queryKey) {
      final age = DateTime.now().difference(_overviewCacheTime!);
      if (age < _overviewCacheTtl) {
        print(
            '✅ fetchAreasOverview cache hit (key=$queryKey, ${age.inSeconds}s old, ${_overviewCache!.items.length} items)');
        return _overviewCache!;
      }
    }

    try {
      final url =
          '${MyConstant().domain_v2}/admin/reports/areas/overview?$queryKey';

      final headers = await _buildHeaders();

      print('🔗 fetchAreasOverview: $url');
      final res = await http.get(Uri.parse(url), headers: headers);
      print(
          '📥 fetchAreasOverview status: ${res.statusCode} bodyLen: ${res.body.length}');

      if (res.statusCode != 200) {
        print('❌ fetchAreasOverview status != 200: ${res.statusCode}');
        print(
            '   body: ${res.body.substring(0, res.body.length > 300 ? 300 : res.body.length)}');
        return const AreaOverviewResult(items: []);
      }

      final jsonRes = json.decode(res.body);
      if (jsonRes is! Map<String, dynamic>) {
        print('⚠️ fetchAreasOverview body is not a Map');
        return const AreaOverviewResult(items: []);
      }

      final data = jsonRes['data'];
      if (data is! Map<String, dynamic>) {
        print('⚠️ fetchAreasOverview data is not a Map');
        return const AreaOverviewResult(items: []);
      }

      final itemsRaw = data['items'];
      if (itemsRaw is! List) {
        print('⚠️ fetchAreasOverview items is not a List');
        return const AreaOverviewResult();
      }

      final items = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map((m) => AreaItem.fromJsonSafe(m))
          .whereType<AreaItem>()
          .toList();

      final result = AreaOverviewResult(
        date: _asStr(data['date']),
        announcementUuid: _asStr(data['announcement_uuid']),
        totalArea: _asInt(data['total_area']),
        totalLeased: _asInt(data['total_leased']),
        totalVacant: _asInt(data['total_vacant']),
        items: items,
      );

      print(
          '✅ fetchAreasOverview parsed: ${items.length} items (total_area=${result.totalArea}, leased=${result.totalLeased}, vacant=${result.totalVacant})');

      // ✅ เก็บ cache (TTL 1 min)
      _overviewCache = result;
      _overviewCacheTime = DateTime.now();
      _overviewCacheKey = queryKey;
      return result;
    } catch (e, st) {
      print('❌ fetchAreasOverview error: $e\n$st');
      return const AreaOverviewResult(items: []);
    }
  }

  static String? _asStr(dynamic v) {
    if (v == null) return null;
    return v.toString();
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  // ===============================================================
  // Headers — สร้างเอง (ใช้ Bearer token จาก MyToken.accessToken)
  // ===============================================================
  Future<Map<String, String>> _buildHeaders() async {
    final token = await MyToken.accessToken;
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}


