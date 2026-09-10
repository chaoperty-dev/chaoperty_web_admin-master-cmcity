import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webviewx/webviewx.dart';

class DashboardHtml extends StatefulWidget {
  const DashboardHtml({super.key});

  @override
  State<DashboardHtml> createState() => _DashboardHtmlState();
}

class _DashboardHtmlState extends State<DashboardHtml> {
  WebViewXController? webviewController;
  bool isLoading = true;
  String htmlContent = '';

  @override
  void initState() {
    super.initState();
    loadHtmlFromAssets();
  }

  Future<void> loadHtmlFromAssets() async {
    try {
      final html = await rootBundle.loadString(
        'images/html/dashboard_vertical_scroll_full.html',
      );

      if (!mounted) return;
      setState(() {
        htmlContent = html;
        // อย่าเพิ่งปิด isLoading จนกว่าหน้าเว็บจะ Render เสร็จ (onPageFinished)
      });
    } catch (e) {
      debugPrint('Error loading HTML: $e');
    }
  }

// ใช้คีย์แบบคงที่ (GlobalKey หรือ UniqueKey ที่สร้างครั้งเดียว)
  final GlobalKey _webViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ใช้พื้นหลังสีเดียวกับ HTML เพื่อไม่ให้จังหวะโหลดดูวูบวาบ
      backgroundColor: const Color(0xFFF8FAFC),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            // บังคับขนาดให้เป๊ะตามจอ
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: WebViewX(
              key:
                  _webViewKey, // ใช้ Key เพื่อป้องกันการทำลาย Widget แล้วสร้างใหม่บ่อยๆ
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              initialContent: htmlContent,
              initialSourceType: SourceType.html,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (controller) => webviewController = controller,
              // ลดการเรียก setState ใน onPageFinished ถ้าไม่จำเป็น
              onPageFinished: (_) {
                if (mounted && isLoading) {
                  setState(() => isLoading = false);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
