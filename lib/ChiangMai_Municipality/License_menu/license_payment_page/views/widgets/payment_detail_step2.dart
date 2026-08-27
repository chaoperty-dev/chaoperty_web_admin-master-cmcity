// ============================================================================
// payment_detail_step2.dart
// ============================================================================
// Step 2 — ใบเสร็จรับเงิน (A4 layout)
// โหลด GET /v2/payments/{uuid}/receipt แล้ว render เป็นกระดาษ A4
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../unity/FormatPhone.dart';
import '../../models/license_payment_detail_model.dart';
import '../../services/license_payment_detail_service.dart';
import '../theme/license_payment_theme.dart';
import '../../viewmodels/license_payment_detail_view_model.dart';

// ============================================================================
// A4 Paper Constants
// 210 x 297 mm @ 96 DPI = 794 x 1123 logical pixels
// ขอบกระดาษราชการ: บน 20 mm, ล่าง 20 mm, ซ้าย 25 mm, ขวา 20 mm
// ============================================================================
class LaPaper {
  static const double mm = 3.7795275591; // 1 mm in logical px @ 96 DPI
  static const double width = 210 * mm; // 794 px
  static const double height = 297 * mm; // 1123 px

  // ขอบกระดาษ
  static const double marginTop = 20 * mm;
  static const double marginBottom = 20 * mm;
  static const double marginLeft = 25 * mm;
  static const double marginRight = 20 * mm;
}

class PaymentDetailStep2 extends StatefulWidget {
  const PaymentDetailStep2({super.key});

  @override
  State<PaymentDetailStep2> createState() => _PaymentDetailStep2State();
}

class _PaymentDetailStep2State extends State<PaymentDetailStep2> {
  bool _didAutoLoad = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicensePaymentDetailViewModel>();

    // ─── ถ้ายังไม่มี receipt uuid ให้ลองหา payment paid อันแรกอัตโนมัติ ───
    final targetUuid = vm.receiptUuid ?? _autoPickPaidUuid(vm);
    if (!_didAutoLoad && !vm.isReceiptLoading && vm.receipt == null) {
      final auto = targetUuid;
      if (auto != null && auto.isNotEmpty) {
        _didAutoLoad = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          vm.loadReceipt(uuid: auto);
        });
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepHeader(
                targetUuid: targetUuid,
                vm: vm,
                receipt: vm.receipt,
              ),
              const SizedBox(height: LaSpace.md),
              _ReceiptBody(uuid: targetUuid),
            ],
          ),
        ),
      ),
    );
  }

  String? _autoPickPaidUuid(LicensePaymentDetailViewModel vm) {
    final list = vm.payments?.data ?? const [];
    for (final p in list) {
      if (p.status.toLowerCase() == 'paid' && p.uuid.isNotEmpty) {
        return p.uuid;
      }
    }
    // fallback: detail.uuid (request-level)
    final detailUuid = vm.detail?.uuid;
    return (detailUuid != null && detailUuid.isNotEmpty) ? detailUuid : null;
  }
}

class _StepHeader extends StatelessWidget {
  final String? targetUuid;
  final LicensePaymentDetailViewModel vm;
  final PaymentReceipt? receipt;
  const _StepHeader({
    required this.targetUuid,
    required this.vm,
    this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    final uuid = targetUuid ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LaColors.primaryLight.withOpacity(.35),
            LaColors.primaryLight.withOpacity(.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.primary.withOpacity(.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: LaColors.primaryDark,
              borderRadius: BorderRadius.circular(LaRadius.sm),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                size: 18, color: Colors.white),
          ),
          const SizedBox(width: LaSpace.sm),
          const Text('ใบเสร็จรับเงิน', style: LaText.h2),
          const Spacer(),
          if (uuid.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: LaColors.surfaceMuted,
                borderRadius: BorderRadius.circular(LaRadius.pill),
                border: Border.all(color: LaColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tag_rounded,
                      size: 13, color: LaColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Payment: ${_short(uuid)}',
                    style: LaText.caption.copyWith(
                      color: LaColors.textSecondary,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: LaSpace.sm),
          // ✅ ปุ่มพิมพ์ PDF (แสดงเมื่อมี receipt)
          if (receipt != null)
            _PrintButton(
              onTap: () => _handlePrint(context, receipt!),
            ),
          const SizedBox(width: LaSpace.sm),
          IconButton(
            tooltip: 'รีโหลด',
            icon: const Icon(Icons.refresh_rounded, size: 18),
            onPressed: uuid.isEmpty ? null : () => vm.loadReceipt(uuid: uuid),
          ),
        ],
      ),
    );
  }

