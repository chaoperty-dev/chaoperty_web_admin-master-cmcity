// ============================================================================
// verify_detail_step2.dart
// ============================================================================
// Step 2 — สรุปการแนบเอกสาร (A4 print-ready layout)
// แสดงตารางเอกสารแนบตามแบบฟอร์ม "ส่วนของผู้รับคำร้อง / เจ้าหน้าที่"
// รวมเป็น 1 หน้า A4 ถ้าข้อมูลไม่เกิน
// โหมด "แสดงอย่างเดียว" — มีปุ่ม "พิมพ์ / PDF" + banner เลขที่/เวอร์ชัน (read-only)
// ไม่มีปุ่มแก้ไข/บันทึก (ตาม attach_detail_step2 แต่ไม่เอา edit logic)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

import '../../models/license_verify_checklist_model.dart';
import '../../viewmodels/license_verify_detail_view_model.dart';
import '../theme/license_verify_theme.dart';

// ============================================================================
// A4 Paper Constants
// 210 x 297 mm @ 96 DPI = 794 x 1123 logical pixels
// ขอบกระดาษราชการ: บน 20 mm, ล่าง 20 mm, ซ้าย 25 mm, ขวา 20 mm
// ============================================================================
class LaPaper {
  static const double mm = 3.7795275591; // 1 mm in logical px @ 96 DPI
  static const double width = 210 * mm; // 794 px
  static const double height = 297 * mm; // 1123 px

  // ขอบกระดาษราชการ
  static const double marginTop = 20 * mm;
  static const double marginBottom = 20 * mm;
  static const double marginLeft = 25 * mm;
  static const double marginRight = 20 * mm;
}

// ============================================================================
// Main Widget (display-only — ไม่ต้องมี state ใด ๆ ทั้งสิ้น)
// ============================================================================
class VerifyDetailStep2 extends StatefulWidget {
  const VerifyDetailStep2({super.key});

  @override
  State<VerifyDetailStep2> createState() => _VerifyDetailStep2State();
}

