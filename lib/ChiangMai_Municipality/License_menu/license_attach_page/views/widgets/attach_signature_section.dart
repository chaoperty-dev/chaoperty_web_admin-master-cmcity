// ============================================================================
// attach_signature_section.dart
// ============================================================================
// Section "ลายเซ็นผู้แนบ" — แสดงก่อนตารางแนบเอกสาร
//
// UI Flow:
//   - Header (แสดงเสมอ): icon + "ลายเซ็นผู้แนบ" + ปุ่ม "เซ็นลายเซ็น"
//   - Body (ซ่อนได้): แสดงเมื่อกดปุ่ม "เซ็นลายเซ็น" เท่านั้น
//       - Signature Pad
//       - ปุ่ม "ล้าง" / "อัปโหลดลายเซ็น"
//       - เมื่ออัปโหลดสำเร็จ → ปิด body อัตโนมัติ
//   - ถ้ามีลายเซ็นแนบแล้ว: header แสดง status pill "✅ มีลายเซ็นแนบแล้ว"
//
// ลอจิกจาก Make_contract_CMM (handleSave/uploadSignature_user)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../theme/license_attach_theme.dart';
import '../../viewmodels/attach_documents_view_model.dart';
import '../../viewmodels/attach_signature_view_model.dart';
import '../../viewmodels/license_attach_detail_view_model.dart';

class AttachSignatureSection extends StatefulWidget {
  /// UUID ของ request
  final String? requestUuid;

  const AttachSignatureSection({super.key, this.requestUuid});

  @override
  State<AttachSignatureSection> createState() => _AttachSignatureSectionState();
}

class _AttachSignatureSectionState extends State<AttachSignatureSection> {
  final GlobalKey<SfSignaturePadState> _signatureKey =
      GlobalKey<SfSignaturePadState>();

  AttachSignatureViewModel? _signatureVm;

  /// สถานะการแสดง Signature Pad (body ซ่อนได้)
  bool _isPadVisible = false;

  @override
  void dispose() {
    _signatureVm?.dispose();
    super.dispose();
  }

  /// สร้าง VM ใหม่ (dispose ตัวเก่าก่อนกัน listener leak)
  AttachSignatureViewModel _ensureVm(AttachDocumentsViewModel docsVm) {
    if (_signatureVm != null) {
      _signatureVm!.dispose();
    }
    return AttachSignatureViewModel(
      documentsProvider: () => docsVm.documents,
    );
  }

  void _showPad() {
    setState(() => _isPadVisible = true);
  }

  void _hidePad() {
    setState(() {
      _isPadVisible = false;
      // ล้าง pad ด้วย (กันลายเซ็นค้าง)
      _signatureKey.currentState?.clear();
    });
  }

  /// หลังอัปโหลดสำเร็จ → ปิด body
  void _onUploaded() {
    _hidePad();
  }

  @override
  Widget build(BuildContext context) {
    final docsVm = context.watch<AttachDocumentsViewModel>();
    final detailVm = context.watch<LicenseAttachDetailViewModel>();
    _signatureVm = _ensureVm(docsVm);

    // 🔒 ถ้าคำขอถูกล็อก → บังคับปิด pad (กัน state ค้าง)
    final locked = detailVm.isLocked;

    return _SectionContainer(
      signatureKey: _signatureKey,
      signatureVm: _signatureVm!,
      hasSignature: _signatureVm!.hasSignature,
      requestUuid: widget.requestUuid,
      isPadVisible: locked ? false : _isPadVisible,
      locked: locked,
      onShowPad: locked ? () {} : _showPad,
      onHidePad: _hidePad,
      onUploaded: _onUploaded,
    );
  }
}

class _SectionContainer extends StatelessWidget {
  final GlobalKey<SfSignaturePadState> signatureKey;
  final AttachSignatureViewModel signatureVm;
  final bool hasSignature;
  final String? requestUuid;
  final bool isPadVisible;
  final bool locked;
  final VoidCallback onShowPad;
  final VoidCallback onHidePad;
  final VoidCallback onUploaded;

