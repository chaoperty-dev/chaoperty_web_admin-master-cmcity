// ============================================================================
// license_fact_check_service.dart
// ============================================================================
// Service — โหลดข้อมูล "ตรวจสอบข้อเท็จจริง" (fact check) จาก API
//
// v1: fetchRequests() → read_GC_Reviews() → GET /v1/admin/approvals (legacy)
// v2: fetchInspections() → GET /api/v2/admin/requests/tasks/inspections (ใหม่)
//
// ใช้ HTTP ตรงสำหรับ zones/subzones/inspection APIs
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:chaoperty/Constant/api_cache.dart';
import 'package:chaoperty/Model/GetSubZone_Model.dart';
import 'package:chaoperty/Model/GetZone_Model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../unity/API_requests_reviews.dart';
import '../../../unity/API_approvals_lastaction.dart';
import '../models/fact_check_item.dart';

class LicensefactcheckService {
  LicensefactcheckService({ApiCache? cache})
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
  // v2 — GET /api/v2/admin/requests/tasks/inspections (ใหม่ ตามที่ user ต้องการ)
  // ===============================================================
  /// สร้าง Uri ไป v2 endpoint — base จาก domain_v1 ตัด /v1 ออก แล้วใส่ v2/...
  Uri _uriV2Inspections([Map<String, String>? qp]) {
    final base = MyConstant().domain_v1;
    final apiRoot = base.replaceFirst(RegExp(r'/v1/?$'), '');
    final uri = Uri.parse('$apiRoot/v2/admin/requests/tasks/inspections');
    if (qp == null || qp.isEmpty) return uri;
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...qp,
    });
  }

  /// โหลดรายการ fact-check (inspections) — v2 endpoint
  /// - GET /api/v2/admin/requests/tasks/inspections
  /// - query params: include_done, sort_by, sort_dir, q, inspection_passed,
  ///                 created_from, created_to, zser, subzoneser, per_page, page, zn
  /// - urlCustom: ลิงก์จาก Laravel pagination (full URL)
  Future<FactCheckListResult> fetchInspections({
    String? urlCustom,
    String query = '',
    int perPage = 50,
    int page = 1,
    String sortBy = 'created_at',
    String sortDir = 'desc',
    bool includeDone = false,
    bool? inspectionPassed,
    String? createdFrom, // YYYY-MM-DD
    String? createdTo, // YYYY-MM-DD
    String? zser,
    String? subzoneser,
    String? zn,
    List<String>? statuses,
  }) async {
    try {
      Uri uri;
      if (urlCustom != null && urlCustom.isNotEmpty) {
        uri = _resolveInspectionsPagingUrl(
          urlCustom,
          perPage: perPage,
          includeDone: includeDone,
          sortBy: sortBy,
          sortDir: sortDir,
          query: query,
          inspectionPassed: inspectionPassed,
          createdFrom: createdFrom,
          createdTo: createdTo,
          zn: zn,
          statuses: statuses,
        );
      } else {
        final qp = <String, String>{
          'per_page': '$perPage',
          'include_done': includeDone ? '1' : '0',
          'sort_by': sortBy,
          'sort_dir': sortDir,
          if (page > 1) 'page': '$page',
        };
        if (query.trim().isNotEmpty) qp['q'] = query.trim();
        if (inspectionPassed != null) {
          qp['inspection_passed'] = inspectionPassed ? 'true' : 'false';
        }
        if (createdFrom != null && createdFrom.isNotEmpty) {
          qp['created_from'] = createdFrom;
        }
        if (createdTo != null && createdTo.isNotEmpty) {
          qp['created_to'] = createdTo;
        }
        if (zser != null && zser.isNotEmpty && zser != '0') qp['zser'] = zser;
        if (subzoneser != null &&
            subzoneser.isNotEmpty &&
            subzoneser != '0') {
          qp['subzoneser'] = subzoneser;
        }
        if (zn != null && zn.isNotEmpty && zn != '0' && zn != 'ทั้งหมด') {
          qp['zn'] = zn;
        }
        if (statuses != null && statuses.isNotEmpty) {
          for (final s in statuses) {
            qp['status[]'] = s;
          }
        }
        uri = _uriV2Inspections(qp);
      }

      // ────────────────────────────────────────────────────────────────
      // DEBUG: print URL + context ทุกครั้งที่ยิง v2 /tasks/inspections
      print('╔══════════════════════════════════════════════════════════════');
      print('║ [fetchInspections][v2] GET → $uri');
      print('║   • urlCustom       : $urlCustom');
      print('║   • query           : "$query"');
      print('║   • zn / zser       : $zn / $zser');
      print('║   • subzoneser      : $subzoneser');
      print('║   • include_done    : $includeDone');
      print('║   • inspection_passed: $inspectionPassed');
      print('║   • created_from    : $createdFrom');
      print('║   • created_to      : $createdTo');
      print('║   • sort            : $sortBy / $sortDir');
      print('║   • perPage         : $perPage');
      print('║   • page            : $page');
      print('╚══════════════════════════════════════════════════════════════');
      // ────────────────────────────────────────────────────────────────

      final headers = await MyHeaders.build();
      final resp = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 25));

      if (resp.statusCode == 204 || resp.body.trim().isEmpty) {
        return FactCheckListResult.empty;
      }
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        print(
            '[fetchInspections][ERR] ${resp.statusCode} ${resp.reasonPhrase}');
        print('[fetchInspections][BODY] ${resp.body}');
        return FactCheckListResult.empty;
      }

      final decoded = json.decode(resp.body);
      if (decoded is! Map) {
        print('[fetchInspections][ERR] body is not a Map');
        return FactCheckListResult.empty;
      }
      final map = decoded;

      // meta
      int currentPage = 0, lastPage = 0, perPageVal = 0, total = 0;
      if (map['meta'] is Map) {
        final meta = map['meta'] as Map;
        currentPage = _toInt(meta['current_page']);
        lastPage = _toInt(meta['last_page']);
        perPageVal = _toInt(meta['per_page']);
        total = _toInt(meta['total']);
      }

      // links
      String? linksFirst, linksLast, linksPrev, linksNext;
      if (map['links'] is Map) {
        final lm = map['links'] as Map;
        linksFirst = lm['first']?.toString();
        linksLast = lm['last']?.toString();
        linksPrev = lm['prev']?.toString();
        linksNext = lm['next']?.toString();
      }

      // data
      final items = <FactCheckItem>[];
      final rawData = map['data'];
      if (rawData is List) {
        for (final raw in rawData) {
          if (raw is Map<String, dynamic>) {
            items.add(FactCheckItem.fromJson(raw));
          }
        }
      }

      print(
          '[fetchInspections][v2][result] currentPage=$currentPage lastPage=$lastPage perPage=$perPageVal total=$total dataCount=${items.length} prev=$linksPrev next=$linksNext');

      return FactCheckListResult(
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
      print('[fetchInspections][exception] $e');
      print(st);
      return FactCheckListResult.empty;
    }
  }

  /// แปลง pagination link (full URL หรือ relative path) → absolute Uri
  Uri _resolveInspectionsPagingUrl(
    String raw, {
    required int perPage,
    required bool includeDone,
    required String sortBy,
    required String sortDir,
    required String query,
    bool? inspectionPassed,
    String? createdFrom,
    String? createdTo,
    String? zn,
    List<String>? statuses,
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
    qp['sort_by'] = qp['sort_by'] ?? sortBy;
    qp['sort_dir'] = qp['sort_dir'] ?? sortDir;
    if (query.trim().isNotEmpty && !qp.containsKey('q')) {
      qp['q'] = query.trim();
    }
    if (inspectionPassed != null && !qp.containsKey('inspection_passed')) {
      qp['inspection_passed'] = inspectionPassed ? 'true' : 'false';
    }
    if (createdFrom != null && createdFrom.isNotEmpty) {
      qp['created_from'] = qp['created_from'] ?? createdFrom;
    }
    if (createdTo != null && createdTo.isNotEmpty) {
      qp['created_to'] = qp['created_to'] ?? createdTo;
    }
    if (zn != null && zn.isNotEmpty && zn != '0' && zn != 'ทั้งหมด') {
      qp['zn'] = zn;
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

  int _toInt(dynamic v) => int.tryParse('$v') ?? 0;

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
    final cacheKey = 'license_fact_check_zone_${ren}_$zoneSubSer';

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
      print('LicensefactcheckService.fetchZones error: $e');
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
    final cacheKey = 'license_fact_check_subzone_$ren';

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
      print('LicensefactcheckService.fetchSubZones error: $e');
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

  // ============================================================================
  // Inspection APIs
  // ============================================================================
  // ทุก endpoint ใช้ bearer token จาก MyHeaders.build()
  // base = MyConstant().domain_v1

  /// POST /admin/requests/{requestUuid}/inspection
  /// เริ่มการตรวจสอบข้อเท็จจริง — คืน inspectionUuid สำหรับใช้กับ images/summary
  Future<InspectionResult> startInspection(String requestUuid) async {
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid/inspection',
    );
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🔵 [startInspection]');
    debugPrint('   METHOD = POST');
    debugPrint('   URL    = ${url.toString()}');
    debugPrint('   HEADERS = $headers');
    debugPrint('   BODY   = (empty — POST นี้ไม่มี body, ตาม spec API)');
    debugPrint('   ─── request sent ───');
    final resp = await http
        .post(url, headers: headers)
        .timeout(const Duration(seconds: 30));
    debugPrint('   ─── response ───');
    debugPrint('   STATUS      = ${resp.statusCode} ${resp.reasonPhrase}');
    debugPrint('   CONTENT-TYPE = ${resp.headers['content-type']}');
    debugPrint('   CONTENT-LEN  = ${resp.headers['content-length']}');
    debugPrint('   BODY        = ${resp.body}');
    debugPrint('═══════════════════════════════════════════════════════');
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'startInspection failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final decoded = json.decode(resp.body) as Map<String, dynamic>;
    // รองรับทั้ง { "data": {...} } และ top-level {...}
    final inner = (decoded['data'] is Map<String, dynamic>)
        ? decoded['data'] as Map<String, dynamic>
        : decoded;
    return InspectionResult.fromJson(inner);
  }

  /// GET /admin/requests/{requestUuid}/inspection
  /// ดูประวัติการตรวจสอบ (history) — คืน List<HistoryEntry>
  Future<List<HistoryEntry>> getHistory(String requestUuid) async {
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid/inspection',
    );
    final resp = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'getHistory failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final decoded = json.decode(resp.body);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(HistoryEntry.fromJson)
          .toList();
    }
    if (decoded is Map && decoded['data'] is List) {
      return (decoded['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(HistoryEntry.fromJson)
          .toList();
    }
    return <HistoryEntry>[];
  }

  /// GET /admin/requests/{requestUuid}/inspection
  /// ดึงรายการ inspection rounds (โฟลเดอร์) — คืน List<InspectionRound>
  /// Response: อาจเป็น List ตรงๆ หรือ { "data": [...] }
  Future<List<InspectionRound>> listInspections(String requestUuid) async {
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid/inspection',
    );
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🟢 [listInspections]');
    debugPrint('   METHOD = GET');
    debugPrint('   URL    = ${url.toString()}');
    debugPrint('   HEADERS = $headers');
    debugPrint('   ─── request sent ───');
    final resp = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 30));
    debugPrint('   ─── response ───');
    debugPrint('   STATUS      = ${resp.statusCode} ${resp.reasonPhrase}');
    debugPrint('   CONTENT-TYPE = ${resp.headers['content-type']}');
    debugPrint('   BODY        = ${resp.body}');
    debugPrint('═══════════════════════════════════════════════════════');
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'listInspections failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final decoded = json.decode(resp.body);
    List<dynamic> raw = const [];
    if (decoded is Map && decoded['data'] is List) {
      raw = decoded['data'] as List;
    } else if (decoded is List) {
      raw = decoded;
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(InspectionRound.fromJson)
        .toList();
  }

  // ============================================================================
  // Checklist Snapshot APIs
  // ============================================================================

  /// POST /admin/requests/{requestUuid}/checklist
  /// สร้าง checklist snapshot จากข้อมูลคำร้องปัจจุบัน
  Future<ChecklistSnapshot> createChecklistSnapshot(String requestUuid) async {
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid/checklist',
    );
    final resp = await http
        .post(url, headers: headers)
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'createChecklistSnapshot failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return ChecklistSnapshot.fromJson(data);
  }

  /// GET /admin/requests/{requestUuid}/checklist
  /// ดู checklist snapshot ล่าสุด (หรือ version ที่ระบุ)
  Future<ChecklistSnapshot?> getChecklistSnapshot(
    String requestUuid, {
    int? version,
  }) async {
    final headers = await MyHeaders.build();
    final qp = <String, String>{};
    if (version != null) qp['version'] = version.toString();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid/checklist',
    ).replace(queryParameters: qp.isEmpty ? null : qp);
    final resp = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'getChecklistSnapshot failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final decoded = json.decode(resp.body);
    if (decoded is Map<String, dynamic>)
      return ChecklistSnapshot.fromJson(decoded);
    if (decoded is Map && decoded['data'] is Map<String, dynamic>) {
      return ChecklistSnapshot.fromJson(
        decoded['data'] as Map<String, dynamic>,
      );
    }
    return null;
  }

  /// GET /admin/requests/{requestUuid}/checklist/preview
  /// Preview checklist ก่อนบันทึก snapshot
  Future<ChecklistSnapshot> previewChecklist(String requestUuid) async {
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid/checklist/preview',
    );
    final resp = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'previewChecklist failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return ChecklistSnapshot.fromJson(data);
  }

  /// GET /admin/inspection/{inspectionUuid}/images
  /// ดูรายการรูปภาพที่อัปโหลดทั้งหมด
  Future<List<InspectionImage>> listImages(String inspectionUuid) async {
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/inspection/$inspectionUuid/images',
    );
    final resp = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'listImages failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final decoded = json.decode(resp.body);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(InspectionImage.fromJson)
          .toList();
    }
    if (decoded is Map && decoded['data'] is List) {
      return (decoded['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(InspectionImage.fromJson)
          .toList();
    }
    return <InspectionImage>[];
  }

  /// GET /admin/inspection/{inspectionUuid}/images/{imageUuid}/preview
  /// ดึงรูปตัวอย่างเป็น bytes (PNG/JPEG) — เหมาะกับ Image.memory
  Future<Uint8List> previewImage(String imageUuid,
      {required String inspectionUuid}) async {
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/inspection/$inspectionUuid/images/$imageUuid/preview',
    );
    final resp = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 60));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'previewImage failed (${resp.statusCode})',
      );
    }
    return resp.bodyBytes;
  }

  /// POST /admin/inspection/{inspectionUuid}/images (multipart)
  /// อัปโหลดรูป 1 ไฟล์ — รับได้ทั้ง File (mobile/desktop) และ bytes (web)
  Future<InspectionImage> uploadImage(
    String inspectionUuid, {
    File? file,
    Uint8List? bytes,
    String? filename,
    String caption = '',
  }) async {
    assert(file != null || bytes != null,
        'uploadImage: ต้องส่ง file หรือ bytes อย่างน้อย 1 อย่าง');

    final headers = await MyHeaders.build();
    // ลบ Content-Type ออก เพื่อให้ http.MultipartRequest ใส่ boundary ให้เอง
    final sendHeaders = Map<String, String>.from(headers)
      ..remove('Content-Type');

    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/inspection/$inspectionUuid/images',
    );
    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(sendHeaders);

    if (caption.isNotEmpty) request.fields['caption'] = caption;

    String actualName;
    if (file != null) {
      actualName = filename ?? p.basename(file.path);
      final mime = _guessMime(actualName);
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          file.path,
          filename: actualName,
          contentType: MediaType.parse(mime),
        ),
      );
    } else {
      actualName = filename ?? 'upload.bin';
      final mime = _guessMime(actualName);
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes!,
          filename: actualName,
          contentType: MediaType.parse(mime),
        ),
      );
    }

    final streamed = await request.send().timeout(const Duration(minutes: 2));
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'uploadImage failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return InspectionImage.fromJson(data);
  }

  /// อัปโหลดรูปหลายไฟล์พร้อมกัน (loop ทีละไฟล์) — เหมาะกับการเลือกหลายรูปจาก file_picker
  /// [files] รายการไฟล์ (mobile/desktop)
  /// [bytesList] รายการ bytes พร้อม filename (web)
  /// คืนผลลัพธ์: สำเร็จ N ไฟล์, ล้มเหลว M ไฟล์, errors list
  Future<BatchUploadResult> uploadMultipleImages(
    String inspectionUuid, {
    List<File>? files,
    List<({Uint8List bytes, String filename})>? bytesList,
    String caption = '',
    void Function(int done, int total)? onProgress,
  }) async {
    assert(files != null || bytesList != null,
        'ต้องส่ง files หรือ bytesList อย่างน้อย 1 อย่าง');

    final total = (files?.length ?? 0) + (bytesList?.length ?? 0);
    if (total == 0) {
      return BatchUploadResult(successCount: 0, failedCount: 0, errors: []);
    }

    final results = <InspectionImage>[];
    final errors = <String>[];
    int done = 0;

    if (files != null) {
      for (final f in files) {
        try {
          final img = await uploadImage(
            inspectionUuid,
            file: f,
            caption: caption,
          );
          results.add(img);
        } catch (e) {
          errors.add('${f.path}: $e');
        }
        done++;
        onProgress?.call(done, total);
      }
    }
    if (bytesList != null) {
      for (final b in bytesList) {
        try {
          final img = await uploadImage(
            inspectionUuid,
            bytes: b.bytes,
            filename: b.filename,
            caption: caption,
          );
          results.add(img);
        } catch (e) {
          errors.add('${b.filename}: $e');
        }
        done++;
        onProgress?.call(done, total);
      }
    }

    return BatchUploadResult(
      successCount: results.length,
      failedCount: errors.length,
      uploaded: results,
      errors: errors,
    );
  }

  /// POST /admin/inspection/{inspectionUuid}/summary
  /// บันทึกสรุปผลการตรวจสอบ (JSON body)
  Future<SaveSummaryResult> saveSummary(
    String inspectionUuid,
    Map<String, dynamic> payload,
  ) async {
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/inspection/$inspectionUuid/summary',
    );
    final resp = await http
        .post(
          url,
          headers: headers,
          body: json.encode(payload),
        )
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'saveSummary failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final decoded =
        resp.body.isEmpty ? <String, dynamic>{} : json.decode(resp.body);
    return SaveSummaryResult.fromJson(decoded as Map<String, dynamic>);
  }

  /// POST /admin/inspection/{reviewUuid}/comment
  /// บันทึกความเห็นผู้ตรวจ (max 2000 chars)
  Future<InspectionActionResult> addInspectionComment(
    String reviewUuid,
    String comment,
  ) async {
    assert(comment.trim().isNotEmpty, 'comment ต้องไม่ว่าง');
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/inspection/$reviewUuid/comment',
    );
    final resp = await http
        .post(
          url,
          headers: headers,
          body: json.encode({'comment': comment}),
        )
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'addInspectionComment failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final decoded = resp.body.isEmpty
        ? <String, dynamic>{}
        : json.decode(resp.body) as Map<String, dynamic>;
    return InspectionActionResult.fromJson(decoded);
  }

  /// POST /admin/inspection/{reviewUuid}/transition
  /// เปลี่ยนสถานะ inspection review
  /// state: pending | in_review | passed | failed | cancelled
  Future<InspectionActionResult> transitionInspection(
    String reviewUuid, {
    required String state,
    String? comment,
  }) async {
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/inspection/$reviewUuid/transition',
    );
    final body = <String, dynamic>{'state': state};
    if (comment != null && comment.trim().isNotEmpty) {
      body['comment'] = comment.trim();
    }
    final resp = await http
        .post(url, headers: headers, body: json.encode(body))
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'transitionInspection failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final decoded = resp.body.isEmpty
        ? <String, dynamic>{}
        : json.decode(resp.body) as Map<String, dynamic>;
    return InspectionActionResult.fromJson(decoded);
  }

  /// POST /admin/inspection/{reviewUuid}/recheck
  /// ปิด round ปัจจุบันและเปิด round ตรวจซ้ำ
  /// คืน InspectionResult (uuid ของ round ใหม่)
  Future<InspectionResult> recheckInspection(
    String reviewUuid, {
    String? comment,
  }) async {
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/inspection/$reviewUuid/recheck',
    );
    final body = <String, dynamic>{};
    if (comment != null && comment.trim().isNotEmpty) {
      body['comment'] = comment.trim();
    }
    final resp = await http
        .post(url, headers: headers, body: json.encode(body))
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'recheckInspection failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return InspectionResult.fromJson(data);
  }

  // ============================================================================
  // Request Management APIs
  // ============================================================================

  /// POST /admin/requests/{requestUuid}/prepayment
  /// บันทึก prepayment รอบใหม่ + deactivate รายการ active เดิม
  /// [debtDetails] ต้องเป็น List<Map<String, dynamic>>
  Future<RequestActionResult> savePrepayment(
    String requestUuid,
    List<Map<String, dynamic>> debtDetails,
  ) async {
    assert(debtDetails.isNotEmpty, 'debt_details ต้องไม่ว่าง');
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid/prepayment',
    );
    final resp = await http
        .post(
          url,
          headers: headers,
          body: json.encode({'debt_details': debtDetails}),
        )
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'savePrepayment failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final decoded = resp.body.isEmpty
        ? <String, dynamic>{}
        : json.decode(resp.body) as Map<String, dynamic>;
    return RequestActionResult.fromJson(decoded);
  }

  /// PATCH /admin/requests/{requestUuid}/dates
  /// แก้ไขวันที่เริ่มต้น/สิ้นสุด (ldate ต้อง >= sdate)
  Future<RequestActionResult> updateRequestDates(
    String requestUuid, {
    required String sdate, // YYYY-MM-DD
    required String ldate, // YYYY-MM-DD
  }) async {
    assert(sdate.isNotEmpty && ldate.isNotEmpty, 'sdate/ldate ต้องไม่ว่าง');
    final headers = await MyHeaders.build();
    final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid/dates',
    );
    final resp = await http
        .patch(
          url,
          headers: headers,
          body: json.encode({'sdate': sdate, 'ldate': ldate}),
        )
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException(
        'updateRequestDates failed (${resp.statusCode}): ${resp.body}',
      );
    }
    final decoded = resp.body.isEmpty
        ? <String, dynamic>{}
        : json.decode(resp.body) as Map<String, dynamic>;
    return RequestActionResult.fromJson(decoded);
  }

  /// เดา MIME จากนามสกุลไฟล์ — fallback เป็น application/octet-stream
  String _guessMime(String filename) {
    final ext =
        filename.contains('.') ? filename.split('.').last.toLowerCase() : '';
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}

