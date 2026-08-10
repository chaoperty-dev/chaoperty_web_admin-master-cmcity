import 'package:flutter/material.dart';

/// โมเดลเมนู navigation ที่โหลดจาก JSON
class NavigationMenuModel {
  final NavigationHeaderModel header;
  final List<NavigationItemModel> items;

  const NavigationMenuModel({
    required this.header,
    required this.items,
  });

  factory NavigationMenuModel.fromJson(Map<String, dynamic> json) {
    return NavigationMenuModel(
      header: NavigationHeaderModel.fromJson(
          json['header'] as Map<String, dynamic>? ?? {}),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => NavigationItemModel.fromJson(e as Map<String, dynamic>))
          .where((e) => e.status)
          .toList(),
    );
  }
}

class NavigationHeaderModel {
  final String title;
  final IconData? icon;

  const NavigationHeaderModel({
    required this.title,
    this.icon,
  });

  factory NavigationHeaderModel.fromJson(Map<String, dynamic> json) {
    return NavigationHeaderModel(
      title: json['title'] as String? ?? 'Chaoperty',
      icon: _parseIcon(json['icon'] as String?),
    );
  }
}

class NavigationItemModel {
  final NavigationItemType type;
  final String label;
  final String? route;
  final IconData? icon;
  final IconData? activeIcon;
  final bool status;
  final bool expandedByDefault;
  final List<NavigationChildModel> children;

  const NavigationItemModel({
    required this.type,
    required this.label,
    this.route,
    this.icon,
    this.activeIcon,
    this.status = true,
    this.expandedByDefault = false,
    this.children = const [],
  });

  factory NavigationItemModel.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] as String? ?? 'item').toNavigationItemType();
    final rawChildren = json['children'] as List<dynamic>? ?? [];

    return NavigationItemModel(
      type: type,
      label: json['label'] as String? ?? '',
      route: json['route'] as String?,
      icon: _parseIcon(json['icon'] as String?),
      activeIcon: _parseIcon(json['activeIcon'] as String?),
      status: json['status'] as bool? ?? true,
      expandedByDefault: json['expandedByDefault'] as bool? ?? false,
      children: rawChildren
          .map((e) => NavigationChildModel.fromJson(e as Map<String, dynamic>))
          .where((e) => e.status)
          .toList(),
    );
  }

  bool get isGroup => type == NavigationItemType.group;
}

class NavigationChildModel {
  final String label;
  final String route;
  final IconData? icon;
  final IconData? activeIcon;
  final bool status;

  const NavigationChildModel({
    required this.label,
    required this.route,
    this.icon,
    this.activeIcon,
    this.status = true,
  });

  factory NavigationChildModel.fromJson(Map<String, dynamic> json) {
    return NavigationChildModel(
      label: json['label'] as String? ?? '',
      route: json['route'] as String? ?? '',
      icon: _parseIcon(json['icon'] as String?),
      activeIcon: _parseIcon(json['activeIcon'] as String?),
      status: json['status'] as bool? ?? true,
    );
  }
}

enum NavigationItemType { item, group }

extension NavigationItemTypeExtension on NavigationItemType {
  static NavigationItemType fromString(String value) {
    switch (value) {
      case 'group':
        return NavigationItemType.group;
      case 'item':
      default:
        return NavigationItemType.item;
    }
  }
}

extension NavigationItemTypeParse on String {
  NavigationItemType toNavigationItemType() {
    switch (this) {
      case 'group':
        return NavigationItemType.group;
      case 'item':
      default:
        return NavigationItemType.item;
    }
  }
}

