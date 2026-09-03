// ============================================================================
// area_zones_api.dart
// ============================================================================
// ✅ SELF-CONTAINED — central zone service ใช้ร่วมทุกเมนู
// ใช้แทน GC_zone.php / GC_zone_sub.php ทั้งหมด
//
// API (v2) — ไม่มี cache เพื่อให้ข้อมูล realtime ตาม backend:
// - GET    /admin/areas/groups                          → หมวดโซน
// - GET    /admin/areas/zones?group_ser=&per_page=&page=→ โซนของหมวดนั้น
// - GET    /admin/areas/groups/{ser}                    → detail หมวด
// - GET    /admin/areas/zones/{ser}                     → detail โซน
// - POST   /admin/areas/groups     body {zn,qty,pri,ren_pri}
// - POST   /admin/areas/zones      body {group_ser,zn,qty,status}
// - PUT    /admin/areas/groups/{ser} body {zn,qty} (partial)
// - PUT    /admin/areas/zones/{ser}  body {zn,qty} (partial)
// - DELETE /admin/areas/groups/{ser}
// - DELETE /admin/areas/zones/{ser}
// ============================================================================

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../Constant/Myconstant.dart';

class AreaZone {
  final String? ser;
  final String? zn;
  final int? qty;
  final int? zonesCount; // groups เท่านั้น
  final String? dataUpdate; // จาก data_update
  final String? datex; // fallback date-only

  const AreaZone({
    this.ser,
    this.zn,
    this.qty,
    this.zonesCount,
    this.dataUpdate,
    this.datex,
  });

  factory AreaZone.fromJson(Map<String, dynamic> j) {
    int? toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('${v ?? ''}');
    }

    return AreaZone(
      ser: j['ser']?.toString(),
      zn: j['zn']?.toString(),
      qty: toInt(j['qty']),
      zonesCount: toInt(j['zones_count']),
      dataUpdate:
          j['data_update']?.toString().isNotEmpty == true
              ? j['data_update'].toString()
              : null,
      datex:
          j['datex']?.toString().isNotEmpty == true
              ? j['datex'].toString()
              : null,
    );
  }

  /// รวม data_update + datex fallback
  String? get effectiveDataUpdate {
    if (dataUpdate != null) return dataUpdate;
    if (datex != null) return '${datex}T00:00:00';
    return null;
  }
}

class AreaZonesApi {
  AreaZonesApi();

  static const String _allLabel = 'ทั้งหมด';

  // ---------- Read ----------

  Future<List<AreaZone>> fetchGroups() async {
    try {
      final headers = await MyHeaders.build();
      final url = '${MyConstant().domain_v2}/admin/areas/groups';
      final res = await http.get(Uri.parse(url), headers: headers);
      if (res.statusCode != 200) {
        debugPrintLog('groups status ${res.statusCode}');
        return _withAll(const []);
      }
      final j = json.decode(res.body);
      if (j is! Map<String, dynamic>) return _withAll(const []);
      final data = j['data'];
      if (data is! List) return _withAll(const []);
      final items = <AreaZone>[];
      for (final row in data) {
        if (row is Map<String, dynamic>) {
          items.add(AreaZone.fromJson(row));
        } else if (row is Map) {
          items.add(AreaZone.fromJson(Map<String, dynamic>.from(row)));
        }
      }
      return _withAll(items);
    } catch (e) {
      debugPrintLog('fetchGroups error: $e');
      return _withAll(const []);
    }
  }

