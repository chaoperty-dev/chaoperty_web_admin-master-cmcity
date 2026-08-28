// ============================================================================
// menu_version.dart
// ============================================================================
// เวอร์ชันของแต่ละเมนู (เริ่มต้น 2.0.0.0)
// - เก็บรวมศูนย์เดียวเพื่อให้ดู/ปรับเวอร์ชันแต่ละเมนูได้ง่าย
// - แต่ละเมนูมีเวอร์ชันของตัวเอง (แก้ค่าใน _versions ได้อิสระ)
// ============================================================================

import 'package:flutter/material.dart';

/// แมปชื่อเมนู → เวอร์ชัน (ปรับค่าแต่ละเมนูได้อิสระ)
class MenuVersions {
  MenuVersions._();

  static const Map<String, String> _versions = {
    'license': '2.0.0.0',
    'area': '2.0.0.0',
    'tenant': '2.0.0.0',
    'registration': '2.0.0.0',
    'report': '2.0.0.0',
    'setting': '2.0.0.0',
    'profile': '2.0.0.0',
  };

  /// อ่านเวอร์ชันของเมนู (คืน '2.0.0.0' ถ้าไม่มีในแมป)
  static String of(String key) => _versions[key] ?? '2.0.0.0';
}

/// Footer แสดงเวอร์ชันเมนู (ด้านล่างของหน้าหลักแต่ละเมนู)
class MenuVersionFooter extends StatelessWidget {
  final String menuKey;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  const MenuVersionFooter({
    super.key,
    required this.menuKey,
    this.padding = const EdgeInsets.only(right: 12, top: 2, bottom: 4),
    this.backgroundColor = const Color(0xFFF5F7FA),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      color: backgroundColor,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          'v${MenuVersions.of(menuKey)}',
          style: const TextStyle(
            fontSize: 8,
            color: Color.fromARGB(255, 181, 192, 204),
            letterSpacing: .2,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// แมป route → menu key (เฉพาะหน้าหลักของแต่ละเมนู)
/// คืน null สำหรับ route ที่ไม่ใช่หน้าหลัก (ไม่แสดง footer)
String? menuKeyForLocation(String location) {
  if (location.startsWith('/report/')) return 'report';
  const map = <String, String>{
    '/contract': 'license',
    '/payment': 'license',
    '/attach': 'license',
    '/verify': 'license',
    '/fact-check': 'license',
    '/approve': 'license',
    '/submit-approval': 'license',
    '/announce': 'license',
    '/area': 'area',
    '/tenant': 'tenant',
    '/registration': 'registration',
    '/setting': 'setting',
    '/profile/manage': 'profile',
  };
  return map[location];
}