  String _short(String uuid) {
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 8)}…';
  }

  /// ✅ สร้าง PDF จาก PaymentReceipt แล้วเปิด Printing.layoutPdf
  Future<void> _handlePrint(BuildContext context, PaymentReceipt r) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      // โหลดฟอนต์ TH Sarabun PSK
      final fontData = await rootBundle.load('fonts/THSarabunNew.ttf');
      final thaiFont = pw.Font.ttf(fontData);

      // โหลดโลโก้
      final logoData = await rootBundle.load('images/cmm_logo3.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final pdf = pw.Document();
          pdf.addPage(
            pw.MultiPage(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.only(
                top: 20 * 3.7795275591,
                bottom: 20 * 3.7795275591,
                left: 25 * 3.7795275591,
                right: 20 * 3.7795275591,
              ),
              // ✅ ใช้ ThemeData.withFont เพื่อ register font กับ bold/italic/ทุก weight
              //    (ถ้าไม่ใส่ Theme, text ที่มี fontWeight: bold จะ fallback
              //    เป็น Helvetica ซึ่งไม่รองรับ Unicode ภาษาไทย)
              theme: pw.ThemeData.withFont(
                base: thaiFont,
                bold: thaiFont,
                italic: thaiFont,
                boldItalic: thaiFont,
              ),
              build: (pw.Context ctx) => [
                ..._buildPdfContent(r, thaiFont, logoImage),
                ..._buildPdfBody(r, thaiFont),
              ],
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

  /// สร้าง PDF content (header, payment meta, vendor, location, items, totals, officer)
  List<pw.Widget> _buildPdfContent(
      PaymentReceipt r, pw.Font thaiFont, pw.MemoryImage logoImage) {
    final mutedStyle =
        pw.TextStyle(font: thaiFont, fontSize: 11, color: PdfColors.grey600);
    final titleStyle = pw.TextStyle(
        font: thaiFont, fontSize: 22, fontWeight: pw.FontWeight.bold);
    final monoBigStyle = pw.TextStyle(
        font: thaiFont, fontSize: 16, fontWeight: pw.FontWeight.bold);

    return [
      // Header (logo + title + receipt no)
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 64,
            height: 64,
            margin: const pw.EdgeInsets.only(right: 12),
            child: pw.Image(logoImage, fit: pw.BoxFit.cover),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ใบเสร็จรับเงิน', style: titleStyle),
                pw.SizedBox(height: 2),
                pw.Text('เทศบาลนครเชียงใหม่', style: mutedStyle),
              ],
            ),
          ),
          // ✅ ขวา: เลขที่ใบเสร็จ + วันที่ (เหมือนหน้าจอ)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                r.receipt.receiptNo.isEmpty ? '-' : r.receipt.receiptNo,
                style: monoBigStyle,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                _pdfReceiptDateLine(r),
                style: mutedStyle,
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 18),
    ];
  }

  /// ฟอร์แมตวันที่ในใบเสร็จ (ใช้ใน PDF)
  static String _pdfReceiptDateLine(PaymentReceipt r) {
    final d = r.receipt.date.isNotEmpty
        ? _formatDate(r.receipt.date)
        : (r.payment.paidAt ?? '');
    return d.isEmpty ? '' : 'วันที่: $d';
  }

  /// ฟอร์แมต ISO date → dd/MM/yyyy
  static String _formatDate(String s) {
    try {
      final dt = DateTime.parse(s);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return s;
    }
  }

  /// ✅ สร้าง PDF content ทั้งหมด
  List<pw.Widget> _buildPdfBody(PaymentReceipt r, pw.Font thaiFont) {
    final mutedStyle =
        pw.TextStyle(font: thaiFont, fontSize: 10, color: PdfColors.grey600);
    final sectionStyle = pw.TextStyle(
      font: thaiFont,
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColor.fromHex('16A34A'),
    );
    final baseStyle = pw.TextStyle(font: thaiFont, fontSize: 13);

    final m = r.method;
    final methodName = m == null
        ? '-'
        : (m.nameTh.isNotEmpty ? '${m.code} (${m.nameTh})' : m.code);

    final p = r.payment;
    final t = r.entries.totals;
    final fee = t.fee > 0 ? t.fee : r.payment.amount;
    final grand = t.grand > 0 ? t.grand : fee;
    final v = r.vendor;
    final addr = v == null
        ? ''
        : [v.addr1, v.addr2, v.zip].where((s) => s.isNotEmpty).join(' ');
    final l = r.location;
    final o = r.officer;

    return [
      // Payment Meta — เรียงเป็น 2 rows
      _pdfMetaGrid([
        [
          'เลขที่ชำระ',
          r.receipt.receiptNo.isEmpty
              ? (p.paymentNo.isEmpty ? '-' : p.paymentNo)
              : r.receipt.receiptNo
        ],
        ['เล่มที่', r.receipt.bookNo.isEmpty ? '-' : r.receipt.bookNo],
        [
          'วันที่ชำระ',
          (p.paidAt?.isNotEmpty ?? false) ? _formatDate(p.paidAt!) : '-'
        ],
        ['ช่องทาง', methodName]
      ], baseStyle, mutedStyle),
      pw.SizedBox(height: 14),
      pw.Divider(color: PdfColors.grey300, height: 1),
      pw.SizedBox(height: 10),

      // Vendor — section title สีเขียว
      if (v != null) ...[
        pw.Text('ผู้ชำระเงิน', style: sectionStyle),
        pw.SizedBox(height: 6),
        _pdfMetaGrid([
          ['รหัส', v.custno.isEmpty ? '-' : v.custno],
          ['ชื่อ-สกุล', v.cname.isEmpty ? v.scname : v.cname],
          ['เลขประจำตัวผู้เสียภาษี', v.tax.isEmpty ? '-' : v.tax],
          ['โทร', v.tel.isEmpty ? '-' : v.tel],
        ], baseStyle, mutedStyle),
        if (addr.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          _pdfFieldFullWidth('ที่อยู่', addr, baseStyle, mutedStyle),
        ],
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.grey300, height: 1),
        pw.SizedBox(height: 10),
      ],

      // Location
      if (l != null) ...[
        pw.Text('สถานที่', style: sectionStyle),
        pw.SizedBox(height: 6),
        _pdfMetaGrid([
          ['บริเวณ', l.subzone.isEmpty ? l.zn : l.subzone],
          ['รหัสพื้นที่', l.ln.isEmpty ? '-' : l.ln],
          ['เลขที่คำร้อง', (targetUuid ?? '').isEmpty ? '-' : targetUuid!],
          [
            'ระยะสัญญา',
            (l.sdate.isNotEmpty || l.ldate.isNotEmpty)
                ? '${_formatDate(l.sdate)} - ${_formatDate(l.ldate)}'
                : '-'
          ],
        ], baseStyle, mutedStyle),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.grey300, height: 1),
        pw.SizedBox(height: 10),
      ],

      // Items — section title สีเขียว
      if (r.entries.fee.isNotEmpty || r.entries.fine.isNotEmpty) ...[
        pw.Text('รายการ', style: sectionStyle),
        pw.SizedBox(height: 6),
        _pdfItemsTable(r, thaiFont),
        pw.SizedBox(height: 10),
      ],

      // Totals
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
        ),
        child: pw.Column(
          children: [
            _pdfTotalsRow('รวมทั้งสิ้น', '${formatMoney(grand)} บาท', thaiFont,
                bold: true),
          ],
        ),
      ),
      pw.SizedBox(height: 16),

      // Officer
      if (o != null)
        pw.Row(
          children: [
            pw.Spacer(),
            pw.Container(
              width: 220,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                      'ลงชื่อ ........................................................',
                      style: pw.TextStyle(
                          font: thaiFont,
                          fontSize: 11,
                          color: PdfColors.grey700)),
                  pw.SizedBox(height: 6),
                  _SignaturePdfImage(signatureUuid: o.signature?.uuid ?? '')
                      .build(),
                  pw.SizedBox(height: 4),
                  pw.Text('(${o.fullName})',
                      style: pw.TextStyle(
                          font: thaiFont,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold)),
                  if (o.position?.nameTh.isNotEmpty == true)
                    pw.Text(o.position!.nameTh,
                        style: pw.TextStyle(
                            font: thaiFont,
                            fontSize: 11,
                            color: PdfColors.grey600)),
                  pw.SizedBox(height: 2),
                  pw.Text('ผู้รับเงิน',
                      style: pw.TextStyle(
                          font: thaiFont,
                          fontSize: 11,
                          color: PdfColors.grey600)),
                ],
              ),
            ),
          ],
        ),
      pw.SizedBox(height: 18),
      pw.Center(
        child: pw.Text('เอกสารนี้ออกโดยระบบ — Powered by Chaoperty CMS',
            style: pw.TextStyle(
                font: thaiFont, fontSize: 10, color: PdfColors.grey500)),
      ),
    ];
  }

  static String _formatDateShort(String s) {
    if (s.isEmpty) return '';
    try {
      final dt = DateTime.parse(s);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.year.toString().substring(2)}';
    } catch (_) {
      return s;
    }
  }

  // ─── PDF helpers (static) ───
  static pw.Widget _pdfField(
      String label, String value, pw.TextStyle base, pw.TextStyle muted) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(label, style: muted),
        pw.SizedBox(height: 2),
        pw.Text(value, style: base),
      ],
    );
  }

  static pw.Widget _pdfMetaGrid(
      List<List<String>> rows, pw.TextStyle base, pw.TextStyle muted) {
    // แสดง 3 fields ต่อ row (เหมือนหน้าจอ)
    const colsPerRow = 3;
    final children = <pw.Widget>[];
    for (var i = 0; i < rows.length; i += colsPerRow) {
      final chunk = rows.skip(i).take(colsPerRow).toList();
      // สร้าง Row นี้
      final rowChildren = <pw.Widget>[];
      for (var j = 0; j < chunk.length; j++) {
        rowChildren.add(pw.Expanded(
          flex: 1,
          child: _pdfField(chunk[j][0], chunk[j][1], base, muted),
        ));
        if (j < chunk.length - 1) {
          rowChildren.add(pw.SizedBox(width: 16));
        }
      }
      // เติม Expanded ว่างถ้า row ไม่ครบ 3 columns (เพื่อให้ layout สมดุล)
      if (chunk.length < colsPerRow) {
        rowChildren.add(pw.Expanded(flex: 1, child: pw.SizedBox()));
        for (var j = chunk.length + 1; j < colsPerRow; j++) {
          rowChildren.add(pw.SizedBox(width: 16));
          rowChildren.add(pw.Expanded(flex: 1, child: pw.SizedBox()));
        }
      }
      children.add(pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: rowChildren,
      ));
      if (i + colsPerRow < rows.length) {
        children.add(pw.SizedBox(height: 10));
      }
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: children,
    );
  }

  /// Field เต็มบรรทัด (ใช้กับ "ที่อยู่" / "ระยะสัญญา")
  static pw.Widget _pdfFieldFullWidth(
      String label, String value, pw.TextStyle base, pw.TextStyle muted) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(label, style: muted),
        pw.SizedBox(height: 2),
        pw.Text(value, style: base),
      ],
    );
  }

  static pw.Widget _pdfItemsTable(PaymentReceipt r, pw.Font thaiFont) {
    final all = <_PdfItem>[
      ...r.entries.fee.map((e) => _PdfItem(e, false)),
      ...r.entries.fine.map((e) => _PdfItem(e, true)),
    ];
    final headerStyle = pw.TextStyle(
      font: thaiFont,
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.grey700,
    );
    final cellStyle = pw.TextStyle(
      font: thaiFont,
      fontSize: 11,
      color: PdfColors.grey700,
    );
    final amountStyle = pw.TextStyle(
      font: thaiFont,
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.grey900,
    );

    pw.Widget cell(String text,
        {double width = double.infinity,
        pw.TextAlign align = pw.TextAlign.left,
        pw.TextStyle? style,
        bool grow = false}) {
      final body = pw.Text(text, style: style ?? cellStyle, textAlign: align);
      if (grow) return pw.Expanded(child: body);
      return pw.SizedBox(width: width, child: body);
    }

    pw.Widget row(
        String seq, String name, String qty, String unit, String amount) {
      return pw.Row(
        children: [
          cell(seq, width: 28, align: pw.TextAlign.center),
          pw.SizedBox(width: 6),
          cell(name, grow: true),
          pw.SizedBox(width: 6),
          cell(qty, width: 60, align: pw.TextAlign.center),
          pw.SizedBox(width: 6),
          cell(unit, width: 60),
          pw.SizedBox(width: 6),
          cell(amount,
              width: 90, align: pw.TextAlign.right, style: amountStyle),
        ],
      );
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: PdfColors.grey200,
            child: pw.DefaultTextStyle(
              style: headerStyle,
              child: row('ลำดับ', 'รายการ', 'จำนวน', 'หน่วย', 'จำนวนเงิน'),
            ),
          ),
          for (var i = 0; i < all.length; i++)
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: pw.BoxDecoration(
                color: i.isOdd ? PdfColors.grey50 : PdfColors.white,
                border: const pw.Border(
                  top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
              ),
              child: row(
                all[i].isFine ? '${i + 1}*' : '${i + 1}',
                all[i].item.name.isEmpty ? '-' : all[i].item.name,
                all[i].item.qty.isEmpty ? '-' : all[i].item.qty,
                all[i].item.unit.isEmpty ? '-' : all[i].item.unit,
                _pdfAmountOf(all[i].item),
              ),
            ),
        ],
      ),
    );
  }

  static String _pdfAmountOf(ReceiptEntryItem it) {
    if (it.amount > 0) return formatMoney(it.amount);
    if (it.amountInclVat.isNotEmpty) return it.amountInclVat;
    return it.amt.isEmpty ? '-' : it.amt;
  }

  /// สร้าง "sdate - ldate" ในรูปแบบ dd/MM/yy
  static String _pdfItemPeriod(_PdfItem it) {
    final s = it.item.sdate;
    final l = it.item.ldate;
    if (s.isEmpty && l.isEmpty) return '-';
    return '${_formatDateShort(s)} - ${_formatDateShort(l)}';
  }

  static pw.Widget _pdfTotalsRow(String label, String value, pw.Font thaiFont,
      {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(label,
                style: pw.TextStyle(
                  font: thaiFont,
                  fontSize: bold ? 14 : 12,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                )),
          ),
          pw.Text(value,
              style: pw.TextStyle(
                font: thaiFont,
                fontSize: bold ? 16 : 12,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              )),
        ],
      ),
    );
  }
}

