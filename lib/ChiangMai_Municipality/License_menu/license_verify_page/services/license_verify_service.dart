// ============================================================================
// license_verify_service.dart
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
import '../models/verify_task_model.dart';

class LicenseVerifyService {
  LicenseVerifyService({ApiCache? cache})
      : _cache = cache ?? ApiCache(ttl: const Duration(seconds: 60));

  final ApiCache _cache;

  // ---------- Legacy v1 fallback ----------
  /// โหลดรายการ "คำขอต่อสัญญา" (ser=0 / level=1) — v1 fallback
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

  // ---------- v2 VerifyTasks list ----------
  /// สร้าง URL สำหรับ v2 API (`/api/v2/...`) — strip `/v1` ออกจาก domain_v1
  Uri _uriV2(String path) {
    final base = MyConstant().domain_v1;
    final apiRoot = base.replaceFirst(RegExp(r'/v1/?$'), '');
    return Uri.parse('$apiRoot/$path');
  }

  /// truncate string เพื่อไม่ให้ print() ล้น buffer
  static String _truncate(String s, int maxLen) {
    if (s.length <= maxLen) return s;
    return '${s.substring(0, maxLen)}...[truncated ${s.length - maxLen}b]';
  }

  /// รวม `status[]` query params ที่ต้องส่งซ้ำหลาย key
  String _statusArrayQs(List<String>? statuses) {
    if (statuses == null || statuses.isEmpty) return '';
    return statuses.map(Uri.encodeQueryComponent).join('&status[]=');
  }

