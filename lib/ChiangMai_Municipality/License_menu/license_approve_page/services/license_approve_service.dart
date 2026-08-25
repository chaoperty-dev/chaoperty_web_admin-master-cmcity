// ============================================================================
// license_approve_service.dart
// ============================================================================
// Service — โหลดข้อมูล "คำขอต่อสัญญา"
// - v1 fetchRequests() → GET /v1/admin/approvals (เดิม)
// - v2 fetchRequestsMe() → GET /v2/admin/approvals/me (ใหม่ ตามที่ user ต้องการ)
// ใช้ read_GC_Reviews() + HTTP ตรงสำหรับ zones/subzones
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:chaoperty/Constant/api_cache.dart';
import 'package:chaoperty/Model/GetSubZone_Model.dart';
import 'package:chaoperty/Model/GetZone_Model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Model/Review_Model.dart';
import '../../../unity/API_requests_reviews.dart';
import '../../../unity/API_approvals_lastaction.dart';

class LicenseApproveService {
  LicenseApproveService({ApiCache? cache})
      : _cache = cache ?? ApiCache(ttl: const Duration(seconds: 60));

  final ApiCache _cache;

  // ===============================================================
  // v1 — backward compatible (ใช้อยู่ที่อื่น)
  // ===============================================================
  /// โหลดรายการ "คำขอต่อสัญญา" (ser=0 / level=1) — v1 endpoint
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

