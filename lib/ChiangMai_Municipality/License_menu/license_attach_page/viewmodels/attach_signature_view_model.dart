// ============================================================================
// attach_signature_view_model.dart
// ============================================================================
// ViewModel — state สำหรับ section "ลายเซ็นผู้แนบ"
//
// เก็บ:
//   - ว่ามีลายเซ็นแนบแล้วหรือไม่ (hasSignature)
//   - สถานะกำลังอัปโหลด (isUploading)
//   - actions: upload / clear / refresh
//
// คัดลอก "ลอจิก" มาจาก Make_contract_CMM Step 2 (signature flow)
// ============================================================================

import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../../../Model/Document_Model.dart';
import '../services/attach_signature_service.dart';

class AttachSignatureViewModel extends ChangeNotifier {
  AttachSignatureViewModel({
    required this.documentsProvider,
    AttachSignatureService? service,
  }) : _service = service ?? AttachSignatureService();

  /// Callback ให้ AttachDocumentsViewModel ส่ง documents มาให้
  /// (ลายเซ็นใช้ document ที่ code = 'users_signature')
  final List<DocumentModel> Function() documentsProvider;

  final AttachSignatureService _service;

  bool _isUploading = false;
  String? _errorMessage;
  DocumentModel? _signatureDoc;

  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  /// ค้นหา document ที่เป็นลายเซ็น (code = 'users_signature')
  DocumentModel? get signatureDoc {
    if (_signatureDoc != null) return _signatureDoc;
    try {
      _signatureDoc =
          documentsProvider().firstWhere((d) => d.code == 'users_signature');
    } catch (_) {
      _signatureDoc = null;
    }
    return _signatureDoc;
  }

  /// มีลายเซ็นแนบอยู่หรือไม่
  bool get hasSignature {
    final doc = signatureDoc;
    if (doc == null) return false;
    return doc.attachments != null && doc.attachments!.isNotEmpty;
  }

  /// ID ของ document ลายเซ็น (ใช้กับ upload)
  int get signatureDocId {
    final doc = signatureDoc;
    if (doc == null) return 0;
    return doc.id is int ? doc.id as int : int.tryParse('${doc.id}') ?? 0;
  }

  /// อัปโหลดลายเซ็นจาก signature pad
  /// [requestUuid] = uuid ของ request
  /// [onUploaded] = callback หลังอัปโหลดสำเร็จ (ใช้ refresh documents)
  Future<bool> upload({
    required String requestUuid,
    required GlobalKey<SfSignaturePadState> signatureKey,
    required VoidCallback onUploaded,
  }) async {
    if (requestUuid.isEmpty) return false;
    final docId = signatureDocId;
    if (docId == 0) {
      _errorMessage = 'ไม่พบ document สำหรับลายเซ็น';
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final pngBytes = await _service.toPngBytes(signatureKey);
      if (pngBytes == null || pngBytes.isEmpty) {
        _errorMessage = 'กรุณาเซ็นลายเซ็นก่อนอัปโหลด';
        return false;
      }

      final result = await _service.uploadSignature(
        requestUuid: requestUuid,
        documentId: docId,
        pngBytes: pngBytes,
      );

      if (!result.ok) {
        _errorMessage = 'อัปโหลดลายเซ็นไม่สำเร็จ (HTTP ${result.statusCode})';
        return false;
      }

      _signatureDoc = null; // reset cache → re-fetch next access
      onUploaded();
      return true;
    } catch (_) {
      _errorMessage = 'เกิดข้อผิดพลาดระหว่างอัปโหลด';
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// ล้าง error message
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Refresh cache (เรียกหลัง documents เปลี่ยน)
  void refresh() {
    _signatureDoc = null;
    notifyListeners();
  }
}
