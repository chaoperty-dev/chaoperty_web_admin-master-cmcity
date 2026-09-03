// ============================================================================
// area_service.dart
// ============================================================================
// Service — เรียก API ทั้งหมดที่หน้า "จัดการ Area" ต้องใช้
// - ใช้ v2 API เท่านั้น (Bearer auth ผ่าน MyHeaders)
// - ฝั่ง AreaZonesApi จัดการ cache 1 นาที + invalidate ตอน mutate
// ============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../../Constant/Myconstant.dart';
import '../models/area_area_model.dart';
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

  String get _baseV2 => MyConstant().domain_v2;

  // ───────────── Groups (หมวดโซน) ─────────────

  /// โหลดรายการหมวดทั้งหมด — `GET /admin/areas/groups`
  Future<List<AreaZoneModel>> fetchGroups() async {
    try {
      final raw = await _zonesApi.fetchGroups();
      final list = <AreaZoneModel>[];
      for (final row in raw) {
        if (row is! AreaZone) continue;
        list.add(AreaZoneModel.fromGroup({
          'ser': row.ser ?? '0',
          'zn': row.zn ?? '',
          'qty': '${row.qty ?? 0}',
          'data_update': row.effectiveDataUpdate ?? '',
          'zones_count': row.zonesCount ?? 0,
        }));
      }
      return list;
    } catch (e) {
      debugPrint('AreaService.fetchGroups error: $e');
      return <AreaZoneModel>[];
    }
  }

  /// โหลดรายการโซนของหมวด — `GET /admin/areas/zones?group_ser=&per_page=`
  Future<List<AreaZoneModel>> fetchZonesOfGroup(String groupSer) async {
    try {
      final raw = await _zonesApi.fetchZones(groupSer: groupSer);
      final list = <AreaZoneModel>[];
      for (final row in raw) {
        if (row is! AreaZone) continue;
        list.add(AreaZoneModel.fromZone({
          'ser': row.ser ?? '0',
          'group_ser': groupSer,
          'zn': row.zn ?? '',
          'qty': '${row.qty ?? 0}',
          'data_update': row.effectiveDataUpdate ?? '',
        }));
      }
      return list;
    } catch (e) {
      debugPrint('AreaService.fetchZonesOfGroup error: $e');
      return <AreaZoneModel>[];
    }
  }

  /// เช็คชื่อโซนซ้ำในหมวด
  Future<bool> zoneExists({
    required String groupSer,
    required String zn,
  }) async {
    final zones = await fetchZonesOfGroup(groupSer);
    return zones.any(
      (z) => z.zn.trim().toLowerCase() == zn.trim().toLowerCase(),
    );
  }

  /// เพิ่มหมวด — `POST /admin/areas/groups`
  Future<bool> addGroup({
    required String zn,
    int qty = 0,
    int pri = 0,
    int renPri = 0,
  }) async {
    return _zonesApi.addGroup(zn: zn, qty: qty, pri: pri, renPri: renPri);
  }

  /// แก้ไขหมวด — `PUT /admin/areas/groups/{ser}`
  Future<bool> updateGroup({
    required String ser,
    String? zn,
    int? qty,
  }) async {
    return _zonesApi.updateGroup(ser: ser, zn: zn, qty: qty);
  }

  /// ลบหมวด — `DELETE /admin/areas/groups/{ser}`
  Future<bool> deleteGroup({required String ser}) async {
    return _zonesApi.deleteGroup(ser: ser);
  }

  // ───────────── Zones ─────────────

  /// เพิ่มโซน — `POST /admin/areas/zones`
  Future<bool> addZone({
    required String groupSer,
    required String zn,
    int qty = 0,
    int status = 1,
  }) async {
    return _zonesApi.addZone(
      groupSer: groupSer,
      zn: zn,
      qty: qty,
      status: status,
    );
  }

  /// แก้ไขโซน — `PUT /admin/areas/zones/{ser}`
  Future<bool> updateZone({
    required String ser,
    String? zn,
    int? qty,
  }) async {
    return _zonesApi.updateZone(ser: ser, zn: zn, qty: qty);
  }

  /// ลบโซน — `DELETE /admin/areas/zones/{ser}`
  Future<bool> deleteZone({required String ser}) async {
    return _zonesApi.deleteZone(ser: ser);
  }

  // ───────────── Areas (Locks) ─────────────

  /// โหลด Area (v2) — `GET /admin/areas/locks?per_page=&page=&zone_ser=&st=&q=`
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
      final response =
          await http.put(uri, headers: headers, body: json.encode(body));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('AreaService.updateLock error: $e');
      return false;
    }
  }
}