/// Item + flag isFine (ใช้ใน PDF builder)
class _PdfItem {
  final ReceiptEntryItem item;
  final bool isFine;
  const _PdfItem(this.item, this.isFine);
}

/// Signature image สำหรับ PDF — โหลด PNG จาก API แบบ async แล้ว embed
class _SignaturePdfImage {
  final String signatureUuid;
  const _SignaturePdfImage({required this.signatureUuid});

  pw.Widget build() {
    if (signatureUuid.isEmpty) {
      return pw.Container(
        width: 160,
        height: 64,
        alignment: pw.Alignment.center,
        child: pw.Text(
          '(ไม่มีลายเซ็น)',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
        ),
      );
    }
    return pw.Container(
      width: 160,
      height: 64,
      alignment: pw.Alignment.center,
      child: pw.Text(
        '(กำลังโหลดลายเซ็น...)',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
      ),
    );
  }
}

class _ReceiptBody extends StatelessWidget {
  final String? uuid;
  const _ReceiptBody({required this.uuid});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicensePaymentDetailViewModel>();

    if ((uuid ?? '').isEmpty) {
      return const _EmptyState(
        icon: Icons.help_outline_rounded,
        title: 'ยังไม่ได้เลือกรายการชำระ',
        subtitle: 'กลับไป Step 1 แล้วกดปุ่ม "ดูใบเสร็จ" ในรายการที่ชำระแล้ว',
      );
    }
    if (vm.isReceiptLoading && vm.receipt == null) {
      return const _LoadingState();
    }
    if (vm.receiptError != null && vm.receipt == null) {
      return _ErrorState(
        message: vm.receiptError!,
        onRetry: () => vm.loadReceipt(uuid: uuid),
      );
    }
    final r = vm.receipt;
    if (r == null) {
      return _EmptyState(
        icon: Icons.inbox_rounded,
        title: 'ยังไม่มีใบเสร็จ',
        subtitle: 'รายการนี้อาจยังไม่ถูกบันทึกการรับชำระ',
        actionLabel: 'ลองโหลดใหม่',
        onAction: () => vm.loadReceipt(uuid: uuid),
      );
    }
    return _A4Paper(receipt: r, requestUuid: uuid);
  }
}