// ============================================================================
// Models
// ============================================================================

/// ผลลัพธ์จาก POST /requests/{uuid}/inspection
class InspectionResult {
  final String? inspectionUuid; // uuid ของ inspection (ใช้อัปโหลดรูป)
  final String? requestUuid;
  final int? round;
  final String? state; // pending | passed | failed | ...
  final String? stateLabel;
  final String? comment;
  final String? reviewerUuid;
  final String? startedAt;
  final String? completedAt;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? raw;

  const InspectionResult({
    this.inspectionUuid,
    this.requestUuid,
    this.round,
    this.state,
    this.stateLabel,
    this.comment,
    this.reviewerUuid,
    this.startedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.raw,
  });

  factory InspectionResult.fromJson(Map<String, dynamic> json) {
    String? pickStr(String k) => json[k] == null ? null : json[k].toString();
    int? pickInt(String k) {
      final v = json[k];
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    String? pickUuid() {
      for (final k in ['inspection_uuid', 'uuid', 'id']) {
        final v = json[k];
        if (v != null) return v.toString();
      }
      return null;
    }

    return InspectionResult(
      inspectionUuid: pickUuid(),
      requestUuid: pickStr('request_uuid'),
      round: pickInt('round'),
      state: pickStr('state'),
      stateLabel: pickStr('state_label'),
      comment: pickStr('comment'),
      reviewerUuid: pickStr('reviewer_uuid'),
      startedAt: pickStr('started_at'),
      completedAt: pickStr('completed_at'),
      createdAt: pickStr('created_at'),
      updatedAt: pickStr('updated_at'),
      raw: json,
    );
  }
}

/// 1 entry ในประวัติการตรวจสอบ
class HistoryEntry {
  final String? uuid;
  final String? action;
  final String? actor;
  final String? note;
  final String? createdAt;
  final Map<String, dynamic>? raw;

