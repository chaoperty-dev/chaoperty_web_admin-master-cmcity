// ============================================================================
// license_attach_service.dart
// ============================================================================
// Service — โหลดข้อมูล "คำขอต่อสัญญา" (status แรก) จาก API
// ใช้ read_GC_Reviews() + HTTP ตรงสำหรับ zones/subzones
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:chaoperty/Constant/api_cache.dart';
import 'package:chaoperty/Model/GetSubZone_Model.dart';
import 'package:chaoperty/Model/GetZone_Model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../unity/API_requests_reviews.dart';
import '../../../unity/API_approvals_lastaction.dart';

class LicenseAttachService {
  LicenseAttachService({ApiCache? cache})
      : _cache = cache ?? ApiCache(ttl: const Duration(seconds: 60));

  final ApiCache _cache;

  // ---------- Requests ----------
  /// โหลดรายการ "คำขอต่อสัญญา" (ser=0 / level=1)
  /// [zn] = filter โซน (null = ทั้งหมด)
  /// [searchField] = field ที่จะใช้ filter (เช่น 'scname', 'uuid', 'tel')
  Future<ReviewResponse> fetchRequests({
    String? urlCustom,
    String query = '',
    int perPage = 50,
    String? orderBy,
    String sortDir = 'asc',
    String? zn,
    String searchField = 'scname',
  }) async {
    return await read_GC_Reviews(
      urlCustom: urlCustom,
      query: query,
      perPage: 50,
      orderBy: orderBy,
      sortDir: sortDir,
      zn: zn,
      fild: [
        {
          'ser': '0',
          'st': '1',
          'title': _fieldTitle(searchField),
          'value': searchField
        },
      ],
    );
  }

  /// Title ตาม search field ที่เลือก (สำหรับ fild)
  String _fieldTitle(String field) {
    switch (field) {
      case 'uuid':
        return 'รหัสรายการ';
      case 'tel':
        return 'เบอร์โทร';
      case 'cid':
        return 'เลขที่สัญญา';
      case 'scname':
      default:
        return 'ชื่อผู้ติดต่อ';
    }
  }

  // ---------- Zones ----------
  /// โหลดรายการ "โซน" (zones) — default คือทั้งหมด
  Future<List<ZoneModel>> fetchZones({String? zoneSubSer}) async {
    final ren = await _getRenTalSer();
    final cacheKey = 'license_attach_zone_${ren}_$zoneSubSer';

    if (_cache.isValid(cacheKey)) {
      final cached = _cache.get(cacheKey);
      if (cached != null) {
        return _applyZoneFilter(cached, zoneSubSer);
      }
    }

    final url = '${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren';
    try {
      final response = await http.get(Uri.parse(url));
      final result = jsonDecode(response.body);
      if (result == null || result is! List) return <ZoneModel>[];
      _cache.set(cacheKey, result);
      return _applyZoneFilter(result, zoneSubSer);
    } catch (e) {
      print('LicenseAttachService.fetchZones error: $e');
      return <ZoneModel>[];
    }
  }

  List<ZoneModel> _applyZoneFilter(List<dynamic> rawList, String? zoneSubSer) {
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
      if (zoneSubSer == null ||
          zoneSubSer == '0' ||
          zone.sub_zone == zoneSubSer) {
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
  /// โหลดรายการ "โซนพื้นที่เช่า" (subzones) — default คือทั้งหมด
  Future<List<SubZoneModel>> fetchSubZones() async {
    final ren = await _getRenTalSer();
    final cacheKey = 'license_attach_subzone_$ren';

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
      print('LicenseAttachService.fetchSubZones error: $e');
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

  // ---------- Helpers ----------
  Future<String?> _getRenTalSer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('renTalSer');
  }
}
