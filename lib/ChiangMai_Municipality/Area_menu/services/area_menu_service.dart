// ============================================================================
// area_menu_service.dart
// ============================================================================
// ✅ SELF-CONTAINED — ไม่ depend on ไฟล์อื่นในโปรเจกต์
// ทุกอย่าง (model, HTTP, parsing) อยู่ในไฟล์นี้ทั้งหมด
//
// API ที่ใช้ (เหมือน ChaoArea_Screen.dart):
// - read_GC_properties(zone, null, null) → /admin/requests/properties
// - GC_areaAll.php
// - GC_areaquot_v2.php
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// ✅ Internal Models — ของตัวเอง ไม่ import จากที่อื่น
// ============================================================================
class _PropertyModel {
  int? aser;
  int? id;
  String? uuid;
  String? requestUuid;
  String? ln;
  String? ldate;
  String? sdate;
  String? zn;
  String? subzone; // ✅ sub-zone name (จาก properties API: new_request.subzone)
  int? requestStep;
  String? requestStatus;
  String? createdAt;
  String? clientName;
  String? clientUuid;

  /// Parse แบบ resilient — ทุก field ใช้ tryParse/null-safe
  static _PropertyModel? fromJsonSafe(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final m = _PropertyModel();
      final nr = json['new_request'];
      if (nr is Map<String, dynamic>) {
        m.aser = _asInt(nr['aser']);
        m.id = _asInt(nr['id']);
        m.uuid = _asString(nr['uuid']);
        m.requestUuid = _asString(nr['request_uuid']);
        m.ln = _asString(nr['ln']);
        m.ldate = _asString(nr['ldate']);
        m.sdate = _asString(nr['sdate']);
        m.zn = _asString(nr['zn']);
        m.subzone = _asString(nr['subzone']); // ✅ parse sub-zone name
        m.requestStep = _asInt(nr['request_step']);
        m.requestStatus = _asString(nr['request_status']);
        m.createdAt = _asString(nr['created_at']);
      }
      final cl = json['client'];
      if (cl is Map<String, dynamic>) {
        m.clientName = _asString(cl['cname']) ?? _asString(cl['scname']);
        m.clientUuid = _asString(cl['uuid']);
      }
      return m;
    } catch (e) {
      print('⚠️ skip malformed property: $e');
      return null;
    }
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static String? _asString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }
}

class _AreaModel {
  String? ser;
  String? zn;
  String? ln;
  String? cid; // ✅ เลขที่สัญญา (จาก API: cid)
  String? sdate;
  String? ldate;
  String? quantity;
  String? ln_q;
  String? sname;
  String? cname;
  String? stype; // ✅ ประเภทธุรกิจ (เช่น "เสื้อผ้าพื้นเมือง/กระเป๋า")
  String? st; // ✅ สถานะสัญญา (เช่น "สัญญาปัจจุบัน")

  /// Parse แบบ defensive
  static _AreaModel? fromJsonSafe(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final a = _AreaModel();
      a.ser = json['ser']?.toString();
      a.zn = json['zn']?.toString();
      a.ln = json['ln']?.toString();
      a.cid = json['cid']?.toString(); // ✅ parse cid
      a.sdate = json['sdate']?.toString();
      a.ldate = json['ldate']?.toString();
      a.quantity = json['quantity']?.toString();
      a.ln_q = json['ln_q']?.toString();
      a.sname = json['sname']?.toString();
      a.cname = json['cname']?.toString();
      a.stype = json['stype']?.toString(); // ✅ parse business type
      a.st = json['st']?.toString(); // ✅ parse contract status
      return a;
    } catch (e) {
      return null;
    }
  }
}

// ============================================================================
// Internal helpers
// ============================================================================
List<_AreaModel> _parseAreasIsolate(List<dynamic> data) {
  return data
      .whereType<Map<String, dynamic>>()
      .map((m) => _AreaModel.fromJsonSafe(m))
      .whereType<_AreaModel>()
      .toList();
}

List<List<T>> _chunked<T>(List<T> list, int size) {
  final out = <List<T>>[];
  for (var i = 0; i < list.length; i += size) {
    final end = math.min(i + size, list.length);
    out.add(list.sublist(i, end));
  }
  return out;
}