  const HistoryEntry({
    this.uuid,
    this.action,
    this.actor,
    this.note,
    this.createdAt,
    this.raw,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    String? pickStr(String k) => json[k] == null ? null : json[k].toString();
    return HistoryEntry(
      uuid: pickStr('uuid') ?? pickStr('id'),
      action: pickStr('action') ?? pickStr('event'),
      actor: pickStr('actor') ?? pickStr('user') ?? pickStr('created_by'),
      note: pickStr('note') ?? pickStr('description') ?? pickStr('message'),
      createdAt: pickStr('created_at') ?? pickStr('updated_at'),
      raw: json,
    );
  }
}

/// metadata ของรูปภาพที่อัปโหลด
class InspectionImage {
  final String? uuid;
  final String? url;
  final String? caption;
  final String? createdAt;
  final int? size;
  final Map<String, dynamic>? raw;

  const InspectionImage({
    this.uuid,
    this.url,
    this.caption,
    this.createdAt,
    this.size,
    this.raw,
  });

  factory InspectionImage.fromJson(Map<String, dynamic> json) {
    String? pickStr(String k) => json[k] == null ? null : json[k].toString();
    return InspectionImage(
      uuid: pickStr('uuid') ?? pickStr('id'),
      url: pickStr('url') ?? pickStr('path'),
      caption: pickStr('caption'),
      createdAt: pickStr('created_at'),
      size: json['size'] is int
          ? json['size'] as int
          : int.tryParse('${json['size'] ?? ''}'),
      raw: json,
    );
  }
}

/// ผลลัพธ์จาก save summary
class SaveSummaryResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? raw;

