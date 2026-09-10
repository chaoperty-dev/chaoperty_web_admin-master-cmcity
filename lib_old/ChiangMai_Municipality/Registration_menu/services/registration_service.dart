// ============================================================================
// registration_service.dart
// ============================================================================
// Service — โหลดข้อมูล "ทะเบียนลูกค้า" จาก API
// - ใช้ shared cache กับ License_menu (ApiCache 60s)
// - ใช้ GC_custo_se.php ตามต้นฉบับ Bureau_Registration/Customer_Screen
// ============================================================================

import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:chaoperty/Constant/api_cache.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Model/GetCustomer_Model.dart';
import '../../../Model/GetType_Model.dart';

class RegistrationService {
  RegistrationService({ApiCache? cache})
      : _cache = cache ?? ApiCache(ttl: const Duration(seconds: 60));

  final ApiCache _cache;

  // ---------- Customers ----------
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
}
