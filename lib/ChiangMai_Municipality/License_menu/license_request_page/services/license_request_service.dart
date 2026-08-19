// ============================================================================
// license_request_service.dart
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
import '../models/license_request_item.dart';

class LicenseRequestService {
  LicenseRequestService({ApiCache? cache})
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

  // ===============================================================
  // v2 — GET /api/v2/admin/requests (ใหม่ ตามที่ user ต้องการ)
  // ===============================================================
  /// สร้าง Uri ไป v2 endpoint — base จาก domain_v1 ตัด /v1 ออก แล้วใส่ v2/...
  Uri _uriV2AdminRequests([Map<String, String>? qp]) {
    final base = MyConstant().domain_v1;
    final apiRoot = base.replaceFirst(RegExp(r'/v1/?$'), '');
    final uri = Uri.parse('$apiRoot/v2/admin/requests');
    if (qp == null || qp.isEmpty) return uri;
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...qp,
    });
  }

  /// โหลดรายการ "คำขอ" — v2 endpoint (ใหม่)
  /// - GET /api/v2/admin/requests
  /// - default: per_page=15, sort_by=created_at, sort_dir=desc
  /// - query: q, announcement_uuid, status[], module_id, customer,
  ///          created_from/to, submitted_from/to,
  ///          review_attachments_all_done, inspection_passed,
  ///          payment_all_done, zser, subzoneser
  /// - ถ้า [zser] ว่าง/null/'0' → ไม่ส่งเลย (=ทั้งหมด); ถ้าส่ง ser จริง = filter โซนนั้น
  Future<LicenseRequestsListResult> listAdminRequests({
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
    String? sortBy = 'created_at',
    String? sortDir = 'desc',
    int perPage = 50,
    int? page,
    String? zser,
    String? subzoneser,
  }) async {
    try {
      Uri uri;
      if (urlCustom != null && urlCustom.isNotEmpty) {
        uri = _resolveAdminRequestsPagingUrl(
          urlCustom,
          perPage: perPage,
          sortBy: sortBy,
          sortDir: sortDir,
          q: q,
          customer: customer,
          statuses: statuses,
          moduleId: moduleId,
          announcementUuid: announcementUuid,
          createdFrom: createdFrom,
          createdTo: createdTo,
          submittedFrom: submittedFrom,
          submittedTo: submittedTo,
          reviewAttachmentsAllDone: reviewAttachmentsAllDone,
          inspectionPassed: inspectionPassed,
          paymentAllDone: paymentAllDone,
          zser: zser,
          subzoneser: subzoneser,
        );
      } else {
        final qp = <String, String>{
          'per_page': '$perPage',
          if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
          if (sortDir != null && sortDir.isNotEmpty) 'sort_dir': sortDir,
          if (page != null && page > 1) 'page': '$page',
        };
        if (q != null && q.trim().isNotEmpty) qp['q'] = q.trim();
        if (customer != null && customer.trim().isNotEmpty) {
          qp['customer'] = customer.trim();
        }
        if (announcementUuid != null && announcementUuid.isNotEmpty) {
          qp['announcement_uuid'] = announcementUuid;
        }
        if (moduleId != null) qp['module_id'] = '$moduleId';
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
        if (inspectionPassed != null) {
          qp['inspection_passed'] = inspectionPassed ? 'true' : 'false';
        }
        if (paymentAllDone != null) {
          qp['payment_all_done'] = paymentAllDone ? 'true' : 'false';
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
        uri = _uriV2AdminRequests(qp);
      }

      // ────────────────────────────────────────────────────────────────
      // DEBUG: print URL + context
      print('╔══════════════════════════════════════════════════════════════');
      print('║ [listAdminRequests][v2] GET → $uri');
      print('║   • urlCustom       : $urlCustom');
      print('║   • q               : "$q"');
      print('║   • customer        : $customer');
      print('║   • statuses        : $statuses');
      print('║   • zser / subzoneser: $zser / $subzoneser');
      print('║   • sort            : $sortBy / $sortDir');
      print('║   • perPage         : $perPage');
      print('║   • page            : $page');
      print('╚══════════════════════════════════════════════════════════════');

      final headers = await MyHeaders.build();
      final resp = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 25));

      if (resp.statusCode == 204 || resp.body.trim().isEmpty) {
        return LicenseRequestsListResult.empty;
      }
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        print('[listAdminRequests][ERR] ${resp.statusCode} ${resp.reasonPhrase}');
        return LicenseRequestsListResult.empty;
      }

      final decoded = json.decode(resp.body);
      if (decoded is! Map) {
        print('[listAdminRequests][ERR] body is not a Map');
        return LicenseRequestsListResult.empty;
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

      final items = <LicenseRequestItem>[];
      final rawData = map['data'];
      if (rawData is List) {
        for (final raw in rawData) {
          if (raw is Map<String, dynamic>) {
            items.add(LicenseRequestItem.fromJson(raw));
          }
        }
      }

      print(
          '[listAdminRequests][v2][result] currentPage=$currentPage lastPage=$lastPage perPage=$perPageVal total=$total dataCount=${items.length} prev=$linksPrev next=$linksNext');

      return LicenseRequestsListResult(
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
      print('[listAdminRequests][exception] $e');
      print(st);
      return LicenseRequestsListResult.empty;
    }
  }

  /// แปลง pagination link (full URL หรือ relative path) → absolute Uri
  Uri _resolveAdminRequestsPagingUrl(
    String raw, {
    required int perPage,
    String? sortBy,
    String? sortDir,
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
    if (moduleId != null && !qp.containsKey('module_id')) {
      qp['module_id'] = '$moduleId';
    }
    if (announcementUuid != null &&
        announcementUuid.isNotEmpty &&
        !qp.containsKey('announcement_uuid')) {
      qp['announcement_uuid'] = announcementUuid;
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
    if (inspectionPassed != null && !qp.containsKey('inspection_passed')) {
      qp['inspection_passed'] = inspectionPassed ? 'true' : 'false';
    }
    if (paymentAllDone != null && !qp.containsKey('payment_all_done')) {
      qp['payment_all_done'] = paymentAllDone ? 'true' : 'false';
    }
    if (zser != null && zser.isNotEmpty && zser != '0') {
      qp['zser'] = qp['zser'] ?? zser;
    }
    if (subzoneser != null && subzoneser.isNotEmpty && subzoneser != '0') {
      qp['subzoneser'] = qp['subzoneser'] ?? subzoneser;
    }
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
    final cacheKey = 'license_request_zone_${ren}_$zoneSubSer';

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
      print('LicenseRequestService.fetchZones error: $e');
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
    final cacheKey = 'license_request_subzone_$ren';

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
      print('LicenseRequestService.fetchSubZones error: $e');
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
