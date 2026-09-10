// ============================================================================
// tenant_license_service.dart
// ============================================================================
// Service — โหลดข้อมูล "ผู้เช่า" จาก API
// ใช้ API เดียวกับ PeopleChao_Screen:
//   - GC_tenantAll_V2.php  (zone=0 หรือ zone=null = ทั้งหมด)
//   - zones via AreaZonesApi (lib/ChiangMai_Municipality/unity/area_zones_api.dart)
// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:chaoperty/Constant/global_http.dart';
import 'package:chaoperty/Model/GetSubZone_Model.dart';
import 'package:chaoperty/Model/GetZone_Model.dart';
import 'package:http/http.dart' as http;

import '../../../unity/area_zones_api.dart';
import '../models/tenant_permit_models.dart';

class TenantLicenseService {
  TenantLicenseService();

  final AreaZonesApi _zonesApi = AreaZonesApi();

  // ---------- Permits (Admin v1) ----------
  /// โหลดรายการใบอนุญาต พร้อม pagination จาก meta
  /// สถานะ "ทั้งหมด" ส่งโดยไม่ใส่ status ใน query
  Future<TenantPermitListResult> fetchPermits({
    int page = 1,
    int perPage = 50,
    String status = '',
    String search = '',
    String zser = '',
  }) async {
    final params = <String, String>{
      'per_page': '$perPage',
      'page': '$page',
    };
    if (status.isNotEmpty && status != 'ทั้งหมด') params['status'] = status;
    if (search.trim().isNotEmpty) params['search'] = search.trim();
    if (zser.isNotEmpty && zser != '0' && zser != 'ทั้งหมด') {
      params['zser'] = zser;
    }

    final uri = Uri.parse('${MyConstant().domain_v1}/admin/permits')
        .replace(queryParameters: params);
    try {
      final headers = await MyHeaders.build();
      debugPrint('[TenantLicenseService] GET permits $uri');
      final response = await http.get(uri, headers: headers);
      print('[TenantLicenseService] permits status=${response.statusCode}');
      if (response.statusCode != 200)
        return const TenantPermitListResult(
          items: [],
          currentPage: 1,
          lastPage: 1,
          total: 0,
        );
      final decoded = jsonDecode(response.body);
      if (decoded is! Map)
        return const TenantPermitListResult(
          items: [],
          currentPage: 1,
          lastPage: 1,
          total: 0,
        );
      return TenantPermitListResult.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (e) {
      print('[TenantLicenseService] fetchPermits error: $e');
      return const TenantPermitListResult(
        items: [],
        currentPage: 1,
        lastPage: 1,
        total: 0,
      );
    }
  }

  /// โหลดรายละเอียดใบอนุญาต
  Future<TenantPermitDetail?> fetchPermitDetail(String permitUuid) async {
    if (permitUuid.trim().isEmpty) return null;
    final uri = Uri.parse(
      '${MyConstant().domain_v1}/admin/permits/${permitUuid.trim()}',
    );
    try {
      final headers = await MyHeaders.build();
      print('[TenantLicenseService] GET permit detail $uri');
      final response = await http.get(uri, headers: headers);
      print(
          '[TenantLicenseService] permit detail status=${response.statusCode}');
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return null;
      final data = decoded['data'];
      if (data is! Map) return null;
      // API คืน `request` เป็น sibling ของ `data` — merge เข้าไปใน data
      // เพื่อให้ TenantPermitDetail.request อ่านได้ (ไม่กระทบ endpoint อื่น)
      final merged = Map<String, dynamic>.from(data);
      if (decoded['request'] is Map) {
        merged['request'] = Map<String, dynamic>.from(decoded['request']);
      }
      return TenantPermitDetail.fromJson(merged);
    } catch (e) {
      print('[TenantLicenseService] fetchPermitDetail error: $e');
      return null;
    }
  }

  /// โหลดรายการชำระเงินล่าสุดของใบอนุญาต
  Future<List<Map<String, dynamic>>> fetchPermitPayments(
      String permitUuid) async {
    final data = await _fetchPermitListEndpoint(
      '$permitUuid/payments',
    );
    return _extractList(data);
  }

  /// โหลดรายละเอียดใบเสร็จของ payment
  Future<Map<String, dynamic>?> fetchReceiptDetail({
    required String permitUuid,
    required String paymentUuid,
  }) async {
    final data = await _fetchPermitEndpoint(
      '$permitUuid/payments/$paymentUuid/receipt',
    );
    final value = data?['data'];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  /// โหลดรอบตรวจของใบอนุญาต
  Future<List<Map<String, dynamic>>> fetchInspections(String permitUuid) async {
    final data = await _fetchPermitListEndpoint('$permitUuid/inspections');
    return _extractList(data);
  }

  Future<List<Map<String, dynamic>>> fetchInspectionImages({
    required String permitUuid,
    required String inspectionUuid,
  }) async {
    final data = await _fetchPermitListEndpoint(
      '$permitUuid/inspections/$inspectionUuid/images',
    );
    return _extractList(data);
  }

  Future<Uint8List?> fetchPermitBytes({
    required String permitUuid,
    required String path,
  }) async {
    final uri = Uri.parse(
      '${MyConstant().domain_v1}/admin/permits/$permitUuid/$path',
    );
    try {
      final headers = await MyHeaders.build();
      headers['Accept'] = 'application/pdf';
      final response = await http.get(uri, headers: headers);
      return response.statusCode == 200 && response.bodyBytes.isNotEmpty
          ? response.bodyBytes
          : null;
    } catch (e) {
      print('[TenantLicenseService] fetchPermitBytes error: $e');
      return null;
    }
  }

  Future<Uint8List?> fetchPermitAttachmentBytes({
    required String permitUuid,
    required String attachmentUuid,
  }) async {
    final uri = Uri.parse(
      '${MyConstant().domain_v1}/admin/permits/$permitUuid/attachments/$attachmentUuid/preview',
    );
    try {
      final headers = await MyHeaders.build();
      final response = await http.get(uri, headers: headers);
      return response.statusCode == 200 && response.bodyBytes.isNotEmpty
          ? response.bodyBytes
          : null;
    } catch (e) {
      print('[TenantLicenseService] fetchPermitAttachmentBytes error: $e');
      return null;
    }
  }

  Future<Uint8List?> fetchInspectionImageBytes({
    required String permitUuid,
    required String inspectionUuid,
    required String imageUuid,
  }) async {
    final uri = Uri.parse(
      '${MyConstant().domain_v1}/admin/permits/$permitUuid/inspections/$inspectionUuid/images/$imageUuid/preview',
    );
    try {
      final headers = await MyHeaders.build();
      final response = await http.get(uri, headers: headers);
      return response.statusCode == 200 && response.bodyBytes.isNotEmpty
          ? response.bodyBytes
          : null;
    } catch (e) {
      print('[TenantLicenseService] fetchInspectionImageBytes error: $e');
      return null;
    }
  }

  Future<bool> retryPermit(String permitUuid) async {
    final uri = Uri.parse(
      '${MyConstant().domain_v1}/admin/permits/$permitUuid/retry',
    );
    try {
      final headers = await MyHeaders.build();
      final response = await http.post(uri, headers: headers);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('[TenantLicenseService] retryPermit error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> _fetchPermitEndpoint(String path) async {
    final uri = Uri.parse('${MyConstant().domain_v1}/admin/permits/$path');
    try {
      final headers = await MyHeaders.build();
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchPermitListEndpoint(String path) =>
      _fetchPermitEndpoint(path);

  List<Map<String, dynamic>> _extractList(Map<String, dynamic>? body) {
    final data = body?['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  // ---------- Zones ----------
  /// โหลดรายการ "โซน" (zones) — default คือทั้งหมด
  Future<List<ZoneModel>> fetchZones({String? zoneSubSer}) async {
    final raw = await _zonesApi.fetchZones(groupSer: zoneSubSer);
    final defaultZone = ZoneModel.fromJson({
      'ser': '0',
      'rser': '0',
      'zn': 'ทั้งหมด',
      'qty': '0',
      'img': '0',
      'data_update': '0',
    });
    final zones = <ZoneModel>[defaultZone];
    for (final row in raw) {
      zones.add(ZoneModel.fromJson({
        'ser': row.ser ?? '0',
        'rser': row.ser ?? '0',
        'zn': row.zn ?? '',
        'qty': '${row.qty ?? 0}',
        'img': '0',
        'data_update': '0',
      }));
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
    final raw = await _zonesApi.fetchGroups();
    final defaultMap = <String, dynamic>{
      'ser': '0',
      'rser': '0',
      'zn': 'ทั้งหมด',
      'qty': '0',
      'img': '0',
      'data_update': '0',
    };
    final subs = <SubZoneModel>[SubZoneModel.fromJson(defaultMap)];
    for (final row in raw) {
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
}
