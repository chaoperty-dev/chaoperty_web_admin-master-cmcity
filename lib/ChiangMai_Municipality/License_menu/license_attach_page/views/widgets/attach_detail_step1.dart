// ============================================================================
// attach_detail_step1.dart
// ============================================================================
// Step 1 — เลือกเอกสารที่จะแนบ
//
// UI frame (SingleChildScrollView > Center > ConstrainedBox > Column > section
// header + section card + info row) คงรูปแบบเดิมทั้งหมด
// ภายใน "section card" ใช้ตารางแสดงรายการเอกสาร + ปุ่มอัปโหลด/ลบ
// (ลอจิกคัดมาจาก Make_contract_CMM Step 2 แต่เขียนใหม่ทั้งหมด standalone)
// ============================================================================

import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:chaoperty/ChiangMai_Municipality/PDF_CMM/unity_pdf_cmm/perviewpdf_ordit_cmm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/attach_documents_view_model.dart';
import '../../viewmodels/license_attach_detail_view_model.dart';
import '../theme/license_attach_theme.dart';
import '../../services/attach_documents_service.dart';

import '../../utils/attachment_utils.dart';
import '../../models/license_attach_document.dart';
import 'attach_signature_section.dart';
import 'attach_batch_upload_sheet.dart';
import 'attach_file_preview_dialog.dart';

class AttachDetailStep1 extends StatelessWidget {
  /// UUID ของ request ที่ต้องการแนบเอกสาร
  final String? requestUuid;

  const AttachDetailStep1({super.key, this.requestUuid});

  @override
  Widget build(BuildContext context) {
    return _Step1Body(requestUuid: requestUuid);
  }
}

/// Breakpoint: < 600px = โทรศัพท์
const double kAttachMobileBreakpoint = 600;

bool _isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < kAttachMobileBreakpoint;

// =============================================================================
// Body หลัก — ห่อ Provider<AttachDocumentsViewModel>
// =============================================================================
class _Step1Body extends StatelessWidget {
  final String? requestUuid;
  const _Step1Body({required this.requestUuid});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AttachDocumentsViewModel>(
      create: (_) => AttachDocumentsViewModel(requestUuid: requestUuid)..load(),
      child: _Step1Scaffold(requestUuid: requestUuid),
    );
  }
}

class _Step1Scaffold extends StatelessWidget {
  final String? requestUuid;
  const _Step1Scaffold({required this.requestUuid});

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    // ดึงจาก detail VM (ที่ parent provide ไว้) เพื่อเช็คว่ามี checklist ที่บันทึกแล้วหรือไม่
    final detailVm = context.watch<LicenseAttachDetailViewModel>();
    final savedChecklist = detailVm.checklist;
    final hasSaved = savedChecklist?.isSaved ?? false;

