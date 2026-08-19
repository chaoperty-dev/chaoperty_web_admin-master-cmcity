// ============================================================================
// verify_file_preview_dialog.dart
// ============================================================================
// Popup ดูไฟล์แนบ (รูป / PDF) — Premium UI + Next/Previous navigation
// - รองรับหลายไฟล์ → Next/Prev ได้
// - รูป (jpg/jpeg/png/gif/webp) → Image.memory + InteractiveViewer + zoom
// - PDF → SfPdfViewer.memory + zoom controls + page navigation
//
// ใช้ LaColors theme tokens เพื่อให้สอดคล้องกับ UI อื่นๆ ใน license_verify_page
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../models/license_verify_document.dart';
import '../../services/verify_documents_service.dart';
import '../theme/license_verify_theme.dart';

/// Popup ดูไฟล์แนบ (รูป/PDF) — รองรับ Next/Previous navigation
///
/// รับ `attachments` (list ของ attachments) + `initialIndex` (เริ่มที่ไฟล์ไหน)
/// - ูป (jpg/jpeg/png/gif/webp) → Image.memory + zoom
/// - PDF → SfPdfViewer.memory (zoom/scroll/print)
class VerifyFilePreviewDialog extends StatefulWidget {
  /// รายการ attachments ทั้งหมดที่จะให้ browse
  final List<LicenseverifyAttachment> attachments;

  /// เริ่มต้นที่ index ไหน (default = 0)
  final int initialIndex;

  /// ชื่อเอกสาร (ใช้แสดง title — ถ้า null จะใช้ fileName ของ attachment แทน)
  final String? title;

  /// รายการ titles (หน่ง title ต่อ attachment) — ใช้แสดง title ที่ dynamic ตามแต่ละไฟล์
  final List<String?>? titles;

  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  VerifyFilePreviewDialog({
    super.key,
    required this.attachments,
    this.initialIndex = 0,
    this.title,
    this.titles,
    this.onApprove,
    this.onReject,
  }) : assert(attachments.isNotEmpty, 'attachments ต้องไม่ว่าง');

  /// เรียกดู popup แบบง่าย — ส่งมาแค่ 1 attachment
  static Future<void> show(
    BuildContext context, {
    required LicenseverifyAttachment attachment,
    String? title,
    VoidCallback? onApprove,
    VoidCallback? onReject,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(.55),
      builder: (_) => VerifyFilePreviewDialog(
        attachments: [attachment],
        initialIndex: 0,
        title: title,
        onApprove: onApprove,
        onReject: onReject,
      ),
    );
  }

  /// เรียกดู popup แบบ Next/Prev — ส่ง list ของ attachments
  static Future<void> showGallery(
    BuildContext context, {
    required List<LicenseverifyAttachment> attachments,
    int initialIndex = 0,
    String? title,
    List<String?>? titles,
    VoidCallback? onApprove,
    VoidCallback? onReject,
  }) {
    if (attachments.isEmpty) return Future.value();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(.55),
      builder: (_) => VerifyFilePreviewDialog(
        attachments: attachments,
        initialIndex: initialIndex.clamp(0, attachments.length - 1),
        title: title,
        titles: titles,
        onApprove: onApprove,
        onReject: onReject,
      ),
    );
  }

  @override
  State<VerifyFilePreviewDialog> createState() =>
      _VerifyFilePreviewDialogState();
}

