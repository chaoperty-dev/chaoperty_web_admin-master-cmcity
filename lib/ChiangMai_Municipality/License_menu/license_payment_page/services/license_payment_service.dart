// ============================================================================
// license_payment_service.dart
// ============================================================================
// Service — CRUD operations สำหรับ "การรับชำระ" (Payment v2)
// ใช้ endpoint ตาม Postman "Chao RAPI - Payment v2 Receipts":
//   - POST  {domain_v1}/v2/payments              → สร้าง draft (internal / external)
// ใช้ MyHeaders.build() + http package เหมือน service อื่นๆ ในระบบ
//
// List payment tasks: GET /api/v2/admin/requests/tasks/payments
//   Laravel envelope {data[], meta{}, links{}}. Support free-text `q`
//   (uuid/lock/zone/subzone) + `customer` + `status[]` + date/boolean filters.
//
// Zones / SubZones: ใช้ legacy PHP API เหมือน LicenseContractService
// (copy มาจาก contract service เพื่อให้ dropdown ทำงาน)
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:chaoperty/Constant/api_cache.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Model/GetSubZone_Model.dart';
import '../../../../Model/GetZone_Model.dart';
import '../models/license_payment_detail_model.dart';
import '../models/payment_task_model.dart';

class LicensePaymentService {
  LicensePaymentService({ApiCache? cache}) : _cache = cache ?? ApiCache();
  final ApiCache _cache;

  Uri _uri(String path) => Uri.parse('${MyConstant().domain_v1}/$path');

  /// สร้าง URL สำหรับ v2 API (`/api/v2/...`) — strip `/v1` ออกจาก domain_v1
  Uri _uriV2(String path) {
    final base = MyConstant().domain_v1;
    final apiRoot = base.replaceFirst(RegExp(r'/v1/?$'), '');
    return Uri.parse('$apiRoot/$path');
  }

