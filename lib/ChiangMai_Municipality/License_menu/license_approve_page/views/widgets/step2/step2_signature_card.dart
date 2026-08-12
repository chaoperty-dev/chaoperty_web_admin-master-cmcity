// ============================================================================
// step2_signature_card.dart
// ============================================================================
// การ์ดแสดงลายเซ็น + โปรไฟล์ผู้อนุมัติ
// - โหลดตั้งแต่เปิดหน้า Step 2 (ผ่าน ViewModel)
// - แสดงรูปลายเซ็น, ชื่อ, ตำแหน่ง
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/license_approve_detail_step2_view_model.dart';
import '../../theme/license_approve_theme.dart';

/// การ์ดแสดงลายเซ็นผู้อนุมัติ (โหลดตั้งแต่เปิดหน้า)
class Step2SignatureCard extends StatelessWidget {
  const Step2SignatureCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseApproveDetailStep2ViewModel>();
    final sig = vm.approverSignature;

    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: LaColors.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  size: 18,
                  color: LaColors.primaryDark,
                ),
              ),
              const SizedBox(width: LaSpace.sm),
              const Text('ผู้อนุมัติ', style: LaText.h2),
            ],
          ),
          const SizedBox(height: LaSpace.md),
          if (sig == null)
            _loadingPlaceholder(context)
          else if (!sig.isReady)
            _warningPlaceholder(context)
          else
            _signatureBody(context, sig.profileName, sig.positionName,
                sig.signatureBytes!),
        ],
      ),
    );
  }

  Widget _loadingPlaceholder(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(LaColors.primary),
          ),
        ),
        const SizedBox(width: LaSpace.sm),
        Text('กำลังโหลดข้อมูลลายเซ็น...', style: LaText.bodyMuted),
      ],
    );
  }

  Widget _warningPlaceholder(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.warning_amber_rounded,
            size: 18, color: LaColors.statusRejectedFg),
        const SizedBox(width: LaSpace.sm),
        Expanded(
          child: Text(
            'ไม่พบข้อมูลลายเซ็นผู้อนุมัติ',
            style: LaText.bodyMuted.copyWith(color: LaColors.statusRejectedFg),
          ),
        ),
      ],
    );
  }

  Widget _signatureBody(
    BuildContext context,
    String name,
    String position,
    dynamic signatureBytes,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info column
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(Icons.person_rounded, 'ชื่อ-นามสกุล', name),
              const SizedBox(height: LaSpace.xs),
              _infoRow(Icons.work_outline_rounded, 'ตำแหน่ง', position),
            ],
          ),
        ),
        const SizedBox(width: LaSpace.md),
        // Signature image
        Expanded(
          flex: 2,
          child: Container(
            height: 80,
            decoration: LaDecor.softCard(),
            padding: const EdgeInsets.all(LaSpace.sm),
            alignment: Alignment.center,
            child: signatureBytes == null
                ? Icon(Icons.image_not_supported_rounded,
                    color: LaColors.textMuted, size: 32)
                : Image.memory(
                    signatureBytes,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.broken_image_rounded,
                      color: LaColors.textMuted,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: LaColors.textMuted),
        const SizedBox(width: 4),
        Text('$label: ', style: LaText.caption),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: LaText.body.copyWith(fontFamily: LaText.fontBold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
