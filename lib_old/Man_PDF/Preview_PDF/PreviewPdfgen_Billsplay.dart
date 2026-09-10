import 'dart:html' as html; // ใช้ได้เฉพาะเว็บ
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../Style/colors.dart';
import 'package:path/path.dart' as path;

import 'WatermarkPainter.dart';

class PreviewPdfgen_Billsplay extends StatefulWidget {
  final pw.Document doc;
  final String? renTal_name;
  final String? title;
  final String? netImageUrl;
  final String? selectedMode;
  // ✅ optional
  final PdfPageFormat? pageFormat;

  const PreviewPdfgen_Billsplay({
    Key? key,
    required this.doc,
    this.renTal_name,
    this.title,
    this.netImageUrl,
    this.selectedMode,
    this.pageFormat, // ✅ ไม่บังคับส่งมา
  }) : super(key: key);

  @override
  State<PreviewPdfgen_Billsplay> createState() =>
      _PreviewPdfgen_BillsplayState();
}

class _PreviewPdfgen_BillsplayState extends State<PreviewPdfgen_Billsplay> {
  bool _busy = false; // ✅ กันกดรัว + แสดง overlay ในขณะประมวลผล

  // ✅ sanitize ชื่อไฟล์กันอักขระต้องห้าม (Windows/macOS)
  String _safeFileName(String name, {String fallback = 'document'}) {
    final trimmed = (name.isEmpty ? fallback : name).trim();
    final safe = trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return safe.isEmpty ? '$fallback.pdf' : '$safe.pdf';
  }

  // ✅ ชื่อไฟล์ PDF หลัก ที่จะใช้ทั้ง preview และ download
  String _pdfName() => _safeFileName('${widget.title ?? 'เอกสาร'}');

  // ✅ สำหรับตั้งชื่อไฟล์ PNG (ตัดนามสกุล .pdf ออกก่อน)
  String _pngBaseName(String pdfName) => pdfName.toLowerCase().endsWith('.pdf')
      ? pdfName.substring(0, pdfName.length - 4)
      : pdfName;

  // ✅ สะดวกและปลอดภัย: กันกดซ้ำ + แจ้งผลสำเร็จ/ผิดพลาด + เคลียร์ busy เสมอ
  Future<void> _withBusy(Future<void> Function() job) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await job();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เสร็จแล้ว')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ✅ เปิด dialog พิมพ์ (cross-platform; บนเว็บจะเปิด print dialog)
  Future<void> _printPdf() async => _withBusy(() async {
        final bytes = await widget.doc.save();
        await Printing.layoutPdf(
            onLayout: (_) async => bytes, name: _pdfName());
      });

  // ✅ ดาวน์โหลด PDF (web-only ด้วย dart:html)
  Future<void> _downloadPdf() async => _withBusy(() async {
        final bytes = await widget.doc.save();
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final a = html.AnchorElement(href: url)
          ..download = _pdfName()
          ..style.display = 'none';
        html.document.body?.append(a);
        a.click(); // trigger download
        a.remove(); // ล้างจาก DOM
        html.Url.revokeObjectUrl(url); // ♻️ เคลียร์ URL object
      });

  // ✅ รองรับ 2 วิธี: ลิงก์ตรง (เร็ว) และ blob (กัน CORS)
  Future<void> downloadImage(String imageUrl) async => _withBusy(() async {
        final cleanUrl = Uri.parse(imageUrl);
        final fileNameFromUrl = path.basename(cleanUrl.path);
        final extWithDot = path.extension(fileNameFromUrl);
        final ext =
            extWithDot.startsWith('.') ? extWithDot.substring(1) : extWithDot;

        final fileName = fileNameFromUrl.isNotEmpty
            ? fileNameFromUrl
            : 'image.${ext.isEmpty ? 'jpg' : ext}';

        // วิธี 1: ลิงก์ตรง
        try {
          final a = html.AnchorElement(href: imageUrl)
            ..download = fileName
            ..style.display = 'none';
          html.document.body?.append(a);
          a.click();
          a.remove();
          return;
        } catch (_) {}

        // วิธี 2: blob (กรณี CORS)
        final req = html.HttpRequest();
        req.open('GET', imageUrl);
        req.responseType = 'blob';
        req.send();
        final blob =
            await req.onLoad.first.then((_) => req.response as html.Blob);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final a = html.AnchorElement(href: url)
          ..download = fileName
          ..style.display = 'none';
        html.document.body?.append(a);
        a.click();
        a.remove();
        html.Url.revokeObjectUrl(url);
      });

  // ✅ แปลงหน้าเดียวเป็น PNG ด้วย Printing.raster
  Future<void> downloadPdfPageAsPng({int page = 1, double dpi = 144}) async =>
      _withBusy(() async {
        final bytes = await widget.doc.save();
        final stream = Printing.raster(bytes, dpi: dpi);
        int i = 0;
        await for (final pageRaster in stream) {
          i++;
          if (i != page) continue;
          final png = await pageRaster.toPng();
          final blob = html.Blob([png], 'image/png');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final a = html.AnchorElement(href: url)
            ..download = '${_pngBaseName(_pdfName())}_p$page.png'
            ..style.display = 'none';
          html.document.body?.append(a);
          a.click();
          a.remove();
          html.Url.revokeObjectUrl(url);
          break; // แค่หน้าเดียว
        }
      });