  const _SectionContainer({
    required this.signatureKey,
    required this.signatureVm,
    required this.hasSignature,
    required this.requestUuid,
    required this.isPadVisible,
    required this.locked,
    required this.onShowPad,
    required this.onHidePad,
    required this.onUploaded,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    return Container(
      decoration: LaDecor.card(),
      // ไม่มี padding ที่ container หลัก — ให้ header/body จัดการเอง
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header (แสดงเสมอ) ───
          _SectionHeader(
            mobile: mobile,
            hasSignature: hasSignature,
            isPadVisible: isPadVisible,
            locked: locked,
            onShowPad: onShowPad,
            onHidePad: onHidePad,
          ),

          // ─── Body (ซ่อนได้ — แสดงเมื่อ isPadVisible) ───
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: isPadVisible
                ? _SectionBody(
                    signatureKey: signatureKey,
                    signatureVm: signatureVm,
                    hasSignature: hasSignature,
                    requestUuid: requestUuid,
                    mobile: mobile,
                    locked: locked,
                    onUploaded: onUploaded,
                    onCancel: onHidePad,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
}

class _SectionHeader extends StatelessWidget {
  final bool mobile;
  final bool hasSignature;
  final bool isPadVisible;
  final bool locked;
  final VoidCallback onShowPad;
  final VoidCallback onHidePad;

  const _SectionHeader({
    required this.mobile,
    required this.hasSignature,
    required this.isPadVisible,
    required this.locked,
    required this.onShowPad,
    required this.onHidePad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? LaSpace.sm : LaSpace.md,
        vertical: LaSpace.sm,
      ),
      decoration: BoxDecoration(
        color: LaColors.primaryLight.withOpacity(.25),
        borderRadius: BorderRadius.circular(LaRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.draw_rounded,
              size: mobile ? 16 : 18, color: LaColors.primaryDark),
          SizedBox(width: mobile ? 6 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ลายเซ็นผู้แนบ',
                  style: LaText.h2.copyWith(fontSize: mobile ? 14 : 16),
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasSignature) ...[
                  const SizedBox(height: 2),
                  _StatusPill(
                    icon: Icons.check_circle_rounded,
                    text: 'มีลายเซ็นแนบแล้ว',
                    bg: LaColors.statusApprovedBg,
                    fg: LaColors.statusApprovedFg,
                    compact: true,
                  ),
                ],
              ],
            ),
          ),

          // 🔒 ล็อก → ซ่อนปุ่มเซ็น/เซ็นใหม่ทั้งหมด
          if (locked)
            _StatusPill(
              icon: Icons.lock_outline_rounded,
              text: 'ล็อก',
              bg: LaColors.statusRejectedBg.withOpacity(.5),
              fg: LaColors.statusRejectedFg,
              compact: true,
            )
          // ─── ปุ่ม toggle (ซ่อน ถ้ามีลายเซ็นแล้วและ body ปิดอยู่) ───
          else if (hasSignature && !isPadVisible)
            _HeaderIconButton(
              icon: Icons.edit_rounded,
              tooltip: 'เซ็นใหม่',
              color: LaColors.primaryDark,
              onTap: onShowPad,
            )
          else if (isPadVisible)
            _HeaderIconButton(
              icon: Icons.expand_less_rounded,
              tooltip: 'ยุบ',
              color: LaColors.textSecondary,
              onTap: onHidePad,
            )
          else
            _SignNowButton(
              mobile: mobile,
              onTap: onShowPad,
            ),
        ],
      ),
    );
  }
}

class _SignNowButton extends StatelessWidget {
  final bool mobile;
  final VoidCallback onTap;
  const _SignNowButton({required this.mobile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LaColors.primary,
      borderRadius: BorderRadius.circular(LaRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LaRadius.md),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? LaSpace.sm : LaSpace.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LaRadius.md),
            border: Border.all(color: LaColors.primaryDark, width: 1),
            gradient: const LinearGradient(
              colors: [LaColors.primary, LaColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: LaColors.primary.withOpacity(.20),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.draw_rounded,
                  size: mobile ? 14 : 16, color: Colors.white),
              if (!mobile) ...[
                const SizedBox(width: 4),
                const Text(
                  'เซ็นลายเซ็น',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: LaText.fontBold,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, color: color, size: 20),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final GlobalKey<SfSignaturePadState> signatureKey;
  final AttachSignatureViewModel signatureVm;
  final bool hasSignature;
  final String? requestUuid;
  final bool mobile;
  final bool locked;
  final VoidCallback onUploaded;
  final VoidCallback onCancel;

  const _SectionBody({
    required this.signatureKey,
    required this.signatureVm,
    required this.hasSignature,
    required this.requestUuid,
    required this.mobile,
    required this.locked,
    required this.onUploaded,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        mobile ? LaSpace.sm : LaSpace.lg,
        mobile ? LaSpace.sm : LaSpace.md,
        mobile ? LaSpace.sm : LaSpace.lg,
        mobile ? LaSpace.sm : LaSpace.lg,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: LaColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Signature Pad ───
          _SignaturePadArea(signatureKey: signatureKey, mobile: mobile),
          SizedBox(height: mobile ? LaSpace.sm : LaSpace.md),

          // ─── Action buttons ───
          _SignatureActions(
            signatureVm: signatureVm,
            signatureKey: signatureKey,
            requestUuid: requestUuid,
            mobile: mobile,
            locked: locked,
            onUploaded: onUploaded,
            onCancel: onCancel,
          ),
        ],
      ),
    );
  }
}

class _SignaturePadArea extends StatelessWidget {
  final GlobalKey<SfSignaturePadState> signatureKey;
  final bool mobile;
  const _SignaturePadArea({
    required this.signatureKey,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: mobile ? 160 : 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(LaRadius.md),
        child: SfSignaturePad(
          key: signatureKey,
          backgroundColor: Colors.white,
          strokeColor: LaColors.textPrimary,
          minimumStrokeWidth: 1.0,
          maximumStrokeWidth: 3.0,
        ),
      ),
    );
  }
}