  const SaveSummaryResult({required this.success, this.message, this.raw});

  factory SaveSummaryResult.fromJson(Map<String, dynamic> json) {
    final ok = json['success'] is bool
        ? json['success'] as bool
        : (json['status']?.toString().toLowerCase() == 'success' ||
            json['status']?.toString().toLowerCase() == 'ok');
    return SaveSummaryResult(
      success: ok,
      message: json['message']?.toString() ?? json['msg']?.toString(),
      raw: json,
    );
  }
}

/// ผลลัพธ์จากการอัปโหลดหลายรูป
class BatchUploadResult {
  final int successCount;
  final int failedCount;
  final List<InspectionImage> uploaded;
  final List<String> errors;

  const BatchUploadResult({
    required this.successCount,
    required this.failedCount,
    this.uploaded = const [],
    this.errors = const [],
  });

  int get total => successCount + failedCount;
  bool get allOk => failedCount == 0 && successCount > 0;
  bool get allFailed => successCount == 0 && failedCount > 0;
  bool get partialSuccess => successCount > 0 && failedCount > 0;
}

/// รอบตรวจ 1 รอบ จาก GET /admin/requests/{requestUuid}/
/// ใช้แสดงเป็น "โฟลเดอร์" ในหน้า detail
class InspectionRound {
  final String? uuid;
  final int? round;
  final String? state; // pending | passed | failed | in_progress ...
  final String? stateLabel;
  final String? comment;
  final String? reviewerUuid;
  final int? imageCount;
  final String? completedAt;
  final String? createdAt;
  final Map<String, dynamic>? raw;