  // ✅ แปลงทุกหน้าเป็น PNG แยกไฟล์ (ดาวน์โหลดทีละไฟล์)
  Future<void> downloadPdfAllPagesAsPng({double dpi = 144}) async =>
      _withBusy(() async {
        final bytes = await widget.doc.save();
        final stream = Printing.raster(bytes, dpi: dpi);
        int index = 0;
        await for (final pageRaster in stream) {
          index++;
          final png = await pageRaster.toPng();
          final blob = html.Blob([png], 'image/png');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final a = html.AnchorElement(href: url)
            ..download = '${_pngBaseName(_pdfName())}_p$index.png'
            ..style.display = 'none';
          html.document.body?.append(a);
          a.click();
          a.remove();
          html.Url.revokeObjectUrl(url);

          // 💡 ถ้าไฟล์ใหญ่/หลายหน้า: อาจพักเบา ๆ ให้เบราเซอร์หายใจ
          // await Future.delayed(const Duration(milliseconds: 40));
        }
      });

  // ✅ RTF เร็วและแก้ไขได้ (ข้อความล้วน + \par แทนบรรทัดใหม่)
  Future<void> downloadRtf(
      {required String fileName, required String body}) async {
    final rtf = r'{\rtf1\ansi ' + body.replaceAll('\n', r'\par ') + '}';
    final blob = html.Blob([rtf], 'application/rtf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final a = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';
    html.document.body?.append(a);
    a.click();
    a.remove();
    html.Url.revokeObjectUrl(url);
  }

  // ✅ “HTML แปะเป็น .doc” — Word เปิดได้/แก้ไขได้ เดินทางลัด
  Future<void> downloadDocFromHtml({
    required String fileName,
    required String htmlBody,
  }) async {
    final htmlString =
        '''
  <html>
    <head><meta charset="utf-8"></head>
    <body>$htmlBody</body>
  </html>''';
    final blob = html.Blob([htmlString], 'application/msword');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final a = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';
    html.document.body?.append(a);
    a.click();
    a.remove();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final appTitle = widget.title ?? 'เอกสาร';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppBarColors.hexColor,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          ),
          centerTitle: true,
          title: Text(appTitle, style: const TextStyle(color: Colors.white)),
          actions: [
            // ✅ ปุ่ม export PNG (หน้าแรก/ทุกหน้า)
            IconButton(
              tooltip: _busy ? 'กำลังทำงาน...' : 'ดาวน์โหลด PNG หน้าแรก',
              icon: const Icon(Icons.image),
              onPressed:
                  _busy ? null : () => downloadPdfPageAsPng(page: 1, dpi: 144),
            ),
            IconButton(
              tooltip: _busy ? 'กำลังทำงาน...' : 'ดาวน์โหลด PNG ทุกหน้า',
              icon: const Icon(Icons.collections),
              onPressed:
                  _busy ? null : () => downloadPdfAllPagesAsPng(dpi: 144),
            ),
            // IconButton(
            //   tooltip: _busy ? 'กำลังทำงาน...' : 'ดาวน์โหลด Word',
            //   icon: const Icon(Icons.document_scanner),
            //   onPressed: _busy
            //       ? null
            //       : () => downloadDocFromHtml(
            //             fileName: '${_pdfName().replaceAll(".pdf", "")}.doc',
            //             htmlBody: '''
            //   <h2>ใบเสร็จ Chaoperty</h2>
            //   <p>ผู้เช่า: ${widget.renTal_name ?? ''}</p>
            //   <p>วันที่: ${DateTime.now()}</p>
            // ''',
            //           ),
            // ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PdfPreview(
                    build: (format) => widget.doc.save(),
                    allowSharing: false,
                    allowPrinting:
                        false, // 🔒 ปิดปุ่ม default ของ PdfPreview (เรามีปุ่มของเราเอง)
                    canDebug: false,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    maxPageWidth: MediaQuery.of(context).size.width * 0.6,
                    // ✅ ใช้ค่าที่ส่งมา ถ้าไม่ส่งมาให้เป็น A4
                    initialPageFormat: widget.pageFormat ?? PdfPageFormat.a4,
                    // initialPageFormat: PdfPageFormat.a4,
                    pdfFileName: _pdfName(),
                  ),
                ),
                // ✅ แถบปุ่มล่าง: print + download PDF
                Material(
                  color: AppBarColors.hexColor.withOpacity(0.8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        tooltip: 'พิมพ์ PDF',
                        icon: const Icon(Icons.print, color: Colors.white),
                        onPressed: _busy ? null : _printPdf,
                      ),
                      IconButton(
                        tooltip: 'ดาวน์โหลด PDF',
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: _busy ? null : _downloadPdf,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // ✅ ลายน้ำทับทั้งจอ (ไม่รับการคลิก)
            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter:
                    WatermarkPainter('Chaoperty ${widget.selectedMode ?? ""}'),
              ),
            ),
            // ✅ Overlay กำลังทำงาน
            if (_busy)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x33000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
