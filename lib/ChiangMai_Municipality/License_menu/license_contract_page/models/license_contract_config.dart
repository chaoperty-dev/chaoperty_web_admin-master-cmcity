// ============================================================================
// license_contract_config.dart
// ============================================================================
// Config / Params ที่ใช้ตอนเปิด Dialog (ค่าเริ่มต้นต่างๆ)
// ============================================================================

import '../../../Model/Properties_Model.dart';

class LicenseContractConfig {
  final bool readOnly;
  final List<PropertiesModel>? properties;
  final List<String>? initialPersonValues;
  final List<String>? initialShopValues;
  final List<String>? initialShopSubValues;
  final List<Map<String, dynamic>>? initialCidValues;

  /// ข้อความประกาศเริ่มต้น (fallback) — ถ้า null จะดึงจาก API อัตโนมัติ
  final String? announcementMessage;
  final String title;

  /// 1 = ทำสัญญาใหม่, 2 = Re-Contact (ต้องส่งมาจาก caller)
  final int moduleId;

  /// เลขที่สัญญาเดิม (ใช้เฉพาะกรณี Re-Contact / moduleId == 2)
  final String? leaseNumber;

  const LicenseContractConfig({
    this.readOnly = false,
    this.properties,
    this.initialPersonValues,
    this.initialShopValues,
    this.initialShopSubValues,
    this.initialCidValues,
    this.announcementMessage,
    this.title = 'ผู้เช่า',
    this.moduleId = 1,
    this.leaseNumber,
  });
}
