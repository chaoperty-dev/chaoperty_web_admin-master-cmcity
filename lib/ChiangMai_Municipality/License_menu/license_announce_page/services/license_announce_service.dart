// Service: ใช้ API v1 (/admin/announcement/*) — ต้องมี Bearer token
//
// ✅ JSON parse ทำใน compute() isolate (M2-ext pattern)
//    ไม่ block UI ตอนโหลด list ยาว
// ✅ HTTP timeout — กัน request ค้าง
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../Constant/Myconstant.dart';
import '../../../Model/AnnounceMentActive_Model.dart';
import '../../../unity/area_zones_api.dart';
import '../models/license_announce_item.dart';

class LicenseAnnounceService {
  String get _baseV1 => MyConstant().domain_v1;
  final AreaZonesApi _zonesApi = AreaZonesApi();

  Future<Map<String, String>> _headers() async => MyHeaders.build();

  // ------------------------------------------------------------------
  // List
  // ------------------------------------------------------------------
  /// โหลด "ประกาศที่กำลัง active" — /admin/announcement/active
  Future<List<LicenseAnnounceItem>> fetchActive() async {
    try {
      final headers = await _headers();
      final url = Uri.parse('$_baseV1/admin/announcement/active');
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        debugPrint('fetchActive status=${response.statusCode}');
        return <LicenseAnnounceItem>[];
      }
      // ✅ Parse ใน background isolate — ไม่ block UI
      return compute(_parseActiveIsolate, response.body);
    } catch (e) {
      debugPrint('fetchActive error: $e');
      return <LicenseAnnounceItem>[];
    }
  }

  /// โหลด "ประกาศทั้งหมด (history)" — /admin/announcement/history
  Future<List<LicenseAnnounceItem>> fetchHistory() async {
    try {
      final headers = await _headers();
      final url = Uri.parse('$_baseV1/admin/announcement/history');
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 60));
      if (response.statusCode != 200) {
        debugPrint('fetchHistory status=${response.statusCode}');
        return <LicenseAnnounceItem>[];
      }
      // ✅ Parse ใน background isolate — ไม่ block UI
      return compute(_parseHistoryIsolate, response.body);
    } catch (e) {
      debugPrint('fetchHistory error: $e');
      return <LicenseAnnounceItem>[];
    }
  }

  /// Legacy: ใช้ชื่อเดิมเพื่อไม่ให้ ViewModel build fail
  Future<List<LicenseAnnounceItem>> fetchAnnouncements(
          String rser, String zoneSer) =>
      fetchActive();

  // ------------------------------------------------------------------
  // Detail — GET /admin/announcement/{uuid}
  // ------------------------------------------------------------------
  /// Response จริงของ detail endpoint:
  /// ```
  /// {
  ///   "data": {
  ///     "uuid": "...",
  ///     "computed_status": "...",
  ///     "can_edit_zone": false,
  ///     "content": { "title": "...", "content": "...", ... },
  ///     "schedule": { "published_at": "...", "effective_at": "...", "expired_at": "...", "c_date_start": "...", "c_date_end": "..." },
  ///     "properties": [{ "zone_id": 9, "zone_pn": "ท่าแพโซน 1" }, ...]
  ///   }
  /// }
  /// ```
  /// ต่างจาก /active ที่ fields ซ้อนใน "announcement" object
  /// → Flatten ให้ตรงกับ AnnounceMentActiveModel ก่อน parse
  Future<LicenseAnnounceItem?> fetchDetail(String uuid) async {
    if (uuid.isEmpty) return null;
    try {
      final headers = await _headers();
      final url = Uri.parse('$_baseV1/admin/announcement/$uuid');
      final response = await http.get(url, headers: headers);
      if (response.statusCode != 200) {
        debugPrint('fetchDetail status=${response.statusCode}');
        return null;
      }
      final result = json.decode(response.body);
      // drill into 'data' (ลึกสุด 3 ชั้น)
      Map<String, dynamic>? nodeNullable;
      if (result is Map) {
        Map cur = result;
        for (int i = 0; i < 3; i++) {
          if (cur['data'] is Map) {
            cur = cur['data'] as Map;
          } else {
            break;
          }
        }
        nodeNullable = Map<String, dynamic>.from(cur);
      }
      if (nodeNullable == null || nodeNullable.isEmpty) {
        debugPrint('fetchDetail: cannot extract node');
        return null;
      }
      final node = nodeNullable;

      // ── Flatten ──
      // ดึง schedule fields ขึ้นมา top-level (effective_at, expired_at, published_at, c_date_start, c_date_end)
      final schedule = node['schedule'];
      if (schedule is Map) {
        for (final k in [
          'published_at',
          'effective_at',
          'expired_at',
          'c_date_start',
          'c_date_end',
        ]) {
          if (schedule[k] != null && node[k] == null) {
            node[k] = schedule[k];
          }
        }
      }

      // ดึง zone_id / zone_pn จาก properties[0] ขึ้นมา top-level (รองรับ field เดิม)
      final props = node['properties'];
      if (props is List && props.isNotEmpty && props.first is Map) {
        final p = Map<String, dynamic>.from(props.first as Map);
        if (node['zone_id'] == null && p['zone_id'] != null) {
          node['zone_id'] = p['zone_id'];
        }
        if (node['zone_pn'] == null && p['zone_pn'] != null) {
          node['zone_pn'] = p['zone_pn'];
        }
      }

      // ตรวจสอบ field หลักก่อน parse
      if (node['effective_at'] == null && node['expired_at'] == null) {
        debugPrint('fetchDetail: response has no schedule data');
      }

      final model = AnnounceMentActiveModel.fromJson(node);
      return LicenseAnnounceItem.fromActiveModel(model);
    } catch (e, st) {
      debugPrint('fetchDetail error: $e\n$st');
      return null;
    }
  }

  // ------------------------------------------------------------------
  // Zones (v2 — /admin/areas/groups + /admin/areas/zones)
  // ------------------------------------------------------------------
  /// โหลดรายการ "โซน" (zones) — รองรับ filter ตาม subZone
  Future<List<LicenseAnnounceZone>> fetchZones(String rser,
      {String? zoneSubSer}) async {
    try {
      final raw = await _zonesApi.fetchZones(groupSer: zoneSubSer);
      return _mapZones(raw);
    } catch (e) {
      debugPrint('fetchZones error: $e');
      return _mapZones(const []);
    }
  }

  List<LicenseAnnounceZone> _mapZones(List<dynamic> rawList) {
    final defaultZone = LicenseAnnounceZone.fromJson(<String, dynamic>{
      'ser': '0',
      'rser': '0',
      'zn': 'ทั้งหมด',
      'qty': '0',
      'img': '0',
      'data_update': '0',
      'sub_zone': '0',
    });
    final zones = <LicenseAnnounceZone>[defaultZone];
    for (final row in rawList) {
      if (row is! AreaZone) continue;
      zones.add(LicenseAnnounceZone.fromJson(<String, dynamic>{
        'ser': row.ser ?? '0',
        'zn': row.zn ?? '',
        'rser': row.ser ?? '0',
        'qty': '${row.qty ?? 0}',
        'sub_zone': '0',
      }));
    }
    return zones;
  }

  /// โหลดรายการ "หมวดโซนพื้นที่" (subzones)
  Future<List<LicenseAnnounceSubZone>> fetchSubZones(String rser) async {
    try {
      final raw = await _zonesApi.fetchGroups();
      return _mapSubZones(raw);
    } catch (e) {
      debugPrint('fetchSubZones error: $e');
      return _mapSubZones(const []);
    }
  }

  List<LicenseAnnounceSubZone> _mapSubZones(List<dynamic> rawList) {
    final defaultMap = <String, dynamic>{
      'ser': '0',
      'rser': '0',
      'zn': 'ทั้งหมด',
    };
    final subs = <LicenseAnnounceSubZone>[
      LicenseAnnounceSubZone.fromJson(defaultMap),
    ];
    for (final row in rawList) {
      if (row is! AreaZone) continue;
      subs.add(LicenseAnnounceSubZone.fromJson(<String, dynamic>{
        'ser': row.ser ?? '0',
        'zn': row.zn ?? '',
        'rser': row.ser ?? '0',
      }));
    }
    return subs;
  }

  // ------------------------------------------------------------------
  // Create — /admin/announcement
  // ------------------------------------------------------------------
  Future<bool> addAnnouncement({
    required String rser,
    required String title,
    required String sdate,
    required String edate,
    required String announceDate,
    String? body,
    String? zone,
    String? cDateStart,
    String? cDateEnd,
    List<int>? zoneIds,
    List<Map<String, dynamic>>? zoneData,
  }) async {
    try {
      final headers = await _headers();
      final url = Uri.parse('$_baseV1/admin/announcement');
      // สร้าง zones จาก zoneData (UI ส่งมา) หรือ zoneIds (legacy)
      final List<Map<String, dynamic>> zonesPayload = [];
      if (zoneData != null && zoneData.isNotEmpty) {
        for (final zd in zoneData) {
          final zoneId = (zd['zone_id'] is int)
              ? zd['zone_id'] as int
              : int.tryParse(zd['zone_id']?.toString() ?? '') ?? 0;
          if (zoneId <= 0) continue;
          final subzoneId = (zd['subzone_id'] is int)
              ? zd['subzone_id'] as int
              : int.tryParse(zd['subzone_id']?.toString() ?? '') ?? 0;
          zonesPayload.add({
            'property_id': 0,
            'property_pn': '0',
            'zone_id': zoneId,
            'zone_pn': zd['zone_pn']?.toString() ?? '',
            'subzone_id': subzoneId,
            'subzone_pn': '0',
          });
        }
      } else if (zoneIds != null && zoneIds.isNotEmpty) {
        for (final zoneId in zoneIds) {
          if (zoneId <= 0) continue;
          zonesPayload.add({
            'property_id': 0,
            'property_pn': '0',
            'zone_id': zoneId,
            'zone_pn': '',
            'subzone_id': 0,
            'subzone_pn': '0',
          });
        }
      } else if (zone != null && zone.isNotEmpty && zone != '0') {
        final zoneId = int.tryParse(zone) ?? 0;
        if (zoneId > 0) {
          zonesPayload.add({
            'property_id': 0,
            'property_pn': '0',
            'zone_id': zoneId,
            'zone_pn': '',
            'subzone_id': 0,
            'subzone_pn': '0',
          });
        }
      }
      final payload = <String, dynamic>{
        'lang': 'TH',
        'title': title,
        'content': body ?? title,
        'meta': <Map<String, dynamic>>[
          {'key': 'author', 'value': 'Admin'},
          {'key': 'version', 'value': '1.0'},
        ],
        'zones': zonesPayload,
        'c_date_start': cDateStart ?? sdate,
        'c_date_end': cDateEnd ?? edate,
        'effective_at': sdate,
        'expired_at': edate,
        'published_at': announceDate,
      };
      debugPrint(
          '[addAnnouncement] payload=${json.encode(payload)}\n[addAnnouncement] url=$url');
      final response =
          await http.post(url, headers: headers, body: json.encode(payload));
      debugPrint(
          '[addAnnouncement] status=${response.statusCode}\n[addAnnouncement] body=${response.body}');
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 409;
    } catch (e, st) {
      debugPrint('addAnnouncement error: $e\n$st');
      return false;
    }
  }

  // ------------------------------------------------------------------
  // Update — PUT /admin/announcement/{uuid}/content
  // ------------------------------------------------------------------
  Future<bool> updateAnnouncement({
    required String rser,
    required String ser,
    required String title,
    required String sdate,
    required String edate,
    required String announceDate,
    String? body,
    String? zone,
    String? cDateStart,
    String? cDateEnd,
    List<int>? zoneIds,
    List<Map<String, dynamic>>? zoneData,
  }) async {
    if (ser.isEmpty) return false;
    try {
      final headers = await _headers();
      final url = Uri.parse('$_baseV1/admin/announcement/$ser/content');
      final payload = <String, dynamic>{
        'title': title,
        'content': body ?? title,
      };
      final response =
          await http.put(url, headers: headers, body: json.encode(payload));
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 409;
    } catch (e) {
      debugPrint('updateAnnouncement error: $e');
      return false;
    }
  }

  // ------------------------------------------------------------------
  // Delete — POST /admin/announcement/{uuid}/delete
  // ------------------------------------------------------------------
  Future<bool> deleteAnnouncement(
      {required String rser, required String ser}) async {
    if (ser.isEmpty) return false;
    try {
      final headers = await _headers();
      final url = Uri.parse('$_baseV1/admin/announcement/$ser/delete');
      final response = await http.post(url, headers: headers);
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 409;
    } catch (e) {
      debugPrint('deleteAnnouncement error: $e');
      return false;
    }
  }
}

