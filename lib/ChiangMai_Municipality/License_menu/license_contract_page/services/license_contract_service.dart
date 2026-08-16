// ============================================================================
// license_contract_service.dart
// ============================================================================
// Service / Repository layer — โหลดข้อมูล Zones / SubZones / Areas
// ใช้ API เดียวกับ ChaoArea_Screen.dart (`GC_areaAll.php`) เพื่อให้ได้ทุกล็อก
// - จัดการ Cache (ApiCache)
// ============================================================================// ignore_for_file: invalid_assignment
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Constant/Myconstant.dart';
import '../../../../Constant/api_cache.dart';
import '../../../../Model/GetArea_Model.dart';
import '../../../../Model/GetSubZone_Model.dart';
import '../../../../Model/GetZone_Model.dart';
import '../../../Model/AnnouncementZone_Model.dart';
import '../../../Model/Properties_Model.dart';
import '../../../unity/API_announcement.dart';
import '../../../unity/API_properties.dart';

class LicenseContractService {
  LicenseContractService({ApiCache? cache})
      : _cache = cache ?? ApiCache(ttl: const Duration(seconds: 60));

  final ApiCache _cache;

  // ---------- Zones ----------
  Future<List<ZoneModel>> fetchZones({String? subZoneSer}) async {
    final ren = await _getRenTalSer();
    final cacheKey = 'license_contract_zone_${ren}_$subZoneSer';

    if (_cache.isValid(cacheKey)) {
      final cached = _cache.get(cacheKey);
      if (cached != null) return _applyZoneFilter(cached, subZoneSer);
    }

    final url = '${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren';
    try {
      final response = await http.get(Uri.parse(url));
      final result = jsonDecode(response.body);
      if (result == null || result is! List) return <ZoneModel>[];
      _cache.set(cacheKey, result);
      return _applyZoneFilter(result, subZoneSer);
    } catch (e) {
      return <ZoneModel>[];
    }
  }

  List<ZoneModel> _applyZoneFilter(List<dynamic> rawList, String? subZoneSer) {
    final defaultZone = ZoneModel.fromJson({
      'ser': '0',
      'rser': '0',
      'zn': 'ทั้งหมด',
      'qty': '0',
      'img': '0',
      'data_update': '0',
    });

    final zones = <ZoneModel>[defaultZone];
    for (final map in rawList) {
      final zone = ZoneModel.fromJson(map);
      if (subZoneSer == null ||
          subZoneSer == '0' ||
          zone.sub_zone == subZoneSer) {
        zones.add(zone);
      }
    }

    zones.sort((a, b) {
      if (a.zn == 'ทั้งหมด') return -1;
      if (b.zn == 'ทั้งหมด') return 1;
      return (a.zn ?? '').compareTo(b.zn ?? '');
    });
    return zones;
  }

  // ---------- SubZones ----------
  Future<List<SubZoneModel>> fetchSubZones() async {
    final ren = await _getRenTalSer();
    final cacheKey = 'license_contract_subzone_$ren';

    if (_cache.isValid(cacheKey)) {
      final cached = _cache.get(cacheKey);
      if (cached != null) return _buildSubZoneList(cached);
    }

    final url = '${MyConstant().domain}/GC_zone_sub.php?isAdd=true&ren=$ren';
    try {
      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);
      _cache.set(cacheKey, result);
      return _buildSubZoneList(result);
    } catch (e) {
      return _buildSubZoneList(<dynamic>[]);
    }
  }

  List<SubZoneModel> _buildSubZoneList(List<dynamic> rawList) {
    final defaultMap = <String, dynamic>{
      'ser': '0',
      'rser': '0',
      'zn': 'ทั้งหมด',
      'qty': '0',
      'img': '0',
      'data_update': '0',
    };
    final subs = <SubZoneModel>[SubZoneModel.fromJson(defaultMap)];
    for (final map in rawList) {
      subs.add(SubZoneModel.fromJson(map));
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
    final propsKey = 'license_contract_properties_${ren}_$zone';
    List<PropertiesModel> properties;
    if (_cache.isValid(propsKey)) {
      final cached = _cache.get(propsKey);
      properties = (cached as List)
          .map((e) => PropertiesModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
    // 🔍 DEBUG: log keys ของ propMap
    print('� [fetchAreas] propMap keys=${propMap.keys.toList()} '
        '(total ${propMap.length} entries, ${properties.length} props)');

    // 4) Join แล้ว set area.properties (cast dynamic เพื่อข้าม analyzer cache casing issue)
    for (final area in areas) {
      final key = area.ser?.toString();
      final dynamic matched = (key != null)
          ? (propMap[key] ?? const <PropertiesModel>[])
          : const <PropertiesModel>[];
      // ignore: invalid_assignment
      area.properties = matched;
      // 🔍 DEBUG: log TEST30 join result
      if ((area.lncode ?? '').startsWith('TEST')) {
        print('🔍 [fetchAreas] lncode=${area.lncode} ser=${area.ser} '
            'matched=${matched.length}');
      }
    }

    // ignore: avoid_print
    print(
        '🔸 fetchAreas zone="$zone" count=${areas.length} properties=${properties.length} '
        'occupied=${areas.where((a) => a.properties.isNotEmpty).length}');
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
}
