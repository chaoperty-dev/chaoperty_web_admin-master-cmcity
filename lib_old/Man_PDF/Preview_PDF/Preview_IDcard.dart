import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../Style/colors.dart';
import 'package:path/path.dart' as path;

import 'WatermarkPainter.dart';

class PreviewScreenIDcard extends StatelessWidget {
  final pw.Document doc;
  final String? netImage_; // ชื่อให้สื่อความ และ type ชัดเจน
  final String filePrefix; // สำหรับตั้งชื่อไฟล์ pdf
  final String? cid; // ใช้ต่อท้ายชื่อไฟล์ถ้าต้องการ (เช่น เลขที่ลูกค้า)

  PreviewScreenIDcard({
    Key? key,
    required this.doc,
    this.netImage_,
    this.filePrefix = 'ข้อมูลผู้เช่า',
    this.cid,
  }) : super(key: key);

  static const customSwatch = MaterialColor(
    0xFF8DB95A,
    <int, Color>{
      50: Color(0xFFC2FD7F),
      100: Color(0xFFB6EE77),
      200: Color(0xFFB2E875),
      300: Color(0xFFACDF71),
      400: Color(0xFFA7DA6E),
      500: Color(0xFFA1D16A),
      600: Color(0xFF94BF62),
      700: Color(0xFF90B961),
      800: Color(0xFF85AB5A),
      900: Color(0xFF7A9B54),
    },
  );

  // ---------- Utils ----------
  String _safeFileName(String name, {String fallback = 'document'}) {
    final trimmed = (name.isEmpty ? fallback : name).trim();
    final safe = trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return safe.isEmpty ? '$fallback.pdf' : '$safe.pdf';
  }

  String _pdfName() => _safeFileName('$filePrefix${cid ?? ''}');

  // ---------- Download image (web only) ----------
  Future<void> downloadImage(String imageUrl) async {
    final cleanUrl = Uri.parse(imageUrl);
    final fileNameFromUrl = path.basename(cleanUrl.path); // photo.jpg
    final extWithDot = path.extension(fileNameFromUrl); // .jpg
    final ext =
        extWithDot.startsWith('.') ? extWithDot.substring(1) : extWithDot;
    final fileName = fileNameFromUrl.isNotEmpty
        ? fileNameFromUrl
        : 'image.${ext.isEmpty ? 'jpg' : ext}';

    // วิธี 1: ลิงก์ตรง (เบาและเร็ว)
    try {
      final a = html.AnchorElement(href: imageUrl)
        ..download = fileName
        ..style.display = 'none';
      html.document.body?.append(a);
      a.click();
      a.remove();
      return;
    } catch (_) {}

    // วิธี 2: blob (บางโดเมนอาจติด CORS)
    try {
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
    } catch (_) {
      // เงียบ ๆ ก็พอ หรือจะแจ้ง SnackBar ก็ได้ถ้าอยู่ใน Stateful
    }
  }

  // ---------- PDF actions ----------
  Future<void> _sharePdf() async {
    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: _pdfName());
  }

  Future<void> _printPdf() async {
    final bytes = await doc.save();
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: _pdfName(),
    );
  }

  Future<void> _downloadPdf() async {
    // บนเว็บ Printing.sharePdf จะดาวน์โหลด/แชร์ให้เองอยู่แล้ว
    // ถ้าต้องดาวน์โหลดทันทีด้วย anchor:
    final bytes = await doc.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final a = html.AnchorElement(href: url)
      ..download = _pdfName()
      ..style.display = 'none';
    html.document.body?.append(a);
    a.click();
    a.remove();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: customSwatch),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppBarColors.hexColor,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          ),
          centerTitle: true,
          title: const Text(
            'สำเนาบัตรประชาชน',
            style: TextStyle(
              color: Colors.white,
              fontFamily: Font_.Fonts_T, // ใช้คอนสแตนต์ฟอนต์ของโปรเจ็กต์
            ),
          ),
          // actions: [
          //   IconButton(
          //     tooltip: 'พิมพ์ PDF',
          //     icon: const Icon(Icons.print),
          //     onPressed: _printPdf,
          //   ),
          //   IconButton(
          //     tooltip: 'ดาวน์โหลด PDF',
          //     icon: const Icon(Icons.download),
          //     onPressed: _downloadPdf,
          //   ),
          // ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PdfPreview(
                    build: (format) => doc.save(),
                    allowSharing: false,
                    allowPrinting: false,
                    canDebug: false,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    initialPageFormat: PdfPageFormat.a4,
                    maxPageWidth: MediaQuery.of(context).size.width * 0.6,
                    pdfFileName: _pdfName(),
                    // actions: [
                    //   IconButton(
                    //     tooltip: 'ดาวน์โหลดรูปแนบ',
                    //     icon: const Icon(Icons.image),
                    //     onPressed: (netImage_ == null || netImage_!.isEmpty)
                    //         ? null
                    //         : () => downloadImage(netImage_!),
                    //   ),
                    // ],
                  ),
                ),
                // แถบล่าง (คงโทนเดิม)
                Material(
                  color: AppBarColors.hexColor.withOpacity(0.8),
                  child: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 24),
                        IconButton(
                          tooltip: 'พิมพ์ PDF',
                          icon: const Icon(Icons.print, color: Colors.white),
                          onPressed: _printPdf,
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          tooltip: 'ดาวน์โหลดรูปแนบ',
                          icon: const Icon(Icons.image, color: Colors.white),
                          onPressed: (netImage_ == null || netImage_!.isEmpty)
                              ? null
                              : () => downloadImage(netImage_!),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          tooltip: 'ดาวน์โหลด PDF',
                          icon: const Icon(Icons.download, color: Colors.white),
                          onPressed: _downloadPdf,
                        ),
                        const SizedBox(width: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // ลายน้ำ
            const IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: WatermarkPainter('Chaoperty'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