// ============================================================================
// Isolate-bound helpers (M2-ext pattern matching areas/customers reports)
// ============================================================================

/// Parse /active response — body shape:
/// `{ "data": [ {...}, {...} ] }` หรือ `{ "data": { ... } }` (single item)
List<LicenseAnnounceItem> _parseActiveIsolate(String body) {
  try {
    final result = json.decode(body);
    final data = (result is Map) ? result['data'] : null;
    if (data == null) return <LicenseAnnounceItem>[];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) =>
              AnnounceMentActiveModel.fromJson(Map<String, dynamic>.from(e)))
          .map(LicenseAnnounceItem.fromActiveModel)
          .toList(growable: false);
    }
    if (data is Map) {
      final m =
          AnnounceMentActiveModel.fromJson(Map<String, dynamic>.from(data));
      return [LicenseAnnounceItem.fromActiveModel(m)];
    }
    return <LicenseAnnounceItem>[];
  } catch (e) {
    debugPrint('_parseActiveIsolate error: $e');
    return <LicenseAnnounceItem>[];
  }
}

/// Parse /history response — body shape:
/// `{ "data": { "data": [ {...}, ... ] } }` หรือ `{ "data": [ ... ] }`
List<LicenseAnnounceItem> _parseHistoryIsolate(String body) {
  try {
    final result = json.decode(body);
    final data = result is Map ? result['data'] : null;
    final list = (data is Map) ? data['data'] : (data is List ? data : null);
    if (list is! List) return <LicenseAnnounceItem>[];
    return list
        .whereType<Map>()
        .map((e) =>
            AnnounceMentActiveModel.fromJson(Map<String, dynamic>.from(e)))
        .map(LicenseAnnounceItem.fromActiveModel)
        .toList(growable: false);
  } catch (e) {
    debugPrint('_parseHistoryIsolate error: $e');
    return <LicenseAnnounceItem>[];
  }
}
