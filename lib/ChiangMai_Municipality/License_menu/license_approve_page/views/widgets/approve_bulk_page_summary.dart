// ============================================================================
// approve_bulk_page_summary.dart
// ============================================================================
// Tab 2 — Layout 2 ฝั่ง:
//   • ซ้าย: กล่องสรุป 1 กล่องต่อ 1 หน้าข้อมูล (ตาม lastPage ของ VM)
//   • ขวา: กล่องผู้อนุมัติ (signature + ชื่อ + ตำแหน่ง) — มีแค่ 1 อัน
//
// - โหลด admin signature ที่ parent (โหลดครั้งเดียว)
// - จำนวนกล่องซ้าย = lastPage จาก LicenseApproveViewModel
// - Responsive:
//     ≥ 960 : Row (grid ซ้าย + signature card ขวา)
//     <  960: Column (signature card บน, grid ล่าง)
// - ขนาดกล่องซ้ายปรับตาม grid width (1-4 คอลัมน์)
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../unity/API_admin_signature.dart';
import '../../services/license_legacy_approval_service.dart';
import '../../viewmodels/license_approve_view_model.dart';
import '../theme/license_approve_theme.dart';

class ApproveBulkPageSummary extends StatefulWidget {
  const ApproveBulkPageSummary({super.key});

  @override
  State<ApproveBulkPageSummary> createState() =>
      _ApproveBulkPageSummaryState();
}

class _ApproveBulkPageSummaryState extends State<ApproveBulkPageSummary> {
  // ─── Service (own) ───
  final LicenseLegacyApprovalService _service = LicenseLegacyApprovalService();

  bool _isLoading = true;
  String? _error;