  Future<List<AreaZone>> fetchZones({
    String? groupSer,
    int page = 1,
    int perPage = 200,
  }) async {
    try {
      final headers = await MyHeaders.build();
      final params = <String, String>{
        'per_page': '$perPage',
        'page': '$page',
      };
      if (groupSer != null && groupSer.isNotEmpty && groupSer != '0') {
        params['group_ser'] = groupSer;
      }
      final uri = Uri.parse('${MyConstant().domain_v2}/admin/areas/zones')
          .replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode != 200) {
        debugPrintLog('zones status ${res.statusCode}');
        return _withAll(const []);
      }
      final j = json.decode(res.body);
      if (j is! Map<String, dynamic>) return _withAll(const []);
      final data = j['data'];
      if (data is! List) return _withAll(const []);
      final items = <AreaZone>[];
      for (final row in data) {
        if (row is Map<String, dynamic>) {
          items.add(AreaZone.fromJson(row));
        } else if (row is Map) {
          items.add(AreaZone.fromJson(Map<String, dynamic>.from(row)));
        }
      }
      return _withAll(items);
    } catch (e) {
      debugPrintLog('fetchZones error: $e');
      return _withAll(const []);
    }
  }

  /// prefix 'ทั้งหมด' (ser='0') นำหน้า list
  List<AreaZone> _withAll(List<AreaZone> raw) {
    return [const AreaZone(ser: '0', zn: _allLabel), ...raw];
  }

  // ---------- Mutate (v2) ----------

  Future<bool> addGroup({
    required String zn,
    int qty = 0,
    int pri = 0,
    int renPri = 0,
  }) async {
    final uri = Uri.parse('${MyConstant().domain_v2}/admin/areas/groups');
    try {
      final headers = await MyHeaders.build();
      final res = await http.post(
        uri,
        headers: headers,
        body: json.encode({
          'zn': zn,
          'qty': qty,
          'pri': pri,
          'ren_pri': renPri,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrintLog('addGroup error: $e');
      return false;
    }
  }

  Future<bool> addZone({
    required String groupSer,
    required String zn,
    int qty = 0,
    int status = 1,
  }) async {
    final uri = Uri.parse('${MyConstant().domain_v2}/admin/areas/zones');
    try {
      final headers = await MyHeaders.build();
      final res = await http.post(
        uri,
        headers: headers,
        body: json.encode({
          'group_ser': int.tryParse(groupSer) ?? groupSer,
          'zn': zn,
          'qty': qty,
          'status': status,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrintLog('addZone error: $e');
      return false;
    }
  }

  Future<bool> deleteGroup({required String ser}) async {
    final uri = Uri.parse('${MyConstant().domain_v2}/admin/areas/groups/$ser');
    try {
      final headers = await MyHeaders.build();
      final request = http.Request('DELETE', uri);
      request.headers.addAll(headers);
      final res = await request.send();
      return res.statusCode == 200;
    } catch (e) {
      debugPrintLog('deleteGroup error: $e');
      return false;
    }
  }

  Future<bool> deleteZone({required String ser}) async {
    final uri = Uri.parse('${MyConstant().domain_v2}/admin/areas/zones/$ser');
    try {
      final headers = await MyHeaders.build();
      final request = http.Request('DELETE', uri);
      request.headers.addAll(headers);
      final res = await request.send();
      return res.statusCode == 200;
    } catch (e) {
      debugPrintLog('deleteZone error: $e');
      return false;
    }
  }

  Future<bool> updateGroup({
    required String ser,
    String? zn,
    int? qty,
  }) async {
    final uri = Uri.parse('${MyConstant().domain_v2}/admin/areas/groups/$ser');
    try {
      final headers = await MyHeaders.build();
      final body = <String, dynamic>{};
      if (zn != null) body['zn'] = zn;
      if (qty != null) body['qty'] = qty;
      final res =
          await http.put(uri, headers: headers, body: json.encode(body));
      return res.statusCode == 200;
    } catch (e) {
      debugPrintLog('updateGroup error: $e');
      return false;
    }
  }

  Future<bool> updateZone({
    required String ser,
    String? zn,
    int? qty,
  }) async {
    final uri = Uri.parse('${MyConstant().domain_v2}/admin/areas/zones/$ser');
    try {
      final headers = await MyHeaders.build();
      final body = <String, dynamic>{};
      if (zn != null) body['zn'] = zn;
      if (qty != null) body['qty'] = qty;
      final res =
          await http.put(uri, headers: headers, body: json.encode(body));
      return res.statusCode == 200;
    } catch (e) {
      debugPrintLog('updateZone error: $e');
      return false;
    }
  }
}

void debugPrintLog(String msg) {
  // หลีกเลี่ยง print() ใน production — ใช้ debugPrint จาก foundation
  // import 'package:flutter/foundation.dart' ผ่าน caller หากต้องการ
  assert(() {
    // ignore: avoid_print
    print('[AreaZonesApi] $msg');
    return true;
  }());
}