// ============================================================================
// Service — ของตัวเองทั้งหมด
// ============================================================================
class AreaMenuService {
  AreaMenuService();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    responseType: ResponseType.json,
  ));
  final CancelToken _cancelToken = CancelToken();

  // ===============================================================
  // ✅ Main: โหลด "คำขอต่อสัญญา" — ใช้ API เดียวกับ ChaoArea
  // ===============================================================
  Future<List<Map<String, dynamic>>> fetchRequestsFromProperties({
    String? zoneSer,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // ✅ รองรับทั้ง key เก่า ('renTalSer') และ key ใหม่ ('rser')
      final ren = prefs.getString('renTalSer') ?? prefs.getString('rser');

      // เงื่อนไขเดิม Data_Properties() — เฉพาะ ren 50/139/195
      if (ren != '50' && ren != '139' && ren != '195') {
        return <Map<String, dynamic>>[];
      }

      final zone = zoneSer ?? prefs.getString('zoneSer');

      // ── Step 1: โหลด properties (HTTP ตรง — ไม่ผ่าน read_GC_properties) ──
      final props = await _loadProperties(zone: zone);
      if (props.isEmpty) {
        print('⚠️ ไม่พบ Properties (area_menu)');
        return <Map<String, dynamic>>[];
      }

      // ── Step 2: โหลด areaAll (Dio) + quot ──
      final areaList = await _loadAreaAll(ren: ren, zone: zone);

      // ── Step 3: Map properties + area เป็น Map<String, dynamic> ──
      final propMap = <String, _PropertyModel>{};
      for (final p in props) {
        if (p.aser != null) propMap[p.aser.toString()] = p;
      }

      final reviews = <Map<String, dynamic>>[];
      for (final area in areaList) {
        final p = propMap[area.ser ?? ''];
        reviews.add(_buildMap(p, area));
      }
      return reviews;
    } catch (e, st) {
      print('❌ fetchRequestsFromProperties error: $e\n$st');
      return <Map<String, dynamic>>[];
    }
  }

  // ===============================================================
  // HTTP #1 — โหลด properties เอง (ไม่ผ่าน read_GC_properties)
  // ===============================================================
  Future<List<_PropertyModel>> _loadProperties({String? zone}) async {
    try {
      final headers = await _buildHeaders();
      final url = (zone == null ||
              zone == '0' ||
              zone == 'null' ||
              zone.isEmpty)
          ? '${MyConstant().domain_v1}/admin/requests/properties?per_page=5000'
          : '${MyConstant().domain_v1}/admin/requests/properties?per_page=1000&q=$zone';

      print('🔗 _loadProperties: $url');
      final res = await http.get(Uri.parse(url), headers: headers);
      print(
          '📥 _loadProperties status: ${res.statusCode} bodyLen: ${res.body.length}');

      if (res.statusCode != 200) {
        print('❌ _loadProperties status != 200: ${res.statusCode}');
        print(
            '   body: ${res.body.substring(0, res.body.length > 300 ? 300 : res.body.length)}');
        return <_PropertyModel>[];
      }

      final jsonRes = json.decode(res.body);
      print('🔍 _loadProperties json type: ${jsonRes.runtimeType}');
      if (jsonRes is! Map<String, dynamic>) {
        print('⚠️ _loadProperties json is not Map: $jsonRes');
        return <_PropertyModel>[];
      }
      final list = jsonRes['data'];
      print(
          '🔍 _loadProperties data type: ${list.runtimeType}, len: ${list is List ? list.length : 'N/A'}');
      if (list is! List) {
        print('️ _loadProperties data is not List');
        return <_PropertyModel>[];
      }

      final out = <_PropertyModel>[];
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          final m = _PropertyModel.fromJsonSafe(e);
          if (m != null) out.add(m);
        }
      }
      print('✅ _loadProperties parsed: ${out.length} items');
      return out;
    } catch (e, st) {
      print('❌ _loadProperties error: $e\n$st');
      return <_PropertyModel>[];
    }
  }

  // ===============================================================
  // HTTP #2 — โหลด areaAll (Dio + isolate parse)
  // ===============================================================
  Future<List<_AreaModel>> _loadAreaAll({
    required String? ren,
    String? zone,
  }) async {
    try {
      final url = Uri.parse(
        '${MyConstant().domain}/GC_areaAll.php'
        '?isAdd=true&ren=$ren&zone=${zone ?? '0'}&typecid=1',
      );
      print('🔗 _loadAreaAll: $url');
      final res = await _dio.getUri(url, cancelToken: _cancelToken);
      final raw = res.data;
      if (raw is! List) return <_AreaModel>[];
      return await compute(_parseAreasIsolate, raw);
    } catch (e) {
      print('❌ _loadAreaAll error: $e');
      return <_AreaModel>[];
    }
  }

  // ===============================================================
  // HTTP #3 — โหลด sub-zones (หมวดโซน)
  // ===============================================================
  Future<List<Map<String, dynamic>>> fetchSubZones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer') ?? prefs.getString('rser') ?? '';
      final url = '${MyConstant().domain}/GC_zone_sub.php?isAdd=true&ren=$ren';
      print('🔗 fetchSubZones: $url');
      final res = await http.get(Uri.parse(url));
      print(
          '📥 fetchSubZones status: ${res.statusCode} bodyLen: ${res.body.length}');
      if (res.statusCode != 200) {
        return <Map<String, dynamic>>[];
      }
      final data = json.decode(res.body);
      if (data is! List) return <Map<String, dynamic>>[];

      // เพิ่ม "ทั้งหมด" ไว้ตัวแรก
      final out = <Map<String, dynamic>>[
        {
          'ser': '0',
          'rser': '0',
          'zn': 'ทั้งหมด',
          'qty': '0',
          'img': '0',
          'data_update': '0',
        },
      ];
      for (final m in data) {
        if (m is Map) {
          out.add(Map<String, dynamic>.from(m));
        }
      }
      print('✅ fetchSubZones: ${out.length} items');
      return out;
    } catch (e) {
      print('❌ fetchSubZones error: $e');
      return <Map<String, dynamic>>[];
    }
  }

  // ===============================================================
  // HTTP #4 — โหลด zones (โซนพื้นที่)
  // ===============================================================
  Future<List<Map<String, dynamic>>> fetchZones({String? zoneSubSer}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer') ?? prefs.getString('rser') ?? '';
      final url = '${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren';
      print('🔗 fetchZones: $url');
      final res = await http.get(Uri.parse(url));
      print(
          '📥 fetchZones status: ${res.statusCode} bodyLen: ${res.body.length}');
      if (res.statusCode != 200) {
        return <Map<String, dynamic>>[];
      }
      final data = json.decode(res.body);
      if (data is! List) return <Map<String, dynamic>>[];

      // เพิ่ม "ทั้งหมด" ไว้ตัวแรก
      final out = <Map<String, dynamic>>[
        {
          'ser': '0',
          'rser': '0',
          'zn': 'ทั้งหมด',
          'qty': '0',
          'img': '0',
          'data_update': '0',
        },
      ];
      for (final m in data) {
        if (m is Map) {
          final z = Map<String, dynamic>.from(m);
          // ถ้ามี zoneSubSer ให้ filter
          if (zoneSubSer == null ||
              zoneSubSer == '0' ||
              z['sub_zone']?.toString() == zoneSubSer) {
            out.add(z);
          }
        }
      }
      print('✅ fetchZones: ${out.length} items');
      return out;
    } catch (e) {
      print('❌ fetchZones error: $e');
      return <Map<String, dynamic>>[];
    }
  }

  // ===============================================================
  // Map properties + area → Map<String, dynamic> (ของตัวเอง ไม่ใช้ ReviewModel)
  // ===============================================================
  Map<String, dynamic> _buildMap(_PropertyModel? p, _AreaModel area) {
    // ✅ ใช้ข้อมูลจาก area API เป็นหลัก (areaAll มีข้อมูลครบถ้วน)
    // properties API ใช้เป็น fallback เฉพาะกรณีที่ area ไม่มีค่า
    return {
      // ids
      'id': p?.id,
      'uuid': p?.uuid ?? area.ser,
      'clients_uuid': p?.clientUuid,
      'created_at': p?.createdAt,
      'submitted_at': p?.createdAt,

      // new_request fields
      'request_uuid': p?.requestUuid,
      'lease_number': area.ln ?? p?.ln,
      'cid': area.cid ?? p?.uuid, // ✅ เลขที่สัญญา (จาก API: cid)
      'property_id': p?.aser,
      'subzoneser': null,
      'subzone': p?.subzone, // raw sub-zone name (จาก properties API)
      'sub_zonename':
          p?.subzone ?? '', // ✅ alias สำหรับ column "บริเวณ" ในตาราง
      'zn': area.zn ?? p?.zn,
      'ln': area.ln ?? p?.ln,
      'ln_q': area.ln_q,
      'sdate': area.sdate ?? p?.sdate,
      'ldate': area.ldate ?? p?.ldate,
      'request_step': p?.requestStep,

      // business type / category
      'stype': area.stype, // ✅ ประเภทธุรกิจ (เช่น "เสื้อผ้าพื้นเมือง/กระเป๋า")

      // client
      'cname': area.cname ?? p?.clientName,
      'scname': area.sname ?? p?.clientName,
      'tel': null,

      // status — ใช้ 'st' จาก area API เป็นหลัก
      'st': area.st ?? p?.requestStatus, // ✅ สถานะ (เช่น "สัญญาปัจจุบัน")
      'status': p?.requestStatus,
      'status_label': p?.requestStep?.toString() ?? area.quantity,

      // badges
      'need_review': false,
      'needs_update': false,
      'has_new_attachment': false,
    };
  }

  // ===============================================================
  // Headers — สร้างเอง (ไม่ใช้ MyHeaders จากที่อื่น)
  // ===============================================================
  Future<Map<String, String>> _buildHeaders() async {
    // ✅ ใช้ MyToken.accessToken (เหมือน MyHeaders.build()) — ไม่ใช้ SharedPreferences
    final token = await MyToken.accessToken;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
