import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../Style/colors.dart';
import 'WatermarkPainter.dart';

class RentalInforman_Agreement extends StatelessWidget {
  final pw.Document doc;
  final context;
  final String? Get_Value_cid; // Get_Value_cid
  // ข้อมูลประกอบไฟล์/ชื่อผู้เช่า ฯลฯ
  final String? cid; // Get_Value_cid
  final String? title; // ชื่อหัวเอกสารบน AppBar
  final String? filePrefix; // prefix ชื่อไฟล์ เช่น "เอกสารสัญญา"

  const RentalInforman_Agreement({
    Key? key,
    required this.doc,
    this.context,
    this.cid,
    this.title,
    this.filePrefix,
    this.Get_Value_cid,
  }) : super(key: key);

  String _safeFileName(String name, {String fallback = 'document'}) {
    final trimmed = (name.isEmpty ? fallback : name).trim();
    final safe = trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return safe.isEmpty ? '$fallback.pdf' : '$safe.pdf';
  }

  Future<void> _sharePdf(BuildContext context) async {
    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: _safeFileName(
          '${filePrefix ?? 'เอกสารสัญญา'} ${Get_Value_cid ?? ''}'),
    );
  }

  Future<void> _printPdf(BuildContext context) async {
    final bytes = await doc.save();
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: _safeFileName(
          '${filePrefix ?? 'เอกสารสัญญา'} ${Get_Value_cid ?? ''}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTitle =
        title ?? 'เอกสารเช่า (ต้นฉบับ / ยังไม่ลงลายมือชื่อดิจิทัล)';
    final fileName =
        _safeFileName('${filePrefix ?? 'เอกสารสัญญา'} ${Get_Value_cid ?? ''}');

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
          title: Text(
            appTitle,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: Font_.Fonts_T,
            ),
          ),
          // actions: [
          //   IconButton(
          //     tooltip: 'พิมพ์',
          //     icon: const Icon(Icons.print, color: Colors.white),
          //     onPressed: () => _printPdf(context),
          //   ),
          //   IconButton(
          //     tooltip: kIsWeb ? 'ดาวน์โหลด PDF' : 'แชร์/บันทึก PDF',
          //     icon: Icon(kIsWeb ? Icons.download : Icons.share,
          //         color: Colors.white),
          //     onPressed: () => _sharePdf(context),
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
                    allowSharing:
                        false, // ให้ปุ่มแชร์ในแถบของ PdfPreview ด้วย (ถ้าต้องการ)
                    allowPrinting: false, // ให้พิมพ์จาก preview ได้
                    canDebug: false,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    initialPageFormat: PdfPageFormat.a4,
                    maxPageWidth: MediaQuery.of(context).size.width * 0.6,
                    pdfFileName: fileName,
                  ),
                ),
                // แถบปุ่มด้านล่าง (คงดีไซน์เดิม แต่ทำให้สะอาดขึ้น)
                Material(
                  color: AppBarColors.hexColor.withOpacity(0.8),
                  child: SizedBox(
                    // height: kToolbarHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 24),
                        IconButton(
                          tooltip: 'พิมพ์ / เปิดในแท็บใหม่',
                          icon: const Icon(Icons.print, color: Colors.white),
                          onPressed: () => _printPdf(context),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          tooltip: 'ดาวน์โหลด PDF',
                          icon: const Icon(Icons.download, color: Colors.white),
                          onPressed: () => _sharePdf(context),
                        ),
                        const SizedBox(width: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ), // ลายน้ำแบบเบา เร็ว และไม่กระพริบ
            const IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: WatermarkPainter('Chaoperty'),
              ),
            ),
          ],
        ),
        // body: PdfPreview(
        //   build: (format) => doc.save(),
        //   allowSharing:
        //       true, // ให้ปุ่มแชร์ในแถบของ PdfPreview ด้วย (ถ้าต้องการ)
        //   allowPrinting: true, // ให้พิมพ์จาก preview ได้
        //   canDebug: false,
        //   canChangeOrientation: false,
        //   canChangePageFormat: false,
        //   initialPageFormat: PdfPageFormat.a4,
        //   maxPageWidth: MediaQuery.of(context).size.width * 0.6,
        //   pdfFileName: fileName,
        // ),
      ),
    );
  }
}
