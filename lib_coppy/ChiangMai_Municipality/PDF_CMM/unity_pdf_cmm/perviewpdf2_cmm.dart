import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../Style/colors.dart';

class PreviewPdfgen2_CMM extends StatelessWidget {
  final pw.Document? doc;
  final Uint8List? bytes;
  final renTal_name;
  final title;
  const PreviewPdfgen2_CMM(
      {Key? key, this.doc, this.bytes, this.renTal_name, this.title})
      : assert(doc != null || bytes != null),
        super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // color: Colors.white,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          background: Colors.white,
        ),
      ),
      // title: 'Flutter Demo',
      // theme: ThemeData(
      //   primarySwatch: customSwatch.withOpacity(0.5),
      // ),
      // theme: ThemeData(
      //   primarySwatch: Colors.green,
      //   scrollbarTheme: ScrollbarThemeData().copyWith(
      //     thumbColor: MaterialStateProperty.all(Colors.lightGreen[200]),
      //   )),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   backgroundColor: AppBarColors.hexColor,
        //   // leading: IconButton(
        //   //   onPressed: () => Navigator.pop(context),
        //   //   icon: const Icon(
        //   //     Icons.arrow_back_outlined,
        //   //     color: Colors.white,
        //   //   ),
        //   // ),
        //   centerTitle: true,
        //   // title: Text(
        //   //   "$title",
        //   //   style: const TextStyle(
        //   //     color: Colors.white,
        //   //     fontFamily: Font_.Fonts_T,
        //   //   ),
        //   // ),
        // ),
        body: Stack(children: [
          PdfPreview(
            build: (format) async {
              if (bytes != null) return bytes!;
              return await doc!.save();
            },
            allowSharing: false,
            allowPrinting: false,
            canDebug: false,
            canChangeOrientation: false,
            canChangePageFormat: false,

            initialPageFormat: PdfPageFormat.a4,
            pdfFileName: "$title.pdf",

            // ⬆ ซูมเข้าโดยให้หน้ากระดาษใหญ่ขึ้นบนจอ
            maxPageWidth: MediaQuery.of(context).size.width * 0.85,

            // ทำพื้นหลังขาวเหมือนเดิม
            scrollViewDecoration: const BoxDecoration(color: Colors.white),
            pdfPreviewPageDecoration: const BoxDecoration(color: Colors.white),

            // ลด margin/padding รอบ ๆ ให้กินพื้นที่มากขึ้น
            padding: EdgeInsets.zero,
            previewPageMargin: const EdgeInsets.symmetric(vertical: 8),
          ),

          // const IgnorePointer(
          //   child: CustomPaint(
          //     size: Size.infinite,
          //     painter: _WatermarkPainter('Chaoperty'),
          //   ),
          // ),
        ]),
      ),
    );
  }
}

/// Painter ลายน้ำ: ประสิทธิภาพสูง ไม่กระพริบ
class _WatermarkPainter extends CustomPainter {
  final String text;
  const _WatermarkPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const double angle = -0.4; // ~ -22°
    canvas.save();
    canvas.rotate(angle);

    final style = const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: Color.fromRGBO(0, 0, 0, 0.08),
    );

    // เว้นระยะห่างแบบคงที่ วาดให้ครอบคลุมทั้งหน้าจอ
    for (double y = -size.height; y < size.height * 2; y += 180) {
      for (double x = -size.width; x < size.width * 2; x += 260) {
        textPainter.text = TextSpan(text: text, style: style);
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
