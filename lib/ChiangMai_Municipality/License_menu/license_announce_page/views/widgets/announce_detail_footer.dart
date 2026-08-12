// ============================================================================
// announce_detail_footer.dart
// ============================================================================
// Footer bar — ปุ่ม "ลบ" + "แก้ไข"
// (โครงสร้างเลียนแบบ RequestDetailFooter แต่ปรับให้เหมาะกับ announce)
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/license_announce_theme.dart';

class AnnounceDetailFooter extends StatelessWidget {
  /// สถานะกำลังลบ (โชว์ spinner + disable ปุ่ม)
  final bool isDeleting;

  /// กำลัง save (โชว์ spinner + disable ปุ่ม)
  final bool isSaving;

  /// callback ตอนกดปุ่ม "ลบประกาศ" (ซ้าย)
  final VoidCallback? onDelete;

  /// callback ตอนกดปุ่ม "แก้ไขประกาศ" (ขวา, primary)
  final VoidCallback? onEdit;

  /// ข้อความอธิบายทางซ้าย
  final String statusText;

  /// icon ทางซ้าย
  final IconData statusIcon;

  const AnnounceDetailFooter({
    super.key,
    this.isDeleting = false,
    this.isSaving = false,
    this.onDelete,
    this.onEdit,
    this.statusText = 'โหมดดูอย่างเดียว',
    this.statusIcon = Icons.visibility_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LrSpace.lg, vertical: LrSpace.md),
      decoration: const BoxDecoration(
        color: LrColors.surfaceMuted,
        border: Border(top: BorderSide(color: LrColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 14, color: LrColors.textMuted),
          const SizedBox(width: 6),
          Text(statusText, style: LrText.caption),
          const Spacer(),
          // ─── ปุ่มลบ (danger, outline) ───
          _DeleteButton(
            isLoading: isDeleting,
            onTap: (isDeleting || isSaving) ? null : onDelete,
          ),
          const SizedBox(width: LrSpace.sm),
          // ─── ปุ่มแก้ไข (primary, gradient) ───
          _EditButton(
            isLoading: isSaving,
            onTap: (isDeleting || isSaving) ? null : onEdit,
          ),
        ],
      ),
    );
  }
}

class _DeleteButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  const _DeleteButton({this.onTap, this.isLoading = false});

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return MouseRegion(
      cursor:
          disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) {
        if (!disabled) setState(() => _hover = true);
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? LrColors.statusRejectedBg : Colors.white,
            borderRadius: BorderRadius.circular(LrRadius.md),
            border: Border.all(
              color: _hover ? LrColors.statusRejectedFg : LrColors.borderStrong,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      _hover
                          ? LrColors.statusRejectedFg
                          : LrColors.textSecondary,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: _hover
                      ? LrColors.statusRejectedFg
                      : LrColors.textSecondary,
                ),
              const SizedBox(width: 6),
              Text(
                'ลบประกาศ',
                style: TextStyle(
                  color: _hover
                      ? LrColors.statusRejectedFg
                      : LrColors.textSecondary,
                  fontFamily: LrText.fontBold,
                  fontSize: 13,
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

class _EditButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  const _EditButton({this.onTap, this.isLoading = false});

  @override
  State<_EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<_EditButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return MouseRegion(
      cursor:
          disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) {
        if (!disabled) setState(() => _hover = true);
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hover
                  ? [LrColors.primaryDark, LrColors.primary]
                  : [LrColors.primary, LrColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(LrRadius.md),
            boxShadow: [
              BoxShadow(
                color: LrColors.primary.withOpacity(_hover ? .35 : .25),
                blurRadius: _hover ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              else
                const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              const Text(
                'แก้ไขประกาศ',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: LrText.fontBold,
                  fontSize: 13,
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
