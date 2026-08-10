// ============================================================================
// registration_service.dart
// ============================================================================
// Service — โหลดข้อมูล "ทะเบียนลูกค้า" จาก API
// - ใช้ shared cache กับ License_menu (ApiCache 60s)
// - ใช้ GC_custo_se.php ตามต้นฉบับ Bureau_Registration/Customer_Screen
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:flutter/foundation.dart';
import 'package:chaoperty/Constant/api_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Model/GetCustomer_Model.dart';
import '../../../../Model/GetType_Model.dart';

class RegistrationService {
  RegistrationService({ApiCache? cache})
      : _cache = cache ?? ApiCache(ttl: const Duration(seconds: 60));

  final ApiCache _cache;

  // ---------- Customers ----------
  /// โหลดรายการ "ทะเบียนลูกค้า" ตาม rental
  /// ใช้ endpoint customer_register_V2.php (ตามต้นฉบับ PeopleChao/Rental_customer.dart)
  /// - ข้อมูลใหม่มี regis_data[] (มีข้อมูล line) และ contract_data[]
  /// - map field lineid จาก regis_data[0].reg_displayname / reg_userid / reg_username
  Future<List<CustomerModel>> fetchCustomers({String? ren}) async {
    final rawRen = ren ?? (await _getRenTalSer());
    // API ต้องการ ren=null เมื่อไม่มีค่า ไม่ใช่ ren=0
    // แต่ถ้า caller ส่ง '0' มาโดยตั้งใจ ให้ใช้ '0' เลย (ไม่แปลงเป็น null)
    final r = (rawRen.isEmpty) ? 'null' : rawRen;
    final cacheKey = 'registration_customers_$r';

    if (_cache.isValid(cacheKey)) {
      final cached = _cache.get(cacheKey);
      if (cached != null) {
        return (cached as List<dynamic>)
            .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    final url =
        '${MyConstant().domain}/customer_register_V2.php?isAdd=true&ren=$r';
    debugPrint('🔄 [RegistrationService.fetchCustomers]');
    debugPrint('   rawRen = $rawRen, resolvedRen = $r');
    debugPrint('   URL = $url');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        debugPrint('   ❌ HTTP ${response.statusCode}');
        return <CustomerModel>[];
      }
      final result = jsonDecode(response.body);
      if (result == null || result is! List) {
        debugPrint('   ⚠️ Response is not a List');
        return <CustomerModel>[];
      }
      debugPrint('   ✅ Got ${result.length} customers');

      // map lineid จาก regis_data[0] (ตามตัวอย่าง)
      final mapped = <Map<String, dynamic>>[];
      for (int i = 0; i < result.length; i++) {
        final row = result[i];
        final m = Map<String, dynamic>.from(row as Map<String, dynamic>);
        // ─── Debug: print row แรกทั้งหมด ───
        if (i == 0) {
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          debugPrint('📋 [fetchCustomers] Sample row 0 (raw JSON):');
          m.forEach((k, v) {
            debugPrint('     $k = $v');
          });
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        }
        // ดึง lineid จาก regis_data[0]
        final regis = m['regis_data'];
        if (regis is List && regis.isNotEmpty) {
          final r0 = regis.first as Map<String, dynamic>;
          // priority: reg_displayname > reg_userid > reg_username
          final lineid = (r0['reg_displayname']?.toString() ?? '').trim();
          final userid = (r0['reg_userid']?.toString() ?? '').trim();
          final username = (r0['reg_username']?.toString() ?? '').trim();
          if (lineid.isNotEmpty) {
            m['lineid'] = lineid;
          } else if (userid.isNotEmpty) {
            m['lineid'] = userid;
          } else if (username.isNotEmpty) {
            m['lineid'] = username;
          }
          // map line_regis_url (ใช้สำหรับเปิด QR dialog)
          final regisUrl = (r0['line_regis_url']?.toString() ?? '').trim();
          if (regisUrl.isNotEmpty) {
            m['line_regis_url'] = regisUrl;
          }
        }
        mapped.add(m);
      }

      _cache.set(cacheKey, mapped);
      final list = mapped
          .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // ─── Debug: print ผลลัพธ์ mapping ของ customer แรก ───
      if (list.isNotEmpty) {
        final c = list.first;
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('🔍 [fetchCustomers] CustomerModel แรก (0):');
        debugPrint('   ser    = ${c.ser}');
        debugPrint('   custno = ${c.custno}');
        debugPrint('   cname  = ${c.cname}');
        debugPrint('   scname = ${c.scname}');
        debugPrint('   tax    = ${c.tax}');
        debugPrint('   tel    = ${c.tel}');
        debugPrint('   type   = ${c.type}');
        debugPrint('   st     = ${c.st}');
        debugPrint('   lineid = ${c.lineid}');
        debugPrint('   lineRegisUrl = ${c.lineRegisUrl}');
        debugPrint('   birth  = ${c.birth}');
        debugPrint('   religion = ${c.religion}');
        debugPrint('   attn   = ${c.attn}');
        debugPrint('   addr1  = ${c.addr1}');
        debugPrint('   addr2  = ${c.addr2}');
        debugPrint('   zip    = ${c.zip}');
        debugPrint('   email  = ${c.email}');
        debugPrint('   uuid   = ${c.uuid}');
        debugPrint('   status = ${c.status}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }

      return list;
    } catch (e, st) {
      debugPrint('❌ [RegistrationService.fetchCustomers] error: $e');
      debugPrint('   StackTrace: $st');
      return <CustomerModel>[];
    }
  }

  /// Toggle / ลบ สถานะการใช้งาน (toggle st: 1 เปิด ↔ 0 ปิด)
  /// ใช้ endpoint De_customer_Bureau.php (GET) แล้วเช็คผลลัพธ์ 'true' / 'false'
  /// ตามต้นฉบับ Bureau_Registration/Customer_Screen
  /// - id: ser ของลูกค้า (running number)
  Future<bool> toggleCustomerStatus(String id, dynamic st) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer') ?? '0';
      final user = prefs.getString('ser') ?? '';

      // เปลี่ยน st: 1 → 0, 0 → 1
      final stStr = st.toString();
      final isOn = (stStr == '1' || stStr.toLowerCase() == 'true');
      final newSt = isOn ? '0' : '1';

      final url =
          '${MyConstant().domain}/De_customer_Bureau.php?isAdd=true&ren=$ren'
          '&user=$id&st=$newSt';

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔄 [RegistrationService.toggleCustomerStatus]');
      debugPrint('   id=$id, st=$stStr → newSt=$newSt');
      debugPrint('   ren=$ren, user=$user');
      debugPrint('   URL = $url');

      final resp =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      debugPrint('   Response status = ${resp.statusCode}');
      debugPrint('   Response body   = ${resp.body}');

      if (resp.statusCode != 200) {
        debugPrint('   ❌ HTTP != 200');
        return false;
      }

      // result เป็น string 'true' / 'false'
      final result = resp.body.trim();
      final success = result.toLowerCase() == 'true';
      debugPrint('   ${success ? "✅" : "❌"} Toggle result = $success');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return success;
    } catch (e, st) {
      debugPrint('❌ [RegistrationService.toggleCustomerStatus] error: $e');
      debugPrint('   StackTrace: $st');
      return false;
    }
  }

  /// ===== APP STATUS (เปิด/ปิด สำหรับแอปผู้เช่า) =====
  /// TODO: รอ API ของฝั่งแอปผู้เช่า (ตอนนี้ยังไม่มี endpoint)
  /// - ตอนนี้ return false เพื่อให้ caller rollback / ไม่เปลี่ยนสถานะ
  /// - เมื่อได้ endpoint แล้ว ให้แทน body ด้วย logic ของ toggleCustomerStatus
  ///   (GET → parse body 'true'/'false')
  Future<bool> toggleCustomerAppStatus(String uuid, dynamic st) async {
    debugPrint('⚠️ [RegistrationService.toggleCustomerAppStatus] '
        'ยังไม่ได้ implement — รอ API ของแอปผู้เช่า');
    debugPrint('   uuid=$uuid, st=$st → return false (no-op)');
    return false;
  }

  // ---------- Types ----------
  /// ประเภทลูกค้า (ใช้สำหรับ filter dropdown)
  Future<List<TypeModel>> fetchTypes() async {
    final cacheKey = 'registration_type';

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

  Future<String> _getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ser') ?? '';
  }
}
