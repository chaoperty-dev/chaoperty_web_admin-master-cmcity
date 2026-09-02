// ============================================================================
// area_zones_api.dart
// ============================================================================
// ✅ SELF-CONTAINED — central zone service ใช้ร่วมทุกเมนู
// ใช้แทน GC_zone.php / GC_zone_sub.php ทั้งหมด
//
// API ใหม่ (v2):
// - GET {domain_v2}/admin/areas/groups
//     → หมวดโซน [{"ser","zn","qty","zones_count",...}, ...]
// - GET {domain_v2}/admin/areas/zones?group_ser=<ser>&per_page=15
//     → โซนของหมวดนั้น [{"ser","zn","qty",...}, ...]
//
// Cache 1 นาที + Bearer token (MyToken.accessToken)
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../Constant/Myconstant.dart';

class AreaZone {
  final String? ser;
  final String? zn;
  final int? qty;
  final int? zonesCount; // groups เท่านั้น

  const AreaZone({this.ser, this.zn, this.qty, this.zonesCount});

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
    );
  }
}

/// Cache + load groups/zones (ใช้ร่วมทุกเมนู)
class AreaZonesApi {
  AreaZonesApi();

  static const String _allLabel = 'ทั้งหมด';
  static const Duration _ttl = Duration(minutes: 1);

  // ---------- Cache ----------
  final Map<String, _CacheEntry<List<AreaZone>>> _cache = {};

  void clearCache() => _cache.clear();

  Future<List<AreaZone>> fetchGroups({bool forceRefresh = false}) async {
    const key = 'groups';
    if (!forceRefresh && _cache[key]?.isValid() == true) {
      return List<AreaZone>.from(_cache[key]!.value);
    }
    try {
      final headers = await MyHeaders.build();
      final url = '${MyConstant().domain_v2}/admin/areas/groups';
      final res = await http.get(Uri.parse(url), headers: headers);
      if (res.statusCode != 200) {
        print('[AreaZonesApi] groups status ${res.statusCode}');
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
      _cache[key] = _CacheEntry(items, DateTime.now());
      return _withAll(items);
    } catch (e) {
      print('[AreaZonesApi] fetchGroups error: $e');
      return _withAll(const []);
    }
  }

  Future<List<AreaZone>> fetchZones({
    String? groupSer,
    bool forceRefresh = false,
  }) async {
    final key = 'zones_${groupSer ?? 'all'}';
    if (!forceRefresh && _cache[key]?.isValid() == true) {
      return List<AreaZone>.from(_cache[key]!.value);
    }
    try {
      final headers = await MyHeaders.build();
      final gs = (groupSer == null || groupSer.isEmpty || groupSer == '0')
          ? ''
          : '&group_ser=$groupSer';
      final url =
          '${MyConstant().domain_v2}/admin/areas/zones?per_page=15$gs';
      final res = await http.get(Uri.parse(url), headers: headers);
      if (res.statusCode != 200) {
        print('[AreaZonesApi] zones status ${res.statusCode}');
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
      _cache[key] = _CacheEntry(items, DateTime.now());
      return _withAll(items);
    } catch (e) {
      print('[AreaZonesApi] fetchZones error: $e');
      return _withAll(const []);
    }
  }

  /// prefix 'ทั้งหมด' (ser='0') นำหน้า list
  List<AreaZone> _withAll(List<AreaZone> raw) {
    return [const AreaZone(ser: '0', zn: _allLabel), ...raw];
  }

  // ---------- Mutate (v2) ----------

  /// เพิ่มหมวดโซน — `POST /admin/areas/groups`
  /// body: `{zn, qty, pri, ren_pri}`
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
      if (res.statusCode == 200) {
        // invalidate groups cache
        _cache.remove('groups');
        return true;
      }
      return false;
    } catch (e) {
      print('[AreaZonesApi] addGroup error: $e');
      return false;
    }
  }

  /// เพิ่มโซน — `POST /admin/areas/zones`
  /// body: `{group_ser, zn, qty, status}`
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
      if (res.statusCode == 200) {
        // invalidate zones cache สำหรับ group นี้
        _cache.remove('zones_$groupSer');
        _cache.remove('zones_all');
        return true;
      }
      return false;
    } catch (e) {
      print('[AreaZonesApi] addZone error: $e');
      return false;
    }
  }

  /// ลบหมวดโซน — `DELETE /admin/areas/groups/{ser}`
  Future<bool> deleteGroup({required String ser}) async {
    final uri = Uri.parse('${MyConstant().domain_v2}/admin/areas/groups/$ser');
    try {
      final headers = await MyHeaders.build();
      final request = http.Request('DELETE', uri);
      request.headers.addAll(headers);
      final res = await request.send();
      if (res.statusCode == 200) {
        _cache.remove('groups');
        return true;
      }
      return false;
    } catch (e) {
      print('[AreaZonesApi] deleteGroup error: $e');
      return false;
    }
  }

  /// ลบโซน — `DELETE /admin/areas/zones/{ser}`
  Future<bool> deleteZone({required String ser}) async {
    final uri = Uri.parse('${MyConstant().domain_v2}/admin/areas/zones/$ser');
    try {
      final headers = await MyHeaders.build();
      final request = http.Request('DELETE', uri);
      request.headers.addAll(headers);
      final res = await request.send();
      if (res.statusCode == 200) {
        // invalidate all zones caches (group ser ไม่รู้แล้ว)
        _cache.removeWhere((k, _) => k.startsWith('zones_'));
        return true;
      }
      return false;
    } catch (e) {
      print('[AreaZonesApi] deleteZone error: $e');
      return false;
    }
  }

  /// แก้ไขหมวดโซน — `PUT /admin/areas/groups/{ser}`
  /// body: `{zn, qty}` (partial — ส่งเฉพาะ field ที่ต้องการอัปเดต)
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
      final res = await http.put(uri, headers: headers, body: json.encode(body));
      if (res.statusCode == 200) {
        _cache.remove('groups');
        return true;
      }
      return false;
    } catch (e) {
      print('[AreaZonesApi] updateGroup error: $e');
      return false;
    }
  }

  /// แก้ไขโซน — `PUT /admin/areas/zones/{ser}`
  /// body: `{zn, qty}` (partial)
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
      final res = await http.put(uri, headers: headers, body: json.encode(body));
      if (res.statusCode == 200) {
        _cache.removeWhere((k, _) => k.startsWith('zones_'));
        return true;
      }
      return false;
    } catch (e) {
      print('[AreaZonesApi] updateZone error: $e');
      return false;
    }
  }
}

class _CacheEntry<T> {
  final T value;
  final DateTime at;
  _CacheEntry(this.value, this.at);
  bool isValid() => DateTime.now().difference(at) < AreaZonesApi._ttl;
}