  const InspectionRound({
    this.uuid,
    this.round,
    this.state,
    this.stateLabel,
    this.comment,
    this.reviewerUuid,
    this.imageCount,
    this.completedAt,
    this.createdAt,
    this.raw,
  });

  factory InspectionRound.fromJson(Map<String, dynamic> json) {
    String? pickStr(String k) => json[k] == null ? null : json[k].toString();
    int? pickInt(String k) {
      final v = json[k];
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    return InspectionRound(
      uuid: pickStr('uuid') ?? pickStr('id'),
      round: pickInt('round'),
      state: pickStr('state'),
      stateLabel: pickStr('state_label'),
      comment: pickStr('comment'),
      reviewerUuid: pickStr('reviewer_uuid'),
      imageCount: pickInt('image_count'),
      completedAt: pickStr('completed_at'),
      createdAt: pickStr('created_at'),
      raw: json,
    );
  }
}

/// Checklist snapshot จาก POST/GET /admin/requests/{uuid}/checklist
class ChecklistSnapshot {
  final String? uuid;
  final String? requestUuid;
  final int? version;
  final String? state;
  final Map<String, dynamic>? items; // โครงสร้าง checklist (Map/List อิง API)
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? raw;

  const ChecklistSnapshot({
    this.uuid,
    this.requestUuid,
    this.version,
    this.state,
    this.items,
    this.createdAt,
    this.updatedAt,
    this.raw,
  });

