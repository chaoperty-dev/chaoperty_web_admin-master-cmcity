// ============================================================================
// license_attach_checklist_service.dart
// ============================================================================
// Service for /api/v1/admin/requests/{uuid}/checklist/preview
// ============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:chaoperty/Constant/Myconstant.dart';

import '../models/license_attach_checklist_model.dart';

class LicenseAttachChecklistService {
  static Future<LicenseAttachChecklistPreview> fetchByUuid(
      String? requestUuid) async {
    final uuid = requestUuid ?? 'a2c54e97-8c06-4dca-8007-9f6b34d9e93f';
    final headers = await MyHeaders.build();
    final url = Uri.parse(
        '${MyConstant().domain_v1}/admin/requests/$uuid/checklist/preview');
    final request = http.Request('GET', url)..headers.addAll(headers);

    try {
      final response = await request.send();
      if (response.statusCode != 200) {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
      final body = await response.stream.bytesToString();
      final jsonBody = json.decode(body) as Map<String, dynamic>;
      return LicenseAttachChecklistPreview.fromJson(
          jsonBody['data'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Checklist API error: $e');
      // Fallback mock data ถ้า API ล้มเหลว
      return _mockByUuid(uuid);
    }
  }

  static LicenseAttachChecklistPreview _mockByUuid(String requestUuid) {
    return LicenseAttachChecklistPreview(
      requestUuid: requestUuid,
      payload: const LicenseAttachChecklistPayload(
        requestNews: LicenseAttachChecklistRequestNews(
          zser: 10,
          zn: 'ท่าแพโซน 1',
          aser: 472,
          ln: 'ล็อค409',
        ),
        signer: LicenseAttachChecklistSigner(
          uuid: '1f780ada-1442-48c9-92b9-b1d16bcdffcd',
          name: 'นาย ผู้ตรวจสอบหลักฐาน1 ทดสอบ',
          position: 'ผู้ตรวจสอบหลักฐาน',
          signaturePath:
              'signatures/1f780ada-1442-48c9-92b9-b1d16bcdffcd/20260801/VU29WCx3B57fdYCFksxo2uHvKyWjkUaF2ayHUsR8.png',
          signedAt: null,
        ),
        attachments: [
          LicenseAttachChecklistAttachment(
            clientDocumentId: 8,
            code: 'payment_proof',
            nameTh: 'หลักฐานการชำระ',
            required: false,
            showAfterSubmit: 4,
            attachmentUuid: '4020c04f-a477-4f2e-ab66-07e2297bac88',
            fileName: 'attach_cRuV5N',
            fileType: '',
            fileSize: 280767,
          ),
          LicenseAttachChecklistAttachment(
            clientDocumentId: 1,
            code: 'photo',
            nameTh: 'รูปถ่าย',
            required: false,
            showAfterSubmit: 2,
            attachmentUuid: 'c39c6881-aa22-40e9-9d4b-03589f411c01',
            fileName: 'payment_qr (73).png',
            fileType: 'png',
            fileSize: 16484,
          ),
          LicenseAttachChecklistAttachment(
            clientDocumentId: 2,
            code: 'photo_with_shop_and_products',
            nameTh: 'รูปถ่ายคู่กับร้านค้าและสินค้า',
            required: false,
            showAfterSubmit: 2,
            attachmentUuid: 'f82bd2a4-1b41-4b6f-8768-baf0402c897e',
            fileName: 'messageImage_1785731540048.jpg',
            fileType: 'jpg',
            fileSize: 75325,
          ),
          LicenseAttachChecklistAttachment(
            clientDocumentId: 3,
            code: 'medical_certificate',
            nameTh: 'ใบรับรองแพทย์',
            required: false,
            showAfterSubmit: 0,
            attachmentUuid: '69b238e2-b2a7-4fc0-b280-4e31a0051b3b',
            fileName: 'messageImage_1785731540048.jpg',
            fileType: 'jpg',
            fileSize: 75325,
          ),
        ],
      ),
    );
  }
}