    return SingleChildScrollView(
      padding: EdgeInsets.all(mobile ? LaSpace.sm : LaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Section: เลือกเอกสาร (เดิม) ───
              const _SectionHeader(),
              const SizedBox(height: LaSpace.md),
              // ─── Banner แจ้งเตือนว่าเคยมีการบันทึกแบบฟอร์มไปแล้ว ───
              if (hasSaved) ...[
                _SavedChecklistNotice(preview: savedChecklist!),
                const SizedBox(height: LaSpace.md),
              ],
              // ─── Section: ลายเซ็นผู้แนบ (ใหม่ — ก่อนตารางเอกสาร) ───
              AttachSignatureSection(requestUuid: requestUuid),
              const SizedBox(height: LaSpace.md),
              // ─── Section: ตารางแนบเอกสาร (เดิม) ───
              const _DocumentsCard(),
              const SizedBox(height: LaSpace.lg),
              const _FooterHint(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner แจ้งเตือนใน step 1 ว่ามีประวัติการบันทึก checklist ไปแล้ว
class _SavedChecklistNotice extends StatelessWidget {
  final dynamic preview; // LicenseAttachChecklistPreview (หลีกเลี่ยง circular import)
  const _SavedChecklistNotice({required this.preview});

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    final checklistNo = preview.checklistNo?.toString() ?? '-';
    final version = preview.version;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? LaSpace.sm : LaSpace.md,
        vertical: LaSpace.sm,
      ),
      decoration: BoxDecoration(
        color: LaColors.statusInfoFg.withOpacity(.08),
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(
          color: LaColors.statusInfoFg.withOpacity(.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_rounded,
              size: 18, color: LaColors.statusInfoFg),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'มีประวัติการบันทึกแบบฟอร์มตรวจสอบเอกสารแล้ว',
                  style: LaText.body.copyWith(
                      fontFamily: LaText.fontBold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  version != null
                      ? 'เลขที่ $checklistNo  ·  เวอร์ชัน $version  ·  '
                          'การเปลี่ยนแปลงเอกสารจะมีผลกับเวอร์ชันถัดไป'
                      : 'เลขที่ $checklistNo  ·  การเปลี่ยนแปลงเอกสารจะมีผลกับเวอร์ชันถัดไป',
                  style: LaText.caption
                      .copyWith(color: LaColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Section Header (เหมือนเดิม 1:1)
// =============================================================================
class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
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
          Icon(Icons.upload_file_rounded,
              size: mobile ? 16 : 18, color: LaColors.primaryDark),
          SizedBox(width: mobile ? 6 : 8),
          Expanded(
            child: Text(
              'เลือกเอกสารที่จะแนบ',
              style: LaText.h2.copyWith(fontSize: mobile ? 14 : 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Documents Card — เนื้อหาหลักของ Step 1
// =============================================================================
class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard();

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    return Container(
      decoration: LaDecor.card(),
      padding: EdgeInsets.all(mobile ? LaSpace.sm : LaSpace.lg),
      child: Consumer<AttachDocumentsViewModel>(
        builder: (context, vm, _) {
          if (!vm.hasRequest) {
            return const _MissingRequestState();
          }
          if (vm.isLoading && vm.documents.isEmpty) {
            return const _LoadingState();
          }
          if (vm.documents.isEmpty) {
            return const _EmptyState();
          }
          return _DocumentsTable(documents: vm.documents);
        },
      ),
    );
  }
}

// =============================================================================
// Table — รายการเอกสาร (ใช้ LaColors token ตามธีมของหน้า)
// =============================================================================
class _DocumentsTable extends StatelessWidget {
  final List<LicenseAttachDocument> documents;
  const _DocumentsTable({required this.documents});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AttachDocumentsViewModel>();
    final mobile = _isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header bar: title + actions
        _TableHeaderBar(documents: documents),
        const SizedBox(height: LaSpace.sm),

        // เลือก layout ตามมุมมองที่ user เลือก
        if (vm.isGridView) ...[
          const Divider(height: 1, color: LaColors.border),
          _DocumentsGrid(documents: documents),
        ] else if (mobile) ...[
          const Divider(height: 1, color: LaColors.border),
          // Card layout บน mobile — ไม่ต้อง horizontal scroll
          for (int i = 0; i < documents.length; i++) ...[
            _DocumentCard(index: i, doc: documents[i]),
            if (i < documents.length - 1)
              const Divider(height: 1, color: LaColors.border),
          ],
        ] else ...[
          // Desktop + List view: ตารางแถวเดียว
          const Divider(height: 1, color: LaColors.border),
          for (int i = 0; i < documents.length; i++) ...[
            _DocumentRow(index: i, doc: documents[i]),
            if (i < documents.length - 1)
              const Divider(height: 1, color: LaColors.border),
          ],
        ],
      ],
    );
  }
}

class _TableHeaderBar extends StatelessWidget {
  final List<LicenseAttachDocument> documents;
  const _TableHeaderBar({required this.documents});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AttachDocumentsViewModel>();
    final detailVm = context.watch<LicenseAttachDetailViewModel>();
    final locked = detailVm.isLocked;
    final hasAny = documents.isNotEmpty;
    final mobile = _isMobile(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LaSpace.sm),
      child: Row(
        children: [
          Icon(Icons.folder_open_rounded,
              size: mobile ? 16 : 18, color: LaColors.primaryDark),
          SizedBox(width: mobile ? 4 : 6),
          Expanded(
            child: Text(
              'เอกสารที่ต้องแนบ (${documents.length} รายการ)',
              style: LaText.h2.copyWith(fontSize: mobile ? 13 : 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Toggle: List / Grid view
          _ViewModeToggle(
            isGrid: vm.isGridView,
            onTap: vm.toggleViewMode,
          ),
          IconButton(
            tooltip: 'รีเฟรช',
            visualDensity:
                mobile ? VisualDensity.compact : VisualDensity.standard,
            onPressed: vm.isLoading ? null : vm.refresh,
            icon: const Icon(Icons.refresh_rounded, color: LaColors.primary),
          ),
          SizedBox(width: mobile ? 0 : 4),
          // ปุ่มเพิ่มหลายรายการ (drag-drop batch upload)
          // บน mobile ซ่อน label เหลือแค่ icon
          _SoftActionButton(
            icon: Icons.library_add_rounded,
            label: 'เพิ่มหลายรายการ',
            showLabel: !mobile,
            onTap: hasAny && !vm.isUploading && !locked
                ? () => _openBatchSheet(context, vm)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _openBatchSheet(
      BuildContext context, AttachDocumentsViewModel vm) async {
    // ใช้ requestUuid จาก VM ผ่าน context (vm เก็บไว้แล้วตอน create)
    final requestUuid = vm.requestUuid;
    if ((requestUuid ?? '').isEmpty) return;

    final result = await showAttachBatchUploadSheet(
      context: context,
      documents: vm.documents,
      requestUuid: requestUuid!,
    );

    if (!context.mounted) return;

    if (result != null && result.isNotEmpty) {
      // refresh เพื่อดึง attachments ใหม่
      await vm.refresh();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('อัปโหลดสำเร็จ ${result.length} รายการ'),
          backgroundColor: LaColors.statusApprovedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _SoftActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool showLabel;
  final VoidCallback? onTap;
  const _SoftActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: Material(
        color: LaColors.primaryLight,
        borderRadius: BorderRadius.circular(LaRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(LaRadius.md),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: showLabel ? LaSpace.md : LaSpace.sm,
              vertical: 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: LaColors.primaryDark),
                if (showLabel) ...[
                  const SizedBox(width: 6),
                  Text(label,
                      style:
                          LaText.label.copyWith(color: LaColors.primaryDark)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Row — เอกสาร 1 รายการ
// =============================================================================
class _DocumentRow extends StatelessWidget {
  final int index;
  final LicenseAttachDocument doc;
  const _DocumentRow({required this.index, required this.doc});

  bool get _hasFile => doc.attachments != null && doc.attachments!.isNotEmpty;

  int get _docId =>
      doc.id is int ? doc.id as int : int.tryParse('${doc.id}') ?? 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AttachDocumentsViewModel>();
    final detailVm = context.watch<LicenseAttachDetailViewModel>();
    final locked = detailVm.isLocked;
    const fields = kAttachDocDisplayFields;
    final mobile = _isMobile(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LaSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── คอลัมน์ตาม data_title_doc ───
          for (final titleDoc in fields)
            Expanded(
              flex: titleDoc['title'] == 'ชื่อเอกสาร' ? 3 : 1,
              child: _buildCell(context, vm, titleDoc),
            ),

          // ─── ปุ่มอัปโหลด / ลบ (คอลัมน์ Action) ───
          SizedBox(
            width: mobile ? 72 : 96,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: locked
                      ? 'คำขอนี้ถูกล็อก — ไม่สามารถอัปโหลดได้'
                      : (_hasFile ? 'อัปโหลดใหม่' : 'อัปโหลดเอกสาร'),
                  visualDensity:
                      mobile ? VisualDensity.compact : VisualDensity.standard,
                  padding: EdgeInsets.zero,
                  constraints: mobile
                      ? const BoxConstraints(minWidth: 36, minHeight: 36)
                      : null,
                  onPressed: (vm.isUploading || locked)
                      ? null
                      : () => _onUpload(context, vm),
                  icon: Icon(
                    Icons.upload_file_rounded,
                    size: mobile ? 20 : 24,
                    color: (vm.isUploading || locked)
                        ? LaColors.textMuted
                        : (_hasFile ? LaColors.statusInfoFg : LaColors.primary),
                  ),
                ),
                if (_hasFile)
                  IconButton(
                    tooltip: locked
                        ? 'คำขอนี้ถูกล็อก — ไม่สามารถลบได้'
                        : 'ลบไฟล์แนบ',
                    visualDensity:
                        mobile ? VisualDensity.compact : VisualDensity.standard,
                    padding: EdgeInsets.zero,
                    constraints: mobile
                        ? const BoxConstraints(minWidth: 36, minHeight: 36)
                        : null,
                    onPressed: (vm.isLoading || locked)
                        ? null
                        : () => _onDelete(context, vm),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: (vm.isLoading || locked)
                          ? LaColors.textMuted
                          : LaColors.statusRejectedFg,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cell builder (ตาม data_title_doc)
  // ---------------------------------------------------------------------------
  Widget _buildCell(
    BuildContext context,
    AttachDocumentsViewModel vm,
    Map<String, String> titleDoc,
  ) {
    final isName = titleDoc['title'] == 'ชื่อเอกสาร';
    final isFile = titleDoc['title'] == 'ไฟล์เอกสาร';
    final isStatus = titleDoc['title'] == 'สถานะ';

    if (isFile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _FileButton(doc: doc, enabled: _hasFile),
      );
    }

    if (isStatus) {
      final label = _statusLabel(doc);
      final palette = _statusPalette(doc);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: LaSpace.sm, vertical: 4),
          decoration: LaDecor.pill(palette.bg, palette.fg),
          child: AutoSizeText(
            label,
            minFontSize: 11,
            maxFontSize: 13,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.fg,
              fontFamily: LaText.fontBold,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      );
    }

    final rawText = _displayText(titleDoc['ser'] ?? '');
    final displayText = isName ? '${index + 1}. $rawText' : rawText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AutoSizeText(
        displayText,
        minFontSize: 11,
        maxFontSize: 13,
        maxLines: 1,
        textAlign: isName ? TextAlign.left : TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: LaText.tableCell,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Display text helpers
  // ---------------------------------------------------------------------------
  String _displayText(String ser) {
    if (ser == '1') {
      // ชื่อเอกสาร — ใช้ nameTh จาก doc
      return (doc.nameTh ?? '').toString();
    }
    if (!_hasFile) return '-';
    final att = doc.attachments!.first;
    switch (ser) {
      case '2': // วันที่ทำรายการ
        return _fmtDate(att.uploadedAt);
      case '4': // สถานะ
        return _statusLabel(doc);
      case '5': // วันที่ตรวจสอบ
        return _fmtDate(att.reviewAt);
      default:
        return '-';
    }
  }

  String _fmtDate(dynamic v) {
    if (v == null) return '-';
    final s = v.toString();
    if (s.isEmpty || s == 'null') return '-';
    try {
      final dt = DateTime.parse(s);
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      return '$dd-$mm-${dt.year}';
    } catch (_) {
      return '-';
    }
  }

  String _statusLabel(LicenseAttachDocument doc) {
    if (!_hasFile) return 'ยังไม่แนบ';
    final s = doc.attachments!.first.status_label?.toString().trim() ?? '';
    if (s.isEmpty || s == 'null') return 'รอตรวจสอบ';
    return s;
  }

  StatusPalette _statusPalette(LicenseAttachDocument doc) {
    final raw =
        (_hasFile ? doc.attachments!.first.status : null)?.toString() ?? '';
    final label = _statusLabel(doc);
    if (raw.contains('อนุมัติ') ||
        label.contains('อนุมัติ') ||
        label.contains('ผ่าน') ||
        label.contains('เสร็จ')) {
      return const StatusPalette(
          LaColors.statusApprovedBg, LaColors.statusApprovedFg);
    }
    if (raw.contains('ปฏิเสธ') ||
        label.contains('ปฏิเสธ') ||
        label.contains('ขอปรับปรุง') ||
        label.contains('ไม่ผ่าน')) {
      return const StatusPalette(
          LaColors.statusRejectedBg, LaColors.statusRejectedFg);
    }
    return const StatusPalette(
        LaColors.statusPendingBg, LaColors.statusPendingFg);
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------
  Future<void> _onUpload(
      BuildContext context, AttachDocumentsViewModel vm) async {
    final service = AttachDocumentsService();
    PickedFile? picked;
    try {
      picked = await service.pickFromDevice();
    } catch (_) {
      picked = null;
    }
    if (picked == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ยกเลิกการเลือกไฟล์'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final ok = await vm.uploadFor(documentId: _docId, picked: picked);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'อัปโหลดสำเร็จ' : 'อัปโหลดไม่สำเร็จ'),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
      ),
    );
  }

  Future<void> _onDelete(
      BuildContext context, AttachDocumentsViewModel vm) async {
    if (!_hasFile) return;
    final att = doc.attachments!.first;
    final uuid = att.uuid?.toString() ?? '';
    if (uuid.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LaRadius.lg),
        ),
        title: const Text('ยืนยันการลบไฟล์'),
        content: Text('ลบไฟล์ "${att.fileName ?? att.filePath ?? '-'}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ',
                style: TextStyle(color: LaColors.statusRejectedFg)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final ok = await vm.deleteAttachment(
      documentId: _docId,
      attachmentUuid: uuid,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'ลบไฟล์สำเร็จ' : 'ลบไฟล์ไม่สำเร็จ'),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
      ),
    );
  }
}

// =============================================================================
// DocumentCard — layout สำหรับ mobile (stack แนวตั้ง)
// =============================================================================
class _DocumentCard extends StatelessWidget {
  final int index;
  final LicenseAttachDocument doc;
  const _DocumentCard({required this.index, required this.doc});

  bool get _hasFile => doc.attachments != null && doc.attachments!.isNotEmpty;

  int get _docId =>
      doc.id is int ? doc.id as int : int.tryParse('${doc.id}') ?? 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AttachDocumentsViewModel>();
    final detailVm = context.watch<LicenseAttachDetailViewModel>();
    final locked = detailVm.isLocked;
    final palette = _statusPalette(doc);
    final statusLabel = _statusLabel(doc);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: LaSpace.xs),
      padding: const EdgeInsets.all(LaSpace.sm),
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted.withOpacity(.5),
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: LaColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Row 1: ลำดับ + ชื่อเอกสาร ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LaColors.primaryLight,
                  borderRadius: BorderRadius.circular(LaRadius.pill),
                ),
                child: Text(
                  '${index + 1}',
                  style: LaText.label.copyWith(
                    color: LaColors.primaryDark,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: LaSpace.sm),
              Expanded(
                child: Text(
                  (doc.nameTh ?? '-').toString(),
                  style: LaText.tableCell.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: LaSpace.xs),

          // ─── Row 2: Status pill ───
          Row(
            children: [
              const Icon(Icons.flag_outlined,
                  size: 12, color: LaColors.textSecondary),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: LaSpace.sm, vertical: 2),
                decoration: LaDecor.pill(palette.bg, palette.fg),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: palette.fg,
                    fontFamily: LaText.fontBold,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              const Spacer(),
              if (_hasFile)
                Text(
                  'อัปโหลด: ${_fmtDateShort(doc.attachments!.first.uploadedAt)}',
                  style: LaText.caption.copyWith(fontSize: 10),
                ),
            ],
          ),
          const SizedBox(height: LaSpace.sm),

          // ─── Row 3: ปุ่ม actions ───
          Row(
            children: [
              // เรียกดูไฟล์ (เต็มพื้นที่ที่เหลือ)
              Expanded(
                child: _FileButton(doc: doc, enabled: _hasFile),
              ),
              const SizedBox(width: LaSpace.xs),
              // ปุ่มอัปโหลด
              IconButton(
                tooltip: locked
                    ? 'คำขอนี้ถูกล็อก — ไม่สามารถอัปโหลดได้'
                    : (_hasFile ? 'อัปโหลดใหม่' : 'อัปโหลดเอกสาร'),
                visualDensity: VisualDensity.compact,
                onPressed: (vm.isUploading || locked)
                    ? null
                    : () => _onUpload(context, vm),
                icon: Icon(
                  Icons.upload_file_rounded,
                  color: (vm.isUploading || locked)
                      ? LaColors.textMuted
                      : (_hasFile ? LaColors.statusInfoFg : LaColors.primary),
                ),
              ),
              if (_hasFile)
                IconButton(
                  tooltip: locked
                      ? 'คำขอนี้ถูกล็อก — ไม่สามารถลบได้'
                      : 'ลบไฟล์แนบ',
                  visualDensity: VisualDensity.compact,
                  onPressed: (vm.isLoading || locked)
                      ? null
                      : () => _onDelete(context, vm),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: (vm.isLoading || locked)
                        ? LaColors.textMuted
                        : LaColors.statusRejectedFg,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // -------- shared helpers (ซ้ำกับ row เพื่อไม่ผูกกัน) --------
  StatusPalette _statusPalette(LicenseAttachDocument doc) {
    final raw =
        (_hasFile ? doc.attachments!.first.status : null)?.toString() ?? '';
    final label = _statusLabel(doc);
    if (raw.contains('อนุมัติ') ||
        label.contains('อนุมัติ') ||
        label.contains('ผ่าน') ||
        label.contains('เสร็จ')) {
      return const StatusPalette(
          LaColors.statusApprovedBg, LaColors.statusApprovedFg);
    }
    if (raw.contains('ปฏิเสธ') ||
        label.contains('ปฏิเสธ') ||
        label.contains('ขอปรับปรุง') ||
        label.contains('ไม่ผ่าน')) {
      return const StatusPalette(
          LaColors.statusRejectedBg, LaColors.statusRejectedFg);
    }
    return const StatusPalette(
        LaColors.statusPendingBg, LaColors.statusPendingFg);
  }

  String _statusLabel(LicenseAttachDocument doc) {
    if (!_hasFile) return 'ยังไม่แนบ';
    final s = doc.attachments!.first.status_label?.toString().trim() ?? '';
    if (s.isEmpty || s == 'null') return 'รอตรวจสอบ';
    return s;
  }

  String _fmtDateShort(dynamic v) {
    if (v == null) return '-';
    final s = v.toString();
    if (s.isEmpty || s == 'null') return '-';
    try {
      final dt = DateTime.parse(s);
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      return '$dd/$mm/${dt.year % 100}';
    } catch (_) {
      return '-';
    }
  }

  // -------- shared actions (อ้างอิง VM/Service เดียวกับ _DocumentRow) --------

  Future<void> _onUpload(
      BuildContext context, AttachDocumentsViewModel vm) async {
    final service = AttachDocumentsService();
    PickedFile? picked;
    try {
      picked = await service.pickFromDevice();
    } catch (_) {
      picked = null;
    }
    if (picked == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ยกเลิกการเลือกไฟล์'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    final ok = await vm.uploadFor(documentId: _docId, picked: picked);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'อัปโหลดสำเร็จ' : 'อัปโหลดไม่สำเร็จ'),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
      ),
    );
  }

  Future<void> _onDelete(
      BuildContext context, AttachDocumentsViewModel vm) async {
    if (!_hasFile) return;
    final att = doc.attachments!.first;
    final uuid = att.uuid?.toString() ?? '';
    if (uuid.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LaRadius.lg),
        ),
        title: const Text('ยืนยันการลบไฟล์'),
        content: Text('ลบไฟล์ "${att.fileName ?? att.filePath ?? '-'}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ',
                style: TextStyle(color: LaColors.statusRejectedFg)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final ok = await vm.deleteAttachment(
      documentId: _docId,
      attachmentUuid: uuid,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'ลบไฟล์สำเร็จ' : 'ลบไฟล์ไม่สำเร็จ'),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
      ),
    );
  }
}

// =============================================================================
// ปุ่ม "เรียกดูไฟล์" (เปิด preview)
// =============================================================================
class _FileButton extends StatelessWidget {
  final LicenseAttachDocument doc;
  final bool enabled;
  const _FileButton({required this.doc, required this.enabled});

  /// เปิด preview ไฟล์แนบ (PDF / รูป) — popup gallery รองรับ Next/Prev
  void _openPreview(BuildContext context) {
    if (!enabled) return;

    // หา attachment ที่ตรงกับ docId ของ row นี้
    final docId =
        doc.id is int ? doc.id as int : int.tryParse('${doc.id}') ?? 0;
    final matched = findAttachmentByDocId(
      doc.attachments ?? <LicenseAttachAttachment>[],
      docId,
    );
    final att = matched ?? doc.attachments!.first;

    // รวบรวม attachments ทั้งหมดจากทุก docs ใน VM เพื่อให้ Next/Prev ทำงาน
    final vm = context.read<AttachDocumentsViewModel>();
    final allAttachments = <LicenseAttachAttachment>[];
    final allTitles = <String?>[];
    for (final d in vm.documents) {
      if (d.attachments != null) {
        for (final a in d.attachments!) {
          allAttachments.add(a);
          // ใช้ doc.nameTh เป็น title สำหรับแต่ละ attachment
          allTitles.add(d.nameTh?.toString());
        }
      }
    }

    // หา index ของ attachment ปัจจุบัน
    final initialIndex = allAttachments
        .indexWhere((a) => a.uuid == att.uuid && a.filePath == att.filePath);

    if (allAttachments.length <= 1) {
      // ถ้ามีแค่ 1 ไฟล์ → ใช้ .show() ปกติ
      AttachFilePreviewDialog.show(
        context,
        attachment: att,
        title: doc.nameTh ?? 'ไฟล์แนบ',
      );
    } else {
      // ถ้ามีหลายไฟล์ → ใช้ .showGallery() รองรับ Next/Prev + ส่ง titles list
      AttachFilePreviewDialog.showGallery(
        context,
        attachments: allAttachments,
        initialIndex: initialIndex >= 0 ? initialIndex : 0,
        title: doc.nameTh ?? 'ไฟล์แนบ',
        titles: allTitles,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: enabled ? LaColors.statusApprovedBg : LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(LaRadius.sm),
          onTap: enabled ? () => _openPreview(context) : null,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: LaSpace.sm, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  enabled
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  size: 14,
                  color:
                      enabled ? LaColors.statusApprovedFg : LaColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  'เรียกดู',
                  style: LaText.label.copyWith(
                    color: enabled
                        ? LaColors.statusApprovedFg
                        : LaColors.textMuted,
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

// =============================================================================
// States (Loading / Empty / MissingRequest)
// =============================================================================
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: LaSpace.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(LaColors.primary),
              ),
            ),
            SizedBox(height: LaSpace.md),
            Text('กำลังโหลดรายการเอกสาร…', style: LaText.bodyMuted),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: LaSpace.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: LaColors.textMuted),
            SizedBox(height: LaSpace.md),
            Text('ไม่พบรายการเอกสารที่ต้องแนบ', style: LaText.bodyMuted),
          ],
        ),
      ),
    );
  }
}

class _MissingRequestState extends StatelessWidget {
  const _MissingRequestState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: LaSpace.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_off_rounded,
                size: 48, color: LaColors.statusRejectedFg),
            SizedBox(height: LaSpace.md),
            Text('ไม่พบรหัสคำขอ', style: LaText.h2),
            SizedBox(height: 4),
            Text(
              'กรุณาเปิดหน้านี้จากรายการ "คำขอต่อสัญญา"',
              style: LaText.bodyMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Footer Hint (เหมือนเดิม 1:1)
// =============================================================================
class _FooterHint extends StatelessWidget {
  const _FooterHint();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.info_outline_rounded, size: 14, color: LaColors.textMuted),
        SizedBox(width: 6),
        Expanded(
          child: Text('เลือกเอกสารให้ครบถ้วนก่อนกด "ถัดไป"',
              style: LaText.caption),
        ),
      ],
    );
  }
}

// =============================================================================
// View Mode Toggle — สลับระหว่าง List / Grid
// =============================================================================
class _ViewModeToggle extends StatelessWidget {
  final bool isGrid;
  final VoidCallback onTap;

  const _ViewModeToggle({required this.isGrid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(LaRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(LaRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.view_list_rounded,
                  size: 14,
                  color: isGrid ? LaColors.textMuted : LaColors.primaryDark,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.view_module_rounded,
                  size: 14,
                  color: isGrid ? LaColors.primaryDark : LaColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Documents Grid — Grid view สูงสุด 4 คอลัมน์ + preview รูป/PDF
// =============================================================================
class _DocumentsGrid extends StatelessWidget {
  final List<LicenseAttachDocument> documents;
  const _DocumentsGrid({required this.documents});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        // Responsive: 1-4 คอลัมน์ ตามความกว้าง
        int columns = 1;
        if (constraints.maxWidth >= 1200) {
          columns = 4;
        } else if (constraints.maxWidth >= 800) {
          columns = 3;
        } else if (constraints.maxWidth >= 500) {
          columns = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.78, // card ค่อนข้างสูง (รูป + ชื่อ + status)
          ),
          itemCount: documents.length,
          itemBuilder: (ctx, i) {
            return _DocumentGridCard(
              index: i,
              doc: documents[i],
              columns: columns,
            );
          },
        );
      },
    );
  }
}

class _DocumentGridCard extends StatelessWidget {
  final int index;
  final LicenseAttachDocument doc;
  final int columns;
  const _DocumentGridCard({
    required this.index,
    required this.doc,
    required this.columns,
  });

  bool get _hasFile => doc.attachments != null && doc.attachments!.isNotEmpty;

  int get _docId =>
      doc.id is int ? doc.id as int : int.tryParse('${doc.id}') ?? 0;

  String _fmtDateShort(dynamic v) {
    if (v == null) return '-';
    final s = v.toString();
    if (s.isEmpty || s == 'null') return '-';
    try {
      final dt = DateTime.parse(s);
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      return '$dd/$mm/${dt.year % 100}';
    } catch (_) {
      return '-';
    }
  }

  String _statusLabel(LicenseAttachDocument doc) {
    if (!_hasFile) return 'ยังไม่แนบ';
    final s = doc.attachments!.first.status_label?.toString().trim() ?? '';
    if (s.isEmpty || s == 'null') return 'รอตรวจสอบ';
    return s;
  }

  StatusPalette _statusPalette(LicenseAttachDocument doc) {
    final raw =
        (_hasFile ? doc.attachments!.first.status : null)?.toString() ?? '';
    final label = _statusLabel(doc);
    if (raw.contains('อนุมัติ') ||
        label.contains('อนุมัติ') ||
        label.contains('ผ่าน') ||
        label.contains('เสร็จ')) {
      return const StatusPalette(
          LaColors.statusApprovedBg, LaColors.statusApprovedFg);
    }
    if (raw.contains('ปฏิเสธ') ||
        label.contains('ปฏิเสธ') ||
        label.contains('ขอปรับปรุง') ||
        label.contains('ไม่ผ่าน')) {
      return const StatusPalette(
          LaColors.statusRejectedBg, LaColors.statusRejectedFg);
    }
    return const StatusPalette(
        LaColors.statusPendingBg, LaColors.statusPendingFg);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AttachDocumentsViewModel>();
    final detailVm = context.watch<LicenseAttachDetailViewModel>();
    final locked = detailVm.isLocked;
    final palette = _statusPalette(doc);
    final statusLabel = _statusLabel(doc);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border, width: 1),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Preview area ───
            Expanded(
              child: _DocumentPreview(
                doc: doc,
                hasFile: _hasFile,
              ),
            ),

            // ─── Body ───
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ลำดับ + ชื่อ
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: LaColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: LaText.label.copyWith(
                            color: LaColors.primaryDark,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          (doc.nameTh ?? '-').toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Status pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: LaDecor.pill(palette.bg, palette.fg),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: palette.fg,
                        fontFamily: LaText.fontBold,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (_hasFile) ...[
                    const SizedBox(height: 4),
                    Text(
                      _fmtDateShort(doc.attachments!.first.uploadedAt),
                      style: LaText.caption.copyWith(fontSize: 9),
                    ),
                  ],

                  const SizedBox(height: 6),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: locked
                            ? 'คำขอนี้ถูกล็อก — ไม่สามารถอัปโหลดได้'
                            : (_hasFile ? 'อัปโหลดใหม่' : 'อัปโหลด'),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: (vm.isUploading || locked)
                            ? null
                            : () => _onUpload(context, vm),
                        icon: Icon(
                          Icons.upload_file_rounded,
                          size: 16,
                          color: (vm.isUploading || locked)
                              ? LaColors.textMuted
                              : (_hasFile
                                  ? LaColors.statusInfoFg
                                  : LaColors.primary),
                        ),
                      ),
                      if (_hasFile)
                        IconButton(
                          tooltip: locked
                              ? 'คำขอนี้ถูกล็อก — ไม่สามารถลบได้'
                              : 'ลบไฟล์แนบ',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(minWidth: 28, minHeight: 28),
                          onPressed: (vm.isLoading || locked)
                              ? null
                              : () => _onDelete(context, vm),
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: (vm.isLoading || locked)
                                ? LaColors.textMuted
                                : LaColors.statusRejectedFg,
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
    );
  }

  Future<void> _onUpload(
      BuildContext context, AttachDocumentsViewModel vm) async {
    final service = AttachDocumentsService();
    PickedFile? picked;
    try {
      picked = await service.pickFromDevice();
    } catch (_) {
      picked = null;
    }
    if (picked == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ยกเลิกการเลือกไฟล์'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    final ok = await vm.uploadFor(documentId: _docId, picked: picked);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'อัปโหลดสำเร็จ' : 'อัปโหลดไม่สำเร็จ'),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
      ),
    );
  }

  Future<void> _onDelete(
      BuildContext context, AttachDocumentsViewModel vm) async {
    if (!_hasFile) return;
    final att = doc.attachments!.first;
    final uuid = att.uuid?.toString() ?? '';
    if (uuid.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LaRadius.lg),
        ),
        title: const Text('ยืนยันการลบไฟล์'),
        content: Text('ลบไฟล์ "${att.fileName ?? att.filePath ?? '-'}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ',
                style: TextStyle(color: LaColors.statusRejectedFg)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final ok = await vm.deleteAttachment(
      documentId: _docId,
      attachmentUuid: uuid,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'ลบไฟล์สำเร็จ' : 'ลบไฟล์ไม่สำเร็จ'),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
      ),
    );
  }
}

// =============================================================================
// Document Preview — โหลด thumbnail รูป/PDF (ใช้ service + auth header)
// =============================================================================
class _DocumentPreview extends StatelessWidget {
  final LicenseAttachDocument doc;
  final bool hasFile;
  const _DocumentPreview({required this.doc, required this.hasFile});

  @override
  Widget build(BuildContext context) {
    if (!hasFile) {
      return _emptyState();
    }

    final att = doc.attachments!.first;

    // ตรวจนามสกุลไฟล์
    final fileType = (att.fileType ?? '').toString().toLowerCase();
    final fileName =
        (att.fileName ?? att.filePath ?? '').toString().toLowerCase();
    final combined = '$fileType $fileName';
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp']
        .any((ext) => combined.contains(ext));
    final isPdf = combined.contains('pdf');

    if (isImage) {
      // โหลดผ่าน service (มี auth header) แล้วแสดงด้วย Image.memory
      return FutureBuilder<Uint8List?>(
        future: AttachDocumentsService().fetchAttachmentBytes(att),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _loadingState();
          }
          final bytes = snap.data;
          if (bytes == null || bytes.isEmpty) {
            return GestureDetector(
              onTap: () => _openPreview(context),
              child: _placeholder(
                Icons.broken_image_rounded,
                'โหลดไม่สำเร็จ',
              ),
            );
          }
          return GestureDetector(
            onTap: () => _openPreview(context),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => _placeholder(
                Icons.broken_image_rounded,
                'แสดงไม่ได้',
              ),
            ),
          );
        },
      );
    }

    // PDF / อื่นๆ → แสดง icon + คลิกเปิด preview เต็มจอ
    return GestureDetector(
      onTap: () {
        // ignore: avoid_print
        print(
            '🔍 [_DocumentPreview] คลิก PDF/ไฟล์: "${att.fileName}" (uuid=${att.uuid})');
        _openPreview(context);
      },
      child: _placeholder(
        isPdf ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_rounded,
        isPdf ? 'PDF' : (fileType.isNotEmpty ? fileType.toUpperCase() : 'FILE'),
        pdfColor: isPdf ? Colors.red.shade400 : null,
      ),
    );
  }

  /// Empty state: ยังไม่มีไฟล์แนบ
  Widget _emptyState() {
    return Container(
      color: LaColors.surfaceMuted,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.upload_file_rounded, size: 32, color: LaColors.textMuted),
          SizedBox(height: 4),
          Text(
            'ยังไม่มีไฟล์',
            style: TextStyle(
              color: LaColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Loading state: กำลังโหลดรูป
  Widget _loadingState() {
    return Container(
      color: LaColors.surfaceMuted,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  /// Placeholder: PDF / ไฟล์อื่น / โหลดไม่สำเร็จ
  Widget _placeholder(IconData icon, String label, {Color? pdfColor}) {
    return Container(
      color: LaColors.surfaceMuted,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: pdfColor ?? LaColors.textMuted),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: pdfColor ?? LaColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'คลิกเพื่อดู',
            style: TextStyle(
              color: LaColors.textMuted,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  /// เปิด preview ไฟล์แนบ — popup gallery รองรับ Next/Prev + ส่ง titles list
  void _openPreview(BuildContext context) {
    if (!hasFile) return;

    // หา attachment ที่ตรงกับ docId
    final raw = doc.id;
    final docId = raw is int
        ? raw
        : (raw is num
            ? raw.toInt()
            : (raw is String ? int.tryParse(raw) ?? 0 : 0));
    final matched = findAttachmentByDocId(
      doc.attachments ?? <LicenseAttachAttachment>[],
      docId,
    );
    final att = matched ?? doc.attachments!.first;

    // รวบรวม attachments + titles ทั้งหมดจากทุก docs ใน VM
    final vm = context.read<AttachDocumentsViewModel>();
    final allAttachments = <LicenseAttachAttachment>[];
    final allTitles = <String?>[];
    for (final d in vm.documents) {
      if (d.attachments != null) {
        for (final a in d.attachments!) {
          allAttachments.add(a);
          // ใช้ doc.nameTh เป็น title สำหรับแต่ละ attachment
          allTitles.add(d.nameTh?.toString());
        }
      }
    }

    // หา index ของ attachment ปัจจุบัน
    final initialIndex = allAttachments
        .indexWhere((a) => a.uuid == att.uuid && a.filePath == att.filePath);

    if (allAttachments.length <= 1) {
      // ถ้ามีแค่ 1 ไฟล์ → ใช้ .show() ปกติ
      AttachFilePreviewDialog.show(
        context,
        attachment: att,
        title: doc.nameTh ?? 'ไฟล์แนบ',
      );
    } else {
      // ถ้ามีหลายไฟล์ → ใช้ .showGallery() + ส่ง titles list เพื่อให้ title เปลี่ยนตามไฟล์
      AttachFilePreviewDialog.showGallery(
        context,
        attachments: allAttachments,
        initialIndex: initialIndex >= 0 ? initialIndex : 0,
        title: doc.nameTh ?? 'ไฟล์แนบ',
        titles: allTitles,
      );
    }
  }
}
