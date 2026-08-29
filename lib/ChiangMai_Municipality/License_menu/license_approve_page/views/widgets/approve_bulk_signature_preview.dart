// ============================================================================
// approve_bulk_signature_preview.dart
// ============================================================================
// Section สำหรับ Tab 2 ของหน้าอนุมัติ: แสดง "ชื่อผู้ลงนาม + ตำแหน่ง"
// ที่ดึงมาจาก /admin/know (admin signature meta API) ผ่าน own service
//
// - ใช้ LicenseLegacyApprovalService เดิม (own service) — ไม่ delegate unity/
// - เน้น minimal: ชื่อ + ตำแหน่ง (user จะเพิ่มเนื้อหาทีหลัง)
// - Self-contained state (initState ยิง load เอง, dispose ตัวเอง)
// ============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/license_legacy_approval_service.dart';
import '../theme/license_approve_theme.dart';

/// แสดงชื่อผู้ลงนาม + ตำแหน่งที่ดึงจาก admin signature API
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

    if (resp != null && resp.statusCode == 200) {
      try {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>?;
        if (data != null) {
          profileName = data['profile'] as String?;
          positionName = data['position_name'] as String?;
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
      _isLoading = false;
      _profileName = profileName;
      _positionName = positionName;
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
            const SizedBox(height: LaSpace.md),
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
