// ============================================================================
// rental_general_service.dart
// ============================================================================
// Service สำหรับหน้า "ข้อมูลทั่วไป" — Port จาก SettingScreen.dart
//
// API endpoints (เหมือนของเดิม):
//   GET   {domain}/GC_rental_setring.php?isAdd=true&ren={ren}
//   GET   {domain}/GC_package.php?isAdd=true&ren={ren}
//   GET   {domain}/GC_areaCount.php?isAdd=true&ren={ren}
//   GET   {domain}/GC_zone.php?isAdd=true&ren={ren}
//   POST  {domain}/UpC_rentel_pn.php?isAdd=true&ren=..&value=..&ser_user=..
//   POST  {domain}/UpC_rentel_open_set_date.php?isAdd=true&ren=..&value=..
//   POST  {domain}/UpC_rentel_mass_on.php?isAdd=true&ren=..&value=..
//   POST  {domain}/File_upload_img_setting.php  (multipart)
//   POST  {domain}/Up_imgMap.php|Up_imglogo.php|Up_imgZone.php (refresh)
//   POST  {domain}/File_Deleted_imgMap.php|File_Deleted_logo.php|File_Deleted_Zone.php
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chaoperty/Constant/Myconstant.dart';
import '../models/rental_general_models.dart';

class RentalGeneralService {
  String _domain;
  RentalGeneralService({String? domain})
      : _domain = domain ?? MyConstant().domain;

  void setDomain(String domain) {
    _domain = domain;
    RentalGeneralModel.setBaseUrl(domain);
  }

  bool get hasDomain => _domain.isNotEmpty;