  factory ChecklistSnapshot.fromJson(Map<String, dynamic> json) {
    String? pickStr(String k) => json[k] == null ? null : json[k].toString();
    int? pickInt(String k) {
      final v = json[k];
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    // items อาจอยู่ใน key "items", "data", "checklist", "snapshot"
    Map<String, dynamic>? items;
    for (final k in ['items', 'checklist', 'snapshot']) {
      final v = json[k];
      if (v is Map<String, dynamic>) {
        items = v;
        break;
      }
    }
    if (items == null && !json.containsKey('items')) {
      items = json; // fallback
    }

    return ChecklistSnapshot(
      uuid: pickStr('uuid') ?? pickStr('id'),
      requestUuid: pickStr('request_uuid') ?? pickStr('requestUuid'),
      version: pickInt('version'),
      state: pickStr('state'),
      items: items,
      createdAt: pickStr('created_at'),
      updatedAt: pickStr('updated_at'),
      raw: json,
    );
  }
}

/// ผลลัพธ์ action ของ inspection (comment / transition)
class InspectionActionResult {
  final bool success;
  final String? message;
  final String? inspectionUuid;
  final String? state;
  final Map<String, dynamic>? raw;

  const InspectionActionResult({
    required this.success,
    this.message,
    this.inspectionUuid,
    this.state,
    this.raw,
  });

