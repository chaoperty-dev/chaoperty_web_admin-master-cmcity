// ============================================================================
// approve_bulk_signature_preview.dart
// ============================================================================
// Section สำหรับ Tab 2 ของหน้าอนุมัติ: แสดง "ลายเซ็น + ชื่อผู้ลงนาม + ตำแหน่ง"
// ที่ดึงมาจาก /admin/know + /admin/users/signatures/{id}/preview
//
// - ใช้ LicenseLegacyApprovalService เดิม (own service) — ไม่ delegate unity/
// - โหลดลายเซ็นผ่าน img_signatureUuid (own helper call) — ไม่ delegate unity/
// - Self-contained state (initState ยิง load เอง, dispose ตัวเอง)
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../unity/API_admin_signature.dart';
import '../../services/license_legacy_approval_service.dart';
import '../theme/license_approve_theme.dart';

/// แสดงลายเซ็น + ชื่อผู้ลงนาม + ตำแหน่งที่ดึงจาก admin signature API
class ApproveBulkSignaturePreview extends StatefulWidget {
  const ApproveBulkSignaturePreview({super.key});

  @override
  State<ApproveBulkSignaturePreview> createState() =>
      _ApproveBulkSignaturePreviewState();
}

class _ApproveBulkSignaturePreviewState
    extends State<ApproveBulkSignaturePreview> {
  // ─── Service (own) ───
  final LicenseLegacyApprovalService _service = LicenseLegacyApprovalService();

  bool _isLoading = true;
  String? _error;

  String? _profileName;
  String? _positionName;
  String? _signatureUuid;
  Uint8List? _signatureBytes;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final resp = await _service.readAdminSignature();
    if (!mounted) return;

    String? profileName;
    String? positionName;
    String? signatureUuid;

    if (resp != null && resp.statusCode == 200) {
      try {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>?;
        if (data != null) {
          profileName = data['profile'] as String?;
          positionName = data['position_name'] as String?;
          signatureUuid = data['signature_uuid'] as String?;
        }
      } catch (_) {
        // ignore parse error
      }
    }

    if (profileName == null && positionName == null) {
      setState(() {
        _isLoading = false;
        _error = 'ไม่สามารถโหลดข้อมูลผู้ลงนามได้';
      });
      return;
    }

    setState(() {
      _profileName = profileName;
      _positionName = positionName;
      _signatureUuid = signatureUuid;
    });

    // โหลดรูปลายเซ็น (ไม่ block — โหลดเสร็จค่อยอัปเดต state)
    if (signatureUuid != null && signatureUuid.isNotEmpty) {
      _loadImage(signatureUuid);
    } else {
      // ไม่มี signatureUuid → ปิด loading ทันที
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadImage(String uuid) async {
    setState(() => _isLoadingImage = true);
    final imgResp = await img_signatureUuid(signatureUuid: uuid);
    if (!mounted) return;
    Uint8List? bytes;
    if (imgResp != null && imgResp.statusCode == 200) {
      bytes = imgResp.bodyBytes;
    }
    setState(() {
      _signatureBytes = bytes;
      _isLoadingImage = false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(LaSpace.lg),
        decoration: LaDecor.card(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: LaSpace.lg),
            if (_isLoading)
              _buildLoading()
            else if (_error != null)
              _buildError()
            else
              _buildInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LaColors.primary.withOpacity(.15),
            borderRadius: BorderRadius.circular(LaRadius.md),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: LaColors.primaryDark,
            size: 20,
          ),
        ),
        const SizedBox(width: LaSpace.sm),
        const Expanded(
          child: Text(
            'ผู้ลงนามอนุมัติ',
            style: LaText.h2,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: LaColors.statusInfoBg,
            borderRadius: BorderRadius.circular(LaRadius.pill),
            border: Border.all(color: LaColors.statusInfoFg.withOpacity(.18)),
          ),
          child: const Text(
            'TAB 2',
            style: TextStyle(
              fontFamily: LaText.fontBold,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: LaColors.statusInfoFg,
              letterSpacing: .5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: BoxDecoration(
        color: LaColors.statusRejectedBg,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.statusRejectedFg.withOpacity(.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: LaColors.statusRejectedFg,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                fontSize: 13,
                color: LaColors.statusRejectedFg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Signature image area ───
        _buildSignatureArea(),
        const SizedBox(height: LaSpace.lg),
        // ─── Meta tiles ───
        _infoTile(
          icon: Icons.badge_rounded,
          label: 'ชื่อ-สกุล',
          value: _profileName ?? '-',
        ),
        const SizedBox(height: LaSpace.sm),
        _infoTile(
          icon: Icons.work_outline_rounded,
          label: 'ตำแหน่ง',
          value: _positionName ?? '-',
        ),
      ],
    );
  }

  Widget _buildSignatureArea() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border),
      ),
      alignment: Alignment.center,
      child: _buildSignatureContent(),
    );
  }

  Widget _buildSignatureContent() {
    if (_isLoadingImage) {
      return const SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(strokeWidth: 2.2),
      );
    }
    if (_signatureBytes == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.draw_rounded,
            size: 28,
            color: LaColors.textSecondary.withOpacity(.55),
          ),
          const SizedBox(height: 6),
          Text(
            _signatureUuid == null || (_signatureUuid?.isEmpty ?? true)
                ? 'ไม่พบลายเซ็นของผู้ดูแล'
                : 'โหลดลายเซ็นไม่สำเร็จ',
            style: LaText.caption,
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.all(LaSpace.sm),
      child: Image.memory(
        _signatureBytes!,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: LaColors.primaryDark),
          const SizedBox(width: LaSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: LaText.label),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: LaText.bodyMuted.copyWith(
                    fontFamily: LaText.fontBold,
                    color: LaColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}