// ============================================================================
// approve_bulk_page_summary.dart
// ============================================================================
// Tab 2 — "อนุมัติรายการทั้งหมด" (NEW bulk flow, no legacy baggage)
//
// Layout:
//   • Header — title + select-all toggle + counter
//   • Grid การ์ด — 1 การ์ดต่อ 1 row จาก vm.requests (checkbox + row info)
//   • Footer — sticky action bar (counter + อนุมัติที่เลือก button)
//   • กล่องผู้อนุมัติ (signature + ชื่อ + ตำแหน่ง) — ขวา (wide) / บน (narrow)
//
// Submit: ใช้ LicenseLegacyApprovalService.bulkApproveStepsChunked
//         (POST {domain_v2}/admin/approvals/bulk/approve, ≤50/round)
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../unity/API_admin_signature.dart';
import '../../../Model/Review_Model.dart';
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

  // ─── Admin signature ───
  bool _isLoading = true;
  String? _error;

  String? _profileName;
  String? _positionName;
  Uint8List? _signatureBytes;

  // ─── Bulk selection + submit ───
  final Set<String> _selectedStepUuids = <String>{};
  bool _isSubmitting = false;

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

  // ─── Selection helpers ───
  void _toggleOne(String uuid) {
    setState(() {
      if (_selectedStepUuids.contains(uuid)) {
        _selectedStepUuids.remove(uuid);
      } else {
        _selectedStepUuids.add(uuid);
      }
    });
  }

  void _toggleSelectAll(List<ReviewModel> rows) {
    setState(() {
      final validUuids = rows
          .where((r) => r.uuid != null && r.uuid!.isNotEmpty)
          .map((r) => r.uuid!)
          .toList();
      final allSelected = validUuids.every(_selectedStepUuids.contains);
      if (allSelected) {
        for (final u in validUuids) {
          _selectedStepUuids.remove(u);
        }
      } else {
        _selectedStepUuids.addAll(validUuids);
      }
    });
  }

  Future<void> _onBulkApprove() async {
    if (_selectedStepUuids.isEmpty || _isSubmitting) return;

    final vm = context.read<LicenseApproveViewModel>();
    final selectedUuids = vm.requests
        .where(
          (r) => r.uuid != null && _selectedStepUuids.contains(r.uuid),
        )
        .map((r) => r.uuid!)
        .toList();
    if (selectedUuids.isEmpty) return;

    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final results = await _service.bulkApproveStepsChunked(
        stepUuids: selectedUuids,
      );
      if (!mounted) return;

      final allOk = results.every(
        (r) => r is Map ? r['error'] != true : true,
      );
      final okCount = results
          .where((r) => r is Map ? r['error'] != true : true)
          .length;
      final total = results.length;

      if (allOk) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'อนุมัติ ${selectedUuids.length} รายการสำเร็จ',
            ),
            backgroundColor: LaColors.statusApprovedFg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LaRadius.md),
            ),
          ),
        );
        setState(() => _selectedStepUuids.clear());
        await vm.refresh();
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'อนุมัติสำเร็จ $okCount / $total รอบ — บางส่วนล้มเหลว',
            ),
            backgroundColor: LaColors.statusRejectedFg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LaRadius.md),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('อนุมัติไม่สำเร็จ: $e'),
          backgroundColor: LaColors.statusRejectedFg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LaRadius.md),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseApproveViewModel>();
    final rows = vm.requests;
    final total = vm.total;
    final validRows = rows
        .where((r) => r.uuid != null && r.uuid!.isNotEmpty)
        .toList();
    final selectedInPage = validRows
        .where((r) => _selectedStepUuids.contains(r.uuid))
        .length;
    final allSelected =
        validRows.isNotEmpty &&
        validRows.every((r) => _selectedStepUuids.contains(r.uuid));

    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth >= 960;
        if (isWide) {
          return _buildWideLayout(
            vm: vm,
            rows: rows,
            total: total,
            validRows: validRows,
            selectedInPage: selectedInPage,
            allSelected: allSelected,
          );
        }
        return _buildNarrowLayout(
          vm: vm,
          rows: rows,
          total: total,
          validRows: validRows,
          selectedInPage: selectedInPage,
          allSelected: allSelected,
        );
      },
    );
  }

  // ─── Wide (≥ 960): Row — grid ซ้าย, signature ขวา ─────────────────
  Widget _buildWideLayout({
    required LicenseApproveViewModel vm,
    required List<ReviewModel> rows,
    required int total,
    required List<ReviewModel> validRows,
    required int selectedInPage,
    required bool allSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _buildMainArea(
              vm: vm,
              rows: rows,
              total: total,
              validRows: validRows,
              selectedInPage: selectedInPage,
              allSelected: allSelected,
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

  // ─── Narrow (< 960): Column — signature บน, main ล่าง ─────────────
  Widget _buildNarrowLayout({
    required LicenseApproveViewModel vm,
    required List<ReviewModel> rows,
    required int total,
    required List<ReviewModel> validRows,
    required int selectedInPage,
    required bool allSelected,
  }) {
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
          _buildMainArea(
            vm: vm,
            rows: rows,
            total: total,
            validRows: validRows,
            selectedInPage: selectedInPage,
            allSelected: allSelected,
          ),
        ],
      ),
    );
  }

  // ─── Main area: header + grid + footer ─────────────────────────────
  Widget _buildMainArea({
    required LicenseApproveViewModel vm,
    required List<ReviewModel> rows,
    required int total,
    required List<ReviewModel> validRows,
    required int selectedInPage,
    required bool allSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(
          total: total,
          selectedInPage: selectedInPage,
          allSelected: allSelected,
          validRows: validRows,
        ),
        const SizedBox(height: LaSpace.md),
        _buildGridOrEmpty(vm: vm, rows: rows, validRows: validRows),
        const SizedBox(height: LaSpace.md),
        _BulkActionFooter(
          selectedInPage: selectedInPage,
          totalInPage: validRows.length,
          isSubmitting: _isSubmitting,
          onApprove: _onBulkApprove,
        ),
      ],
    );
  }

  Widget _buildHeader({
    required int total,
    required int selectedInPage,
    required bool allSelected,
    required List<ReviewModel> validRows,
  }) {
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
          child: const Icon(
            Icons.done_all_rounded,
            color: LaColors.primaryDark,
            size: 20,
          ),
        ),
        const SizedBox(width: LaSpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('อนุมัติรายการทั้งหมด', style: LaText.h2),
              const SizedBox(height: 2),
              Text(
                'เลือกรายการแล้ว $selectedInPage จาก ${validRows.length} รายการในหน้านี้',
                style: LaText.caption,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: LaSpace.sm),
        _SelectAllChip(
          allSelected: allSelected,
          enabled: validRows.isNotEmpty,
          onTap: () => _toggleSelectAll(validRows),
        ),
      ],
    );
  }

  Widget _buildGridOrEmpty({
    required LicenseApproveViewModel vm,
    required List<ReviewModel> rows,
    required List<ReviewModel> validRows,
  }) {
    if (vm.isLoading && rows.isEmpty) {
      return _buildLoadingBlock();
    }
    if (rows.isEmpty) {
      return _buildEmptyBlock();
    }
    return LayoutBuilder(
      builder: (context, c) {
        final cols = _colsForGrid(c.maxWidth);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: validRows.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: LaSpace.sm,
            mainAxisSpacing: LaSpace.sm,
            childAspectRatio: _aspectForGrid(cols),
          ),
          itemBuilder: (context, i) {
            final r = validRows[i];
            final selected = _selectedStepUuids.contains(r.uuid);
            return _RequestCard(
              key: ValueKey(r.uuid ?? i),
              model: r,
              selected: selected,
              onToggle: () => _toggleOne(r.uuid!),
            );
          },
        );
      },
    );
  }

  int _colsForGrid(double width) {
    if (width >= 1100) return 3;
    if (width >= 720) return 2;
    return 1;
  }

  double _aspectForGrid(int cols) {
    switch (cols) {
      case 3:
        return 2.0;
      case 2:
        return 2.4;
      default:
        return 3.2;
    }
  }

  Widget _buildLoadingBlock() {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(LaColors.primary),
            ),
          ),
          SizedBox(height: 12),
          Text('กำลังโหลดข้อมูล...', style: LaText.bodyMuted),
        ],
      ),
    );
  }

  Widget _buildEmptyBlock() {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: LaColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 36,
              color: LaColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ไม่พบรายการที่ต้องอนุมัติ',
            style: LaText.h2,
          ),
          const SizedBox(height: 6),
          const Text(
            'ลองปรับตัวกรองหรือคำค้นหาใหม่อีกครั้ง',
            style: LaText.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// _SelectAllChip — toggle เลือกทั้งหมด (chip style)
// ─────────────────────────────────────────────────────────────────────
class _SelectAllChip extends StatelessWidget {
  final bool allSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _SelectAllChip({
    required this.allSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = !enabled
        ? LaColors.surfaceMuted
        : allSelected
            ? LaColors.primaryDark
            : LaColors.primaryLight;
    final fg = !enabled
        ? LaColors.textMuted
        : allSelected
            ? Colors.white
            : LaColors.primaryDark;
    final iconData = allSelected
        ? Icons.check_box_rounded
        : Icons.check_box_outline_blank_rounded;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(LaRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(LaRadius.pill),
            border: Border.all(
              color: !enabled
                  ? LaColors.border
                  : allSelected
                      ? LaColors.primaryDark
                      : LaColors.primary.withOpacity(.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconData, size: 14, color: fg),
              const SizedBox(width: 4),
              Text(
                allSelected ? 'ยกเลิกทั้งหมด' : 'เลือกทั้งหมด',
                style: TextStyle(
                  fontFamily: LaText.fontBold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// _BulkActionFooter — sticky bottom action bar
// ─────────────────────────────────────────────────────────────────────
class _BulkActionFooter extends StatelessWidget {
  final int selectedInPage;
  final int totalInPage;
  final bool isSubmitting;
  final VoidCallback onApprove;

  const _BulkActionFooter({
    required this.selectedInPage,
    required this.totalInPage,
    required this.isSubmitting,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final canApprove = selectedInPage > 0 && !isSubmitting;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LaSpace.md,
        vertical: LaSpace.sm,
      ),
      decoration: LaDecor.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'เลือก $selectedInPage / $totalInPage รายการ',
                  style: LaText.tableHeader,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'สูงสุด 50 รายการต่อรอบ',
                  style: LaText.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: LaSpace.sm),
          FilledButton.icon(
            onPressed: canApprove ? onApprove : null,
            icon: isSubmitting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_circle_rounded, size: 18),
            label: Text(
              isSubmitting
                  ? 'กำลังอนุมัติ...'
                  : 'อนุมัติที่เลือก ($selectedInPage)',
              style: const TextStyle(
                fontFamily: LaText.fontBold,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: LaColors.primaryDark,
              foregroundColor: Colors.white,
              disabledBackgroundColor: LaColors.surfaceMuted,
              disabledForegroundColor: LaColors.textMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LaRadius.md),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// _RequestCard — per-row card (checkbox + info)
// ─────────────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final ReviewModel model;
  final bool selected;
  final VoidCallback onToggle;

  const _RequestCard({
    super.key,
    required this.model,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final name = (model.client?.scname?.isNotEmpty == true)
        ? model.client!.scname
        : (model.client?.cname ?? '-');
    final subzone = model.newRequest?.subzone ?? '-';
    final ln = model.newRequest?.ln ?? '-';
    final uuidShort = (model.uuid ?? '-').length > 8
        ? (model.uuid!).substring(0, 8)
        : (model.uuid ?? '-');
    final status = LicenseApproveViewModel.statusLabel(model.status ?? '');

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(LaRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(LaSpace.md),
          decoration: BoxDecoration(
            color: selected
                ? LaColors.primary.withOpacity(.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(LaRadius.lg),
            border: Border.all(
              color: selected
                  ? LaColors.primaryDark
                  : LaColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                selected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 22,
                color: selected
                    ? LaColors.primaryDark
                    : LaColors.textSecondary,
              ),
              const SizedBox(width: LaSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: LaText.tableHeader.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$subzone • $ln',
                      style: LaText.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: LaColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(LaRadius.sm),
                          ),
                          child: Text(
                            uuidShort,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontFamilyFallback: [LaText.fontRegular],
                              fontSize: 10,
                              color: LaColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: StatusPalette.of(status).bg,
                              borderRadius:
                                  BorderRadius.circular(LaRadius.pill),
                            ),
                            child: Text(
                              status.isEmpty ? '-' : status,
                              style: TextStyle(
                                fontFamily: LaText.fontBold,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: StatusPalette.of(status).fg,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// _ApproverCard — signature + name + position (right side / top)
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
          _buildHeader(),
          const SizedBox(height: LaSpace.sm),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LaColors.primary.withOpacity(.15),
            borderRadius: BorderRadius.circular(LaRadius.md),
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            color: LaColors.primaryDark,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text('ผู้ลงนามอนุมัติ', style: LaText.h2),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: LaColors.statusInfoBg,
            borderRadius: BorderRadius.circular(LaRadius.pill),
            border: Border.all(color: LaColors.statusInfoFg.withOpacity(.18)),
          ),
          child: const Text(
            'ผู้อนุมัติ',
            style: TextStyle(
              fontFamily: LaText.fontBold,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: LaColors.statusInfoFg,
              letterSpacing: .5,
            ),
          ),
        ),
      ],
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
        const Text('ไม่พบลายเซ็น', style: LaText.caption),
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