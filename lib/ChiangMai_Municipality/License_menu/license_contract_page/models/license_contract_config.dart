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
  final String? announcementMessage;
  final String title;

  const LicenseContractConfig({
    this.readOnly = false,
    this.properties,
    this.initialPersonValues,
    this.initialShopValues,
    this.initialShopSubValues,
    this.initialCidValues,
    this.announcementMessage,
    this.title = 'ผู้เช่า',
  });
}
