// ============================================================================
// tenant_license_service.dart
// ============================================================================
// Service — โหลดข้อมูล "ผู้เช่า" จาก API
// ใช้ API เดียวกับ PeopleChao_Screen:
//   - GC_tenantAll.php  (zone=0 หรือ zone=null = ทั้งหมด)
//   - GC_tenant.php     (filter ตาม zone)
//   - GC_zone.php / GC_zone_sub.php สำหรับ zones/subzones
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:chaoperty/Constant/api_cache.dart';
import 'package:chaoperty/Constant/global_http.dart';
import 'package:chaoperty/Model/GetSubZone_Model.dart';
import 'package:chaoperty/Model/GetTeNant_Model.dart';
import 'package:chaoperty/Model/GetZone_Model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TenantLicenseService {
  TenantLicenseService({ApiCache? cache})
      : _cache = cache ?? ApiCache(ttl: const Duration(seconds: 60));

  final ApiCache _cache;

  // ---------- Tenants ----------
  /// โหลดรายการ "ผู้เช่า" ตาม zone ที่เลือก
  /// [zone] = null / '0' / 'ทั้งหมด' → ดึงทั้งหมด
  /// [zone] = อื่นๆ → ดึงเฉพาะโซน
  /// [status] = null / 'ทั้งหมด' → ไม่กรองสถานะ
  ///            'ปัจจุบัน' → '1', 'หมดสัญญา' → '2', 'ใกล้หมดสัญญา' → '3'
  Future<List<TeNantModel>> fetchTenants({
    String? zone,
    String? status,
  }) async {
    final ren = await _getRenTalSer();
    final statusParam = _statusParam(status);
    final cacheKey =
        'tenant_license_tenants_${ren}_${zone ?? 'all'}_${statusParam ?? 'all'}';

    if (_cache.isValid(cacheKey)) {
      final cached = _cache.get(cacheKey);
      if (cached != null) return _buildTenantList(cached);
    }

    final baseUrl = (zone == null || zone == '0' || zone == 'ทั้งหมด')
        ? '${MyConstant().domain}/GC_tenantAll_V2.php?isAdd=true&ren=$ren&zone=0'
        : '${MyConstant().domain}/GC_tenantAll_V2.php?isAdd=true&ren=$ren&zone=$zone';

    final url = statusParam != null ? '$baseUrl&status=$statusParam' : baseUrl;
    print(url);

    try {
      final response = await httpClient.get(Uri.parse(url));
      final result = json.decode(response.body);
      if (result != null && result is Map && result['data'] is List) {
        _cache.set(cacheKey, result['data']);
        return _buildTenantList(result['data'] as List);
      }
      if (result != null && result is List) {
        _cache.set(cacheKey, result);
        return _buildTenantList(result);
      }
      return <TeNantModel>[];
    } catch (e) {
      print('TenantLicenseService.fetchTenants error: $e');
      return <TeNantModel>[];
    }
  }

  String? _statusParam(String? status) {
    switch (status) {
      case 'ปัจจุบัน':
        return '1';
      case 'หมดสัญญา':
        return '2';
      case 'ใกล้หมดสัญญา':
        return '3';
      case 'ทั้งหมด':
      default:
        return null;
    }
  }

  List<TeNantModel> _buildTenantList(List<dynamic> rawList) {
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(TeNantModel.fromJson)
        .toList();
  }

  // ---------- Zones ----------
  /// โหลดรายการ "โซน" (zones) — default คือทั้งหมด
  Future<List<ZoneModel>> fetchZones({String? zoneSubSer}) async {
    final ren = await _getRenTalSer();
    final cacheKey = 'tenant_license_zone_${ren}_$zoneSubSer';

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
      print('TenantLicenseService.fetchZones error: $e');
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
    final cacheKey = 'tenant_license_subzone_$ren';

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
      print('TenantLicenseService.fetchSubZones error: $e');
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