  // ===============================================================
  // v2 — GET /api/v2/admin/approvals/me
  // ===============================================================
  /// สร้าง Uri ไป v2 endpoint — base จาก domain_v1 ตัด /v1 ออก แล้วใส่ v2/...
  /// เช่น https://host/api/v1 → https://host/api/v2/admin/approvals/me
  Uri _uriV2Me([Map<String, String>? queryParams]) {
    final base = MyConstant().domain_v1;
    final apiRoot = base.replaceFirst(RegExp(r'/v1/?$'), '');
    final uri = Uri.parse('$apiRoot/v2/admin/approvals/me');
    if (queryParams == null || queryParams.isEmpty) return uri;
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParams,
    });
  }

  /// โหลดรายการ "คำขอต่อสัญญา" — v2 endpoint
  /// - GET /api/v2/admin/approvals/me
  /// - query params: per_page, page, q, zn
  /// - urlCustom: ลิงก์จาก Laravel pagination (full URL หรือ relative path)
  Future<ReviewResponse> fetchRequestsMe({
    String? urlCustom,
    String query = '',
    int perPage = 50,
    int page = 1,
    String? zn,
    List<String>? statuses,
    String? sortBy,
    String? sortDir,
  }) async {
    try {
      Uri uri;
      if (urlCustom != null && urlCustom.isNotEmpty) {
        // ─── next/prev link (อาจเป็น full URL หรือ relative path) ───
        uri = _resolvePagingUrl(urlCustom,
            query: query, perPage: perPage, zn: zn, statuses: statuses);
      } else {
        final qp = <String, String>{
          'per_page': '$perPage',
          if (page > 1) 'page': '$page',
        };
        if (query.trim().isNotEmpty) qp['q'] = query.trim();
        if (zn != null && zn.isNotEmpty && zn != '0' && zn != 'ทั้งหมด') {
          qp['zn'] = zn;
        }
        if (statuses != null && statuses.isNotEmpty) {
          for (final s in statuses) {
            qp['status[]'] = s;
          }
        }
        if (sortBy != null && sortBy.isNotEmpty) {
          qp['sort_by'] = sortBy;
        }
        if (sortDir != null && sortDir.isNotEmpty) {
          qp['sort_dir'] = sortDir;
        }
        // ซ่อนรายการที่ done แล้วเป็น default (user request: ทุกเส้น ใส่ include_done=0)
        qp['include_done'] = '0';
        uri = _uriV2Me(qp);
      }

      // ────────────────────────────────────────────────────────────────
      // DEBUG: print URL + context ทุกครั้งที่ยิง v2 /admin/approvals/me
      print('╔══════════════════════════════════════════════════════════════');
      print('║ [fetchRequestsMe][v2] GET → $uri');
      print('║   • urlCustom  : $urlCustom');
      print('║   • query      : "$query"');
      print('║   • zn (zone)  : $zn');
      print('║   • perPage    : $perPage');
      print('║   • page       : $page');
      print('╚══════════════════════════════════════════════════════════════');
      // ────────────────────────────────────────────────────────────────

      final headers = await MyHeaders.build();
      final resp = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 25));

      if (resp.statusCode == 204 || resp.body.trim().isEmpty) {
        return _emptyResponse();
      }
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        print('[fetchRequestsMe][ERR] ${resp.statusCode} ${resp.reasonPhrase}');
        print('[fetchRequestsMe][BODY] ${resp.body}');
        return _emptyResponse();
      }

      final decoded = json.decode(resp.body);
      if (decoded is! Map) {
        print('[fetchRequestsMe][ERR] body is not a Map');
        return _emptyResponse();
      }
      final map = decoded;

      // ─── meta ───
      int currentPage = 0, lastPage = 0, perPageVal = 0, total = 0;
      if (map['meta'] is Map) {
        final meta = map['meta'] as Map;
        currentPage = _toInt(meta['current_page']);
        lastPage = _toInt(meta['last_page']);
        perPageVal = _toInt(meta['per_page']);
        total = _toInt(meta['total']);
      }

      // ─── links (v2 ส่งมาเป็น relative path เช่น "/?page=2") ───
      String? linksFirst, linksLast, linksPrev, linksNext;
      if (map['links'] is Map) {
        final lm = map['links'] as Map;
        linksFirst = lm['first']?.toString();
        linksLast = lm['last']?.toString();
        linksPrev = lm['prev']?.toString();
        linksNext = lm['next']?.toString();
      }

      // ─── data ───
      final dataList = <ReviewModel>[];
      final rawData = map['data'];
      if (rawData is List) {
        for (final raw in rawData) {
          if (raw is Map<String, dynamic>) {
            dataList.add(ReviewModel.fromJson(raw));
          }
        }
      }

      print(
          '[fetchRequestsMe][v2][result] currentPage=$currentPage lastPage=$lastPage perPage=$perPageVal total=$total dataCount=${dataList.length} prev=$linksPrev next=$linksNext');

      return ReviewResponse(
        data: dataList,
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
      print('[fetchRequestsMe][exception] $e');
      print(st);
      return _emptyResponse();
    }
  }

  /// แปลง pagination link (full URL หรือ relative path) → absolute Uri
  /// ใส่ query params ที่ต้องคงไว้ (q, zn, per_page) ถ้าลิงก์เดิมไม่มี
  Uri _resolvePagingUrl(
    String raw, {
    required String query,
    required int perPage,
    String? zn,
    List<String>? statuses,
  }) {
    final base = MyConstant().domain_v1.replaceFirst(RegExp(r'/v1/?$'), '');
    Uri source;
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      source = Uri.parse(raw);
    } else {
      // relative path เช่น "/?page=2" → prepend host (root ของ /api)
      final path = raw.startsWith('/') ? raw : '/$raw';
      source = Uri.parse('$base$path');
    }
    // backend ส่ง next URL เป็น http:// → redirect ไป https ทำให้หลุด Authorization (401)
    if (source.scheme == 'http') {
      source = source.replace(scheme: 'https');
    }
    final qp = Map<String, String>.from(source.queryParameters);
    qp['per_page'] = qp['per_page'] ?? '$perPage';
    if (query.trim().isNotEmpty && !qp.containsKey('q')) {
      qp['q'] = query.trim();
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
    // ซ่อนรายการที่ done แล้วเป็น default (user request: ทุกเส้น ใส่ include_done=0)
    qp['include_done'] = '0';
    return source.replace(queryParameters: qp);
  }

  ReviewResponse _emptyResponse() => ReviewResponse(
        data: [],
        currentPage: 0,
        lastPage: 0,
        perPage: 0,
        total: 0,
        linksFirst: null,
        linksLast: null,
        linksPrev: null,
        linksNext: null,
      );

  int _toInt(dynamic v) => int.tryParse('$v') ?? 0;

  // ===============================================================
  // Zones (เหมือนเดิม — ไม่ยุ่ง)
  // ===============================================================
  /// โหลดรายการ "โซน" (zones) — default คือทั้งหมด
  Future<List<ZoneModel>> fetchZones({String? zoneSubSer}) async {
    final ren = await _getRenTalSer();
    final cacheKey = 'license_approve_zone_${ren}_$zoneSubSer';

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
      print('LicenseApproveService.fetchZones error: $e');
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

  // ===============================================================
  // SubZones (เหมือนเดิม — ไม่ยุ่ง)
  // ===============================================================
  /// โหลดรายการ "โซนพื้นที่เช่า" (subzones) — default คือทั้งหมด
  Future<List<SubZoneModel>> fetchSubZones() async {
    final ren = await _getRenTalSer();
    final cacheKey = 'license_approve_subzone_$ren';

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
      print('LicenseApproveService.fetchSubZones error: $e');
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

  // ===============================================================
  // Helpers
  // ===============================================================
  Future<String?> _getRenTalSer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('renTalSer');
  }
}