class _VerifyDetailStep2State extends State<VerifyDetailStep2> {
  final GlobalKey _contentKey = GlobalKey();
  double _measuredHeight = 0;
  final double _availableHeight =
      LaPaper.height - LaPaper.marginTop - LaPaper.marginBottom;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // parent ไม่ได้เรียก loadChecklist() ให้ — step 2 เป็นคนจุดไฟเอง
      final vm = context.read<LicenseverifyDetailViewModel>();
      if (vm.checklist == null && !vm.isLoading && vm.error == null) {
        vm.loadChecklist();
      }
      _measureContentHeight();
    });
  }

  void _measureContentHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_contentKey.currentContext != null) {
        final renderBox =
            _contentKey.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null && mounted) {
          setState(() {
            _measuredHeight = renderBox.size.height;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseverifyDetailViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: LaColors.statusRejectedFg),
            const SizedBox(height: 8),
            Text('โหลดข้อมูลไม่สำเร็จ: ${vm.error}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => vm.loadChecklist(),
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    final preview = vm.checklist;
    if (preview == null) {
      return const Center(child: Text('ไม่มีข้อมูล'));
    }

    return _buildContent(context, preview);
  }

  Widget _buildContent(
      BuildContext context, LicenseverifyChecklistPreview preview) {
    final vm = context.read<LicenseverifyDetailViewModel>();
    final docs = vm.mergedAttachments; // รวม preview + all-attachments (เห็นทุกรายการ)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── Header band (display-only — ไม่มีปุ่มบันทึก/แก้ไข, มีปุ่มพิมพ์) ───
          _StepHeader(
            onPrint: () => _handlePrint(context, preview),
            showPrint: vm.shouldShowPrintButton,
          ),
          const SizedBox(height: LaSpace.md),

          // ─── Saved Checklist Banner (read-only — ไม่มีปุ่มแก้ไข) ───
          if (preview.isSaved) ...[
            _SavedChecklistBanner(preview: preview),
            const SizedBox(height: LaSpace.md),
          ],

          // ─── A4 Preview with Rulers (responsive) ───
          // - จอกว้างพอ (>= A4 + ruler): แสดงแบบ center ตามเดิม
          // - จอแคบ (< A4 + ruler): horizontal scroll กัน RenderFlex overflow
          LayoutBuilder(
            builder: (context, constraints) {
              const totalWidth = 24.0 + LaPaper.width; // rulerSize + A4
              final a4Frame = _A4RulerFrame(
                measuredHeight: _measuredHeight,
                availableHeight: _availableHeight,
                child: _A4Sheet(
                  child: Column(
                    key: _contentKey,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ส่วนของผู้รับคำร้อง
                      _FormSection(
                        title: 'ส่วนของผู้รับคำร้อง',
                        subtitle: 'ใบรับคำขอรับใบอนุญาตฯ / ต่ออายุใบอนุญาต',
                        accent: LaColors.primary,
                        requestNews: preview.payload.requestNews,
                        indexDate: '',
                        compact: true,
                        showLogo: true,
                        child: Column(
                          children: [
                            _DocumentTable(
                              docs: docs,
                              fillMode: _FillMode.receiver,
                              compact: true,
                            ),
                            const SizedBox(height: LaSpace.sm),
                            _OfficerFooter(preview: preview, compact: true),
                            const SizedBox(height: LaSpace.sm),
                            const _PaymentNoticeBox(),
                          ],
                        ),
                      ),
                      const SizedBox(height: LaSpace.md),
                      const Divider(height: 1, color: LaColors.borderStrong),
                      const SizedBox(height: LaSpace.md),
                      // ส่วนของเจ้าหน้าที่
                      _FormSection(
                        title: 'ส่วนของเจ้าหน้าที่',
                        subtitle: 'ใบรับคำขอรับใบอนุญาตฯ / ต่ออายุใบอนุญาต',
                        accent: LaColors.statusInfoFg,
                        requestNews: preview.payload.requestNews,
                        indexDate: '',
                        compact: true,
                        showLogo: true,
                        child: Column(
                          children: [
                            _DocumentTable(
                              docs: docs,
                              fillMode: _FillMode.officer,
                              compact: true,
                            ),
                            const SizedBox(height: LaSpace.sm),
                            _OfficerFooter(preview: preview, compact: true),
                            const SizedBox(height: LaSpace.sm),
                            const _PaymentNoticeBox(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
              if (constraints.maxWidth >= totalWidth) {
                return Center(child: a4Frame);
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                child: a4Frame,
              );
            },
          ),
          const SizedBox(height: LaSpace.lg),
        ],
      ),
    );
  }

  Future<void> _handlePrint(
      BuildContext context, LicenseverifyChecklistPreview preview) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final vm = context.read<LicenseverifyDetailViewModel>();

    try {
      final fontData = await rootBundle.load('fonts/THSarabunNew.ttf');
      final thaiFont = pw.Font.ttf(fontData);
      final thaiBoldFont = pw.Font.ttf(fontData);

      final logoData = await rootBundle.load('images/cmm_logo3.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final pdf = pw.Document();
          pdf.addPage(
            pw.MultiPage(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.only(
                top: 15 * 2.8346456693,
                bottom: 15 * 2.8346456693,
                left: 20 * 2.8346456693,
                right: 15 * 2.8346456693,
              ),
              build: (pw.Context ctx) => _buildPdfContent(
                ctx,
                thaiFont: thaiFont,
                thaiBoldFont: thaiBoldFont,
                preview: preview,
                docs: vm.mergedAttachments,
                logoImage: logoImage,
              ),
            ),
          );
          return pdf.save();
        },
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('พิมพ์ไม่สำเร็จ: $e'),
          backgroundColor: LaColors.statusRejectedFg,
        ),
      );
    }
  }

  List<pw.Widget> _buildPdfContent(
    pw.Context ctx, {
    required pw.Font thaiFont,
    required pw.Font thaiBoldFont,
    required LicenseverifyChecklistPreview preview,
    required List<LicenseverifyChecklistAttachment> docs,
    required pw.MemoryImage logoImage,
  }) {
    final requestNews = preview.payload.requestNews;

    final baseStyle = pw.TextStyle(font: thaiFont, fontSize: 12);
    final boldStyle = pw.TextStyle(font: thaiBoldFont, fontSize: 12);
    final smallStyle = pw.TextStyle(font: thaiFont, fontSize: 10);
    final smallBoldStyle = pw.TextStyle(font: thaiBoldFont, fontSize: 10);

    pw.Widget buildSectionHeader(
      String title,
      String subtitle,
      String indexDate, {
      required PdfColor accent,
      bool showLogo = false,
    }) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (showLogo)
                pw.Container(
                  width: 36,
                  height: 36,
                  margin: const pw.EdgeInsets.only(right: 8),
                  child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                )
              else
                pw.Container(
                  width: 36,
                  height: 36,
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text('ก',
                        style: pw.TextStyle(
                            font: thaiFont,
                            fontSize: 16,
                            color: PdfColors.grey600)),
                  ),
                ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(title,
                        style: pw.TextStyle(
                            font: thaiBoldFont, fontSize: 14, color: accent),
                        textAlign: pw.TextAlign.center),
                    pw.SizedBox(height: 1),
                    pw.Text(subtitle,
                        style: pw.TextStyle(
                            font: thaiFont,
                            fontSize: 10,
                            color: PdfColors.grey600),
                        textAlign: pw.TextAlign.center),
                  ],
                ),
              ),
              if (requestNews != null)
                pw.Container(
                  width: 110,
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(3),
                    border: pw.Border.all(color: PdfColors.grey300, width: 1),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(requestNews.plotLabel,
                          style: pw.TextStyle(
                              font: thaiBoldFont,
                              fontSize: 11,
                              color: PdfColors.grey700)),
                      pw.Text(requestNews.lockLabel,
                          style: pw.TextStyle(
                              font: thaiFont,
                              fontSize: 10,
                              color: PdfColors.grey600)),
                    ],
                  ),
                ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Text('ได้รับเรื่องเมื่อวันที่',
                  style: pw.TextStyle(
                      font: thaiFont, fontSize: 10, color: PdfColors.grey600)),
              pw.SizedBox(width: 6),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(3),
                  border: pw.Border.all(color: PdfColors.grey300, width: 1),
                ),
                child: pw.Text(indexDate, style: smallBoldStyle),
              ),
              pw.Spacer(),
              pw.Text('ตรวจสอบแล้วว่าและเอกสารหลักฐาน แล้วดังนี้',
                  style: pw.TextStyle(
                      font: thaiFont, fontSize: 10, color: PdfColors.grey600)),
            ],
          ),
        ],
      );
    }

    pw.Widget buildTable(_FillMode fillMode) {
      return pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(4),
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
        ),
        child: pw.Column(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.SizedBox(
                      width: 40,
                      child: pw.Text('ลำดับ',
                          style: pw.TextStyle(
                              font: thaiBoldFont,
                              fontSize: 10,
                              color: PdfColors.grey600))),
                  pw.Expanded(
                      flex: 5,
                      child: pw.Text('รายการเอกสาร',
                          style: pw.TextStyle(
                              font: thaiBoldFont,
                              fontSize: 10,
                              color: PdfColors.grey600))),
                  pw.SizedBox(
                      width: 60,
                      child: pw.Text('ครบ',
                          style: pw.TextStyle(
                              font: thaiBoldFont,
                              fontSize: 10,
                              color: PdfColors.grey600),
                          textAlign: pw.TextAlign.center)),
                  pw.SizedBox(
                      width: 60,
                      child: pw.Text('ไม่ครบ',
                          style: pw.TextStyle(
                              font: thaiBoldFont,
                              fontSize: 10,
                              color: PdfColors.grey600),
                          textAlign: pw.TextAlign.center)),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text('หมายเหตุ/เหตุผลประกอบ',
                          style: pw.TextStyle(
                              font: thaiBoldFont,
                              fontSize: 10,
                              color: PdfColors.grey600))),
                ],
              ),
            ),
            for (var i = 0; i < docs.length; i++)
              _buildPdfRow(
                docs[i],
                i + 1,
                i == docs.length - 1,
                fillMode,
                baseStyle: baseStyle,
                boldStyle: boldStyle,
                smallStyle: smallStyle,
                thaiFont: thaiFont,
                thaiBoldFont: thaiBoldFont,
              ),
          ],
        ),
      );
    }

    return [
      buildSectionHeader(
        'ส่วนของผู้รับคำร้อง',
        'ใบรับคำขอรับใบอนุญาตฯ / ต่ออายุใบอนุญาต',
        '',
        accent: PdfColor.fromHex('16A34A'),
        showLogo: true,
      ),
      pw.SizedBox(height: 3),
      buildTable(_FillMode.receiver),
      pw.SizedBox(height: 3),
      _buildPdfOfficerFooter(
        preview,
        baseStyle: baseStyle,
        boldStyle: boldStyle,
        smallStyle: smallStyle,
        thaiFont: thaiFont,
        thaiBoldFont: thaiBoldFont,
      ),
      pw.SizedBox(height: 3),
      _buildPdfPaymentNotice(thaiFont: thaiFont, thaiBoldFont: thaiBoldFont),
      pw.SizedBox(height: 4),
      pw.Divider(color: PdfColors.grey300, height: 1),
      pw.SizedBox(height: 4),
      buildSectionHeader(
        'ส่วนของเจ้าหน้าที่',
        'ใบรับคำขอรับใบอนุญาตฯ / ต่ออายุใบอนุญาต',
        '',
        accent: PdfColor.fromHex('1D4ED8'),
        showLogo: true,
      ),
      pw.SizedBox(height: 3),
      buildTable(_FillMode.officer),
      pw.SizedBox(height: 3),
      _buildPdfOfficerFooter(
        preview,
        baseStyle: baseStyle,
        boldStyle: boldStyle,
        smallStyle: smallStyle,
        thaiFont: thaiFont,
        thaiBoldFont: thaiBoldFont,
      ),
      pw.SizedBox(height: 3),
      _buildPdfPaymentNotice(thaiFont: thaiFont, thaiBoldFont: thaiBoldFont),
    ];
  }

  pw.Widget _buildPdfRow(
    LicenseverifyChecklistAttachment doc,
    int index,
    bool isLast,
    _FillMode fillMode, {
    required pw.TextStyle baseStyle,
    required pw.TextStyle boldStyle,
    required pw.TextStyle smallStyle,
    required pw.Font thaiFont,
    required pw.Font thaiBoldFont,
  }) {
    final hasFile = doc.hasFile;
    final isComplete = hasFile;
    final isIncomplete = !hasFile;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: isLast
              ? pw.BorderSide.none
              : const pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(
            width: 40,
            child: pw.Text('$index.', style: boldStyle),
          ),
          pw.Expanded(
            flex: 5,
            child: pw.Row(
              children: [
                pw.Container(
                  width: 6,
                  height: 6,
                  margin: const pw.EdgeInsets.only(right: 5, top: 1),
                  decoration: pw.BoxDecoration(
                    color: hasFile ? PdfColors.green700 : PdfColors.grey300,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    '${doc.nameTh}${doc.required ? ' *' : ''}',
                    style: baseStyle,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(
            width: 60,
            child: fillMode == _FillMode.officer
                ? _pdfCheckIcon(isComplete)
                : _pdfEmptyCell(),
          ),
          pw.SizedBox(
            width: 60,
            child: fillMode == _FillMode.officer
                ? _pdfCheckIcon(isIncomplete, cross: true)
                : _pdfEmptyCell(),
          ),
          pw.Expanded(
            flex: 3,
            child: _buildPdfRemarkCell(thaiFont),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfCheckIcon(bool active, {bool cross = false}) {
    final color = active ? PdfColors.green700 : PdfColors.red700;
    final bg = active ? PdfColors.green100 : PdfColors.red100;
    return pw.Center(
      child: pw.Container(
        width: 22,
        height: 22,
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: pw.BorderRadius.circular(3),
          border: pw.Border.all(color: color, width: 1),
        ),
        child: pw.Center(
          child: pw.Text(
            cross ? 'x' : '/',
            style: pw.TextStyle(
                fontSize: 12, fontWeight: pw.FontWeight.bold, color: color),
          ),
        ),
      ),
    );
  }

  pw.Widget _pdfEmptyCell() {
    return pw.Center(
      child: pw.Container(
        width: 22,
        height: 22,
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(3),
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
        ),
      ),
    );
  }

  pw.Widget _buildPdfRemarkCell(pw.Font thaiFont) {
    return pw.Container(
      height: 14,
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
        ),
      ),
      child: pw.Align(
        alignment: pw.Alignment.centerLeft,
        child: pw.Text(
          '',
          style: pw.TextStyle(font: thaiFont, fontSize: 10),
        ),
      ),
    );
  }

  pw.Widget _buildPdfOfficerFooter(
    LicenseverifyChecklistPreview preview, {
    required pw.TextStyle baseStyle,
    required pw.TextStyle boldStyle,
    required pw.TextStyle smallStyle,
    required pw.Font thaiFont,
    required pw.Font thaiBoldFont,
  }) {
    final signer = preview.payload.signer;
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '** เอกสารฉบับนี้ คือ หลักฐานการยื่นคำขอต่ออายุใบอนุญาตฯ ไม่ใช่ใบอนุญาตฉบับจริง '
            'ผู้ยื่นคำขอจะได้รับใบอนุญาตเมื่อผ่านการพิจารณาคุณสมบัติและชำระเงินค่าธรรมเนียมแล้ว',
            style: pw.TextStyle(
                font: thaiFont, fontSize: 8, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(
                      height: 24,
                      child: signer?.signaturePath != null
                          ? pw.Center(
                              child: pw.Text('ลงชื่อ',
                                  style: pw.TextStyle(
                                      font: thaiFont,
                                      fontSize: 11,
                                      color: PdfColors.grey600)))
                          : pw.Container(
                              margin:
                                  const pw.EdgeInsets.symmetric(horizontal: 28),
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                    top: pw.BorderSide(
                                        color: PdfColors.black, width: 1)),
                              ),
                            ),
                    ),
                    pw.Text('(ลงชื่อ)',
                        style: pw.TextStyle(
                            font: thaiFont,
                            fontSize: 8,
                            color: PdfColors.grey600)),
                    pw.Text(signer?.name ?? '', style: boldStyle),
                    if (signer != null)
                      pw.Text('(${_formatDateThai(signer.signedAt)})',
                          style: pw.TextStyle(
                              font: thaiFont,
                              fontSize: 8,
                              color: PdfColors.grey500)),
                  ],
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(height: 24),
                    pw.Text('ตำแหน่ง',
                        style: pw.TextStyle(
                            font: thaiFont,
                            fontSize: 8,
                            color: PdfColors.grey600)),
                    pw.Text(signer?.position ?? '', style: boldStyle),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfPaymentNotice({
    required pw.Font thaiFont,
    required pw.Font thaiBoldFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.green200, width: 1),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 8,
            height: 8,
            margin: const pw.EdgeInsets.only(right: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.green700,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              'สามารถติดต่อชำระค่าธรรมเนียมได้ในวันที่',
              style: pw.TextStyle(
                  font: thaiBoldFont, fontSize: 9, color: PdfColors.green700),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// A4 Sheet Widget
// ============================================================================
class _A4Sheet extends StatelessWidget {
  final Widget child;

  const _A4Sheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: LaPaper.width,
      padding: const EdgeInsets.only(
        top: LaPaper.marginTop,
        bottom: LaPaper.marginBottom,
        left: LaPaper.marginLeft,
        right: LaPaper.marginRight,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: LaColors.borderStrong, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============================================================================
// A4 Ruler Frame (top + left rulers) - อยู่ในกรอบของกระดาษพอดี
// ============================================================================
class _A4RulerFrame extends StatelessWidget {
  final Widget child;
  final double measuredHeight;
  final double availableHeight;

  const _A4RulerFrame({
    required this.child,
    required this.measuredHeight,
    required this.availableHeight,
  });

  @override
  Widget build(BuildContext context) {
    const rulerSize = 24.0;
    const rulerColor = Color(0xFFFFF8E1); // สีเหลืองอ่อน
    const tickColor = Color(0xFF8D6E63); // สีเส้นขีด
    const textColor = Color(0xFF5D4037);

    // คำนวณจำนวนหน้าจากความสูงจริงที่วัดได้
    final totalPages =
        measuredHeight > 0 ? (measuredHeight / availableHeight).ceil() : 1;
    final showPageBoundary = measuredHeight > availableHeight;

    return Container(
      width: rulerSize + LaPaper.width,
      decoration: BoxDecoration(
        color: rulerColor,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แถวบน: มุมบนซ้าย + ไม้บรรทัดบน
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: rulerSize, height: rulerSize),
                SizedBox(
                  width: LaPaper.width,
                  height: rulerSize,
                  child: CustomPaint(
                    painter: _HorizontalRulerPainter(
                      tickColor: tickColor,
                      textColor: textColor,
                    ),
                  ),
                ),
              ],
            ),
            // เนื้อหา: ไม้บรรทัดซ้าย + กระดาษ
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: rulerSize,
                  height: measuredHeight > 0 ? measuredHeight : LaPaper.height,
                  child: CustomPaint(
                    painter: _VerticalRulerPainter(
                      tickColor: tickColor,
                      textColor: textColor,
                    ),
                  ),
                ),
                _A4PageBoundaries(
                  measuredHeight: measuredHeight,
                  availableHeight: availableHeight,
                  totalPages: totalPages,
                  showPageBoundary: showPageBoundary,
                  child: child,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// A4 Page Boundaries — วาดเส้นขอบเขตหน้า + หมายเลขหน้า ตามความสูงจริง
// ============================================================================
class _A4PageBoundaries extends StatelessWidget {
  final Widget child;
  final double measuredHeight;
  final double availableHeight;
  final int totalPages;
  final bool showPageBoundary;

  const _A4PageBoundaries({
    required this.child,
    required this.measuredHeight,
    required this.availableHeight,
    required this.totalPages,
    required this.showPageBoundary,
  });

  @override
  Widget build(BuildContext context) {
    const pageBoundaryPosition =
        LaPaper.height - LaPaper.marginBottom - LaPaper.marginTop;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          top: pageBoundaryPosition,
          child: IgnorePointer(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(.5),
              ),
            ),
          ),
        ),
        if (showPageBoundary)
          for (var page = 2; page < totalPages; page++)
            Positioned(
              left: 0,
              right: 0,
              top: pageBoundaryPosition + ((page - 1) * availableHeight),
              child: IgnorePointer(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.5),
                  ),
                ),
              ),
            ),
        Positioned(
          right: 8,
          top: pageBoundaryPosition - 22,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade300, width: 1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'Page $totalPages / $totalPages',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HorizontalRulerPainter extends CustomPainter {
  final Color tickColor;
  final Color textColor;

  _HorizontalRulerPainter({required this.tickColor, required this.textColor});

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 1;

    final textStyle = TextStyle(
      color: textColor,
      fontSize: 8,
      fontWeight: FontWeight.w500,
    );

    const cmPx = LaPaper.mm * 10;
    final cmCount = (size.width / cmPx).floor();

    for (var i = 0; i <= cmCount; i++) {
      final x = i * cmPx;
      final isCm = i % 10 == 0;
      final tickHeight = isCm
          ? size.height * 0.7
          : (i % 5 == 0 ? size.height * 0.5 : size.height * 0.3);

      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, size.height - tickHeight),
        tickPaint,
      );

      if (isCm && i > 0) {
        final textSpan = TextSpan(
          text: '${i ~/ 10}',
          style: textStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x + 2, 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VerticalRulerPainter extends CustomPainter {
  final Color tickColor;
  final Color textColor;

  _VerticalRulerPainter({required this.tickColor, required this.textColor});

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 1;

    final textStyle = TextStyle(
      color: textColor,
      fontSize: 8,
      fontWeight: FontWeight.w500,
    );

    const cmPx = LaPaper.mm * 10;
    final cmCount = (size.height / cmPx).floor();

    for (var i = 0; i <= cmCount; i++) {
      final y = i * cmPx;
      final isCm = i % 10 == 0;
      final tickWidth = isCm
          ? size.width * 0.7
          : (i % 5 == 0 ? size.width * 0.5 : size.width * 0.3);

      canvas.drawLine(
        Offset(size.width, y),
        Offset(size.width - tickWidth, y),
        tickPaint,
      );

      if (isCm && i > 0) {
        final textSpan = TextSpan(
          text: '${i ~/ 10}',
          style: textStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(2, y + 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// Step Header — มีปุ่ม "พิมพ์ / PDF" แต่ไม่มีปุ่มแก้ไข/บันทึก
// ============================================================================
class _StepHeader extends StatelessWidget {
  final VoidCallback onPrint;
  final bool showPrint;

  const _StepHeader({required this.onPrint, this.showPrint = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.sm),
      decoration: BoxDecoration(
        color: LaColors.primaryLight.withOpacity(.25),
        borderRadius: BorderRadius.circular(LaRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.task_alt_rounded,
              size: 18, color: LaColors.primaryDark),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('สรุปการแนบเอกสาร', style: LaText.h2),
          ),
          if (showPrint) _PrintButton(onTap: onPrint),
        ],
      ),
    );
  }
}

// ============================================================================
// Print / PDF Button
// ============================================================================
class _PrintButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PrintButton({required this.onTap});

  @override
  State<_PrintButton> createState() => _PrintButtonState();
}

class _PrintButtonState extends State<_PrintButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? LaColors.primary : LaColors.primaryLight,
            borderRadius: BorderRadius.circular(LaRadius.md),
            border: Border.all(
              color: _hover ? LaColors.primaryDark : LaColors.primary,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.print_rounded,
                size: 16,
                color: _hover ? Colors.white : LaColors.primaryDark,
              ),
              const SizedBox(width: 6),
              Text(
                'พิมพ์ / PDF',
                style: TextStyle(
                  color: _hover ? Colors.white : LaColors.primaryDark,
                  fontFamily: LaText.fontBold,
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

// ============================================================================
// Saved Checklist Banner (read-only — ไม่มีปุ่มแก้ไข/ยกเลิก)
// ============================================================================
class _SavedChecklistBanner extends StatelessWidget {
  final LicenseverifyChecklistPreview preview;

  const _SavedChecklistBanner({required this.preview});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.sm),
      decoration: BoxDecoration(
        color: LaColors.statusInfoFg.withOpacity(.08),
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(
          color: LaColors.statusInfoFg.withOpacity(.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded,
              size: 18, color: LaColors.statusInfoFg),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _MetaChip(
                  label: 'เลขที่',
                  value: preview.checklistNo ?? '-',
                ),
                if (preview.version != null)
                  _MetaChip(
                    label: 'เวอร์ชัน',
                    value: '${preview.version}',
                  ),
                if (preview.checkedAt != null)
                  _MetaChip(
                    label: 'ลงนามเมื่อ',
                    value: _formatDateThai(preview.checkedAt),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;
  const _MetaChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: LaText.caption.copyWith(color: LaColors.textSecondary),
        ),
        Text(
          value,
          style: LaText.body.copyWith(
              fontFamily: LaText.fontBold, fontSize: 13),
        ),
      ],
    );
  }
}

// ============================================================================
// Form Section
// ============================================================================
class _FormSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final LicenseverifyChecklistRequestNews? requestNews;
  final String indexDate;
  final Color accent;
  final Widget child;
  final bool compact;
  final bool showLogo;

  const _FormSection({
    required this.title,
    required this.subtitle,
    this.requestNews,
    required this.indexDate,
    required this.accent,
    required this.child,
    this.compact = false,
    this.showLogo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: compact ? 40 : 48,
              height: compact ? 40 : 48,
              decoration: showLogo
                  ? null
                  : BoxDecoration(
                      color: LaColors.surfaceMuted,
                      shape: BoxShape.circle,
                      border: Border.all(color: LaColors.border, width: 1),
                    ),
              child: showLogo
                  ? Image.asset('images/cmm_logo3.png', fit: BoxFit.contain)
                  : const Icon(Icons.account_balance_rounded,
                      size: 20, color: LaColors.textSecondary),
            ),
            const SizedBox(width: LaSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: LaText.h2.copyWith(
                      color: accent,
                      fontSize: compact ? 15 : 17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: LaText.caption.copyWith(
                      color: LaColors.textSecondary,
                      fontSize: compact ? 10 : 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (requestNews != null)
              Container(
                width: 110,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: LaColors.surface,
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                  border: Border.all(color: LaColors.borderStrong, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      requestNews!.plotLabel,
                      style: LaText.body
                          .copyWith(fontFamily: LaText.fontBold, fontSize: 11),
                    ),
                    Text(
                      requestNews!.lockLabel,
                      style: LaText.caption.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: LaSpace.sm),
        Row(
          children: [
            Text('ได้รับเรื่องเมื่อวันที่',
                style: LaText.bodyMuted.copyWith(fontSize: compact ? 11 : 12)),
            const SizedBox(width: LaSpace.sm),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: LaDecor.softCard(),
              child: Text(
                indexDate,
                style: LaText.body.copyWith(
                    fontFamily: LaText.fontBold, fontSize: compact ? 12 : 13),
              ),
            ),
            const Spacer(),
            Text('ตรวจสอบแล้วว่าและเอกสารหลักฐาน แล้วดังนี้',
                style: LaText.bodyMuted.copyWith(fontSize: compact ? 11 : 12)),
          ],
        ),
        const SizedBox(height: LaSpace.sm),
        child,
      ],
    );
  }
}

// ============================================================================
// Document Table
// ============================================================================
enum _FillMode { receiver, officer }

class _DocumentTable extends StatelessWidget {
  final List<LicenseverifyChecklistAttachment> docs;
  final _FillMode fillMode;
  final bool compact;

  const _DocumentTable({
    required this.docs,
    required this.fillMode,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LaColors.cardBg,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: compact ? LaSpace.sm : LaSpace.md,
                vertical: compact ? LaSpace.xs : LaSpace.sm),
            decoration: const BoxDecoration(
              color: LaColors.surfaceMuted,
              border: Border(
                bottom: BorderSide(color: LaColors.borderStrong, width: 1),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text('ลำดับ', style: LaText.tableHeader),
                ),
                Expanded(
                  flex: 5,
                  child: Text('รายการเอกสาร', style: LaText.tableHeader),
                ),
                SizedBox(
                  width: 60,
                  child: Text('ครบ',
                      style: LaText.tableHeader, textAlign: TextAlign.center),
                ),
                SizedBox(
                  width: 60,
                  child: Text('ไม่ครบ',
                      style: LaText.tableHeader, textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 3,
                  child: Text('หมายเหตุ/เหตุผลประกอบ',
                      style: LaText.tableHeader),
                ),
              ],
            ),
          ),
          for (var i = 0; i < docs.length; i++)
            _DocumentRow(
              index: i + 1,
              doc: docs[i],
              fillMode: fillMode,
              isLast: i == docs.length - 1,
              compact: compact,
            ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final int index;
  final LicenseverifyChecklistAttachment doc;
  final _FillMode fillMode;
  final bool isLast;
  final bool compact;

  const _DocumentRow({
    required this.index,
    required this.doc,
    required this.fillMode,
    required this.isLast,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = doc.hasFile;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? LaSpace.sm : LaSpace.md,
          vertical: compact ? LaSpace.xs : LaSpace.sm),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: LaColors.border, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: compact ? 40 : 50,
            child: Text(
              '$index.',
              style: LaText.tableCell.copyWith(
                  fontFamily: LaText.fontBold, fontSize: compact ? 12 : 13),
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Container(
                  width: compact ? 7 : 8,
                  height: compact ? 7 : 8,
                  margin: const EdgeInsets.only(right: 6, top: 2),
                  decoration: BoxDecoration(
                    color: hasFile
                        ? LaColors.statusApprovedFg
                        : LaColors.borderStrong,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${doc.nameTh}${doc.required ? ' *' : ''}',
                    style:
                        LaText.tableCell.copyWith(fontSize: compact ? 12 : 13),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: compact ? 60 : 70,
            child: hasFile
                ? const _CheckIcon(active: true, kind: _CheckKind.tick)
                : const _EmptyCell(),
          ),
          SizedBox(
            width: compact ? 60 : 70,
            child: hasFile
                ? const _EmptyCell()
                : const _CheckIcon(active: true, kind: _CheckKind.cross),
          ),
          const Expanded(
            flex: 3,
            child: _RemarkText(), // display-only (แทน _RemarkField + TextField)
          ),
        ],
      ),
    );
  }
}

enum _CheckKind { tick, cross }

class _CheckIcon extends StatelessWidget {
  final bool active;
  final _CheckKind kind;
  const _CheckIcon({required this.active, this.kind = _CheckKind.tick});

  @override
  Widget build(BuildContext context) {
    final icon =
        kind == _CheckKind.tick ? Icons.check_rounded : Icons.close_rounded;
    const size = 20.0;
    const iconSize = 14.0;
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(LaRadius.sm),
          border: Border.all(color: LaColors.textPrimary, width: 1),
        ),
        child: Icon(icon, size: iconSize, color: LaColors.textPrimary),
      ),
    );
  }
}

class _EmptyCell extends StatelessWidget {
  const _EmptyCell();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 20.0,
        height: 20.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(LaRadius.sm),
          border: Border.all(color: LaColors.textPrimary, width: 1),
        ),
      ),
    );
  }
}

