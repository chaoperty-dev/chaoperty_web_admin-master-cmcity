import 'dart:math';
import 'package:flutter/material.dart';

// ใช้แทนฟังก์ชัน viewpage เดิม
class ViewPageBadge extends StatefulWidget {
  final dynamic ser; // ใช้ผูกสี/ดีไซน์ให้คงที่ต่อหน้า
  final VoidCallback? onTap; // ถ้าต้องการคลิกไปหน้าอื่น

  const ViewPageBadge({super.key, required this.ser, this.onTap});

  @override
  State<ViewPageBadge> createState() => _ViewPageBadgeState();
}

class _ViewPageBadgeState extends State<ViewPageBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final int seed;

  // โทนสีหรู ๆ (เลือก 1 คู่ต่อ badge จาก seed)
  static const palettes = <List<Color>>[
    [Color(0xFF7C3AED), Color(0xFFF59E0B)], // purple → amber
    [Color(0xFF06B6D4), Color(0xFF6366F1)], // cyan → indigo
    [Color(0xFFEC4899), Color(0xFFF97316)], // pink → orange
    [Color(0xFF22C55E), Color(0xFF0EA5E9)], // green → sky
  ];
  // static const palettes = <List<Color>>[
  //   [Color(0xFFEDE9FE), Color(0xFFD8B4FE)], // very light purple → lavender
  //   [Color(0xFFE0F2FE), Color(0xFFBAE6FD)], // light sky → baby blue
  //   [Color(0xFFFCE7F3), Color(0xFFFBCFE8)], // rose → pink pastel
  //   [Color(0xFFD1FAE5), Color(0xFFA7F3D0)], // mint green → pastel green
  //   [Color(0xFFFFF7ED), Color(0xFFFDE68A)], // off white → soft amber
  // ];

  @override
  void initState() {
    super.initState();
    // ทำ seed คงที่ต่อ ser เพื่อไม่สุ่มทุก build
    seed = widget.ser.hashCode;
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = palettes[seed.abs() % palettes.length];
    final c1 = palette.first;
    final c2 = palette.last;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _ac,
          builder: (context, _) {
            // เคลื่อน gradient เบา ๆ
            final t = _ac.value;
            final begin = Alignment(-1 + t, -1);
            final end = Alignment(1 - t, 1);

            return Container(
              height: 35,
              width: 110,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                // กรอบขาวโปร่งนิด ๆ
                border:
                    Border.all(color: Colors.white.withOpacity(0.85), width: 2),
                // เงานุ่ม
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                gradient: LinearGradient(
                  begin: begin,
                  end: end,
                  colors: [c1, c2],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // วงกลม glow รองโลโก้
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // เบลอสีรองเพื่อทำ glow
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.65),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                      const Image(
                        image: AssetImage('images/chaoperty_dark.png'),
                        height: 20,
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  // // ข้อความ/สถานะ (ปรับได้)
                  // Expanded(
                  //   child: Text(
                  //     'Chaoperty',
                  //     maxLines: 1,
                  //     overflow: TextOverflow.ellipsis,
                  //     style: const TextStyle(
                  //       color: Colors.white,
                  //       fontWeight: FontWeight.w600,
                  //       letterSpacing: .4,
                  //     ),
                  //   ),
                  // ),
                  // แท็กขาวเล็ก ๆ ให้ตัดกับพื้น
                  // SizedBox(
                  //   width: 25,
                  //   height: 25,
                  //   child: ClipOval(
                  //     child: Image.network(
                  //       'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExNjJ6OTJhNHE3NGJqNjljZDM2aXZncDFxY216M24zZDN2YWNqcXB3MCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/aWOeexAloWLQpVggC6/giphy.gif',
                  //       fit: BoxFit.cover,
                  //       gaplessPlayback: false,
                  //       frameBuilder: (context, child, frame, wasSync) =>
                  //           AnimatedOpacity(
                  //         opacity: frame == null ? 0 : 1,
                  //         duration: const Duration(milliseconds: 220),
                  //         child: child,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Container(
                  //   padding:
                  //       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white.withOpacity(0.90),
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child:
                  //    const Text(
                  //     'LIVE',
                  //     style: TextStyle(
                  //       color: Colors.black87,
                  //       fontSize: 11,
                  //       fontWeight: FontWeight.w700,
                  //       letterSpacing: .6,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
