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
import '../models/verify_attachment_item.dart';

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

  // ===============================================================
  // v2 — GET /api/v2/admin/requests/tasks/attachments (ใหม่ ตามที่ user ต้องการ)
  // ===============================================================
  /// สร้าง Uri ไป v2 endpoint — base จาก domain_v1 ตัด /v1 ออก แล้วใส่ v2/...
  Uri _uriV2Attachments([Map<String, String>? qp]) {
    final base = MyConstant().domain_v1;
    final apiRoot = base.replaceFirst(RegExp(r'/v1/?$'), '');
    final uri = Uri.parse('$apiRoot/v2/admin/requests/tasks/attachments');
    if (qp == null || qp.isEmpty) return uri;
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...qp,
    });
  }

  /// โหลดรายการ "ตรวจสอบหลักฐาน" (attachments) — v2 endpoint
  /// - GET /api/v2/admin/requests/tasks/attachments
  /// - query params: include_done, sort_by, sort_dir, q, status[],
  ///                 customer, created_from/to, submitted_from/to,
  ///                 zser, subzoneser, per_page, page
  /// - urlCustom: ลิงก์จาก Laravel pagination (full URL)
  /// - ถ้า [zser] ว่าง/null/'0' → ไม่ส่งเลย (=ทั้งหมด); ถ้าส่ง ser จริง = filter โซนนั้น
  Future<VerifyAttachmentsListResult> listTasksAttachments({
    String? urlCustom,
    String? q,
    String? customer,
    List<String>? statuses,
    String? createdFrom,
    String? createdTo,
    String? submittedFrom,
    String? submittedTo,
    bool? reviewAttachmentsAllDone,
    String? sortBy = 'created_at',
    String? sortDir = 'desc',
    bool includeDone = false,
    int perPage = 50,
    String? zser,
    String? subzoneser,
  }) async {
    try {
      Uri uri;
      if (urlCustom != null && urlCustom.isNotEmpty) {
        uri = _resolveAttachmentsPagingUrl(
          urlCustom,
          perPage: perPage,
          includeDone: includeDone,
          sortBy: sortBy,
          sortDir: sortDir,
          q: q,
          customer: customer,
          statuses: statuses,
          createdFrom: createdFrom,
          createdTo: createdTo,
          submittedFrom: submittedFrom,
          submittedTo: submittedTo,
          reviewAttachmentsAllDone: reviewAttachmentsAllDone,
          zser: zser,
          subzoneser: subzoneser,
        );
      } else {
        final qp = <String, String>{
          'per_page': '$perPage',
          'include_done': includeDone ? '1' : '0',
          if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
          if (sortDir != null && sortDir.isNotEmpty) 'sort_dir': sortDir,
        };
        if (q != null && q.trim().isNotEmpty) qp['q'] = q.trim();
        if (customer != null && customer.trim().isNotEmpty) {
          qp['customer'] = customer.trim();
        }
        if (createdFrom != null && createdFrom.isNotEmpty) {
          qp['created_from'] = createdFrom;
        }
        if (createdTo != null && createdTo.isNotEmpty) {
          qp['created_to'] = createdTo;
        }
        if (submittedFrom != null && submittedFrom.isNotEmpty) {
          qp['submitted_from'] = submittedFrom;
        }
        if (submittedTo != null && submittedTo.isNotEmpty) {
          qp['submitted_to'] = submittedTo;
        }
        if (reviewAttachmentsAllDone != null) {
          qp['review_attachments_all_done'] =
              reviewAttachmentsAllDone ? 'true' : 'false';
        }
        if (zser != null && zser.isNotEmpty && zser != '0') qp['zser'] = zser;
        if (subzoneser != null &&
            subzoneser.isNotEmpty &&
            subzoneser != '0') {
          qp['subzoneser'] = subzoneser;
        }
        if (statuses != null && statuses.isNotEmpty) {
          for (final s in statuses) {
            qp['status[]'] = s;
          }
        }
        uri = _uriV2Attachments(qp);
      }

      // ────────────────────────────────────────────────────────────────
      // DEBUG: print URL + context
      print('╔══════════════════════════════════════════════════════════════');
      print('║ [listTasksAttachments][v2] GET → $uri');
      print('║   • urlCustom       : $urlCustom');
      print('║   • q               : "$q"');
      print('║   • customer        : $customer');
      print('║   • statuses        : $statuses');
      print('║   • zser / subzoneser: $zser / $subzoneser');
      print('║   • include_done    : $includeDone');
      print('║   • sort            : $sortBy / $sortDir');
      print('║   • perPage         : $perPage');
      print('╚══════════════════════════════════════════════════════════════');

      final headers = await MyHeaders.build();
      final resp = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 25));

      if (resp.statusCode == 204 || resp.body.trim().isEmpty) {
        return VerifyAttachmentsListResult.empty;
      }
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        print('[listTasksAttachments][ERR] ${resp.statusCode} ${resp.reasonPhrase}');
        print('[listTasksAttachments][BODY] ${_truncate(resp.body, 200)}');
        return VerifyAttachmentsListResult.empty;
      }

      final decoded = json.decode(resp.body);
      if (decoded is! Map) {
        print('[listTasksAttachments][ERR] body is not a Map');
        return VerifyAttachmentsListResult.empty;
      }
      final map = decoded;

      int toInt(dynamic v) =>
          v is int ? v : (v is num ? v.toInt() : (int.tryParse('$v') ?? 0));
      int currentPage = 0, lastPage = 0, perPageVal = 0, total = 0;
      if (map['meta'] is Map) {
        final meta = map['meta'] as Map;
        currentPage = toInt(meta['current_page']);
        lastPage = toInt(meta['last_page']);
        perPageVal = toInt(meta['per_page']);
        total = toInt(meta['total']);
      }

      String? linksFirst, linksLast, linksPrev, linksNext;
      if (map['links'] is Map) {
        final lm = map['links'] as Map;
        linksFirst = lm['first']?.toString();
        linksLast = lm['last']?.toString();
        linksPrev = lm['prev']?.toString();
        linksNext = lm['next']?.toString();
      }

      final items = <VerifyAttachmentItem>[];
      final rawData = map['data'];
      if (rawData is List) {
        for (final raw in rawData) {
          if (raw is Map<String, dynamic>) {
            items.add(VerifyAttachmentItem.fromJson(raw));
          }
        }
      }

      print(
          '[listTasksAttachments][v2][result] currentPage=$currentPage lastPage=$lastPage perPage=$perPageVal total=$total dataCount=${items.length} prev=$linksPrev next=$linksNext');

      return VerifyAttachmentsListResult(
        items: items,
        currentPage: currentPage,
        lastPage: lastPage,
        perPage: perPageVal,
        total: total,
        linksFirst: linksFirst,
        linksLast: linksLast,
        linksPrev: linksPrev,
        linksNext: linksNext,
      );
    } catch (e, st) {
      print('[listTasksAttachments][exception] $e');
      print(st);
      return VerifyAttachmentsListResult.empty;
    }
  }

  /// แปลง pagination link (full URL หรือ relative path) → absolute Uri
  Uri _resolveAttachmentsPagingUrl(
    String raw, {
    required int perPage,
    required bool includeDone,
    String? sortBy,
    String? sortDir,
    String? q,
    String? customer,
    List<String>? statuses,
    String? createdFrom,
    String? createdTo,
    String? submittedFrom,
    String? submittedTo,
    bool? reviewAttachmentsAllDone,
    String? zser,
    String? subzoneser,
  }) {
    final base = MyConstant().domain_v1.replaceFirst(RegExp(r'/v1/?$'), '');
    Uri source;
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      source = Uri.parse(raw);
    } else {
      final path = raw.startsWith('/') ? raw : '/$raw';
      source = Uri.parse('$base$path');
    }
    // backend ส่ง next URL เป็น http:// → redirect ไป https ทำให้หลุด Authorization (401)
    if (source.scheme == 'http') {
      source = source.replace(scheme: 'https');
    }
    final qp = Map<String, String>.from(source.queryParameters);
    qp['per_page'] = qp['per_page'] ?? '$perPage';
    qp['include_done'] = qp['include_done'] ?? (includeDone ? '1' : '0');
    if (sortBy != null && sortBy.isNotEmpty) {
      qp['sort_by'] = qp['sort_by'] ?? sortBy;
    }
    if (sortDir != null && sortDir.isNotEmpty) {
      qp['sort_dir'] = qp['sort_dir'] ?? sortDir;
    }
    if (q != null && q.trim().isNotEmpty && !qp.containsKey('q')) {
      qp['q'] = q.trim();
    }
    if (customer != null && customer.trim().isNotEmpty) {
      qp['customer'] = qp['customer'] ?? customer.trim();
    }
    if (createdFrom != null && createdFrom.isNotEmpty) {
      qp['created_from'] = qp['created_from'] ?? createdFrom;
    }
    if (createdTo != null && createdTo.isNotEmpty) {
      qp['created_to'] = qp['created_to'] ?? createdTo;
    }
    if (submittedFrom != null && submittedFrom.isNotEmpty) {
      qp['submitted_from'] = qp['submitted_from'] ?? submittedFrom;
    }
    if (submittedTo != null && submittedTo.isNotEmpty) {
      qp['submitted_to'] = qp['submitted_to'] ?? submittedTo;
    }
    if (reviewAttachmentsAllDone != null &&
        !qp.containsKey('review_attachments_all_done')) {
      qp['review_attachments_all_done'] =
          reviewAttachmentsAllDone ? 'true' : 'false';
    }
    if (zser != null && zser.isNotEmpty && zser != '0') {
      qp['zser'] = qp['zser'] ?? zser;
    }
    if (subzoneser != null && subzoneser.isNotEmpty && subzoneser != '0') {
      qp['subzoneser'] = qp['subzoneser'] ?? subzoneser;
    }
    // merge status[]
    if (statuses != null && statuses.isNotEmpty) {
      final existing = qp.keys.where((k) => k.startsWith('status[')).toList();
      if (existing.isEmpty) {
        for (final s in statuses) {
          qp['status[]'] = s;
        }
      }
    }
    return source.replace(queryParameters: qp);
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