  factory InspectionActionResult.fromJson(Map<String, dynamic> json) {
    String? pickStr(String k) => json[k] == null ? null : json[k].toString();
    final ok = json['success'] is bool
        ? json['success'] as bool
        : (json['status']?.toString().toLowerCase() == 'success' ||
            json['status']?.toString().toLowerCase() == 'ok');
    return InspectionActionResult(
      success: ok,
      message: pickStr('message') ?? pickStr('msg'),
      inspectionUuid: pickStr('inspection_uuid') ?? pickStr('uuid'),
      state: pickStr('state'),
      raw: json,
    );
  }
}

/// ผลลัพธ์ action ของ request (prepayment / dates)
class RequestActionResult {
  final bool success;
  final String? message;
  final String? requestUuid;
  final Map<String, dynamic>? raw;

  const RequestActionResult({
    required this.success,
    this.message,
    this.requestUuid,
    this.raw,
  });

  factory RequestActionResult.fromJson(Map<String, dynamic> json) {
    String? pickStr(String k) => json[k] == null ? null : json[k].toString();
    final ok = json['success'] is bool
        ? json['success'] as bool
        : (json['status']?.toString().toLowerCase() == 'success' ||
            json['status']?.toString().toLowerCase() == 'ok');
    return RequestActionResult(
      success: ok,
      message: pickStr('message') ?? pickStr('msg'),
      requestUuid: pickStr('request_uuid') ?? pickStr('uuid'),
      raw: json,
    );
  }
}
