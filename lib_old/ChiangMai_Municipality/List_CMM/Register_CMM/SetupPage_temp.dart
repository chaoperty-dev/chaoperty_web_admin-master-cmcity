// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'Login_page_cmm.dart';

// class SetupPage extends StatefulWidget {
//   const SetupPage({super.key});

//   @override
//   State<SetupPage> createState() => _SetupPageState();
// }

// class _SetupPageState extends State<SetupPage> {
//   late Timer _timer;
//   int _secondsRemaining = 3;

//   @override
//   void initState() {
//     super.initState();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_secondsRemaining == 1) {
//         _navigateToHome();
//       } else {
//         setState(() {
//           _secondsRemaining--;
//         });
//       }
//     });
//   }

//   void _navigateToHome() {
//     _timer.cancel();

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const HomePage()),
//     );
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   Color BG_cl = Color(0xfff3f3ee);
//   Color Fool_cl = Color.fromARGB(255, 141, 185, 90);
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       // ✅ ดักปุ่มย้อนกลับ
//       onWillPop: () async => false, // ❌ ไม่อนุญาตให้ย้อน
//       child: Scaffold(
//         backgroundColor: BG_cl,
//         // appBar: AppBar(title: const Text('ตั้งค่าครั้งแรก')),
//         body: Stack(
//           children: [
//             const DiagonalBackground2(), // 👈 ลวดลายพื้นหลังที่วาดเอง
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // SizedBox(
//                   //   width: 170,
//                   //   height: 170,
//                   //   child: DecoratedBox(
//                   //     decoration: BoxDecoration(
//                   //       shape: BoxShape.circle,
//                   //       // วงแหวนไล่เฉด
//                   //       // gradient: const SweepGradient(
//                   //       //   colors: [
//                   //       //     Color(0xFF6EA8FF),
//                   //       //     Color(0xFFA78BFA),
//                   //       //     Color(0xFF5EEAD4),
//                   //       //     Color(0xFF6EA8FF),
//                   //       //   ],
//                   //       //   stops: [0.0, 0.5, 0.85, 1.0],
//                   //       // ),
//                   //       // boxShadow: [
//                   //       //   BoxShadow(
//                   //       //     color: Colors.black
//                   //       //         .withOpacity(0.15),
//                   //       //     blurRadius: 20,
//                   //       //     offset: const Offset(0, 10),
//                   //       //   ),
//                   //       // ],
//                   //     ),
//                   //     child: Padding(
//                   //       padding:
//                   //           const EdgeInsets.all(6), // ความหนาของ “ขอบวงแหวน”
//                   //       child: ClipOval(
//                   //         child: Image.network(
//                   //           //  Image.asset(
//                   //           // 'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExeHk0cXZncDgwaHlrMnBxeHZydHNwbTA5NWhyejh2MGlycjZvd2pjeCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/t9Qr1B9q0bm9QnsKXu/giphy.gif',
//                   //           'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExNjJ6OTJhNHE3NGJqNjljZDM2aXZncDFxY216M24zZDN2YWNqcXB3MCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/aWOeexAloWLQpVggC6/giphy.gif',
//                   //           // 'images/0001.gif', // ให้ตรงกับ pubspec.yaml
//                   //           // key: ValueKey(
//                   //           //     _gifTick), // 👈 สำคัญ: เปลี่ยนเมื่อเริ่มโหลดใหม่
//                   //           fit: BoxFit.cover,
//                   //           gaplessPlayback: false, // ให้รีสตาร์ทจริง ๆ
//                   //           // ใส่เฟดอินนิดนึงให้ดูเนียน
//                   //           frameBuilder: (context, child, frame, wasSync) {
//                   //             return AnimatedOpacity(
//                   //               opacity: frame == null ? 0 : 1,
//                   //               duration: const Duration(milliseconds: 220),
//                   //               child: child,
//                   //             );
//                   //           },
//                   //         ),
//                   //       ),
//                   //     ),
//                   //   ),
//                   // ),
//                   Center(
//                     child: Stack(
//                       children: [
//                         Image(
//                           image: AssetImage('images/gif-LOGOchao.gif'),
//                           // width: 200,
//                         ),
//                         Positioned(
//                           top: 5,
//                           // right: 0,
//                           left: 1,
//                           child: SizedBox(
//                             width: 100,
//                             height: 100,
//                             child: DecoratedBox(
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 // วงแหวนไล่เฉด
//                                 // gradient: const SweepGradient(
//                                 //   colors: [
//                                 //     Color(0xFF6EA8FF),
//                                 //     Color(0xFFA78BFA),
//                                 //     Color(0xFF5EEAD4),
//                                 //     Color(0xFF6EA8FF),
//                                 //   ],
//                                 //   stops: [0.0, 0.5, 0.85, 1.0],
//                                 // ),
//                                 // boxShadow: [
//                                 //   BoxShadow(
//                                 //     color: Colors.black
//                                 //         .withOpacity(0.15),
//                                 //     blurRadius: 20,
//                                 //     offset: const Offset(0, 10),
//                                 //   ),
//                                 // ],
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(
//                                     6), // ความหนาของ “ขอบวงแหวน”
//                                 child: ClipOval(
//                                   child: Image.network(
//                                     //  Image.asset(
//                                     // 'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExeHk0cXZncDgwaHlrMnBxeHZydHNwbTA5NWhyejh2MGlycjZvd2pjeCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/t9Qr1B9q0bm9QnsKXu/giphy.gif',
//                                     'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExNjJ6OTJhNHE3NGJqNjljZDM2aXZncDFxY216M24zZDN2YWNqcXB3MCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/aWOeexAloWLQpVggC6/giphy.gif',
//                                     // 'images/0001.gif', // ให้ตรงกับ pubspec.yaml
//                                     // key: ValueKey(
//                                     //     _gifTick), // 👈 สำคัญ: เปลี่ยนเมื่อเริ่มโหลดใหม่
//                                     fit: BoxFit.cover,
//                                     gaplessPlayback: false, // ให้รีสตาร์ทจริง ๆ
//                                     // ใส่เฟดอินนิดนึงให้ดูเนียน
//                                     frameBuilder:
//                                         (context, child, frame, wasSync) {
//                                       return AnimatedOpacity(
//                                         opacity: frame == null ? 0 : 1,
//                                         duration:
//                                             const Duration(milliseconds: 220),
//                                         child: child,
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                   // const Image(
//                   //   image: AssetImage('images/gif-LOGOchao.gif'),
//                   //   width: 150,
//                   // ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'กำลังเตรียมความพร้อม...',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     'ไปหน้าแรกภายใน $_secondsRemaining วินาที',
//                     style: const TextStyle(fontSize: 15, color: Colors.black54),
//                   ),
//                   const SizedBox(height: 30),
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.fast_forward),
//                     label: const Text('ไปหน้าแรกทันที'),
//                     onPressed: _navigateToHome,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ////////-------------------->
// class GridBoxBackground extends StatelessWidget {
//   const GridBoxBackground({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: _GridBoxPainter(),
//       size: MediaQuery.of(context).size,
//     );
//   }
// }