class _SignatureActions extends StatelessWidget {
  final AttachSignatureViewModel signatureVm;
  final GlobalKey<SfSignaturePadState> signatureKey;
  final String? requestUuid;
  final bool mobile;
  final bool locked;
  final VoidCallback onUploaded;
  final VoidCallback onCancel;

  const _SignatureActions({
    required this.signatureVm,
    required this.signatureKey,
    required this.requestUuid,
    required this.mobile,
    required this.locked,
    required this.onUploaded,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final docsVm = context.read<AttachDocumentsViewModel>();
    final canUpload = !signatureVm.isUploading &&
        !locked &&
        (requestUuid ?? '').isNotEmpty &&
        signatureVm.signatureDocId != 0;

    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.close_rounded,
            label: 'ยกเลิก',
            primary: false,
            onTap: (signatureVm.isUploading || locked) ? null : onCancel,
          ),
        ),
        SizedBox(width: LaSpace.sm),
        Expanded(
          child: _ActionButton(
            icon: Icons.clear_rounded,
            label: 'ล้าง',
            primary: false,
            onTap: (signatureVm.isUploading || locked)
                ? null
                : () => signatureKey.currentState?.clear(),
          ),
        ),
        SizedBox(width: LaSpace.sm),
        Expanded(
          flex: 2,
          child: _ActionButton(
            icon: Icons.cloud_upload_rounded,
            label: signatureVm.isUploading ? 'กำลังอัปโหลด…' : 'อัปโหลด',
            primary: true,
            loading: signatureVm.isUploading,
            onTap: canUpload ? () => _onUpload(context, docsVm) : null,
          ),
        ),
      ],
    );
  }

  Future<void> _onUpload(
      BuildContext context, AttachDocumentsViewModel docsVm) async {
    final ok = await signatureVm.upload(
      requestUuid: requestUuid ?? '',
      signatureKey: signatureKey,
      onUploaded: () {
        docsVm.refresh();
        onUploaded();
      },
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'อัปโหลดลายเซ็นสำเร็จ'
              : (signatureVm.errorMessage ?? 'อัปโหลดไม่สำเร็จ'),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
      ),
    );

    if (ok) {
      signatureKey.currentState?.clear();
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final bool loading;
  final VoidCallback? onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: Material(
        borderRadius: BorderRadius.circular(LaRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(LaRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: LaSpace.sm,
              vertical: LaSpace.sm + 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(LaRadius.md),
              color: primary ? null : LaColors.surfaceMuted,
              border: Border.all(
                color: primary ? LaColors.primaryDark : LaColors.border,
                width: 1,
              ),
              gradient: primary
                  ? const LinearGradient(
                      colors: [LaColors.primary, LaColors.primaryDark],
                    )
                  : null,
              boxShadow: primary
                  ? [
                      BoxShadow(
                        color: LaColors.primary.withOpacity(.20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(
                    icon,
                    size: 16,
                    color: primary ? Colors.white : LaColors.textSecondary,
                  ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: primary ? Colors.white : LaColors.textSecondary,
                      fontFamily: LaText.fontBold,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bg;
  final Color fg;
  final bool compact;
  const _StatusPill({
    required this.icon,
    required this.text,
    required this.bg,
    required this.fg,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : LaSpace.sm,
        vertical: compact ? 2 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(LaRadius.pill),
        border: Border.all(color: fg.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 10 : 12, color: fg),
          SizedBox(width: compact ? 3 : 4),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontFamily: LaText.fontBold,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
