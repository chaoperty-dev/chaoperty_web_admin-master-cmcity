// ============================================================================
// area_service.dart
// ============================================================================
// Service — เรียก API ทั้งหมดที่หน้า "จัดการ Area" ต้องใช้
// - ใช้ MyConstant().domain (PHP API) เป็น base
// - debugPrint error แทน swallow แบบไม่มีข้อมูล
// ============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../../Constant/Myconstant.dart';
import '../models/area_area_model.dart';
import '../models/area_count_model.dart';
import '../models/area_type_model.dart';
import '../models/area_zone_model.dart';
import '../../../../unity/area_zones_api.dart';

class AreaLocksResult {
  final List<AreaAreaModel> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const AreaLocksResult({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory AreaLocksResult.empty() => const AreaLocksResult(
        data: [],
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 0,
      );
}

class AreaService {
  AreaService();

  final AreaZonesApi _zonesApi = AreaZonesApi();

  String get _base => MyConstant().domain;
  String get _baseV2 => MyConstant().domain_v2;

  // ───────────── Zones ─────────────

  /// โหลดรายการโซนทั้งหมด
  Future<List<AreaZoneModel>> fetchZones(String rser) async {
    try {
      final raw = await _zonesApi.fetchGroups();
      final zones = <AreaZoneModel>[];
      for (final row in raw) {
        if (row is! AreaZone) continue;
        zones.add(AreaZoneModel.fromJson({
          'ser': row.ser ?? '0',
          'rser': row.ser ?? '0',
          'zn': row.zn ?? '',
          'qty': '${row.qty ?? 0}',
          'img': '0',
          'data_update': '',
        }));
      }
      zones.sort((a, b) {
        if (a.zn == 'ทั้งหมด') return -1;
        if (b.zn == 'ทั้งหมด') return 1;
        return a.zn.compareTo(b.zn);
      });
      return zones;
    } catch (e) {
      debugPrint('AreaService.fetchZones error: $e');
      return <AreaZoneModel>[];
    }
  }

  /// เช็คว่ามีโซนชื่อนี้แล้วหรือยัง
  Future<bool> zoneExists({
    required String rser,
    required String zn,
  }) async {
    final zones = await fetchZones(rser);
    return zones.any(
      (z) => z.zn.trim().toLowerCase() == zn.trim().toLowerCase(),
    );
  }

  /// เพิ่มโซนใหม่ (v2: `POST /admin/areas/zones`)
  /// - ต้องระบุ group_ser (หมวดโซน) ที่จะใส่โซนใหม่ลงไป
  Future<bool> addZone({
    required String rser,
    required String zn,
    String? groupSer,
    int qty = 0,
    int status = 1,
  }) async {
    final gs = groupSer ?? rser;
    final ok = await _zonesApi.addZone(
      groupSer: gs,
      zn: zn,
      qty: qty,
      status: status,
    );
    if (ok) {
      _zonesApi.clearCache();
    }
    return ok;
  }

  /// เพิ่มหมวดโซน (v2: `POST /admin/areas/groups`)
  Future<bool> addGroup({
    required String zn,
    int qty = 0,
    int pri = 0,
    int renPri = 0,
  }) async {
    final ok = await _zonesApi.addGroup(
      zn: zn,
      qty: qty,
      pri: pri,
      renPri: renPri,
    );
    if (ok) {
      _zonesApi.clearCache();
    }
    return ok;
  }

  /// ลบโซน (v2: `DELETE /admin/areas/zones/{zoneSer}`)
  Future<bool> deleteZone({
    required String rser,
    required String zoneSer,
  }) async {
    final ok = await _zonesApi.deleteZone(ser: zoneSer);
    if (ok) {
      _zonesApi.clearCache();
    }
    return ok;
  }

  /// ลบหมวดโซน (v2: `DELETE /admin/areas/groups/{ser}`)
  Future<bool> deleteGroup({required String ser}) async {
    final ok = await _zonesApi.deleteGroup(ser: ser);
    if (ok) {
      _zonesApi.clearCache();
    }
    return ok;
  }

  // ───────────── Areas (v2: /admin/areas/locks) ─────────────

  /// โหลด Area (v2) — `GET /admin/areas/locks?per_page=&page=&zone_ser=&st=&q=`
  /// - ใช้ Bearer token จาก AuthTokenStore
  /// - คืนทั้ง data + meta (pagination)
  Future<AreaLocksResult> fetchLocks({
    int perPage = 200,
    int page = 1,
    String zoneSer = '',
    String st = '',
    String q = '',
  }) async {
    final query = <String, String>{
      'per_page': '$perPage',
      'page': '$page',
    };
    if (zoneSer.isNotEmpty && zoneSer != '0') {
      query['zone_ser'] = zoneSer;
    }
    if (st.isNotEmpty) query['st'] = st;
    if (q.isNotEmpty) query['q'] = q;

    final uri = Uri.parse(
      '$_baseV2/admin/areas/locks',
    ).replace(queryParameters: query);

    try {
      final headers = await MyHeaders.build();
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) {
        debugPrint('AreaService.fetchLocks http=${response.statusCode}');
        return AreaLocksResult.empty();
      }
      final body = json.decode(response.body);
      if (body is! Map<String, dynamic>) return AreaLocksResult.empty();

      final dataRaw = body['data'];
      final metaRaw = body['meta'];
      final list = (dataRaw is List)
          ? dataRaw
              .whereType<Map>()
              .map((e) => AreaAreaModel.fromJson(e.cast<String, dynamic>()))
              .toList()
          : <AreaAreaModel>[];

      int asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
      final meta = (metaRaw is Map)
          ? metaRaw.cast<String, dynamic>()
          : const <String, dynamic>{};

      return AreaLocksResult(
        data: list,
        currentPage: asInt(meta['current_page'] ?? page),
        lastPage: asInt(meta['last_page'] ?? 1),
        perPage: asInt(meta['per_page'] ?? perPage),
        total: asInt(meta['total'] ?? list.length),
      );
    } catch (e) {
      debugPrint('AreaService.fetchLocks error: $e');
      return AreaLocksResult.empty();
    }
  }

  /// เพิ่ม Area ใหม่ (v2: `POST /admin/areas/locks`)
  /// body ตาม API: `{zone_ser, lncode, ln, area, rent}`
  Future<bool> addLock({
    required String zoneSer,
    required String lncode,
    required String ln,
    required String area,
    required String rent,
  }) async {
    final uri = Uri.parse('$_baseV2/admin/areas/locks');
    try {
      final headers = await MyHeaders.build();
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({
          'zone_ser': int.tryParse(zoneSer) ?? zoneSer,
          'lncode': lncode,
          'ln': ln,
          'area': num.tryParse(area) ?? area,
          'rent': num.tryParse(rent) ?? rent,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('AreaService.addLock error: $e');
      return false;
    }
  }

  /// ลบ Area (v2: `DELETE /admin/areas/locks/{ser}`)
  Future<bool> deleteLock({required String ser}) async {
    final uri = Uri.parse('$_baseV2/admin/areas/locks/$ser');
    try {
      final headers = await MyHeaders.build();
      final request = http.Request('DELETE', uri);
      request.headers.addAll(headers);
      final streamed = await request.send();
      return streamed.statusCode == 200;
    } catch (e) {
      debugPrint('AreaService.deleteLock error: $e');
      return false;
    }
  }

  /// แก้ไข Area (v2: `PUT /admin/areas/locks/{ser}`)
  /// body: `{rent, st}` (partial)
  Future<bool> updateLock({
    required String ser,
    String? rent,
    int? st,
  }) async {
    final uri = Uri.parse('$_baseV2/admin/areas/locks/$ser');
    try {
      final headers = await MyHeaders.build();
      final body = <String, dynamic>{};
      if (rent != null) body['rent'] = num.tryParse(rent) ?? rent;
      if (st != null) body['st'] = st;
      final response = await http.put(uri, headers: headers, body: json.encode(body));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('AreaService.updateLock error: $e');
      return false;
    }
  }

  // ───────────── Types ─────────────

  /// โหลด AreaType ทั้งหมด
  Future<List<AreaTypeModel>> fetchTypes(String rser) async {
    final url = '$_base/GC_areatype.php?isAdd=true&ren=$rser';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return <AreaTypeModel>[];
      final result = json.decode(response.body);
      if (result is! List) return <AreaTypeModel>[];
      return result
          .whereType<Map<String, dynamic>>()
          .map(AreaTypeModel.fromJson)
          .toList();
    } catch (e) {
      debugPrint('AreaService.fetchTypes error: $e');
      return <AreaTypeModel>[];
    }
  }

  // ───────────── Count ─────────────

  /// โหลดจำนวน Area ทั้งหมด
  Future<int> fetchAreaCount(String rser) async {
    final url = '$_base/GC_areaCount.php?isAdd=true&ren=$rser';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return 0;
      final result = json.decode(response.body);
      if (result is! List || result.isEmpty) return 0;
      final c = AreaCountModel.fromJson(
        (result.first as Map).cast<String, dynamic>(),
      );
      return int.tryParse(c.counta) ?? 0;
    } catch (e) {
      debugPrint('AreaService.fetchAreaCount error: $e');
      return 0;
    }
  }
}
