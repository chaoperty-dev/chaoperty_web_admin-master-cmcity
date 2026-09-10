import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Login_page_cmm.dart';
import 'dart:html' as html;

// ===== Shared palette ให้ตรงกับหน้า Login (พาสเทลมินิมอล) =====
const kBgGradient = [
  Color(0xFFEDE7F6), // lavender
  Color(0xFFD1C4E9), // soft purple gray
  Color(0xFFFFF8E1), // cream
];
final kPrimary = Colors.purple[700];

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  late Timer _timer;
  int _secondsRemaining = 3;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 1) {
        _navigateToHome();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
    // Removed corrupted history pushState
  }

  void _navigateToHome() {
    _timer.cancel();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false, // ❌ ลบทุก route ออก
    );

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (_) => const HomePage()),
    // );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // BG เป็น gradient ให้โทนเดียวกับหน้า Login
        body: Stack(
          children: [
            const _SetupBackground(), // 👈 พื้นหลังแบบ “พาสเทลเฉียง + เส้นโค้ง” (ต่างจากหน้า Login นิดหน่อย)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // โลโก้ (อนุรักษ์ของเดิม)
                  Stack(
                    children: [
                      const Image(
                          image: AssetImage('images/chaoperty_dark.png')),
                      // วงกลม GIF เล็ก ๆ ให้มีชีวิตชีวา
                      // Positioned(
                      //   top: 5,
                      //   left: 1,
                      //   child: SizedBox(
                      //     width: 96,
                      //     height: 96,
                      //     child: ClipOval(
                      //       child: Image.network(
                      //         'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExNjJ6OTJhNHE3NGJqNjljZDM2aXZncDFxY216M24zZDN2YWNqcXB3MCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/aWOeexAloWLQpVggC6/giphy.gif',
                      //         fit: BoxFit.cover,
                      //         gaplessPlayback: false,
                      //         frameBuilder: (context, child, frame, wasSync) =>
                      //             AnimatedOpacity(
                      //           opacity: frame == null ? 0 : 1,
                      //           duration: const Duration(milliseconds: 220),
                      //           child: child,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'กำลังเตรียมความพร้อม...',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ไปหน้าแรกภายใน $_secondsRemaining วินาที',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                    ),
                    icon: const Icon(Icons.fast_forward),
                    label: const Text('ไปหน้าแรกทันที'),
                    onPressed: _navigateToHome,
                  ),
                  const SizedBox(height: 24),
                  // Footer สองภาษา ให้ไปในทางเดียวกับหน้า Login
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'Chaoperty works in partnership with Chiang Mai Municipality — Powered from Chiang Mai',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withOpacity(.55),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== พื้นหลัง “เข้าชุดกับหน้า Login แต่ไม่ซ้ำ” =====
/// - ใช้ gradient สีเดียวกัน
/// - เพิ่มลายเฉียงด้านล่าง + เส้นโค้งนุ่ม ๆ (แทนภูเขา)
class _SetupBackground extends StatelessWidget {
  const _SetupBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SetupPainter(),
      size: MediaQuery.of(context).size,
    );
  }
}

class _SetupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Gradient พาสเทลเดียวกับหน้า Login
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: kBgGradient,
        stops: [0.0, 0.6, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    // แถบเฉียงนุ่ม ๆ ด้านล่าง (ให้ความรู้สึกคล้าย login footer)
    final layer1 = Paint()..color = const Color(0xFFFFFFFF).withOpacity(.35);
    final p1 = Path()
      ..moveTo(0, size.height * 0.88)
      ..quadraticBezierTo(
          size.width * .35, size.height * .80, size.width, size.height * .86)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p1, layer1);

    // เส้นโค้งบาง ๆ ซ้อนอีกชั้นให้มีมิติ
    final layer2 = Paint()..color = const Color(0xFFFFFFFF).withOpacity(.22);
    final p2 = Path()
      ..moveTo(0, size.height * 0.94)
      ..quadraticBezierTo(
          size.width * .55, size.height * .86, size.width, size.height * .92)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p2, layer2);

    // จุด pattern โปร่งบาง ๆ (ต่างจากหน้า Login เล็กน้อย)
    final dot = Paint()..color = const Color(0xFF000000).withOpacity(.04);
    const spacing = 42.0;
    for (double y = 24; y < size.height * 0.75; y += spacing) {
      for (double x = 24; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.6, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
