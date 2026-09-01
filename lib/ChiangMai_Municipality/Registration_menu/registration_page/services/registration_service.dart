// ============================================================================
// registration_service.dart
// ============================================================================
// Service — ทะเบียนผู้เช่า
// - ตาราง "เมนูทะเบียน" ดึงจากรายงานลูกค้า (domain_v2/admin/reports/customers)
//   คืนค่าเป็น CustomerReportItem (read-only display)
// - รายละเอียด / แก้ไข ยังคงใช้ API เดิม (CustomerModel) เพื่อให้แก้ไขข้อมูล
//   ทะเบียนได้เหมือนเดิม
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/ChiangMai_Municipality/Report_menu/customers/services/customers_report_service.dart';
import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:chaoperty/Constant/api_cache.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Model/GetCustomer_Model.dart';
import '../../../../Model/GetType_Model.dart';
import '../../../Report_menu/customers/services/customers_report_service.dart'
    show CustomerReportResult;

class RegistrationService {
  RegistrationService({ApiCache? cache})
      : _cache = cache ?? ApiCache(ttl: const Duration(seconds: 60));

  final ApiCache _cache;

  // ใช้ service รายงานลูกค้า (read-only) สำหรับตารางเมนู
  final CustomersReportService _report = CustomersReportService();

  // http client reuse
  final http.Client _client = http.Client();

  // ===============================================================
  // รายงานลูกค้า (MENU LIST) — CustomerReportItem
  // ===============================================================
  /// โหลดรายการลูกค้า "ทีละหน้า" จาก `/api/v1/admin/c-customers`
  /// ใช้แสดงในตาราง "ทะเบียนผู้เช่า" — server-side pagination
  /// - perPage ค่าเริ่มต้น 50 ตาม Laravel paginator
  /// - คืน CustomerReportResult { items, total, currentPage, lastPage }
  Future<CustomerReportResult> fetchReportCustomersPage({
    int page = 1,
    int perPage = 50,
    bool forceRefresh = false,
  }) async {
    return _report.fetchCCustomersPage(
      page: page,
      perPage: perPage,
      forceRefresh: forceRefresh,
    );
  }

  // ===============================================================
  // ทะเบียนลูกค้า (DETAIL / EDIT) — CustomerModel (legacy API)
  // ===============================================================
  /// โหลดรายการ "ทะเบียนลูกค้า" ตาม rental
  /// ใช้ endpoint เดิมของ Bureau_Registration/Customer_Screen.select_coutumer
  Future<List<CustomerModel>> fetchCustomers({String? ren}) async {
    final r = ren ?? (await _getRenTalSer());
    final cacheKey = 'registration_customers_$r';

    if (_cache.isValid(cacheKey)) {
      final cached = _cache.get(cacheKey);
      if (cached != null) {
        return (cached as List<dynamic>)
            .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    final url = '${MyConstant().domain}/GC_custo_se.php?isAdd=true&ren=$r';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        print('RegistrationService.fetchCustomers HTTP ${response.statusCode}');
        return <CustomerModel>[];
      }
      final result = jsonDecode(response.body);
      if (result == null || result is! List) return <CustomerModel>[];
      _cache.set(cacheKey, result);
      return result
          .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('RegistrationService.fetchCustomers error: $e');
      return <CustomerModel>[];
    }
  }