class _A4Paper extends StatefulWidget {
  final PaymentReceipt receipt;
  final String? requestUuid;
  const _A4Paper({required this.receipt, this.requestUuid});

  @override
  State<_A4Paper> createState() => _A4PaperState();
}

class _A4PaperState extends State<_A4Paper> {
  final GlobalKey _contentKey = GlobalKey();
  double _measuredHeight = 0;
  final double _availableHeight =
      LaPaper.height - LaPaper.marginTop - LaPaper.marginBottom;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final r = widget.receipt;
    final requestUuid = widget.requestUuid;
    const totalWidth = 24.0 + LaPaper.width; // rulerSize + A4
    final a4Frame = _A4RulerFrame(
      measuredHeight: _measuredHeight,
      availableHeight: _availableHeight,
      onMeasured: _measureContentHeight,
      child: _A4Sheet(
        child: Column(
          key: _contentKey,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _a4Header(r),
            const SizedBox(height: 18),
            _a4PaymentMeta(r),
            const Divider(height: 28, thickness: 1, color: Color(0xFFE5E7EB)),
            _a4Vendor(r),
            const SizedBox(height: 12),
            _a4Location(r, requestUuid),
            const Divider(height: 28, thickness: 1, color: Color(0xFFE5E7EB)),
            _a4Items(r),
            const SizedBox(height: 12),
            _a4Totals(r),
            const SizedBox(height: 24),
            _a4Officer(r),
            const SizedBox(height: 18),
            _a4Footer(),
          ],
        ),
      ),
    );

    // ✅ จอกว้างพอ → center / จอแคบ → horizontal scroll (กัน overflow)
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= totalWidth) {
          return Center(child: a4Frame);
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          child: a4Frame,
        );
      },
    );
  }

  // ───────────────────── header ─────────────────────
  Widget _a4Header(PaymentReceipt r) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'images/cmm_logo3.png',
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: LaColors.primaryDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance_rounded,
                  color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ใบเสร็จรับเงิน',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'เทศบาลนครเชียงใหม่',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // ✅ ห่อด้วย ConstrainedBox + Flexible → กัน overflow เมื่อ receipt_no ยาว
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                r.receipt.receiptNo.isEmpty ? '-' : r.receipt.receiptNo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  color: Color(0xFF111827),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
              const SizedBox(height: 2),
              Text(
                _receiptDateLine(r),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _receiptDateLine(PaymentReceipt r) {
    final d = r.receipt.date.isNotEmpty
        ? _fmtDate(r.receipt.date)
        : (r.payment.paidAt ?? '');
    return d.isEmpty ? '' : 'วันที่: $d';
  }

  // ─────────────────── payment meta ───────────────────
  Widget _a4PaymentMeta(PaymentReceipt r) {
    final p = r.payment;
    final m = r.method;
    return Wrap(
      spacing: 18,
      runSpacing: 10,
      children: [
        _a4Field(
            'เลขที่ชำระ',
            r.receipt.receiptNo.isEmpty
                ? (p.paymentNo.isEmpty ? '-' : p.paymentNo)
                : r.receipt.receiptNo),
        _a4Field('เล่มที่', r.receipt.bookNo.isEmpty ? '-' : r.receipt.bookNo),
        _a4Field('วันที่ชำระ',
            (p.paidAt?.isNotEmpty ?? false) ? _fmtDate(p.paidAt!) : '-'),
        _a4Field(
            'ช่องทาง',
            m == null
                ? '-'
                : (m.nameTh.isNotEmpty ? '${m.code} (${m.nameTh})' : m.code)),
      ],
    );
  }

  Widget _a4Field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            )),
      ],
    );
  }

  // ───────────────────── vendor ─────────────────────
  Widget _a4Vendor(PaymentReceipt r) {
    final v = r.vendor;
    if (v == null) return const SizedBox.shrink();
    final addr = [v.addr1, v.addr2, v.zip].where((s) => s.isNotEmpty).join(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ผู้ชำระเงิน'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: [
            _a4Field('รหัส', v.custno.isEmpty ? '-' : v.custno),
            _a4Field('ชื่อ-สกุล', v.cname.isEmpty ? v.scname : v.cname),
            _a4Field('เลขประจำตัวผู้เสียภาษี', v.tax.isEmpty ? '-' : v.tax),
            _a4Field('โทร', v.tel.isEmpty ? '-' : formatPhoneNumber(v.tel)),
          ],
        ),
        if (addr.isNotEmpty) ...[
          const SizedBox(height: 8),
          _a4Field('ที่อยู่', addr),
        ],
      ],
    );
  }

  // ─────────────────── location ───────────────────
  Widget _a4Location(PaymentReceipt r, String? requestUuid) {
    final l = r.location;
    if (l == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('สถานที่'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: [
            _a4Field('บริเวณ', l.subzone.isEmpty ? l.zn : l.subzone),
            _a4Field('รหัสพื้นที่', l.ln.isEmpty ? '-' : l.ln),
            _a4Field('เลขที่คำร้อง',
                (requestUuid ?? '').isEmpty ? '-' : requestUuid!),
            _a4Field(
                'ระยะสัญญา',
                (l.sdate.isNotEmpty || l.ldate.isNotEmpty)
                    ? '${_fmtDate(l.sdate)} - ${_fmtDate(l.ldate)}'
                    : '-'),
          ],
        ),
      ],
    );
  }

  // ─────────────────── items table ───────────────────
  Widget _a4Items(PaymentReceipt r) {
    final fees = r.entries.fee;
    final fines = r.entries.fine;
    if (fees.isEmpty && fines.isEmpty) return const SizedBox.shrink();
    final all = <_ItemRow>[
      ...fees.map((e) => _ItemRow(e, false)),
      ...fines.map((e) => _ItemRow(e, true)),
    ];
    final cols = _detectColumns(all);
    if (cols.isEmpty) return const SizedBox.shrink();
    final rows = <Widget>[];
    rows.add(_itemsHeader(cols));
    for (var i = 0; i < all.length; i++) {
      rows.add(_itemsRow(i, all[i], cols));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('รายการ'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(6),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          ),
        ),
      ],
    );
  }

  /// ตรวจว่าแต่ละ row มี field ใดบ้างที่ "มีค่า" → คืนเฉพาะคอลัมน์ที่อย่างน้อย 1 แถวมี
  List<_ColDef> _detectColumns(List<_ItemRow> rows) {
    bool hasQty = false;
    bool hasUnit = false;
    bool hasSdate = false;
    bool hasLdate = false;
    bool hasAmt = false;
    for (final r in rows) {
      if (r.item.qty.isNotEmpty) hasQty = true;
      if (r.item.unit.isNotEmpty) hasUnit = true;
      if (r.item.sdate.isNotEmpty) hasSdate = true;
      if (r.item.ldate.isNotEmpty) hasLdate = true;
      if (_amountOf(r.item).isNotEmpty) hasAmt = true;
    }
    return _colDefsFromFlags(
      qty: hasQty,
      unit: hasUnit,
      sdate: hasSdate,
      ldate: hasLdate,
      amount: hasAmt,
    );
  }

  List<_ColDef> _colDefsFromFlags({
    required bool qty,
    required bool unit,
    required bool sdate,
    required bool ldate,
    required bool amount,
  }) {
    // ถ้ามีทั้ง sdate และ ldate → รวมเป็น "ระยะเวลา" คอลัมน์เดียว
    // ถ้ามีแค่ sdate หรือ ldate → แยกคนละคอลัมน์
    final cols = <_ColDef>[];
    if (qty) cols.add(const _ColDef('จำนวน', 64, alignRight: true));
    if (unit) cols.add(const _ColDef('หน่วย', 64));
    // if (sdate && ldate) {
    //   cols.add(const _ColDef('ระยะเวลา', 160));
    // } else {
    //   if (sdate) cols.add(const _ColDef('เริ่ม', 90));
    //   if (ldate) cols.add(const _ColDef('สิ้นสุด', 90));
    // }
    if (amount) {
      cols.add(const _ColDef('จำนวนเงิน', 100, alignRight: true, mono: true));
    }
    return cols;
  }

  Widget _itemsHeader(List<_ColDef> cols) {
    return Container(
      color: const Color(0xFFF3F4F6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          const SizedBox(
              width: 28,
              child: Text('ลำดับ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151)))),
          const Expanded(
              child: Text('รายการ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151)))),
          for (final c in cols)
            SizedBox(
              width: c.width,
              child: Text(
                c.label,
                textAlign: c.alignRight ? TextAlign.right : TextAlign.start,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _itemsRow(int idx, _ItemRow row, List<_ColDef> cols) {
    final it = row.item;
    final period = (it.sdate.isNotEmpty || it.ldate.isNotEmpty)
        ? '${_fmtDateShort(it.sdate)} - ${_fmtDateShort(it.ldate)}'
        : '-';
    final amt = _amountOf(it);
    return Container(
      decoration: BoxDecoration(
        color: idx.isOdd ? const Color(0xFFFAFAFA) : Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          SizedBox(
              width: 28,
              child: Text(row.isFine ? '${idx + 1}*' : '${idx + 1}',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF374151)))),
          Expanded(
              child: Text(it.name.isEmpty ? '-' : it.name,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827)))),
          for (final c in cols)
            SizedBox(
              width: c.width,
              child: Text(
                _cellValue(c, it, period, amt),
                textAlign: c.alignRight ? TextAlign.right : TextAlign.start,
                style: TextStyle(
                  fontSize: c.mono ? 12 : 11,
                  fontFamily: c.mono ? 'monospace' : null,
                  fontWeight: c.mono ? FontWeight.w700 : FontWeight.w400,
                  color: c.mono
                      ? const Color(0xFF111827)
                      : const Color(0xFF374151),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _cellValue(_ColDef c, ReceiptEntryItem it, String period, String amt) {
    switch (c.label) {
      case 'จำนวน':
        return it.qty.isEmpty ? '-' : it.qty;
      case 'หน่วย':
        return it.unit.isEmpty ? '-' : it.unit;
      case 'ระยะเวลา':
        return period;
      case 'เริ่ม':
        return _fmtDateShort(it.sdate);
      case 'สิ้นสุด':
        return _fmtDateShort(it.ldate);
      case 'จำนวนเงิน':
        return amt.isEmpty ? '-' : amt;
      default:
        return '-';
    }
  }

  String _amountOf(ReceiptEntryItem it) {
    if (it.amount > 0) return formatMoney(it.amount);
    if (it.amountInclVat.isNotEmpty) return it.amountInclVat;
    return it.amt;
  }

  // ───────────────────── totals ─────────────────────
  Widget _a4Totals(PaymentReceipt r) {
    final t = r.entries.totals;
    final fee = t.fee > 0 ? t.fee : r.payment.amount;
    final grand = t.grand > 0 ? t.grand : fee;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          _totalsRow('รวมทั้งสิ้น', '${formatMoney(grand)} บาท', bold: true),
        ],
      ),
    );
  }

  Widget _totalsRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontSize: bold ? 14 : 12,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: const Color(0xFF111827),
                )),
          ),
          Text(value,
              style: TextStyle(
                fontSize: bold ? 16 : 12,
                fontFamily: 'monospace',
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: bold ? LaColors.primaryDark : const Color(0xFF111827),
              )),
        ],
      ),
    );
  }

  // ─────────────────── officer + signature ───────────────────
  Widget _a4Officer(PaymentReceipt r) {
    final o = r.officer;
    if (o == null) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'ลงชื่อ ........................................................',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              _SignatureImage(signatureUuid: o.signature?.uuid ?? ''),
              const SizedBox(height: 4),
              Text(
                '(${o.fullName})',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              if (o.position?.nameTh.isNotEmpty == true)
                Text(
                  o.position!.nameTh,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              const SizedBox(height: 2),
              Text(
                'ผู้รับเงิน',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _a4Footer() {
    return Center(
      child: Text(
        'เอกสารนี้ออกโดยระบบ — Powered by Chaoperty CMS',
        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
      ),
    );
  }

  // ─────────────────── section title ───────────────────
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: .4,
        color: LaColors.primaryDark,
      ),
    );
  }

  String _fmtDate(String s) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  String _fmtDateShort(String s) {
    try {
      return DateFormat('dd/MM/yy').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  String _fmtDateTime(String s) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }
}

// ============================================================================
// Print Button — ปุ่ม "พิมพ์ / PDF"
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hover ? LaColors.primary : LaColors.primaryLight,
            borderRadius: BorderRadius.circular(LaRadius.sm),
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
                size: 14,
                color: _hover ? Colors.white : LaColors.primaryDark,
              ),
              const SizedBox(width: 4),
              Text(
                'พิมพ์ PDF',
                style: TextStyle(
                  color: _hover ? Colors.white : LaColors.primaryDark,
                  fontFamily: LaText.fontBold,
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

class _SignatureImage extends StatefulWidget {
  final String signatureUuid;
  const _SignatureImage({required this.signatureUuid});

  @override
  State<_SignatureImage> createState() => _SignatureImageState();
}

// ============================================================================
// A4 Sheet Widget — กระดาษ A4 พร้อม margin + shadow + border
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
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
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
// A4 Ruler Frame (top + left rulers + page boundaries)
// ============================================================================
class _A4RulerFrame extends StatelessWidget {
  final Widget child;
  final double measuredHeight;
  final double availableHeight;
  final VoidCallback onMeasured;

  const _A4RulerFrame({
    required this.child,
    required this.measuredHeight,
    required this.availableHeight,
    required this.onMeasured,
  });

  @override
  Widget build(BuildContext context) {
    const rulerSize = 24.0;
    const rulerColor = Color(0xFFFFF8E1);
    const tickColor = Color(0xFF8D6E63);
    const textColor = Color(0xFF5D4037);

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
// A4 Page Boundaries — เส้นขอบเขตหน้า + ป้าย "Page X / Y"
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
        // เส้นขอบเขตหน้า 1 (เสมอ)
        Positioned(
          left: 0,
          right: 0,
          top: pageBoundaryPosition,
          child: IgnorePointer(
            child: Container(
              height: 2,
              decoration: BoxDecoration(color: Colors.red.withOpacity(.5)),
            ),
          ),
        ),
        // เส้นขอบเขตหน้าถัดๆ (ถ้ามี)
        if (showPageBoundary)
          for (var page = 2; page < totalPages; page++)
            Positioned(
              left: 0,
              right: 0,
              top: pageBoundaryPosition + ((page - 1) * availableHeight),
              child: IgnorePointer(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(color: Colors.red.withOpacity(.5)),
                ),
              ),
            ),
        // ป้าย "Page X / Y" ที่มุมขวาล่างของหน้า 1
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
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SignatureImageState extends State<_SignatureImage> {
  Uint8List? _bytes;
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (widget.signatureUuid.isNotEmpty) _load();
  }

  @override
  void didUpdateWidget(covariant _SignatureImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.signatureUuid != widget.signatureUuid &&
        widget.signatureUuid.isNotEmpty) {
      _bytes = null;
      _failed = false;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final b = await LicensePaymentDetailService()
          .previewSignature(signatureUuid: widget.signatureUuid);
      if (!mounted) return;
      setState(() {
        _bytes = b;
        _loading = false;
        _failed = b == null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const size = Size(160, 64);
    if (_loading) {
      return SizedBox(
        width: size.width,
        height: size.height,
        child: const Center(
          child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 1.6)),
        ),
      );
    }
    if (_bytes != null) {
      return SizedBox(
        width: size.width,
        height: size.height,
        child: Image.memory(_bytes!, fit: BoxFit.contain),
      );
    }
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Center(
        child: Text(
          _failed ? '(ไม่พบลายเซ็น)' : '(ไม่มีลายเซ็น)',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xxl),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: LaColors.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(LaRadius.lg),
            ),
            child: Icon(icon, size: 36, color: LaColors.primary),
          ),
          const SizedBox(height: LaSpace.md),
          Text(title, style: LaText.h2, textAlign: TextAlign.center),
          const SizedBox(height: LaSpace.sm),
          Text(subtitle, style: LaText.bodyMuted, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: LaSpace.md),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(actionLabel!),
              style: FilledButton.styleFrom(
                backgroundColor: LaColors.primaryDark,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: LaSpace.xxl),
      child: const Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(height: LaSpace.md),
          Text('กำลังโหลดใบเสร็จ...', style: LaText.bodyMuted),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: LaColors.statusRejectedFg),
          const SizedBox(width: LaSpace.sm),
          Expanded(
            child: Text(message,
                style: LaText.body.copyWith(color: LaColors.statusRejectedFg)),
          ),
          TextButton(onPressed: onRetry, child: const Text('ลองใหม่')),
        ],
      ),
    );
  }
}

// ───────────────────── helpers ─────────────────────

/// 1 แถวในตาราง + flag isFine (ค่าปรับ)
class _ItemRow {
  final ReceiptEntryItem item;
  final bool isFine;
  const _ItemRow(this.item, this.isFine);
}

/// Definition ของคอลัมน์ที่จะแสดงในตาราง items
class _ColDef {
  final String label;
  final double width;
  final bool alignRight;
  final bool mono;
  const _ColDef(this.label, this.width,
      {this.alignRight = false, this.mono = false});
}