  /// โหลด "คำขอต่อสัญญา" (ตรวจสอบ) จาก v2 endpoint (Laravel paginated)
  Future<VerifyTasksResponse> listVerifyTasks({
    String? urlCustom,
    String? q,
    String? customer,
    List<String>? statuses,
    int? moduleId,
    String? announcementUuid,
    String? createdFrom,
    String? createdTo,
    String? submittedFrom,
    String? submittedTo,
    bool? reviewAttachmentsAllDone,
    bool? inspectionPassed,
    bool? paymentAllDone,
    bool includeDone = true,
    int perPage = 50,
  }) async {
    print('============================================================');
    print('[listVerifyTasks] urlCustom=$urlCustom q=$q customer=$customer');
    print('============================================================');

    try {
      final headers = await MyHeaders.build();

      Uri uri;
      if (urlCustom != null && urlCustom.isNotEmpty) {
        final parsed = Uri.parse(urlCustom);
        final merged = Map<String, String>.from(parsed.queryParameters);
        if (q != null && q.isNotEmpty) merged['q'] = q;
        if (customer != null && customer.isNotEmpty) merged['customer'] = customer;
        if (moduleId != null) merged['module_id'] = '$moduleId';
        if (announcementUuid != null && announcementUuid.isNotEmpty) {
          merged['announcement_uuid'] = announcementUuid;
        }
        if (createdFrom != null && createdFrom.isNotEmpty) {
          merged['created_from'] = createdFrom;
        }
        if (createdTo != null && createdTo.isNotEmpty) {
          merged['created_to'] = createdTo;
        }
        if (submittedFrom != null && submittedFrom.isNotEmpty) {
          merged['submitted_from'] = submittedFrom;
        }
        if (submittedTo != null && submittedTo.isNotEmpty) {
          merged['submitted_to'] = submittedTo;
        }
        if (reviewAttachmentsAllDone != null) {
          merged['review_attachments_all_done'] =
              reviewAttachmentsAllDone ? 'true' : 'false';
        }
        if (inspectionPassed != null) {
          merged['inspection_passed'] = inspectionPassed ? 'true' : 'false';
        }
        if (paymentAllDone != null) {
          merged['payment_all_done'] = paymentAllDone ? 'true' : 'false';
        }
        merged['include_done'] = includeDone ? '1' : '0';
        merged['per_page'] = '$perPage';

        final baseStr = parsed.replace(queryParameters: merged).toString();
        final sQs = _statusArrayQs(statuses);
        uri = sQs.isEmpty
            ? Uri.parse(baseStr)
            : Uri.parse('$baseStr&status[]=$sQs');
      } else {
        final params = <String, String>{
          if (q != null && q.isNotEmpty) 'q': q,
          if (customer != null && customer.isNotEmpty) 'customer': customer,
          if (moduleId != null) 'module_id': '$moduleId',
          if (announcementUuid != null && announcementUuid.isNotEmpty)
            'announcement_uuid': announcementUuid,
          if (createdFrom != null && createdFrom.isNotEmpty)
            'created_from': createdFrom,
          if (createdTo != null && createdTo.isNotEmpty)
            'created_to': createdTo,
          if (submittedFrom != null && submittedFrom.isNotEmpty)
            'submitted_from': submittedFrom,
          if (submittedTo != null && submittedTo.isNotEmpty)
            'submitted_to': submittedTo,
          if (reviewAttachmentsAllDone != null)
            'review_attachments_all_done':
                reviewAttachmentsAllDone ? 'true' : 'false',
          if (inspectionPassed != null)
            'inspection_passed': inspectionPassed ? 'true' : 'false',
          if (paymentAllDone != null)
            'payment_all_done': paymentAllDone ? 'true' : 'false',
          'include_done': includeDone ? '1' : '0',
          'per_page': '$perPage',
        };
        final base = _uriV2('v2/admin/requests/tasks/inspections');
        final baseStr = base.replace(queryParameters: params).toString();
        final sQs = _statusArrayQs(statuses);
        uri = sQs.isEmpty
            ? Uri.parse(baseStr)
            : Uri.parse('$baseStr&status[]=$sQs');
      }

      print('[listVerifyTasks] URL = $uri');

      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      print('[listVerifyTasks] status=${res.statusCode}');

      if (res.statusCode != 200) {
        print('[listVerifyTasks][ERROR body] ${_truncate(res.body, 200)}');
        throw Exception('โหลดรายการไม่สำเร็จ (status: ${res.statusCode})');
      }

      final body = json.decode(res.body) as Map<String, dynamic>;
      final dataRaw = body['data'];
      final data = dataRaw is List
          ? dataRaw
              .whereType<Map<String, dynamic>>()
              .map(VerifyTask.fromJson)
              .toList()
          : <VerifyTask>[];

      final meta = body['meta'] is Map
          ? Map<String, dynamic>.from(body['meta'] as Map)
          : <String, dynamic>{};
      final links = body['links'] is Map
          ? Map<String, dynamic>.from(body['links'] as Map)
          : <String, dynamic>{};

      return VerifyTasksResponse(
        data: data,
        currentPage: int.tryParse('${meta['current_page'] ?? 1}') ?? 1,
        lastPage: int.tryParse('${meta['last_page'] ?? 1}') ?? 1,
        perPage: int.tryParse('${meta['per_page'] ?? perPage}') ?? perPage,
        total: int.tryParse('${meta['total'] ?? data.length}') ?? data.length,
        linksFirst: (links['first'] ?? '').toString().isEmpty
            ? null
            : links['first'].toString(),
        linksLast: (links['last'] ?? '').toString().isEmpty
            ? null
            : links['last'].toString(),
        linksPrev: (links['prev'] ?? '').toString().isEmpty
            ? null
            : links['prev'].toString(),
        linksNext: (links['next'] ?? '').toString().isEmpty
            ? null
            : links['next'].toString(),
      );
    } catch (e) {
      print('[listVerifyTasks][ERROR] $e');
      rethrow;
    }
  }

  // ---------- Zones ----------
  /// โหลดรายการ "โซน" (zones) — default คือทั้งหมด
  Future<List<ZoneModel>> fetchZones({String? zoneSubSer}) async {
    final ren = await _getRenTalSer();
    final cacheKey = 'license_verify_zone_${ren}_$zoneSubSer';

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
      print('LicenseVerifyService.fetchZones error: $e');
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
    final cacheKey = 'license_verify_subzone_$ren';

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
      print('LicenseVerifyService.fetchSubZones error: $e');
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