  String? _profileName;
  String? _positionName;
  Uint8List? _signatureBytes;

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
      _isLoading = false;
    });

    if (signatureUuid != null && signatureUuid.isNotEmpty) {
      _loadImage(signatureUuid);
    }
  }

  Future<void> _loadImage(String uuid) async {
    final imgResp = await img_signatureUuid(signatureUuid: uuid);
    if (!mounted) return;
    Uint8List? bytes;
    if (imgResp != null && imgResp.statusCode == 200) {
      bytes = imgResp.bodyBytes;
    }
    setState(() => _signatureBytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final lastPage = context.select<LicenseApproveViewModel, int>(
      (vm) => vm.lastPage,
    );

    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth >= 960;
        if (isWide) {
          return _buildWideLayout(lastPage);
        }
        return _buildNarrowLayout(lastPage);
      },
    );
  }

  // ─── Wide (>=960): Row — grid ซ้าย, signature ขวา ─────────────────
  Widget _buildWideLayout(int lastPage) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _PageGridSection(
              lastPage: lastPage,
              isLoading: _isLoading,
            ),
          ),
          const SizedBox(width: LaSpace.lg),
          SizedBox(
            width: 300,
            child: _ApproverCard(
              isLoading: _isLoading,
              error: _error,
              profileName: _profileName,
              positionName: _positionName,
              signatureBytes: _signatureBytes,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Narrow (<960): Column — signature บน, grid ล่าง ─────────────
  Widget _buildNarrowLayout(int lastPage) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ApproverCard(
            isLoading: _isLoading,
            error: _error,
            profileName: _profileName,
            positionName: _positionName,
            signatureBytes: _signatureBytes,
          ),
          const SizedBox(height: LaSpace.lg),
          _PageGridSection(
            lastPage: lastPage,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// _PageGridSection — ฝั่งซ้าย: grid กล่อง 1 กล่องต่อ 1 หน้า
// ─────────────────────────────────────────────────────────────────────
class _PageGridSection extends StatelessWidget {
  final int lastPage;
  final bool isLoading;
  const _PageGridSection({required this.lastPage, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          icon: Icons.grid_view_rounded,
          title: 'สรุปการลงนามต่อหน้า',
          subtitle: lastPage > 0
              ? 'แสดงกล่องหน้าทั้งหมด ($lastPage หน้า)'
              : 'รอข้อมูลหน้าแรก',
          badgeText: 'TAB 2',
        ),
        const SizedBox(height: LaSpace.lg),
        _buildGrid(),
      ],
    );
  }

  Widget _buildGrid() {
    if (lastPage <= 0) {
      return _buildEmptyBlock();
    }
    return LayoutBuilder(
      builder: (context, c) {
        final cols = _colsFor(c.maxWidth);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: lastPage,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: LaSpace.md,
            mainAxisSpacing: LaSpace.md,
            childAspectRatio: _aspectFor(cols),
          ),
          itemBuilder: (context, index) {
            return _PageTile(
              pageNumber: index + 1,
              totalPages: lastPage,
            );
          },
        );
      },
    );
  }

  int _colsFor(double width) {
    if (width >= 720) return 3;
    if (width >= 480) return 2;
    return 1;
  }

  double _aspectFor(int cols) {
    switch (cols) {
      case 3:
        return 1.4;
      case 2:
        return 1.7;
      default:
        return 3.2;
    }
  }

  Widget _buildEmptyBlock() {
    return Container(
      padding: const EdgeInsets.all(LaSpace.lg),
      decoration: LaDecor.softCard(),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 36,
            color: LaColors.textSecondary.withOpacity(.55),
          ),
          const SizedBox(height: 8),
          const Text(
            'ยังไม่มีข้อมูลหน้าให้แสดง',
            style: LaText.bodyMuted,
          ),
          const SizedBox(height: 4),
          const Text(
            'ลองรอข้อมูลโหลด หรือตรวจสอบ filter',
            style: LaText.caption,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// _ApproverCard — ฝั่งขวา (wide) หรือ บน (narrow): signature + meta
// ─────────────────────────────────────────────────────────────────────
class _ApproverCard extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final String? profileName;
  final String? positionName;
  final Uint8List? signatureBytes;

  const _ApproverCard({
    required this.isLoading,
    required this.error,
    required this.profileName,
    required this.positionName,
    required this.signatureBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: LaDecor.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SectionHeader(
            icon: Icons.verified_user_rounded,
            title: 'ผู้ลงนามอนุมัติ',
            subtitle: 'ลายเซ็นที่ใช้กับทุกหน้า',
            badgeText: 'ผู้อนุมัติ',
          ),
          const SizedBox(height: LaSpace.md),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Container(
        height: 110,
        alignment: Alignment.center,
        decoration: LaDecor.softCard(),
        child: const SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      );
    }
    if (error != null) {
      return _buildErrorBlock(error!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSignatureArea(),
        const SizedBox(height: LaSpace.sm),
        _infoRow(Icons.badge_rounded, 'ชื่อ-สกุล', profileName ?? '-'),
        const SizedBox(height: 6),
        _infoRow(Icons.work_outline_rounded, 'ตำแหน่ง', positionName ?? '-'),
      ],
    );
  }

  Widget _buildSignatureArea() {
    return Container(
      height: 110,
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
    if (signatureBytes != null) {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Image.memory(
          signatureBytes!,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.draw_rounded,
          size: 26,
          color: LaColors.textSecondary.withOpacity(.55),
        ),
        const SizedBox(height: 4),
        const Text(
          'ไม่พบลายเซ็น',
          style: LaText.caption,
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border),
      ),
      child: Row(
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

  Widget _buildErrorBlock(String msg) {
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
}

// ─────────────────────────────────────────────────────────────────────
// _PageTile — 1 กล่องต่อ 1 หน้า (ฝั่งซ้าย)
// ─────────────────────────────────────────────────────────────────────
class _PageTile extends StatelessWidget {
  final int pageNumber;
  final int totalPages;

  const _PageTile({required this.pageNumber, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: LaDecor.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LaColors.primaryLight,
              borderRadius: BorderRadius.circular(LaRadius.md),
              border: Border.all(
                color: LaColors.primary.withOpacity(.25),
              ),
            ),
            child: Text(
              '$pageNumber',
              style: const TextStyle(
                fontFamily: LaText.fontBold,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: LaColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: LaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'หน้า $pageNumber',
                  style: LaText.tableHeader,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'จากทั้งหมด $totalPages หน้า',
                  style: LaText.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_box_outline_blank_rounded,
            size: 22,
            color: LaColors.textSecondary.withOpacity(.55),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// _SectionHeader — shared small header row
// ─────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeText;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LaColors.primary.withOpacity(.15),
            borderRadius: BorderRadius.circular(LaRadius.md),
          ),
          child: Icon(icon, color: LaColors.primaryDark, size: 20),
        ),
        const SizedBox(width: LaSpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: LaText.h2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: LaText.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: LaSpace.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: LaColors.statusInfoBg,
            borderRadius: BorderRadius.circular(LaRadius.pill),
            border: Border.all(color: LaColors.statusInfoFg.withOpacity(.18)),
          ),
          child: Text(
            badgeText,
            style: const TextStyle(
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
}