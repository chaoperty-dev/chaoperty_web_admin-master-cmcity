import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:html' as html;

// void main() {
//   runApp(MaterialApp(home: ReceiptPage()));
// }

class ReceiptPage extends StatefulWidget {
  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _captureAndDownload() async {
    // ✅ รอหลายเฟรมให้แน่ใจว่า render เสร็จ
    for (int i = 0; i < 10; i++) {
      await Future.delayed(Duration(milliseconds: 300));
      await WidgetsBinding.instance.endOfFrame;

      final boundary = _globalKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary != null && !boundary.debugNeedsPaint) {
        try {
          ui.Image image = await boundary.toImage(pixelRatio: 3.0);
          ByteData? byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);
          Uint8List pngBytes = byteData!.buffer.asUint8List();
          _download(pngBytes, 'ReceiptPage');
          return;
        } catch (e) {
          //   print('❌ Error during capture: $e');
          return;
        }
      }

      //   print('⏳ ยัง render ไม่เสร็จ รอเพิ่ม...');
    }

    //print('❌ รอครบแล้วแต่ยัง capture ไม่ได้');
  }

  void _download(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "$fileName.png")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("สร้างใบเสร็จ")),
      body: Stack(
        children: [
          // ✅ แสดงจริงแต่ทำให้มองไม่เห็น (ยัง render ได้)
          Opacity(
            opacity: 0.01,
            child: RepaintBoundary(
              key: _globalKey,
              child: ReceiptWidget(),
            ),
          ),

          // ✅ ปุ่มสั่งงาน
          Center(
            child: ElevatedButton(
              onPressed: _captureAndDownload,
              child: Text("📥 สร้าง & ดาวน์โหลดใบเสร็จ"),
            ),
          ),
        ],
      ),
    );
  }
}

class ReceiptWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      padding: EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🧾 ใบเสร็จรับเงิน",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text("เลขที่: INV-001"),
          Text("วันที่: 2025-07-27"),
          Divider(),
          Text("รายการ:", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("- ค่าบริการเช่า: 10,000 บาท"),
          Text("- ค่าน้ำ: 500 บาท"),
          Text("- ค่าไฟ: 800 บาท"),
          Divider(),
          Text("รวมทั้งสิ้น: 11,300 บาท", style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
