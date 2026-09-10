import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../Style/colors.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
// ถ้าต้องใช้ js เปิดหน้าต่างคงไว้
import 'dart:js' as js;

import 'WatermarkPainter.dart';

class PreviewScreenRental_ extends StatelessWidget {
  final String title;
  final String Url;

  PreviewScreenRental_({
    Key? key,
    required this.title,
    required this.Url,
  }) : super(key: key);

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  String _sanitizeFileName(String name, {String fallback = 'document'}) {
    final trimmed = name.trim();
    final safe = trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return (safe.isEmpty ? fallback : safe) + '.pdf';
  }

  /// พยายามดาวน์โหลดแบบลิงก์ตรงก่อน (เบา/เร็ว)
  void _downloadDirect(String fileName) {
    final a = html.AnchorElement(href: Url)
      ..download = fileName
      ..style.display = 'none';
    html.document.body?.append(a);
    a.click();
    a.remove();
  }

  /// ถ้าโดน CORS ตอน fetch ให้ try/catch เงียบ ๆ แล้ว fallback
  Future<void> _downloadViaBlob(String fileName) async {
    final res = await http.get(Uri.parse(Url));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final blob = html.Blob([res.bodyBytes], 'application/pdf');
    final objUrl = html.Url.createObjectUrlFromBlob(blob);
    final a = html.AnchorElement(href: objUrl)
      ..download = fileName
      ..style.display = 'none';
    html.document.body?.append(a);
    a.click();
    a.remove();
    html.Url.revokeObjectUrl(objUrl);
  }

  Future<void> downloadPdf() async {
    final fileName = _sanitizeFileName(title.isEmpty ? 'ข้อมูลผู้เช่า' : title);
    try {
      // วิธี 1: ดาวน์โหลดตรง
      _downloadDirect(fileName);
    } catch (_) {
      try {
        // วิธี 2: ผ่าน blob (อาจชน CORS)
        await _downloadViaBlob(fileName);
      } catch (_) {
        // เงียบ ๆ หรือจะแจ้ง SnackBar ก็ได้
        // ScaffoldMessenger.of(context).showSnackBar(...); // ถ้าเป็น Stateful
      }
    }
  }

  void _openInNewTab() {
    // เปิดไฟล์ในแท็บใหม่สำหรับสั่งพิมพ์
    js.context.callMethod('open', [Url]);
    // หรือ html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
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
            title,
            overflow: TextOverflow.ellipsis,
            style:
                const TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SfPdfViewer.network(
                    Url,
                    key: _pdfViewerKey,
                    enableDocumentLinkAnnotation: false,
                    canShowScrollHead: false,
                    canShowScrollStatus: false,
                    pageLayoutMode: PdfPageLayoutMode.continuous,
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
                          onPressed: _openInNewTab,
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          tooltip: 'ดาวน์โหลด PDF',
                          icon: const Icon(Icons.download, color: Colors.white),
                          onPressed: downloadPdf,
                        ),
                        const SizedBox(width: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // ลายน้ำแบบเบา เร็ว และไม่กระพริบ
            const IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: WatermarkPainter('Chaoperty'),
              ),
            ),
          ],
        ),

        //  Column(
        //   children: [
        //     Expanded(
        //       child: SfPdfViewer.network(
        //         Url,
        //         key: _pdfViewerKey,
        //         enableDocumentLinkAnnotation: false,
        //         canShowScrollHead: false,
        //         canShowScrollStatus: false,
        //         pageLayoutMode: PdfPageLayoutMode.continuous,
        //       ),
        //     ),
        //     // แถบปุ่มด้านล่าง (คงดีไซน์เดิม แต่ทำให้สะอาดขึ้น)
        //     Material(
        //       color: const Color.fromARGB(255, 141, 185, 90),
        //       child: SizedBox(
        //         // height: kToolbarHeight,
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //           children: [
        //             const SizedBox(width: 24),
        //             IconButton(
        //               tooltip: 'พิมพ์ / เปิดในแท็บใหม่',
        //               icon: const Icon(Icons.print, color: Colors.white),
        //               onPressed: _openInNewTab,
        //             ),
        //             const SizedBox(width: 24),
        //             IconButton(
        //               tooltip: 'ดาวน์โหลด PDF',
        //               icon: const Icon(Icons.download, color: Colors.white),
        //               onPressed: downloadPdf,
        //             ),
        //             const SizedBox(width: 24),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
