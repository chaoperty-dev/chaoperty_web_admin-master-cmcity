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

import '../../../../Constant/Myconstant.dart';
import '../../../../Constant/api_cache.dart';
import '../../../../Model/AreaOverview_Model.dart';
import '../../../../Model/GetSubZone_Model.dart';
import '../../../../Model/GetZone_Model.dart';
import '../../../Model/AnnouncementZone_Model.dart';
import '../unity/API_announcement.dart';

class LicenseContractService {
  LicenseContractService({ApiCache? cache})
      : _cache = cache ?? ApiCache(ttl: const Duration(seconds: 60));

  final ApiCache _cache;
  final AreaZonesApi _zonesApi = AreaZonesApi();

  // ---------- Zones (v2 — /admin/areas/groups + /admin/areas/zones) ----------
  Future<List<ZoneModel>> fetchZones({String? zoneSubSer}) async {
    final api = _zonesApi;
    final raw = await api.fetchZones(groupSer: zoneSubSer);
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

  // ---------- Areas Overview (API ใหม่ — มี aser, status EN key) ----------
  /// โหลดรายการพื้นที่ 1 หน้า:
  ///   GET {domain_v2}/admin/areas/overview
  ///   ?subzoneser=<subzoneSer>&zser=<zoneSer>&per_page=5&page=<page>
  ///
  /// null/0/'0' ของ filter จะไม่ถูกส่ง (= ทั้งหมด)
  /// pagination เป็น server-driven จาก data.pagination
  Future<AreaOverviewResponse> fetchAreasOverview({
    String? zoneSer,
    String? subzoneSer,
    int page = 1,
  }) async {
    final headers = await MyHeaders.build();
    final params = <String, String>{
      'per_page': '5',
      'page': '$page',
    };
    if (subzoneSer != null && subzoneSer.isNotEmpty && subzoneSer != '0') {
      params['subzoneser'] = subzoneSer;
    }
    if (zoneSer != null && zoneSer.isNotEmpty && zoneSer != '0') {
      params['zser'] = zoneSer;
    }

    final url = Uri.parse('${MyConstant().domain_v2}/admin/areas/overview')
        .replace(queryParameters: params);

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
