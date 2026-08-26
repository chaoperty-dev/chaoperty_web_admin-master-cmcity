// ============================================================================
// cancel_request_button.dart
// ============================================================================
// Widget ของตัวเอง — ปุ่ม + Dialog ยกเลิกคำขอ
//
// แยกจาก RequestDetailFooter (ไม่ดึงของ footer/shared มาใช้)
// - ปุ่ม destructive style (แดง) พร้อม loading spinner
// - มี confirm dialog ของตัวเอง
// - ยิง API ผ่าน LicenseRequestDetailService (ของตัวเองเฉพาะ page นี้)
// - คืน Navigator.pop(true) เมื่อสำเร็จ (ให้ list refresh)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/license_request_detail_view_model.dart';

/// ปุ่ม "ยกเลิกคำขอ" — ใช้ในหน้า request detail step 1
class CancelRequestButton extends StatelessWidget {
  /// UUID ของคำขอที่จะยกเลิก
  final String requestUuid;

  /// label ปุ่ม (กำหนดเองได้ — default: "ยกเลิกคำขอ")
  final String label;

  /// ไอคอนปุ่ม (default: cancel icon)
  final IconData icon;

  /// โหมด compact (icon-only) — ใช้ใน header เพื่อไม่ให้บีบ title
  final bool compact;

  /// โหมด dark (ปรับสำหรับพื้นเข้ม) — ค่าเริ่มต้น false (พื้นอ่อน)
  final bool darkMode;

  const CancelRequestButton({
    super.key,
    required this.requestUuid,
    this.label = 'ยกเลิกคำขอ',
    this.icon = Icons.cancel_outlined,
    this.compact = false,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ อ่าน VM ของตัวเอง — loading state มาจากตรงนี้
    final vm = context.watch<LicenseRequestDetailViewModel>();
    return _CancelRequestButtonInner(
      label: label,
      icon: icon,
      isLoading: vm.isCancelling,
      compact: compact,
      darkMode: darkMode,
      onTap: vm.isCancelling ? null : () => _handleCancelTap(context),
    );
  }

  Future<void> _handleCancelTap(BuildContext context) async {
    if (requestUuid.trim().isEmpty) return;
    final vm = context.read<LicenseRequestDetailViewModel>();
    // ✅ capture ก่อน await — เลี่ยง use_build_context_synchronously
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await _showConfirmDialog(context);
    if (confirmed != true) return;

    // ใช้ service ของตัวเองผ่าน VM (เลี่ยงสร้าง service instance ใหม่ใน UI)
    final ok = await vm.cancelRequest(uuid: requestUuid);
    if (ok) {
      // ✅ pop กลับ list page — list page จะแสดง SnackBar เอง
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(vm.cancelError ?? 'ยกเลิกคำขอไม่สำเร็จ'),
          backgroundColor: const Color(0xFFD32F2F),
        ),
      );
    }
  }

  Future<bool?> _showConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        // ✅ padding กว้างขึ้น — ป้องกัน Thai text wrap แคบเกินไป
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Color(0xFFD32F2F), size: 22),
            SizedBox(width: 10),
            Flexible(
              child: Text('ยืนยันยกเลิกคำขอ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        // ✅ แยกเป็น 2 paragraph — ลดโอกาส Thai text ตกบรรทัดเป็นตัวๆ
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'เมื่อยกเลิกแล้ว',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
                height: 1.4,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'จะไม่สามารถกลับมาแก้ไขหรือดำเนินการต่อได้',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'ต้องการยกเลิกคำขอนี้หรือไม่?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'ไม่ยกเลิก',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'ยืนยันยกเลิก',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Internal — pure UI (stateful เฉพาะ hover) ───
class _CancelRequestButtonInner extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final bool compact;
  final bool darkMode;
  final VoidCallback? onTap;

  const _CancelRequestButtonInner({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onTap,
    this.compact = false,
    this.darkMode = false,
  });

  @override
  State<_CancelRequestButtonInner> createState() =>
      _CancelRequestButtonInnerState();
}

class _CancelRequestButtonInnerState extends State<_CancelRequestButtonInner> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null || widget.isLoading;
    // ✅ เลือก color theme ตาม darkMode
    final baseColor = widget.darkMode
        ? const Color(0xFFFCA5A5) // red-300 สำหรับพื้นเข้ม
        : const Color(0xFFB91C1C); // red-700 สำหรับพื้นอ่อน
    final hoverBg =
        widget.darkMode ? const Color(0xFFB91C1C) : const Color(0xFFB91C1C);
    final defaultBg =
        widget.darkMode ? Colors.white.withOpacity(.12) : Colors.transparent;
    final borderColor = widget.darkMode
        ? Colors.white.withOpacity(.25)
        : const Color(0xFFB91C1C);
    final hoverBorder = widget.darkMode
        ? Colors.white.withOpacity(.40)
        : const Color(0xFFB91C1C);

    final iconColor = _hover ? Colors.white : baseColor;
    final spinnerColor = _hover ? Colors.white : baseColor;
    final textColor = _hover ? Colors.white : baseColor;

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          // ✅ compact = icon-only (square)
          padding: widget.compact
              ? const EdgeInsets.all(7)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: disabled
                ? (widget.darkMode
                    ? Colors.white.withOpacity(.10)
                    : const Color(0xFFF1F5F9))
                : _hover
                    ? hoverBg
                    : defaultBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hover ? hoverBorder : borderColor,
              width: 1,
            ),
          ),
          child: widget.compact
              // ── Compact: icon only ──
              ? Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(spinnerColor),
                          ),
                        )
                      : Icon(widget.icon, size: 16, color: iconColor),
                )
              // ── Normal: icon + label ──
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(spinnerColor),
                        ),
                      )
                    else
                      Icon(widget.icon, size: 14, color: iconColor),
                    const SizedBox(width: 6),
                    Text(
                      widget.isLoading ? 'กำลังยกเลิก...' : widget.label,
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'NotoSansThai',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
