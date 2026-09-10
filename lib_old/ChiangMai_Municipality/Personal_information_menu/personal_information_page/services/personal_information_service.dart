// ============================================================================
// personal_information_service.dart
// ============================================================================
// Service — โหลดข้อมูล admin profile + บันทึกลายเซ็น
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../unity/API_admin_signature.dart';
import '../../../unity/API_permission.dart';
import '../../../unity/Enum.dart';
import '../../../unity/ReusableSignaturePad.dart';
import '../../../unity/SecurePrefs_helper.dart';
import '../models/personal_information_models.dart';

class PersonalInformationService {
  /// โหลด profile + signature ของ admin ที่ login อยู่
  Future<AdminProfile> loadProfile() async {
    // 1. meta
    final response = await read_AdminSignature();
    if (response == null) {
      throw Exception('ไม่ได้รับการตอบกลับจากเซิร์ฟเวอร์');
    }

    final dynamic result = json.decode(response.body);
    final data = (result is Map<String, dynamic>) ? result['data'] : null;

    final profileUuid = data?['profile_uuid'] as String? ?? '';
    final profile = data?['profile'] as String? ?? '';
    final signatureUuid = data?['signature_uuid'] as String? ?? '';
    final positionName = data?['position_name'] as String? ?? '';

    // 2. secure user
    final userJson = await SecurePrefs.getDecrypted(
      SecurePrefsType.authUserObject,
    );
    final userUuid = await SecurePrefs.getDecrypted(
      SecurePrefsType.authUserUuid,
    );

    String email = '';
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      email = (userMap['email'] as String?) ?? '';
    }

    // 3. signature image
    Uint8List? sigBytes;
    if (signatureUuid.isNotEmpty) {
      final sigResp = await img_signatureUuid(signatureUuid: signatureUuid);
      if (sigResp != null && sigResp.statusCode == 200) {
        sigBytes = sigResp.bodyBytes;
      }
    }

    return AdminProfile(
      userUuid: userUuid ?? '',
      profileUuid: profileUuid,
      signatureUuid: signatureUuid,
      fullName: profile,
      positionName: positionName,
      email: email,
      signatureBytes: sigBytes,
    );
  }

  /// บันทึกลายเซ็นใหม่ของ admin (multipart upload)
  /// [signedData] = PNG bytes จาก signature pad
  /// คืน true = สำเร็จ
  Future<bool> saveSignature({
    required Uint8List signedData,
    required String userUuid,
  }) async {
    if (userUuid.isEmpty) {
      throw Exception('ไม่พบ UUID ของผู้ใช้');
    }

    final response = await Post_Signatures_Permission(
      fileData: signedData,
      userUuid: userUuid,
    );

    if (response == null) {
      throw Exception('ไม่ได้รับการตอบกลับ');
    }

    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// แปลงลายเซ็นจาก pad → PNG bytes (wrapper ให้ service level)
  Future<Uint8List?> exportSignatureBytes(
    SignatureActionType action,
    dynamic signatureKey,
  ) async {
    return await handleSave(
      '',
      0,
      signatureKey,
      action,
    ) as Uint8List?;
  }
}