  // ---------- 1. สร้าง Payment Draft (Internal / External) ----------
  /// POST /v2/payments
  Future<PaymentDetail> createPaymentDraft({
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
    return PaymentDetail.fromJson(data);
  }

  // ---------- 2. List Payment Tasks (v2 endpoint) ----------
  /// GET /api/v2/admin/requests/tasks/payments
  /// Laravel paginated envelope {data, meta, links}.
  /// [urlCustom] ใช้ตอน paginate — Laravel ส่ง links.next/prev เป็น absolute URL
  Future<PaymentTasksResponse> listPaymentTasks({
    String? urlCustom,
    String? q, // uuid / lock / zone / subzone
    String? customer, // name / custno / tel
    List<String>? statuses, // repeatable status[]=a&status[]=b
    String? announcementUuid,
    int? moduleId,
    String? createdFrom, // Y-m-d
    String? createdTo,
    String? submittedFrom,
    String? submittedTo,
    bool? reviewAttachmentsAllDone,
    bool? inspectionPassed,
    bool? paymentAllDone,
    bool? includeDone,
    int perPage = 50,
    String? zser,
    String? subzoneser,
    String? sortBy,
    String? sortDir,
  }) async {
    final headers = await MyHeaders.build();

    String _statusArrayQs(List<String>? ss) {
      if (ss == null || ss.isEmpty) return '';
      return ss.map(Uri.encodeQueryComponent).join('&status[]=');
    }

    Uri _buildUri() {
      final base = _uriV2('v2/admin/requests/tasks/payments');

      void put(Map<String, String> qp, String k, String? v) {
        if (v != null && v.trim().isNotEmpty) qp[k] = v.trim();
      }

      void putBool(Map<String, String> qp, String k, bool? v) {
        if (v != null) qp[k] = v ? '1' : '0';
      }

      Map<String, String> qp;
      Uri urlCustomUri;
      if (urlCustom != null && urlCustom.isNotEmpty) {
        // กรณี paginate: ใช้ query params เดิมจาก URL ของ Laravel + เติม filter
        urlCustomUri = Uri.parse(urlCustom);
        // backend ส่ง next URL เป็น http:// → redirect ไป https ทำให้หลุด Authorization (401)
        if (urlCustomUri.scheme == 'http') {
          urlCustomUri = urlCustomUri.replace(scheme: 'https');
        }
        qp = Map<String, String>.from(urlCustomUri.queryParameters);
        qp['per_page'] = '$perPage';
      } else {
        urlCustomUri = Uri.parse('');
        qp = <String, String>{'per_page': '$perPage'};
      }
      put(qp, 'q', q);
      put(qp, 'customer', customer);
      put(qp, 'announcement_uuid', announcementUuid);
      put(qp, 'created_from', createdFrom);
      put(qp, 'created_to', createdTo);
      put(qp, 'submitted_from', submittedFrom);
      put(qp, 'submitted_to', submittedTo);
      if (moduleId != null) qp['module_id'] = '$moduleId';
      putBool(qp, 'review_attachments_all_done', reviewAttachmentsAllDone);
      putBool(qp, 'inspection_passed', inspectionPassed);
      putBool(qp, 'payment_all_done', paymentAllDone);
      putBool(qp, 'include_done', includeDone);
      // zser/subzoneser — ถ้าไม่ส่งเลย = ทั้งหมด, ถ้าส่ง '0' = ทั้งหมดเช่นกัน,
      // ถ้าส่ง ser จริง = filter โซนนั้น
      put(qp, 'zser', zser);
      put(qp, 'subzoneser', subzoneser);
      put(qp, 'sort_by', sortBy);
      put(qp, 'sort_dir', sortDir);

      final baseUri = base.replace(
        queryParameters: {...base.queryParameters, ...qp},
      );
      final baseStr = baseUri.toString();
      final sQs = _statusArrayQs(statuses);
      if (sQs.isEmpty) return baseUri;
      return Uri.parse('$baseStr&status[]=$sQs');
    }

    try {
      final uri = _buildUri();
      print('[listPaymentTasks][GET] $uri');

      final resp = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 25));

      if (resp.statusCode == 204 || resp.body.trim().isEmpty) {
        return const PaymentTasksResponse(
          data: [],
          currentPage: 0,
          lastPage: 0,
          perPage: 0,
          total: 0,
        );
      }
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        print('[ERR listPaymentTasks] ${resp.statusCode} ${resp.body}');
        throw Exception(
            'โหลดรายการรับชำระไม่สำเร็จ (status: ${resp.statusCode})');
      }

      final decoded = json.decode(resp.body);
      if (decoded is! Map) {
        throw Exception('Unexpected JSON shape (not a Map)');
      }
      final map = decoded;

      int toInt(dynamic v) => int.tryParse('$v') ?? 0;
      int currentPage = 0, lastPage = 0, perPageVal = 0, total = 0;
      if (map['meta'] is Map) {
        final m = map['meta'] as Map;
        currentPage = toInt(m['current_page']);
        lastPage = toInt(m['last_page']);
        perPageVal = toInt(m['per_page']);
        total = toInt(m['total']);
      }
      String? linksFirst, linksLast, linksPrev, linksNext;
      if (map['links'] is Map) {
        final l = map['links'] as Map;
        linksFirst = l['first']?.toString();
        linksLast = l['last']?.toString();
        linksPrev = l['prev']?.toString();
        linksNext = l['next']?.toString();
      }

      final raw = map['data'];
      List<PaymentTask> rows = const [];
      if (raw is List) {
        rows = raw
            .whereType<Map<String, dynamic>>()
            .map(PaymentTask.fromJson)
            .toList();
      }

      return PaymentTasksResponse(
        data: rows,
        currentPage: currentPage,
        lastPage: lastPage,
        perPage: perPageVal,
        total: total,
        linksFirst: linksFirst,
        linksLast: linksLast,
        linksPrev: linksPrev,
        linksNext: linksNext,
      );
    } catch (e) {
      print('[listPaymentTasks][exception] $e');
      rethrow;
    }
  }

  // ---------- 3. Zones (dropdown filter) ----------

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