class _VerifyFilePreviewDialogState extends State<VerifyFilePreviewDialog> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  LicenseverifyAttachment get _currentAttachment =>
      widget.attachments[_currentIndex];

  bool get _hasNext => _currentIndex < widget.attachments.length - 1;
  bool get _hasPrev => _currentIndex > 0;
  bool get _hasMultiple => widget.attachments.length > 1;

  void _goNext() {
    print(
        '🔵 [_goNext] clicked — _currentIndex=$_currentIndex / ${widget.attachments.length - 1}, _hasNext=$_hasNext');
    if (_hasNext) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goPrev() {
    print(
        '🟡 [_goPrev] clicked — _currentIndex=$_currentIndex, _hasPrev=$_hasPrev');
    if (_hasPrev) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// ตรวจว่าเป็นรูปหรือไม่
  bool _isImage(LicenseverifyAttachment att) {
    final fileType = (att.fileType ?? '').toString().toLowerCase();
    final fileName =
        (att.fileName ?? att.filePath ?? '').toString().toLowerCase();
    final combined = '$fileType $fileName';
    return ['jpg', 'jpeg', 'png', 'gif', 'webp']
        .any((ext) => combined.contains(ext));
  }

  bool _isPdf(LicenseverifyAttachment att) {
    final fileType = (att.fileType ?? '').toString().toLowerCase();
    final fileName =
        (att.fileName ?? att.filePath ?? '').toString().toLowerCase();
    return '$fileType $fileName'.contains('pdf');
  }

  /// ดึง icon ตามประเภทไฟล์
  IconData _getIcon(LicenseverifyAttachment att) {
    if (_isImage(att)) return Icons.image_outlined;
    if (_isPdf(att)) return Icons.picture_as_pdf_outlined;
    return Icons.insert_drive_file_outlined;
  }

  /// ดึงสีหลักตามประเภทไล์
  Color _getPrimaryColor(LicenseverifyAttachment att) {
    if (_isPdf(att)) return const Color(0xFFE53935);
    if (_isImage(att)) return LaColors.primary;
    return LaColors.textSecondary;
  }

  /// ดงสีอ่อนตามประเภทไฟล์
  Color _getSoftColor(LicenseverifyAttachment att) {
    if (_isPdf(att)) return const Color(0xFFFFEBEE);
    if (_isImage(att)) return LaColors.primaryLight;
    return LaColors.surfaceMuted;
  }

  /// ดึง label ตามประเภทไฟล์
  String _getTypeLabel(LicenseverifyAttachment att) {
    if (_isImage(att)) return 'IMAGE';
    if (_isPdf(att)) return 'PDF';
    final type = (att.fileType ?? '').toString();
    return type.isNotEmpty ? type.toUpperCase() : 'FILE';
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
      ),
      insetPadding: EdgeInsets.all(isMobile ? 8 : 16),
      backgroundColor: Colors.transparent,
      elevation: 16,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? screenWidth - 16 : 1000,
          maxHeight: mq.size.height * 0.95,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
          child: Material(
            color: LaColors.surface,
            elevation: 8,
            shadowColor: Colors.black.withOpacity(.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isMobile: isMobile),
                Expanded(
                  child: _buildBody(),
                ),
                _buildFooter(isMobile: isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header — สวยงาม + มี icon + title + Next/Prev + close
  Widget _buildHeader({bool isMobile = false}) {
    final att = _currentAttachment;
    final primary = _getPrimaryColor(att);
    final soft = _getSoftColor(att);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [soft.withOpacity(.6), soft.withOpacity(.3)],
        ),
        border: Border(
          bottom: BorderSide(color: primary.withOpacity(.2), width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      child: Row(
        children: [
          // ปุ่ม Previous — แสดงเมื่อมีหลายไฟล์
          if (_hasMultiple)
            IconButton(
              tooltip: 'ก่อนหน้า',
              onPressed: _hasPrev ? _goPrev : null,
              icon: Icon(
                Icons.chevron_left_rounded,
                size: 28,
              ),
              color: _hasPrev ? primary : LaColors.textMuted.withOpacity(.5),
              style: IconButton.styleFrom(
                backgroundColor:
                    _hasPrev ? primary.withOpacity(.1) : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _hasPrev ? primary.withOpacity(.3) : LaColors.border,
                    width: 1,
                  ),
                ),
              ),
            ),
          if (_hasMultiple) const SizedBox(width: 8),

          // Icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary.withOpacity(.15),
                  primary.withOpacity(.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primary.withOpacity(.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _getIcon(att),
              size: 24,
              color: primary,
            ),
          ),
          const SizedBox(width: 12),

          // Title + counter (เปลี่ยนตามไฟล์ที่กำลังดู)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title หลัก: ใช้ clientDocument.nameTh → widget.title → fileName → default
                Builder(
                  builder: (_) {
                    final att2 = att;
                    final dynTitle = att2.clientDocument?.nameTh?.toString() ??
                        widget.title ??
                        att2.fileName?.toString() ??
                        'ไฟล์แนบ';
                    return Text(
                      dynTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: LaColors.textPrimary,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    );
                  },
                ),
                // Subtitle: ชื่อไฟล์ (fileName)
                if (att.fileName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      att.fileName!.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: LaColors.textMuted,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        _getTypeLabel(att),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_hasMultiple)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: LaColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: LaColors.border, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.layers_rounded,
                                size: 11, color: LaColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${_currentIndex + 1} / ${widget.attachments.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: LaColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ปุ่ม Next — แสดงเมื่อมีหลายไฟล์
          if (_hasMultiple)
            IconButton(
              tooltip: 'ถัดไป',
              onPressed: _hasNext ? _goNext : null,
              icon: Icon(
                Icons.chevron_right_rounded,
                size: 28,
              ),
              color: _hasNext ? primary : LaColors.textMuted.withOpacity(.5),
              style: IconButton.styleFrom(
                backgroundColor:
                    _hasNext ? primary.withOpacity(.1) : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _hasNext ? primary.withOpacity(.3) : LaColors.border,
                    width: 1,
                  ),
                ),
              ),
            ),
          if (_hasMultiple) const SizedBox(width: 4),

          // Close button
          IconButton(
            tooltip: 'ปิด',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 20),
            color: LaColors.textSecondary,
            style: IconButton.styleFrom(
              backgroundColor: LaColors.surfaceMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: LaColors.border, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ดึง title ำหรับ attachment ปัจจุบัน — ใช้ titles[index] ก่อน (dynamic)
  String _getTitleForCurrent() {
    // 1) titles list (dynamic per file)
    final tList = widget.titles;
    if (tList != null &&
        _currentIndex < tList.length &&
        tList[_currentIndex] != null) {
      return tList[_currentIndex]!;
    }
    // 2) clientDocument.nameTh
    final att = _currentAttachment;
    final cdName = att.clientDocument?.nameTh?.toString();
    if (cdName != null && cdName.isNotEmpty) return cdName;
    // 3) widget.title (static)
    if (widget.title != null && widget.title!.isNotEmpty) return widget.title!;
    // 4) fileName
    final fName = att.fileName?.toString();
    if (fName != null && fName.isNotEmpty) return fName;
    // 5) default
    return 'ไฟล์แนบ';
  }

  /// Body — PageView สำหรับ Next/Prev navigation
  Widget _buildBody() {
    return PageView.builder(
      controller: _pageController,
      physics: _hasMultiple
          ? const PageScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        print(
            '🟢 [onPageChanged] newIndex=$index (of ${widget.attachments.length})');
        HapticFeedback.selectionClick();
        setState(() {
          _currentIndex = index;
        });
      },
      itemCount: widget.attachments.length,
      itemBuilder: (context, index) {
        final att = widget.attachments[index];
        final isImage = _isImage(att);
        final isPdf = _isPdf(att);
        final hasFile = att.uuid?.toString().isNotEmpty == true ||
            att.filePath?.toString().isNotEmpty == true;

        if (!hasFile) {
          return _buildEmptyState();
        }

        if (isImage) {
          return _ImageViewer(
            key: ValueKey('img_${att.uuid}_$index'),
            attachment: att,
          );
        }

        if (isPdf) {
          return _PdfViewer(
            key: ValueKey('pdf_${att.uuid}_$index'),
            attachment: att,
          );
        }

        return _NonImageViewer(attachment: att);
      },
    );
  }

  /// Footer — toolbar (zoom hint + close)
  Widget _buildFooter({bool isMobile = false}) {
    final att = _currentAttachment;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted,
        border: Border(top: BorderSide(color: LaColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // Hint
          Expanded(
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPrimaryColor(att).withOpacity(.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getPrimaryColor(att).withOpacity(.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded,
                          size: 11, color: _getPrimaryColor(att)),
                      const SizedBox(width: 4),
                      Text(
                        _isPdf(att)
                            ? 'ดับเิ้ลแท็ปเพื่อซูม'
                            : 'ลาก/นิ้วเพื่อซูม',
                        style: TextStyle(
                          fontSize: 10,
                          color: _isPdf(att)
                              ? const Color(0xFFB71C1C)
                              : LaColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    att.fileName ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: LaColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Next/Prev toolbar (เมื่อมีหลายไฟล์)
          if (_hasMultiple) ...[
            IconButton(
              tooltip: 'ก่อนหน้า',
              onPressed: _hasPrev ? _goPrev : null,
              icon: const Icon(Icons.chevron_left_rounded, size: 22),
              color: _hasPrev
                  ? LaColors.textSecondary
                  : LaColors.textMuted.withOpacity(.5),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            Text(
              '${_currentIndex + 1}/${widget.attachments.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: LaColors.textPrimary,
              ),
            ),
            IconButton(
              tooltip: 'ถัดไป',
              onPressed: _hasNext ? _goNext : null,
              icon: const Icon(Icons.chevron_right_rounded, size: 22),
              color: _hasNext
                  ? LaColors.textSecondary
                  : LaColors.textMuted.withOpacity(.5),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ] else ...[
            IconButton(
              tooltip: 'ปิด',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, size: 16),
              style: IconButton.styleFrom(
                foregroundColor: LaColors.textSecondary,
              ),
            ),
          ],
            const SizedBox(width: 8),
            Flexible(
              child: _PreviewReviewActions(
                att: att,
                onApprove: widget.onApprove,
                onReject: widget.onReject,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: LaColors.surfaceMuted,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: LaColors.border, width: 1.5),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 44,
                color: LaColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ไม่พบไฟล์แนบ',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: LaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ไฟล์นี้อาจถูกลบหรือยังไม่ได้อัปโหลด',
              style: TextStyle(fontSize: 12, color: LaColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PreviewReviewActions — ปุ่ม อนุมัติ/ปฏิเสธ ใน preview popup
// =============================================================================
class _PreviewReviewActions extends StatelessWidget {
  final LicenseverifyAttachment? att;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _PreviewReviewActions({
    this.att,
    required this.onApprove,
    required this.onReject,
  });

  bool get _canReview {
    if (att == null) return false;
    final status = (att!.status ?? '').toString().toLowerCase();
    final label = (att!.status_label ?? '').toString().toLowerCase();
    // approved: อนุมัติ / ผ่าน / เสร็จ
    if (status.contains('อนุมัติ') ||
        label.contains('อนุมัติ') ||
        label.contains('ผ่าน') ||
        label.contains('เสร็จ')) {
      return false;
    }
    // rejected: ปฏิเสธ / ไม่ผ่าน / ขอปรับปรุง (needs_update)
    if (status.contains('ปฏิเสธ') ||
        label.contains('ปฏิเสธ') ||
        label.contains('ไม่ผ่าน') ||
        label.contains('ขอปรับปรุง')) {
      return false;
    }
    final hasFile = att!.uuid?.toString().isNotEmpty == true ||
        att!.filePath?.toString().isNotEmpty == true;
    return hasFile;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = onApprove != null && onReject != null && _canReview;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: enabled ? onApprove : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: LaColors.statusApprovedBg,
            foregroundColor: LaColors.statusApprovedFg,
            disabledBackgroundColor: LaColors.surfaceMuted,
            disabledForegroundColor: LaColors.textMuted,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('อนุมัติ'),
        ),
        const SizedBox(width: 6),
        ElevatedButton(
          onPressed: enabled ? onReject : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: LaColors.statusRejectedBg,
            foregroundColor: LaColors.statusRejectedFg,
            disabledBackgroundColor: LaColors.surfaceMuted,
            disabledForegroundColor: LaColors.textMuted,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('ปฏิเสธ'),
        ),
      ],
    );
  }
}

/// โหลด bytes แล้วแสดงรูป + zoom (พร้อม toolbar)
class _ImageViewer extends StatefulWidget {
  final LicenseverifyAttachment attachment;
  const _ImageViewer({super.key, required this.attachment});

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer>
    with SingleTickerProviderStateMixin {
  Uint8List? _bytes;
  bool _isLoading = true;
  String? _error;
  final TransformationController _transformController =
      TransformationController();
  double _currentScale = 1.0;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _transformController.addListener(() {
      final scale = _transformController.value.getMaxScaleOnAxis();
      if ((scale - _currentScale).abs() > 0.05) {
        setState(() => _currentScale = scale);
      }
    });
    _loadBytes();
  }

  @override
  void didUpdateWidget(_ImageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attachment.uuid != widget.attachment.uuid ||
        oldWidget.attachment.filePath != widget.attachment.filePath) {
      _loadBytes();
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadBytes() async {
    print('🖼️ [_ImageViewer] loading "${widget.attachment.fileName}"');
    setState(() {
      _isLoading = true;
      _bytes = null;
      _error = null;
      _transformController.value = Matrix4.identity();
      _currentScale = 1.0;
    });
    final bytes =
        await VerifyDocumentsService().fetchAttachmentBytes(widget.attachment);
    if (!mounted) return;
    setState(() {
      _bytes = bytes;
      _isLoading = false;
      if (bytes == null || bytes.isEmpty) {
        _error = 'โหลดรูปไม่สำเร็จ';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        constraints: const BoxConstraints(minHeight: 280),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1E)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, __) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          LaColors.primary.withOpacity(.3),
                          LaColors.primary.withOpacity(.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: LaColors.primary.withOpacity(.3),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'กำลังโหลดรูปภาพ...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_error != null || _bytes == null) {
      return Container(
        constraints: const BoxConstraints(minHeight: 280),
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: LaColors.statusRejectedBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.broken_image_rounded,
                    size: 40, color: LaColors.statusRejectedFg),
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'โหลดรูปไม่สำเร็จ',
                style: const TextStyle(
                    color: LaColors.textPrimary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'uuid: ${widget.attachment.uuid ?? '-'}',
                style: const TextStyle(color: LaColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 320),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1E)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 5.0,
              child: Center(
                child: Image.memory(
                  _bytes!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    color: LaColors.surfaceMuted,
                    child: const Center(
                      child: Icon(Icons.broken_image_rounded,
                          size: 64, color: LaColors.statusRejectedFg),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.zoom_in_rounded,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    '${(_currentScale * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// PDF Viewer — ใช้ SfPdfViewer.memory
class _PdfViewer extends StatefulWidget {
  final LicenseverifyAttachment attachment;
  const _PdfViewer({super.key, required this.attachment});

  @override
  State<_PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<_PdfViewer>
    with SingleTickerProviderStateMixin {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _errorMessage;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadPdf();
  }

  @override
  void didUpdateWidget(_PdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attachment.uuid != widget.attachment.uuid ||
        oldWidget.attachment.filePath != widget.attachment.filePath) {
      _loadPdf();
    }
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    print('📄 [_PdfViewer] loading "${widget.attachment.fileName}"');
    setState(() {
      _isLoading = true;
      _pdfBytes = null;
      _errorMessage = null;
    });
    final bytes =
        await VerifyDocumentsService().fetchAttachmentBytes(widget.attachment);
    if (!mounted) return;
    setState(() {
      _pdfBytes = bytes;
      _isLoading = false;
      if (bytes == null || bytes.isEmpty) {
        _errorMessage = 'โหลด PDF ไม่สำเร็จ';
      } else {
        print('✅ [_PdfViewer] loaded ${bytes.length} bytes');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        constraints: const BoxConstraints(minHeight: 320),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, __) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFE53935).withOpacity(.3),
                          const Color(0xFFE53935).withOpacity(.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE53935).withOpacity(.3),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'กำลังโหลด PDF...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB71C1C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null || _pdfBytes == null) {
      return Container(
        constraints: const BoxConstraints(minHeight: 320),
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: LaColors.statusRejectedBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.broken_image_rounded,
                    size: 40, color: LaColors.statusRejectedFg),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'โหลด PDF ไม่สำเร็จ',
                style: const TextStyle(
                    color: LaColors.textPrimary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'uuid: ${widget.attachment.uuid ?? '-'}',
                style: const TextStyle(color: LaColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      type: MaterialType.canvas,
      color: const Color(0xFF1A1A1E),
      child: SizedBox(
        height: 500,
        child: SfPdfViewer.memory(
          _pdfBytes!,
          key: _pdfViewerKey,
          controller: _pdfViewerController,
          canShowScrollHead: false,
          canShowScrollStatus: false,
          pageLayoutMode: PdfPageLayoutMode.continuous,
          enableDoubleTapZooming: true,
        ),
      ),
    );
  }
}

/// สำหรับไฟล์ที่ไม่ใช่รูป/PDF — แสดง icon + meta
class _NonImageViewer extends StatelessWidget {
  final LicenseverifyAttachment attachment;
  const _NonImageViewer({required this.attachment});

  @override
  Widget build(BuildContext context) {
    final name = (attachment.fileName ?? attachment.filePath ?? '').toString();
    final type = (attachment.fileType ?? '').toString();

    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            LaColors.surface,
            LaColors.surfaceMuted.withOpacity(.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    LaColors.primary.withOpacity(.15),
                    LaColors.primary.withOpacity(.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: LaColors.primary.withOpacity(.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: LaColors.primary.withOpacity(.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.insert_drive_file_outlined,
                size: 52,
                color: LaColors.primary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              name.isEmpty ? 'ไม่ทราบชื่อไฟล์' : name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: LaColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            if (type.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: LaColors.primary.withOpacity(.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: LaColors.primary.withOpacity(.3), width: 1),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: LaColors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            const SizedBox(height: 22),
            const Text(
              'ไฟล์ประเภทนี้ยังไม่รองรับการแสดงผลแบบ inline',
              style: TextStyle(color: LaColors.textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


