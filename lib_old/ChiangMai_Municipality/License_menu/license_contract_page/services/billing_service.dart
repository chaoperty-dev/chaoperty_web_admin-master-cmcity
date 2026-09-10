// ============================================================================
// billing_service.dart
// ============================================================================
// Service สำหรับ BillingTable — โหลดข้อมูลค่าบริการจาก API
// ============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Constant/Myconstant.dart';
import '../models/billing_models.dart';

class BillingService {
  /// โหลดประเภทค่าบริการ
  Future<List<LcExpTypeModel>> loadExpTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final ren = prefs.getString('renTalSer') ?? '';
    final url = '${MyConstant().domain}/GC_exptype.php?isAdd=true&ren=$ren';
    return _fetchList(url, (map) => LcExpTypeModel.fromJson(map));
  }

  /// โหลดหน่วยนับ
  Future<List<LcUnitModel>> loadUnits() async {
    final url = '${MyConstant().domain}/GC_unit.php?isAdd=true';
    return _fetchList(url, (map) => LcUnitModel.fromJson(map));
  }

  /// โหลด VAT
  Future<List<LcVatModel>> loadVats() async {
    final prefs = await SharedPreferences.getInstance();
    final ren = prefs.getString('renTalSer') ?? '';
    final url = '${MyConstant().domain}/GC_vat.php?isAdd=true&ren=$ren';
    return _fetchList(url, (map) => LcVatModel.fromJson(map));
  }

  /// โหลด WHT
  Future<List<LcWhtModel>> loadWhts() async {
    final prefs = await SharedPreferences.getInstance();
    final ren = prefs.getString('renTalSer') ?? '';
    final url = '${MyConstant().domain}/GC_wht.php?isAdd=true&ren=$ren';
    return _fetchList(url, (map) => LcWhtModel.fromJson(map));
  }

  /// โหลดประกาศโซน → คืน pay_status
  Future<int> loadPayStatusFine() async {
    final prefs = await SharedPreferences.getInstance();
    final zoneser = prefs.getString('zoneSer') ?? '';
    final url =
        '${MyConstant().domain}/AnnounceMent_Getzone.php?zoneid=$zoneser';
    try {
      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);
      final data = result['data'];
      if (data != null) {
        return int.tryParse(data['pay_status']?.toString() ?? '0') ?? 0;
      }
    } catch (e) {
      // ignore
    }
    return 0;
  }

  /// โหลดค่าบริการอัตโนมัติ
  Future<List<LcAutoExpModel>> loadAutoExps(int payStatusFine) async {
    final prefs = await SharedPreferences.getInstance();
    final ren = prefs.getString('renTalSer') ?? '';
    final url = '${MyConstant().domain}/GC_exp_setring.php?isAdd=true&ren=$ren';
    try {
      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);
      if (result is List) {
        return result
            .map((map) => LcAutoExpModel.fromJson(map))
            .where((m) => !(payStatusFine == 0 && m.etype == 'F'))
            .toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  Future<List<T>> _fetchList<T>(
    String url,
    T Function(Map<String, dynamic>) parser,
  ) async {
    try {
      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);
      if (result is List) {
        return result
            .map((map) => parser(map as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }
}
