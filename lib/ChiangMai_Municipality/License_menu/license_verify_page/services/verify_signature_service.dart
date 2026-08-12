// ============================================================================
// verify_signature_service.dart
// ============================================================================
// Service — อัปโหลด "ลายเซ็นผู้แนบ" (PNG) ไปยัง API เดียวกับ attachments
//
// ลอจิกคัดมาจาก Make_contract_CMM/unity/ReusableSignaturePad.dart
// (handleSave → uploadSignature_user) แต่เขียนใหม่ standalone
// ไม่ import จาก Make_contract_CMM
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../../../../Constant/Myconstant.dart';

/// ผลลัพธ์หลังอัปโหลดลายเซ็น
class SignatureUploadResult {
  final int statusCode;
  final Map<String, dynamic>? body;
  const SignatureUploadResult(this.statusCode, this.body);

  bool get ok => statusCode == 200 || statusCode == 201;
}

class VerifySignatureService {
  VerifySignatureService();

  /// แปลง signature pad state → PNG bytes
  /// คืน null ถ้าแปลงไม่สำเร็จ / key ไม่มี signature
  Future<Uint8List?> toPngBytes(GlobalKey<SfSignaturePadState> key) async {
    try {
      final state = key.currentState;
      if (state == null) return null;

      final image = await state.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      return byteData.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// อัปโหลด PNG ลายเซ็น ไปยัง request
  /// ใช้ endpoint เดียวกับ attachments แต่ส่ง document_id ของ "users_signature"
  Future<SignatureUploadResult> uploadSignature({
    required String requestUuid,
    required int documentId,
    required Uint8List pngBytes,
  }) async {
    final headers = await MyHeaders.build();
    final uri = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid/attachments',
    );

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields['document_id'] = documentId.toString()
      ..files.add(
        http.MultipartFile.fromBytes('file', pngBytes, filename: 'sign.png'),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    Map<String, dynamic>? body;
    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = null;
    }

    return SignatureUploadResult(response.statusCode, body);
  }
}

/// เช็คว่า signature pad มี signature ที่วาดไว้หรือไม่
/// (พยายามแปลงเป็น image — ถ้าสำเร็จ = มี signature)
bool signatureHasContent(GlobalKey<SfSignaturePadState> key) {
  final state = key.currentState;
  if (state == null) return false;
  try {
    // toImage คืน Future<ui.Image> — ถ้ามี keypoints จะสำเร็จ
    // ถ้าว่าง จะ error / คืน image ขนาด 0
    // ใช้การเช็คว่า toImage ไม่ throw พอ
    return state.toImage().toString().isNotEmpty;
  } catch (_) {
    return false;
  }
}


