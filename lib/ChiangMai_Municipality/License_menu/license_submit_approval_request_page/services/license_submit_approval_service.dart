// ============================================================================
// license_submit_approval_service.dart
// ============================================================================
// Service — CRUD operations สำหรับ "ส่งคำร้องขออนุมัติ" (SubmitApproval)
//
// Endpoints (ตามที่ user ต้องการ — ใช้ v2):
//   - GET  /api/v2/admin/requests/tasks/approvals     (list — ใหม่)
//   - POST {domain_v1}/v2/payments                   (create draft — เดิม)
//
// หมายเหตุ: ไม่แตะไฟล์อื่นนอกโฟรเดอร์นี้
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:chaoperty/Constant/api_cache.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Model/GetSubZone_Model.dart';
import '../../../../Model/GetZone_Model.dart';
import '../models/license_submit_approval_detail_model.dart';
import '../../license_request_page/services/license_request_service.dart';

class SubmitApprovalListResult {
  final List<SubmitApprovalDetail> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? linksNext;
  final String? linksPrev;
  const SubmitApprovalListResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.linksNext,
    this.linksPrev,
  });
}

class LicenseSubmitApprovalService {
  LicenseSubmitApprovalService(
      {LicenseRequestService? requestService, ApiCache? cache})
      : _requestService = requestService ?? LicenseRequestService(),
        _cache = cache ?? ApiCache();
  final ApiCache _cache;
  final LicenseRequestService _requestService;

  Uri _uri(String path) => Uri.parse('${MyConstant().domain_v1}/$path');

  /// สร้าง Uri ไป v2 endpoint — base จาก domain_v1 ตัด /v1 ออก แล้วใส่ v2/...
  /// เช่น https://host/api/v1 → https://host/api/v2/...
  Uri _uriV2(String path, [Map<String, String>? qp]) {
    final base = MyConstant().domain_v1;
    final apiRoot = base.replaceFirst(RegExp(r'/v1/?$'), '');
    final uri = Uri.parse('$apiRoot/$path');
    if (qp == null || qp.isEmpty) return uri;
    return uri.replace(queryParameters: {...uri.queryParameters, ...qp});
  }

  // ---------- 1. สร้าง Payment Draft (Internal / External) ----------
  /// POST /v2/payments
  Future<SubmitApprovalDetail> createPaymentDraft({
    required String requestUuid,
    required String paymentSystem,
    required String payType,
    int? paymentMethodId,
    double? amount,
  }) async {
    if (requestUuid.trim().isEmpty) {
      throw Exception('Request UUID is required');
    }
    if (paymentSystem != 'internal' && paymentSystem != 'external') {
      throw Exception('payment_system ต้องเป็น internal หรือ external');
    }

    final payload = <String, dynamic>{
      'request_uuid': requestUuid,
      'payment_system': paymentSystem,
      'pay_type': payType,
    };
    if (paymentSystem == 'internal' && paymentMethodId != null) {
      payload['payment_method_id'] = paymentMethodId;
    }
    if (amount != null) {
      payload['amount'] = amount;
    }

    final headers = await MyHeaders.build();
    final res = await http
        .post(
          _uri('v2/payments'),
          headers: {
            ...headers,
            'Content-Type': 'application/json',
          },
          body: json.encode(payload),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200 && res.statusCode != 201) {
      String msg = 'สร้าง Payment draft ไม่สำเร็จ (status: ${res.statusCode})';
      try {
        final b = json.decode(res.body);
        if (b is Map && b['message'] is String) msg = b['message'] as String;
      } catch (_) {}
      throw Exception(msg);
    }

    final body = json.decode(res.body) as Map<String, dynamic>;
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return SubmitApprovalDetail.fromJson(data);
  }

  // ---------- 2. List Tasks Approvals (v2 — ใหม่) ----------
  /// GET /api/v2/admin/requests/tasks/approvals
  /// - query params: per_page, page, q, zn
  /// - urlCustom: ลิงก์จาก Laravel pagination (full URL)
  /// ใช้ SubmitApprovalDetail.fromJson() parse (รองรับ v2 shape)
  Future<SubmitApprovalListResult> listTasksApprovals({
    String? urlCustom,
    String query = '',
    int perPage = 50,
    int page = 1,
    String? zn,
    List<String>? statuses,
  }) async {
    try {
      Uri uri;
      if (urlCustom != null && urlCustom.isNotEmpty) {
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
        uri = _uriV2('v2/admin/requests/tasks/approvals', qp);
      }

      // ────────────────────────────────────────────────────────────────
      // DEBUG: print URL + context ทุกครั้งที่ยิง v2 tasks/approvals
      print('╔══════════════════════════════════════════════════════════════');
      print('║ [listTasksApprovals][v2] GET → $uri');
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
        return const SubmitApprovalListResult(
          items: [],
          currentPage: 0,
          lastPage: 0,
          perPage: 0,
          total: 0,
        );
      }
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        print('[listTasksApprovals][ERR] ${resp.statusCode} ${resp.reasonPhrase}');
        print('[listTasksApprovals][BODY] ${resp.body}');
        return const SubmitApprovalListResult(
          items: [],
          currentPage: 0,
          lastPage: 0,
          perPage: 0,
          total: 0,
        );
      }

