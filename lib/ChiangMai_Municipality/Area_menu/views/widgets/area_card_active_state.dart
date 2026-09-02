// ============================================================================
// area_card_active_state.dart
// ============================================================================
// Active card state — track which AreaMenuBoxCard is "lifted" (callout open)
// - Singleton ValueNotifier<String?> เก็บ key ของ block ที่กดอยู่
// - Key = composite เดียวกับ ValueKey ใน AreaMenuCardGrid (aser|zone|subzone|lock)
// - Card listen → rebuild เมื่อ state เปลี่ยน (เพื่อใส่ shadow/border ลอย)
// - Callout clear → ปิด callout ก็ clear state พร้อมกัน
// ============================================================================

import 'package:flutter/foundation.dart';

class AreaCardActiveState {
  AreaCardActiveState._();
  static final ValueNotifier<String?> instance = ValueNotifier<String?>(null);

  static void activate(String key) => instance.value = key;
  static void clear() => instance.value = null;

  /// คำนวณ key เสถียรจาก model — ต้องตรงกับที่ AreaMenuCardGrid ใช้
  static String keyOf(Map<String, dynamic> model) {
    return [
      model['aser'] ?? '',
      model['zone'] ?? '',
      model['subzone'] ?? '',
      model['lock'] ?? '',
    ].join('|');
  }
}