  Future<String?> _getRen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('renTalSer');
  }

  Future<String?> _getSer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ser');
  }

  // ════════════════════════════════════════════════════════════════════
  // READ — โหลดข้อมูลทั้งหมด
  // ════════════════════════════════════════════════════════════════════

  /// โหลด rental + package + area count พร้อมกัน และ merge
  Future<RentalGeneralEvent> fetchAll() async {
    if (!hasDomain) {
      return const ErrorRentalGeneral('ยังไม่ได้ตั้งค่า domain');
    }

    final results = await Future.wait([
      fetchRental(),
      fetchAreaCount(),
    ]);

    RentalGeneralModel merged = RentalGeneralModel.empty();
    String? firstError;

    for (final ev in results) {
      if (ev is LoadedRentalGeneral) {
        merged = _merge(merged, ev.data);
      } else if (ev is ErrorRentalGeneral) {
        firstError ??= ev.message;
      }
    }

    if (merged.ser != null) {
      // Set folder for zone image URLs
      if (merged.dbn != null) {
        ZoneImageModel.setFolder(merged.dbn!);
      }
      return LoadedRentalGeneral(merged);
    }
    return ErrorRentalGeneral(firstError ?? 'ไม่พบข้อมูล');
  }

  /// GET GC_rental_setring.php
  Future<RentalGeneralEvent> fetchRental() async {
    if (!hasDomain) {
      return const ErrorRentalGeneral('ยังไม่ได้ตั้งค่า domain');
    }
    final ren = await _getRen();
    final uri = Uri.parse(
      '$_domain/GC_rental_setring.php?isAdd=true&ren=$ren',
    );
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 30));
      if (resp.statusCode != 200) {
        return ErrorRentalGeneral('HTTP ${resp.statusCode}');
      }
      final decoded = json.decode(resp.body);
      if (decoded is! List || decoded.isEmpty) {
        return const ErrorRentalGeneral('ไม่พบข้อมูล rental');
      }
      final m = decoded.first as Map<String, dynamic>;
      return LoadedRentalGeneral(
        RentalGeneralModel(
          ser: m['ser']?.toString(),
          pn: (m['pn'] ?? '').toString().trim(),
          rtname: m['rtname']?.toString(),
          type: m['type']?.toString(),
          typex: m['typex']?.toString(),
          pk: (m['pk'] ?? '').toString().trim(),
          pkqty: int.tryParse((m['pkqty'] ?? '').toString()),
          pkuser: int.tryParse((m['pkuser'] ?? '').toString()),
          dbn: m['dbn']?.toString(),
          img: m['img']?.toString(),
          imglogo: m['imglogo']?.toString(),
          imglineqr: m['imglineqr']?.toString(),
          lineqr: m['lineqr']?.toString(),
          openSetDate: int.tryParse(m['open_set_date']?.toString() ?? '0') ?? 0,
          massOn: int.tryParse(m['mass_on']?.toString() ?? '0') ?? 0,
        ),
      );
    } catch (e) {
      return ErrorRentalGeneral('โหลด rental ไม่สำเร็จ: $e');
    }
  }

  /// GET GC_areaCount.php
  Future<RentalGeneralEvent> fetchAreaCount() async {
    if (!hasDomain) {
      return const ErrorRentalGeneral('ยังไม่ได้ตั้งค่า domain');
    }
    final ren = await _getRen();
    final uri = Uri.parse(
      '$_domain/GC_areaCount.php?isAdd=true&ren=$ren',
    );
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 30));
      if (resp.statusCode != 200) {
        return ErrorRentalGeneral('HTTP ${resp.statusCode}');
      }
      final decoded = json.decode(resp.body);
      if (decoded is! List || decoded.isEmpty) {
        return const ErrorRentalGeneral('ไม่พบ area count');
      }
      final m = decoded.first as Map<String, dynamic>;
      return LoadedRentalGeneral(
        RentalGeneralModel(
          countArea: int.tryParse(m['counta']?.toString() ?? '0') ?? 0,
        ),
      );
    } catch (e) {
      return ErrorRentalGeneral('โหลด area count ไม่สำเร็จ: $e');
    }
  }

  /// GET GC_zone.php — คืนรายการ zone (พร้อม logo + contract เป็น row แรก)
  Future<RentalGeneralEvent> fetchZones() async {
    if (!hasDomain) {
      return const ErrorRentalGeneral('ยังไม่ได้ตั้งค่า domain');
    }
    final ren = await _getRen();
    final uri = Uri.parse(
      '$_domain/GC_zone.php?isAdd=true&ren=$ren',
    );
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 30));
      if (resp.statusCode != 200) {
        return ErrorRentalGeneral('HTTP ${resp.statusCode}');
      }
      final decoded = json.decode(resp.body);
      if (decoded is! List) {
        return const ErrorRentalGeneral('รูปแบบข้อมูลไม่ถูกต้อง');
      }

      final zones = <ZoneImageModel>[];

      // row 0: โลโก้ (placeholder)
      zones.add(ZoneImageModel(
        ser: '-1',
        rser: '0',
        zn: 'โลโก้',
        qty: '0',
        img: '',
        dataUpdate: '',
      ));
      // row 1: แผนผัง (placeholder)
      zones.add(ZoneImageModel(
        ser: '0',
        rser: '0',
        zn: 'แผนผัง',
        qty: '0',
        img: '',
        dataUpdate: '',
      ));
      // rows จาก API
      for (final raw in decoded) {
        if (raw is Map<String, dynamic>) {
          zones.add(ZoneImageModel.fromJson(raw));
        }
      }

      // sort: โลโก้ → แผนผัง → อื่นๆ
      zones.sort((a, b) {
        if (a.zn == 'โลโก้') return -1;
        if (a.zn == 'แผนผัง') return b.zn == 'โลโก้' ? 1 : -1;
        if (b.zn == 'โลโก้' || b.zn == 'แผนผัง') return 1;
        return (a.zn ?? '').compareTo(b.zn ?? '');
      });

      return LoadedZoneImages(zones);
    } catch (e) {
      return ErrorRentalGeneral('โหลด zones ไม่สำเร็จ: $e');
    }
  }

  RentalGeneralModel _merge(RentalGeneralModel a, RentalGeneralModel b) {
    return RentalGeneralModel(
      ser: b.ser ?? a.ser,
      pn: b.pn ?? a.pn,
      rtname: b.rtname ?? a.rtname,
      type: b.type ?? a.type,
      typex: b.typex ?? a.typex,
      pk: b.pk ?? a.pk,
      pkqty: b.pkqty ?? a.pkqty,
      pkuser: b.pkuser ?? a.pkuser,
      dbn: b.dbn ?? a.dbn,
      img: b.img ?? a.img,
      imglogo: b.imglogo ?? a.imglogo,
      imglineqr: b.imglineqr ?? a.imglineqr,
      lineqr: b.lineqr ?? a.lineqr,
      openSetDate: b.openSetDate ?? a.openSetDate,
      massOn: b.massOn ?? a.massOn,
      countArea: b.countArea ?? a.countArea,
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // UPDATE — แก้ไขข้อมูล
  // ════════════════════════════════════════════════════════════════════

  /// POST UpC_rentel_pn.php — แก้ไข "ชื่อสถานที่"
  Future<bool> updateName(String value) async {
    final ren = await _getRen();
    final ser = await _getSer();
    final uri = Uri.parse(
      '$_domain/UpC_rentel_pn.php?isAdd=true&ren=$ren&value=$value&ser_user=$ser',
    );
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 30));
      return resp.body.trim() == 'true';
    } catch (_) {
      return false;
    }
  }

  /// POST UpC_rentel_open_set_date.php
  Future<bool> updateOpenSetDate(int days) async {
    final ren = await _getRen();
    final ser = await _getSer();
    final uri = Uri.parse(
      '$_domain/UpC_rentel_open_set_date.php?isAdd=true&ren=$ren&value=$days&ser_user=$ser',
    );
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 30));
      return resp.body.trim() == 'true';
    } catch (_) {
      return false;
    }
  }

  /// POST UpC_rentel_mass_on.php — toggle
  Future<bool> toggleMassOn(int newValue) async {
    final ren = await _getRen();
    final ser = await _getSer();
    final uri = Uri.parse(
      '$_domain/UpC_rentel_mass_on.php?isAdd=true&ren=$ren&value=$newValue&ser_user=$ser',
    );
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 30));
      return resp.body.trim() == 'true';
    } catch (_) {
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════════
  // IMAGE — upload / refresh / delete
  // ════════════════════════════════════════════════════════════════════

  /// Upload image (multipart POST)
  /// path: 'logo' | 'contract' | 'zone'
  Future<bool> uploadImage({
    required String path,
    required String fileName,
    required String extension,
    required String folder,
    required String base64Image,
  }) async {
    final uri = Uri.parse(
      '$_domain/File_upload_img_setting.php?name=$fileName&Foder=$folder&extension=$extension&Path=$path',
    );
    try {
      final resp = await http.post(uri, body: {
        'image': base64Image,
        'Foder': folder,
        'name': fileName,
        'ex': extension,
        'Path': path,
      });
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// POST หลัง upload เพื่อบันทึกชื่อรูปใน DB
  Future<bool> refreshImageRecord({
    required String path,
    required String fileName,
    required String? ser, // สำหรับ zone
  }) async {
    final ren = await _getRen();
    final String url;
    switch (path) {
      case 'logo':
        url =
            '$_domain/Up_imglogo.php?isAdd=true&ren=$ren&value=$fileName&ser_user=$ren';
        break;
      case 'contract':
        url =
            '$_domain/Up_imgMap.php?isAdd=true&ren=$ren&value=$fileName&ser_user=$ren';
        break;
      case 'zone':
        url =
            '$_domain/Up_imgZone.php?isAdd=true&ren=$ren&value=$fileName&ser=$ser';
        break;
      default:
        return false;
    }
    try {
      final resp = await http.get(Uri.parse(url));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Delete image (ใช้ web API ผ่าน POST endpoint)
  /// path: 'logo' | 'contract' | 'zone'
  Future<bool> deleteImage({
    required String path,
    required String? fileName,
    String? folder,
    String? ser, // สำหรับ zone
  }) async {
    final ren = await _getRen();
    final String url;
    switch (path) {
      case 'logo':
        url = '$_domain/File_Deleted_logo.php?Foder=$folder&name=$fileName';
        break;
      case 'contract':
        url = '$_domain/File_Deleted_imgMap.php?Foder=$folder&name=$fileName';
        break;
      case 'zone':
        url =
            '$_domain/File_Deleted_Zone.php?Foder=$folder&name=$fileName&ser=$ser';
        break;
      default:
        return false;
    }
    try {
      final resp = await http.get(Uri.parse(url));
      // ลบ record ใน DB
      final emptyValue = '';
      final clearUrl = path == 'logo'
          ? '$_domain/Up_imglogo.php?isAdd=true&ren=$ren&value=$emptyValue&ser_user=$ren'
          : path == 'contract'
              ? '$_domain/Up_imgMap.php?isAdd=true&ren=$ren&value=$emptyValue&ser_user=$ren'
              : '$_domain/Up_imgZone.php?isAdd=true&ren=$ren&value=$emptyValue&ser=$ser';
      await http.get(Uri.parse(clearUrl));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
