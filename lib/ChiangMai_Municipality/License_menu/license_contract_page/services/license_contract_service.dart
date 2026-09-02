// ============================================================================
// license_contract_service.dart
// ============================================================================
// Service / Repository layer — โหลดข้อมูล Zones / SubZones / Areas
// ใช้ API เดียวกับ ChaoArea_Screen.dart (`GC_areaAll.php`) เพื่อให้ได้ทุกล็อก
// - จัดการ Cache (ApiCache)
// ============================================================================// ignore_for_file: invalid_assignment
import 'dart:convert';

import 'package:chaoperty/ChiangMai_Municipality/unity/area_zones_api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Constant/Myconstant.dart';
import '../../../../Constant/api_cache.dart';
import '../../../../Model/AreaOverview_Model.dart';
import '../../../../Model/GetArea_Model.dart';
import '../../../../Model/GetSubZone_Model.dart';
import '../../../../Model/GetZone_Model.dart';
import '../../../Model/AnnouncementZone_Model.dart';
import '../../../Model/Properties_Model.dart';
import '../unity/API_announcement.dart';
import '../unity/API_properties.dart';


class LicenseContractService {
  LicenseContractService({ApiCache? cache})
      : _cache = cache ?? ApiCache(ttl: const Duration(seconds: 60));

  final ApiCache _cache;
  final AreaZonesApi _zonesApi = AreaZonesApi();

  // ---------- Zones (v2 — /admin/areas/groups + /admin/areas/zones) ----------
  Future<List<ZoneModel>> fetchZones({String? subZoneSer}) async {
    final api = _zonesApi;
    final raw = await api.fetchZones(groupSer: subZoneSer);
    return _mapZones(raw);
  }

  // ---------- SubZones (v2 — /admin/areas/groups) ----------
  Future<List<SubZoneModel>> fetchSubZones() async {
    final raw = await _zonesApi.fetchGroups();
    return _mapSubZones(raw);
  }

  List<ZoneModel> _mapZones(List<dynamic> rawList) {
    final defaultZone = ZoneModel.fromJson({
      'ser': '0',
      'rser': '0',
      'zn': 'ทั้งหมด',
      'qty': '0',
      'img': '0',
      'data_update': '0',
    });
    final zones = <ZoneModel>[defaultZone];
    for (final row in rawList) {
      if (row is! AreaZone) continue;
      zones.add(ZoneModel.fromJson({
        'ser': row.ser ?? '0',
        'rser': row.ser ?? '0',
        'zn': row.zn ?? '',
        'qty': '${row.qty ?? 0}',
        'img': '0',
        'data_update': '0',
      }));
    }
    return zones;
  }

  List<SubZoneModel> _mapSubZones(List<dynamic> rawList) {
    final defaultMap = <String, dynamic>{
      'ser': '0',
      'rser': '0',
      'zn': 'ทั้งหมด',
      'qty': '0',
      'img': '0',
      'data_update': '0',
    };
    final subs = <SubZoneModel>[SubZoneModel.fromJson(defaultMap)];
    for (final row in rawList) {
      if (row is! AreaZone) continue;
      subs.add(SubZoneModel.fromJson({
        'ser': row.ser ?? '0',
        'rser': row.ser ?? '0',
        'zn': row.zn ?? '',
        'qty': '${row.qty ?? 0}',
        'img': '0',
        'data_update': '0',
      }));
    }
    return subs;
  }

  // ---------- Areas (ทุกล็อกทั้งหมด + join properties) ----------
  /// โหลดล็อกทั้งหมดจาก `GC_areaAll.php` ตามโซนที่เลือก + join กับ PropertiesModel
  /// จาก API `/admin/requests/properties` (เหมือน Data_Properties ใน ChaoArea_Screen)
  ///
  /// หลังจาก join แล้ว:
  /// - `area.properties` (List<PropertiesModel>) จะมีรายการที่ join สำเร็จ
  ///   (aser == area.ser) — ใช้บอกว่าล็อกนี้ "มี request ที่ active"
  Future<List<AreaModel>> fetchAreas({String? zoneSer}) async {
    final ren = await _getRenTalSer();
    final zone = (zoneSer == null || zoneSer == '0') ? '' : zoneSer;
    final cacheKey = 'license_contract_areas_${ren}_$zone';

    // 1) โหลด Areas
    List<dynamic> rawAreas;
    if (_cache.isValid(cacheKey)) {
      final cached = _cache.get(cacheKey);
      rawAreas = (cached as List).toList();
    } else {
      final url = Uri.parse(
        '${MyConstant().domain}/GC_areaAll.php'
        '?isAdd=true&ren=$ren&zone=$zone&typecid=0',
      );
      try {
        final response = await http.get(url);
        final result = json.decode(response.body);
        if (result == null || result is! List) return <AreaModel>[];
        rawAreas = result;
        _cache.set(cacheKey, result);
      } catch (e) {
        print('LicenseContractService.fetchAreas error: $e');
        return <AreaModel>[];
      }
    }

    final areas = rawAreas.map((e) => AreaModel.fromJson(e)).toList();

    // 2) โหลด PropertiesModel (มี aser ที่ join กับ area.ser)
    // key bump v3 — entry เก่า payment_json เป็น _JsonMap โดน skip → ทิ้ง cache เก่า
    final propsKey = 'license_contract_properties_v3_${ren}_$zone';
    List<PropertiesModel> properties;
    if (_cache.isValid(propsKey)) {
      final cached = _cache.get(propsKey);
      // กัน cache เก่า schema เพี้ยน → parse ทีละตัว ข้าม entry ที่พัง
      final tmp = <PropertiesModel>[];
      for (final e in (cached as List)) {
        try {
          tmp.add(PropertiesModel.fromJson(e as Map<String, dynamic>));
        } catch (_) {}
      }
      properties = tmp;
      if (properties.isEmpty) {
        // cache เพี้ยนทั้งชุด → fetch ใหม่
        properties =
            await read_GC_properties(zone.isEmpty ? null : zone, null, null);
        _cache.set(
            propsKey,
            properties.map((p) {
              return {
                'new_request': p.newRequest?.toJson(),
                'client': p.client?.toJson(),
              };
            }).toList());
      }
    } else {
      properties =
          await read_GC_properties(zone.isEmpty ? null : zone, null, null);
      _cache.set(
          propsKey,
          properties.map((p) {
            return {
              'new_request': p.newRequest?.toJson(),
              'client': p.client?.toJson(),
            };
          }).toList());
    }

    // 3) ทำ map aser -> props (O(1) lookup) — เหมือน ChaoArea_Screen บรรทัด 976-980
    final propMap = <String, List<PropertiesModel>>{};
    for (final p in properties) {
      final key = p.newRequest?.aser?.toString();
      if (key == null) continue;
      (propMap[key] ??= []).add(p);
    }
    // 4) Join แล้ว set area.properties (cast dynamic เพื่อข้าม analyzer cache casing issue)
    for (final area in areas) {
      final key = area.ser?.toString();
      final dynamic matched = (key != null)
          ? (propMap[key] ?? const <PropertiesModel>[])
          : const <PropertiesModel>[];
      // ignore: invalid_assignment
      area.properties = matched;
    }

    return areas;
  }