/// แปลงชื่อ icon จาก JSON เป็น IconData ของ Material Icons
///
/// รองรับทั้งชื่อเต็ม เช่น `people_outline`, `people_rounded`, `people`
/// และ base name เช่น `people` แล้ว auto เติม suffix
IconData? _parseIcon(String? name) {
  if (name == null || name.isEmpty) return null;

  // 1) ลองหาตรงตัวก่อน (เช่น people_outline)
  final exact = _materialIconMap[name];
  if (exact != null) return exact;

  // 2) ถ้าไม่เจอ ให้ลบ suffix แล้วหา base icon
  final baseName = name
      .replaceAll('_outlined', '')
      .replaceAll('_rounded', '')
      .replaceAll('_sharp', '');

  final outlined = name.endsWith('_outlined');
  final rounded = name.endsWith('_rounded');
  final sharp = name.endsWith('_sharp');

  final baseIcon = _materialIconMap[baseName];
  if (baseIcon == null) return null;

  if (outlined) return _toOutlined(baseIcon);
  if (rounded) return _toRounded(baseIcon);
  if (sharp) return _toSharp(baseIcon);
  return baseIcon;
}

IconData? _toOutlined(IconData icon) {
  final key = '${icon.fontFamily}_${icon.codePoint}_outlined';
  return _outlinedIconMap[key];
}

IconData? _toRounded(IconData icon) {
  final key = '${icon.fontFamily}_${icon.codePoint}_rounded';
  return _roundedIconMap[key];
}

IconData? _toSharp(IconData icon) {
  final key = '${icon.fontFamily}_${icon.codePoint}_sharp';
  return _sharpIconMap[key];
}

// ═══════════════════════════════════════════════════════════════════════
// Icon mapping — เก็บทั้ง base + outlined + rounded + sharp
// ═══════════════════════════════════════════════════════════════════════

const Map<String, IconData> _materialIconMap = <String, IconData>{
  // base
  'people': Icons.people,
  'description': Icons.description,
  'edit_note': Icons.edit_note,
  'payments': Icons.payments,
  'attach_file': Icons.attach_file,
  'rule': Icons.rule,
  'search': Icons.search,
  'check_circle': Icons.check_circle,
  'campaign': Icons.campaign,
  'app_registration': Icons.app_registration,
  'manage_accounts': Icons.manage_accounts,
  'bolt': Icons.bolt,
  'map': Icons.map,
  'settings': Icons.settings,
  // outlined (exact name)
  'people_outline': Icons.people_outline,
  'description_outlined': Icons.description_outlined,
  'edit_note_outlined': Icons.edit_note_outlined,
  'payments_outlined': Icons.payments_outlined,
  'attach_file_outlined': Icons.attach_file_outlined,
  'rule_outlined': Icons.rule_outlined,
  'search_outlined': Icons.search_outlined,
  'check_circle_outline': Icons.check_circle_outline,
  'campaign_outlined': Icons.campaign_outlined,
  'app_registration_outlined': Icons.app_registration_outlined,
  'manage_accounts_outlined': Icons.manage_accounts_outlined,
  'bolt_outlined': Icons.bolt_outlined,
  'map_outlined': Icons.map_outlined,
  'settings_outlined': Icons.settings_outlined,
};

// สำหรับ suffix _outlined/_rounded/_sharp ที่ไม่มีใน _materialIconMap
const Map<String, IconData> _outlinedIconMap = <String, IconData>{
  'MaterialIcons_0xe7ef_outlined': Icons.people_outline,
  'MaterialIcons_0xe873_outlined': Icons.description_outlined,
  'MaterialIcons_0xe25a_outlined': Icons.edit_note_outlined,
  'MaterialIcons_0xe8a1_outlined': Icons.payments_outlined,
  'MaterialIcons_0xe226_outlined': Icons.attach_file_outlined,
  'MaterialIcons_0xf0c5_outlined': Icons.rule_outlined,
  'MaterialIcons_0xe8b6_outlined': Icons.search_outlined,
  'MaterialIcons_0xe86c_outlined': Icons.check_circle_outline,
  'MaterialIcons_0xe7f7_outlined': Icons.campaign_outlined,
  'MaterialIcons_0xe5fe_outlined': Icons.app_registration_outlined,
  'MaterialIcons_0xe8f9_outlined': Icons.manage_accounts_outlined,
  'MaterialIcons_0xe3b0_outlined': Icons.bolt_outlined,
};

const Map<String, IconData> _roundedIconMap = <String, IconData>{};
const Map<String, IconData> _sharpIconMap = <String, IconData>{};
