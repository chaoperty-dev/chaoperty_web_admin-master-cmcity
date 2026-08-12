// ============================================================================
// area_service.dart
// ============================================================================
// Service — เรียก API ทั้งหมดที่หน้า "จัดการ Area" ต้องใช้
// - ใช้ MyConstant().domain (PHP API) เป็น base
// - debugPrint error แทน swallow แบบไม่มีข้อมูล
// ============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../../Constant/Myconstant.dart';
import '../models/area_area_model.dart';
import '../models/area_count_model.dart';
import '../models/area_type_model.dart';
import '../models/area_zone_model.dart';

class AreaService {
  AreaService();

  String get _base => MyConstant().domain;

  // ───────────── Zones ─────────────

  /// โหลดรายการโซนทั้งหมด
  Future<List<AreaZoneModel>> fetchZones(String rser) async {
    final url = '$_base/GC_zone.php?isAdd=true&ren=$rser';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return <AreaZoneModel>[];
      final result = json.decode(response.body);
      if (result is! List) return <AreaZoneModel>[];
      final zones = result
          .whereType<Map<String, dynamic>>()
          .map(AreaZoneModel.fromJson)
          .toList();
      // 'ทั้งหมด' ขึ้นก่อน, ที่เหลือเรียงตามชื่อ
      zones.sort((a, b) {
        if (a.zn == 'ทั้งหมด') return -1;
        if (b.zn == 'ทั้งหมด') return 1;
        return a.zn.compareTo(b.zn);
      });
      return zones;
    } catch (e) {
      debugPrint('AreaService.fetchZones error: $e');
      return <AreaZoneModel>[];
    }
  }

  /// เช็คว่ามีโซนชื่อนี้แล้วหรือยัง
  Future<bool> zoneExists({
    required String rser,
    required String zn,
  }) async {
    final zones = await fetchZones(rser);
    return zones.any(
      (z) => z.zn.trim().toLowerCase() == zn.trim().toLowerCase(),
    );
  }

  /// เพิ่มโซนใหม่ (GET ตาม API เดิม: InC_zone_setring.php)
  Future<bool> addZone({
    required String rser,
    required String zn,
  }) async {
    final url = '$_base/InC_zone_setring.php?isAdd=true&ren=$rser&zonename=$zn';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return false;
      final body = response.body;
      final result = body.isNotEmpty ? json.decode(body) : null;
      return result.toString() == 'true';
    } catch (e) {
      debugPrint('AreaService.addZone error: $e');
      return false;
    }
  }

  /// ลบโซน (GET ตาม API เดิม: DeC_Zone.php)
  Future<bool> deleteZone({
    required String rser,
    required String zoneSer,
  }) async {
    final url = '$_base/DeC_Zone.php?isAdd=true&ren=$rser&zonename=$zoneSer';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return false;
      final body = response.body;
      final result = body.isNotEmpty ? json.decode(body) : null;
      return result.toString() == 'true';
    } catch (e) {
      debugPrint('AreaService.deleteZone error: $e');
      return false;
    }
  }

  // ───────────── Areas ─────────────

  /// โหลด Area (ถ้า zoneSer == '0' หรือว่าง จะดึงทั้งหมด)
  Future<List<AreaAreaModel>> fetchAreas({
    required String rser,
    required String zoneSer,
  }) async {
    final useAll = zoneSer.isEmpty || zoneSer == '0';
    final url = useAll
        ? '$_base/GC_areaAll.php?isAdd=true&ren=$rser'
        : '$_base/GC_areaAll.php?isAdd=true&ren=$rser&zone=$zoneSer';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return <AreaAreaModel>[];
      final result = json.decode(response.body);
      if (result is! List) return <AreaAreaModel>[];
      return result
          .whereType<Map<String, dynamic>>()
          .map(AreaAreaModel.fromJson)
          .toList();
    } catch (e) {
      debugPrint('AreaService.fetchAreas error: $e');
      return <AreaAreaModel>[];
    }
  }

  /// เพิ่ม Area ใหม่ (POST ตาม API เดิม: InC_area_setring.php)
  Future<bool> addArea({
    required String rser,
    required String zone,
    required String ln,
    required String sname,
    required String area,
    required String rent,
    required String rentMaket,
    required String sw,
    required String typeId,
  }) async {
    final url = '$_base/InC_area_setring.php?isAdd=true&ren=$rser';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'zonename': zone,
          'area_ser': ln,
          'area_name': sname,
          'area_qty': area,
          'area_pri': rent,
          'areamarket_pri': rentMaket,
          'sw': sw,
          'typeser': typeId,
        },
      );
      if (response.statusCode != 200) return false;
      final body = response.body;
      final result = body.isNotEmpty ? json.decode(body) : null;
      return result.toString() == 'true';
    } catch (e) {
      debugPrint('AreaService.addArea error: $e');
      return false;
    }
  }

  /// แก้ไข Area (POST ตาม API เดิม: UpC_area_setring.php — ส่ง ser ของ area ที่จะแก้)
  Future<bool> updateArea({
    required String rser,
    required String ser,
    required String zone,
    required String ln,
    required String sname,
    required String area,
    required String rent,
    required String rentMaket,
    required String sw,
    required String typeId,
  }) async {
    final url = '$_base/InC_area_setring.php?isAdd=true&ren=$rser';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'ser': ser,
          'zonename': zone,
          'area_ser': ln,
          'area_name': sname,
          'area_qty': area,
          'area_pri': rent,
          'areamarket_pri': rentMaket,
          'sw': sw,
          'typeser': typeId,
        },
      );
      if (response.statusCode != 200) return false;
      final body = response.body;
      final result = body.isNotEmpty ? json.decode(body) : null;
      return result.toString() == 'true';
    } catch (e) {
      debugPrint('AreaService.updateArea error: $e');
      return false;
    }
  }

  /// ลบ Area (GET ตาม API เดิม: DeC_area.php)
  Future<bool> deleteArea({
    required String rser,
    required String ser,
  }) async {
    final url = '$_base/DeC_area.php?isAdd=true&ren=$rser&vser=$ser';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return false;
      final body = response.body;
      final result = body.isNotEmpty ? json.decode(body) : null;
      return result.toString() == 'true';
    } catch (e) {
      debugPrint('AreaService.deleteArea error: $e');
      return false;
    }
  }

  // ───────────── Types ─────────────

  /// โหลด AreaType ทั้งหมด
  Future<List<AreaTypeModel>> fetchTypes(String rser) async {
    final url = '$_base/GC_areatype.php?isAdd=true&ren=$rser';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return <AreaTypeModel>[];
      final result = json.decode(response.body);
      if (result is! List) return <AreaTypeModel>[];
      return result
          .whereType<Map<String, dynamic>>()
          .map(AreaTypeModel.fromJson)
          .toList();
    } catch (e) {
      debugPrint('AreaService.fetchTypes error: $e');
      return <AreaTypeModel>[];
    }
  }

  // ───────────── Count ─────────────

  /// โหลดจำนวน Area ทั้งหมด
  Future<int> fetchAreaCount(String rser) async {
    final url = '$_base/GC_areaCount.php?isAdd=true&ren=$rser';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return 0;
      final result = json.decode(response.body);
      if (result is! List || result.isEmpty) return 0;
      final c = AreaCountModel.fromJson(
        (result.first as Map).cast<String, dynamic>(),
      );
      return int.tryParse(c.counta) ?? 0;
    } catch (e) {
      debugPrint('AreaService.fetchAreaCount error: $e');
      return 0;
    }
  }
}
