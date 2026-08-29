// ============================================================================
// approve_legacy_signature_section.dart
// ============================================================================
// Section แสดงลายเซ็นผู้อนุมัติ (read-only, โหมด V1)
// - โหลดข้อมูลลายเซ็นจาก API: GET /admin/know + GET .../signatures/{uuid}/preview
// - แสดงภาพลายเซ็น + ชื่อ/ตำแหน่ง admin
// - ไม่มี comment box, ไม่มี confirm button, ไม่มี submit action
//   (ตามที่ user ระบุ: "ลายเซนเอามาแสดงเลย ไม่ต้องมีการประทับอะไรทั้งนั้น")
// - Self-contained: state/UI ทั้งหมดอยู่ในไฟล์นี้
// - ห้าม import cignaturepad_cmm.dart / request_examiner*_cmm.dart
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../unity/API_admin_signature.dart';
import '../theme/license_approve_theme.dart';

/// Section widget สำหรับแสดงลายเซ็นผู้อนุมัติ (read-only)
/// วางใต้ `_RoundsSection` ในหน้า approve_detail_step1.dart
class ApproveLegacySignatureSection extends StatefulWidget {
  const ApproveLegacySignatureSection({super.key});

  @override
  State<ApproveLegacySignatureSection> createState() =>
      _ApproveLegacySignatureSectionState();
}

class _ApproveLegacySignatureSectionState
    extends State<ApproveLegacySignatureSection> {
  // ─── Loading state ───
  bool _isLoadingImage = false; // GET signatures/{uuid}/preview

  // ─── Error ───
  String? _loadError;

  // ─── Admin / signature data (จาก /admin/know) ───
  String? _profileUuid;
  String? _profileName;
  String? _positionName;

  // ─── Signature image bytes (จาก .../signatures/{uuid}/preview) ───
  Uint8List? _signatureBytes;

  // ─────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSignature());
  }

  Future<void> _loadSignature() async {
    setState(() {
      _loadError = null;
    });

    // 1) โหลด admin meta จาก /admin/know
    final metaResp = await read_AdminSignature();
    if (!mounted) return;

    String? profileUuid;
    String? profileName;
    String? signatureUuid;
    String? positionName;

    if (metaResp != null && metaResp.statusCode == 200) {
      try {
        final result = jsonDecode(metaResp.body) as Map<String, dynamic>;
        final data = result['data'] as Map<String, dynamic>?;
        if (data != null) {
          profileUuid = data['profile_uuid'] as String?;
          profileName = data['profile'] as String?;
          signatureUuid = data['signature_uuid'] as String?;
          positionName = data['position_name'] as String?;
        }
      } catch (_) {
        // ignore parse error — fall through to error state
      }
    }

    if (profileUuid == null && signatureUuid == null && profileName == null) {
      if (!mounted) return;
      setState(() {
        _loadError = 'ไม่สามารถโหลดข้อมูลผู้ลงนามได้';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _profileUuid = profileUuid;
      _profileName = profileName;
      _positionName = positionName;
    });

    // 2) โหลดภาพลายเซ็น (ถ้ามี signatureUuid)
    if (signatureUuid != null && signatureUuid.isNotEmpty) {
      setState(() => _isLoadingImage = true);
      final imgResp = await img_signatureUuid(signatureUuid: signatureUuid);
      if (!mounted) return;
      if (imgResp != null && imgResp.statusCode == 200) {
        setState(() {
          _signatureBytes = imgResp.bodyBytes;
          _isLoadingImage = false;
        });
      } else {
        setState(() => _isLoadingImage = false);
      }
    }
  }

  String _shortUuid(String? uuid) {
    if (uuid == null || uuid.isEmpty) return '-';
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 8)}…${uuid.substring(uuid.length - 4)}';
  }

  // ─────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: LaSpace.md),
          if (_loadError != null)
            _buildErrorBanner(_loadError!)
          else
            _buildBody(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.draw_rounded, size: 18, color: LaColors.primaryDark),
        const SizedBox(width: 8),
        const Expanded(
          child: Text('ลายเซ็นผู้อนุมัติ', style: LaText.h2),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: LaColors.statusInfoBg,
            borderRadius: BorderRadius.circular(LaRadius.pill),
            border: Border.all(
              color: LaColors.statusInfoFg.withOpacity(.18),
              width: 1,
            ),
          ),
          child: const Text(
            'V1',
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

  Widget _buildErrorBanner(String msg) {
    return Container(
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: BoxDecoration(
        color: LaColors.statusRejectedBg,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.statusRejectedFg.withOpacity(.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 16, color: LaColors.statusRejectedFg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
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

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 480;
        final signatureBox = _buildSignatureBox();
        final infoColumn = _buildInfoColumn();
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              signatureBox,
              const SizedBox(height: LaSpace.md),
              infoColumn,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            signatureBox,
            const SizedBox(width: LaSpace.lg),
            Expanded(child: infoColumn),
          ],
        );
      },
    );
  }

  Widget _buildSignatureBox() {
    return Container(
      width: 240,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border),
      ),
      alignment: Alignment.center,
      child: _isLoadingImage
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : _signatureBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(LaRadius.md - 1),
                  child: Image.memory(
                    _signatureBytes!,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.image_not_supported_rounded,
                        size: 28, color: LaColors.textMuted),
                    SizedBox(height: 4),
                    Text(
                      'ไม่สามารถโหลดลายเซ็นได้',
                      style: LaText.caption,
                    ),
                  ],
                ),
    );
  }

  Widget _buildInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(
          icon: Icons.person_rounded,
          label: 'ชื่อ-สกุล',
          value: _profileName ?? '-',
        ),
        const SizedBox(height: LaSpace.sm),
        _infoRow(
          icon: Icons.work_outline_rounded,
          label: 'ตำแหน่ง',
          value: _positionName ?? '-',
        ),
        const SizedBox(height: LaSpace.sm),
        _infoRow(
          icon: Icons.tag_rounded,
          label: 'Profile UUID',
          value: _shortUuid(_profileUuid),
          mono: true,
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    bool mono = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: LaColors.primaryDark),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: LaText.label),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: mono ? 'monospace' : LaText.fontRegular,
                  fontSize: mono ? 12 : 13,
                  fontWeight: mono ? FontWeight.w500 : FontWeight.w600,
                  color: LaColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