  // ---------- Types ----------
  /// ประเภทลูกค้า (ใช้สำหรับ filter dropdown)
  Future<List<TypeModel>> fetchTypes() async {
    const cacheKey = 'registration_type';

    if (_cache.isValid(cacheKey)) {
      final cached = _cache.get(cacheKey);
      if (cached != null) {
        return (cached as List<dynamic>)
            .map((e) => TypeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    final url = '${MyConstant().domain}/GC_type.php?isAdd=true';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        print('RegistrationService.fetchTypes HTTP ${response.statusCode}');
        return <TypeModel>[];
      }
      final result = jsonDecode(response.body);
      if (result == null || result is! List) return <TypeModel>[];
      _cache.set(cacheKey, result);
      return result
          .map((e) => TypeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('RegistrationService.fetchTypes error: $e');
      return <TypeModel>[];
    }
  }

  // ---------- Helpers ----------
  Future<String> _getRenTalSer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('renTalSer') ?? '0';
  }

  // ===============================================================
  // CRUD — POST/PUT/DELETE /v1/admin/c-customers
  // ใช้จาก "เพิ่มทะเบียน" (POST), "แก้ไขทะเบียน" (PUT), "ลบทะเบียน" (DELETE)
  // - body ของ POST ใส่ field ครบ
  // - body ของ PUT ใส่เฉพาะ field ที่ต้องการอัพเดต (partial update)
  // - ทุก call clear แคชของ customers report เพื่อให้ list refresh ทันที
  // ===============================================================

  /// GET /v1/admin/c-customers/{uuid} — ดึงรายละเอียดลูกค้า 1 รายการ
  /// ใช้ในหน้า Detail (read-only)
  /// Response shape: `{ "data": { uuid, custno, sname, ... } }`
  Future<Map<String, dynamic>?> fetchCustomerByUuid(String uuid) async {
    if (uuid.trim().isEmpty) return null;
    final url = '${MyConstant().domain_v1}/admin/c-customers/$uuid';
    final headers = await MyHeaders.build();
    final res = await _client
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw Exception('โหลดรายละเอียดลูกค้าไม่สำเร็จ (HTTP ${res.statusCode})');
    }
    final body = json.decode(res.body);
    if (body is Map && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    if (body is Map) return Map<String, dynamic>.from(body);
    return null;
  }

  String? _extractMessage(dynamic body) {
    try {
      final b = body is String ? json.decode(body) : body;
      if (b is Map && b['message'] is String) return b['message'] as String;
    } catch (_) {}
    return null;
  }

  /// POST /v1/admin/c-customers — สร้างทะเบียนใหม่
  /// Returns: `{"custno": "01520", "uuid": "...", ...}` (จาก data.data)
  Future<Map<String, dynamic>> createCustomer(
      Map<String, dynamic> payload) async {
    final url = '${MyConstant().domain_v1}/admin/c-customers';
    final headers = await MyHeaders.build();
    final res = await _client
        .post(Uri.parse(url),
            headers: headers, body: json.encode(payload))
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200 && res.statusCode != 201) {
      final msg = _extractMessage(res.body) ??
          'สร้างทะเบียนไม่สำเร็จ (HTTP ${res.statusCode})';
      throw Exception(msg);
    }

    _report.clearCache();
    final body = json.decode(res.body);
    if (body is Map && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    if (body is Map) return Map<String, dynamic>.from(body);
    return <String, dynamic>{};
  }

  /// PUT /v1/admin/c-customers/{uuid} — อัพเดต (partial — ใส่เฉพาะ field ที่เปลี่ยน)
  Future<void> updateCustomer(
      {required String uuid, required Map<String, dynamic> payload}) async {
    if (uuid.trim().isEmpty) {
      throw Exception('Customer UUID is required');
    }
    final url = '${MyConstant().domain_v1}/admin/c-customers/$uuid';
    final headers = await MyHeaders.build();
    final res = await _client
        .put(Uri.parse(url),
            headers: headers, body: json.encode(payload))
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200 && res.statusCode != 201) {
      final msg = _extractMessage(res.body) ??
          'อัพเดตทะเบียนไม่สำเร็จ (HTTP ${res.statusCode})';
      throw Exception(msg);
    }

    _report.clearCache();
  }

  /// DELETE /v1/admin/c-customers/{uuid} — ลบทะเบียน
  Future<void> deleteCustomer(String uuid) async {
    if (uuid.trim().isEmpty) {
      throw Exception('Customer UUID is required');
    }
    final url = '${MyConstant().domain_v1}/admin/c-customers/$uuid';
    final headers = await MyHeaders.build();
    final res = await _client
        .delete(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200 && res.statusCode != 201 && res.statusCode != 204) {
      final msg = _extractMessage(res.body) ??
          'ลบทะเบียนไม่สำเร็จ (HTTP ${res.statusCode})';
      throw Exception(msg);
    }

    _report.clearCache();
  }
}