  // ---------- Announcement ----------
  /// โหลดประกาศของโซนที่เลือกจาก `/admin/announcement/getzone?zoneid=$zoneSer`
  /// คืนค่า AnnouncementZone ตัวแรก (ถ้ามี) พร้อม message จาก response
  Future<({AnnouncementZone? zone, String? message})> fetchAnnouncement({
    required String zoneSer,
  }) async {
    if (zoneSer.isEmpty || zoneSer == '0') {
      return (zone: null, message: null);
    }

    final cacheKey = 'license_contract_announcement_$zoneSer';
    if (_cache.isValid(cacheKey)) {
      final cached = _cache.get(cacheKey);
      if (cached is Map<String, dynamic>) {
        return (
          zone: AnnouncementZone.fromJson(cached),
          message: cached['_message'] as String?,
        );
      }
    }

    try {
      final response = await read_AnnounceMent_Getzone(zoneid: zoneSer);
      if (response == null || response.statusCode != 200) {
        return (zone: null, message: null);
      }

      final result = json.decode(response.body);
      final data = result['data'];
      final message = result['message']?.toString();

      if (data == null) {
        return (zone: null, message: message);
      }

      AnnouncementZone? zone;
      if (data is List && data.isNotEmpty) {
        zone = AnnouncementZone.fromJson(data.first as Map<String, dynamic>);
      } else if (data is Map) {
        zone = AnnouncementZone.fromJson(Map<String, dynamic>.from(data));
      }

      if (zone != null) {
        final cacheMap = zone.toJson();
        cacheMap['_message'] = message;
        _cache.set(cacheKey, cacheMap);
      }

      return (zone: zone, message: message);
    } catch (e) {
      print('LicenseContractService.fetchAnnouncement error: $e');
      return (zone: null, message: null);
    }
  }

  // ---------- Helpers ----------
  Future<String?> _getRenTalSer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('renTalSer');
  }

  // ---------- Areas Overview (API ใหม่ — มี aser, status EN key) ----------
  /// โหลด "ภาพรวมพื้นที่เช่า" ทั้งหมด:
  ///   GET {domain_v2}/admin/areas/overview?zser=<zoneSer>&sort_by=lock&sort_dir=asc&page=1
  ///
  /// - zser = null/0/'0' → ไม่ส่ง query (ดูทั้งหมด)
  /// - zser อื่นๆ → filter ตามโซน
  ///
  /// คืน AreaOverviewResponse (items[] + totals)
  /// ถ้า response ไม่ใช่ 200 / JSON parse พัง → throw
  Future<AreaOverviewResponse> fetchAreasOverview({String? zoneSer}) async {
    final headers = await MyHeaders.build();

    final z = (zoneSer == null || zoneSer == '0') ? '' : zoneSer;
    final qs = z.isEmpty ? '' : '?zser=$z&sort_by=lock&sort_dir=asc&page=1';
    final url = Uri.parse(
      '${MyConstant().domain_v2}/admin/areas/overview$qs',
    );

    // ignore: avoid_print
    print('[fetchAreasOverview] URL = $url');
    final http.Response response;
    try {
      response = await http.get(url, headers: headers);
    } catch (e) {
      throw Exception('ไม่สามารถเชื่อมต่อ API overview: $e');
    }

    // ignore: avoid_print
    print(
        '[fetchAreasOverview] status=${response.statusCode} bodyLen=${response.body.length}');

    if (response.statusCode != 200) {
      throw Exception(
          'โหลด Areas Overview ไม่สำเร็จ (status: ${response.statusCode})');
    }

    final Map<String, dynamic> body;
    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('รูปแบบ JSON ไม่ถูกต้อง: $e');
    }

    final data = body['data'];
    if (data is! Map) {
      throw Exception('response.data ไม่ใช่ object');
    }
    final Map<String, dynamic> dataMap =
        data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data);

    return AreaOverviewResponse.fromJson(dataMap);
  }
}