      final decoded = json.decode(resp.body);
      if (decoded is! Map) {
        print('[listTasksApprovals][ERR] body is not a Map');
        return const SubmitApprovalListResult(
          items: [],
          currentPage: 0,
          lastPage: 0,
          perPage: 0,
          total: 0,
        );
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
      String? linksPrev, linksNext;
      if (map['links'] is Map) {
        final lm = map['links'] as Map;
        linksPrev = lm['prev']?.toString();
        linksNext = lm['next']?.toString();
      }

      // data
      final items = <SubmitApprovalDetail>[];
      final rawData = map['data'];
      if (rawData is List) {
        for (final raw in rawData) {
          if (raw is Map<String, dynamic>) {
            items.add(SubmitApprovalDetail.fromJson(raw));
          }
        }
      }

      print(
          '[listTasksApprovals][v2][result] currentPage=$currentPage lastPage=$lastPage perPage=$perPageVal total=$total dataCount=${items.length} prev=$linksPrev next=$linksNext');

      return SubmitApprovalListResult(
        items: items,
        currentPage: currentPage,
        lastPage: lastPage,
        perPage: perPageVal,
        total: total,
        linksNext: linksNext,
        linksPrev: linksPrev,
      );
    } catch (e, st) {
      print('[listTasksApprovals][exception] $e');
      print(st);
      return const SubmitApprovalListResult(
        items: [],
        currentPage: 0,
        lastPage: 0,
        perPage: 0,
        total: 0,
      );
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
    return source.replace(queryParameters: qp);
  }

  int _toInt(dynamic v) => int.tryParse('$v') ?? 0;

  // ---------- 3. List Payments (legacy alias — backward-compat) ----------
  /// ใช้ v1 API `/admin/approvals` แทน `/v2/payments`
  /// Map ReviewModel → SubmitApprovalDetail (alias)
  /// เก็บไว้เผื่อ caller อื่น — ไม่แนะนำให้ใช้แล้ว, ใช้ listTasksApprovals() แทน
  Future<List<SubmitApprovalDetail>> listPayments({
    String? paymentUuid,
    String? paymentNo,
    String? dateTo,
    String? bookNo,
    String? receiptNo,
    String? zn,
    int? perPage,
    String? sortBy,
    String sortDir = 'desc',
  }) async {
    final result = await _requestService.fetchRequests(
      query: paymentUuid ?? '',
      perPage: perPage ?? 50,
      sortDir: sortDir,
      searchField: 'uuid',
      zn: zn,
    );

    return result.data.map((r) {
      return SubmitApprovalDetail(
        uuid: r.uuid ?? '',
        paymentNo: r.newRequest?.leaseNumber ?? '-',
        paymentSystem: r.newRequest?.subzone ?? '-',
        payType: r.newRequest?.zn ?? '-',
        status: r.status ?? 'draft',
        methodName: r.newRequest?.ln ?? '-',
        payerName: r.client?.cname ?? '-',
        clientTel: r.client?.tel ?? '',
        clientTax: r.client?.tax ?? '',
        clientAddr1: r.client?.addr1 ?? '',
        amount: 0,
        amountReceived: null,
        paidAt: r.newRequest?.ldate,
        createdAt: null,
        moduleName: r.module?.nameTh ?? '',
        moduleCode: r.module?.code ?? '',
        subzone: r.newRequest?.subzone ?? '',
        zn: r.newRequest?.zn ?? '',
        ln: r.newRequest?.ln ?? '',
      );
    }).toList();
  }

  // ---------- 4. Zones ----------
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
      print('LicenseSubmitApprovalService.fetchZones error: $e');
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

  // ---------- 5. SubZones ----------
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
      print('LicenseSubmitApprovalService.fetchSubZones error: $e');
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