// ============================================================================
// Remark — display-only (no TextField, no onChanged)
// แสดงเฉพาะค่าที่บันทึกมาจาก preview (ถ้ามี) — ใช้ static text เพื่อกันแก้ไข
// ============================================================================
class _RemarkText extends StatelessWidget {
  const _RemarkText();

  @override
  Widget build(BuildContext context) {
    // แสดงเป็น static text — ไม่อ่าน VM (ตามแนว "เอาแค่มาแสดงอย่างเดียว")
    // ถ้าจะดึง remark ที่บันทึกไว้จริง ๆ ต้องมี getter ฝั่ง model/preview
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '',
        style: LaText.body,
      ),
    );
  }
}

// ============================================================================
// Officer Footer
// ============================================================================
class _OfficerFooter extends StatelessWidget {
  final LicenseverifyChecklistPreview preview;
  final bool compact;
  const _OfficerFooter({required this.preview, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final signer = preview.payload.signer;
    return Container(
      padding: EdgeInsets.all(compact ? LaSpace.sm : LaSpace.md),
      decoration: LaDecor.softCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded,
                  size: compact ? 12 : 14, color: LaColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '** เอกสารฉบับนี้ คือ หลักฐานการยื่นคำขอต่ออายุใบอนุญาตฯ '
                  'ไม่ใช่ใบอนุญาตฉบับจริง ผู้ยื่นคำขอจะได้รับใบอนุญาตเมื่อ '
                  'ผ่านการพิจารณาคุณสมบัติและชำระเงินค่าธรรมเนียมแล้ว',
                  style:
                      LaText.bodyMuted.copyWith(fontSize: compact ? 11 : 12),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? LaSpace.sm : LaSpace.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SignatureBox(
                  label: '(ลงชื่อ)',
                  name: signer?.name ?? '',
                  showSignature: signer?.signaturePath != null,
                  dateText: signer != null
                      ? '(${_formatDateThai(signer.signedAt)})'
                      : '',
                  compact: compact,
                ),
              ),
              const SizedBox(width: LaSpace.md),
              Expanded(
                child: _PositionBox(
                  position: signer?.position ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatDateThai(DateTime? dt) {
  if (dt == null) return '';
  const months = [
    '',
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];
  final thaiYear = dt.year + 543;
  return '${dt.day} ${months[dt.month]} $thaiYear';
}

class _SignatureBox extends StatelessWidget {
  final String label;
  final String name;
  final bool showSignature;
  final String dateText;
  final bool compact;
  const _SignatureBox({
    required this.label,
    required this.name,
    required this.showSignature,
    required this.dateText,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: compact ? 36 : 48,
          child: showSignature
              ? Container(
                  alignment: Alignment.center,
                  child: Icon(Icons.draw_rounded,
                      size: compact ? 28 : 36,
                      color: LaColors.statusApprovedFg),
                )
              : Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: LaColors.textPrimary, width: 1),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(label, style: LaText.bodyMuted),
        const SizedBox(height: 2),
        Text(
          name,
          style: LaText.body.copyWith(
              fontFamily: LaText.fontBold, fontSize: compact ? 12 : 13),
          textAlign: TextAlign.center,
        ),
        if (dateText.isNotEmpty)
          Text(
            dateText,
            style: LaText.caption.copyWith(fontSize: compact ? 10 : 11),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

class _PositionBox extends StatelessWidget {
  final String position;
  const _PositionBox({required this.position});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        const SizedBox(height: 4),
        const Text('ตำแหน่ง', style: LaText.bodyMuted),
        const SizedBox(height: 2),
        Text(
          position,
          style: LaText.body.copyWith(
              fontFamily: LaText.fontBold, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ============================================================================
// Payment Notice Box
// ============================================================================
class _PaymentNoticeBox extends StatelessWidget {
  const _PaymentNoticeBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.sm),
      decoration: BoxDecoration(
        color: LaColors.primaryLight.withOpacity(.35),
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(
          color: LaColors.primary.withOpacity(.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available_rounded,
              size: 16, color: LaColors.primaryDark),
          const SizedBox(width: LaSpace.sm),
          Expanded(
            child: Text(
              'สามารถติดต่อชำระค่าธรรมเนียมได้ในวันที่',
              style: LaText.body
                  .copyWith(fontFamily: LaText.fontBold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