// class _GridBoxPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFFE7EDF5)
//       ..style = PaintingStyle.fill;

//     const double spacing = 50.0;
//     const double boxSize = 20.0;

//     for (double y = 0; y < size.height; y += spacing) {
//       for (double x = 0; x < size.width; x += spacing) {
//         final rect = Rect.fromLTWH(x, y, boxSize, boxSize);
//         canvas.drawRect(rect, paint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// ////////-------------------->
// class DotPatternBackground extends StatelessWidget {
//   const DotPatternBackground({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: _DotPainter(),
//       size: MediaQuery.of(context).size,
//     );
//   }
// }

// class _DotPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFFCDD5E0).withOpacity(0.2)
//       ..style = PaintingStyle.fill;

//     const double spacing = 40.0;
//     for (double y = 0; y < size.height; y += spacing) {
//       for (double x = 0; x < size.width; x += spacing) {
//         canvas.drawCircle(Offset(x, y), 2, paint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// ////////---------------------------------------->
// class DiagonalBackground extends StatelessWidget {
//   const DiagonalBackground({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: _DiagonalPainter(),
//       size: MediaQuery.of(context).size,
//     );
//   }
// }

// class _DiagonalPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;

//     // Layer 1
//     paint.color = const Color(0xFFECEFF5);
//     final path1 = Path()
//       ..moveTo(0, size.height * 0.3)
//       ..lineTo(size.width, size.height * 0.2)
//       ..lineTo(size.width, size.height)
//       ..lineTo(0, size.height)
//       ..close();
//     canvas.drawPath(path1, paint);

//     // Layer 2
//     paint.color = const Color(0xFFDDE3ED);
//     final path2 = Path()
//       ..moveTo(0, size.height * 0.5)
//       ..lineTo(size.width, size.height * 0.35)
//       ..lineTo(size.width, size.height)
//       ..lineTo(0, size.height)
//       ..close();
//     canvas.drawPath(path2, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// ////////---------------------------------------->
// class DiagonalBackground2 extends StatelessWidget {
//   const DiagonalBackground2({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: _DiagonalPainter2(),
//       size: MediaQuery.of(context).size,
//     );
//   }
// }

// class _DiagonalPainter2 extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;

//     // Layer 1 – ลายเฉียงต่ำ
//     paint.color = const Color(0xFFECEFF5);
//     final path1 = Path()
//       ..moveTo(0, size.height * 0.85)
//       ..lineTo(size.width, size.height * 0.75)
//       ..lineTo(size.width, size.height)
//       ..lineTo(0, size.height)
//       ..close();
//     canvas.drawPath(path1, paint);

//     // Layer 2 – ซ้อนให้มีมิติ
//     paint.color = const Color(0xFFDDE3ED);
//     final path2 = Path()
//       ..moveTo(0, size.height * 0.95)
//       ..lineTo(size.width, size.height * 0.85)
//       ..lineTo(size.width, size.height)
//       ..lineTo(0, size.height)
//       ..close();
//     canvas.drawPath(path2, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// ///////---------------------------------------->
// class DiagonalBackground3 extends StatelessWidget {
//   const DiagonalBackground3({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: _DiagonalPainter2(),
//       size: MediaQuery.of(context).size,
//     );
//   }
// }

// class _DiagonalPainter3 extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;

//     // Layer 1 – ลายเฉียงต่ำ
//     paint.color = const Color(0xFFECEFF5);
//     final path1 = Path()
//       ..moveTo(0, size.height * 0.35)
//       ..lineTo(size.width, size.height * 0.25)
//       ..lineTo(size.width, size.height * 0.25)
//       ..lineTo(0, size.height * 0.25)
//       ..close();
//     canvas.drawPath(path1, paint);

//     // Layer 2 – ซ้อนให้มีมิติ
//     paint.color = const Color(0xFFDDE3ED);
//     final path2 = Path()
//       ..moveTo(0, size.height * 0.95)
//       ..lineTo(size.width, size.height * 0.35)
//       ..lineTo(size.width, size.height * 0.25)
//       ..lineTo(0, size.height * 0.25)
//       ..close();
//     canvas.drawPath(path2, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
