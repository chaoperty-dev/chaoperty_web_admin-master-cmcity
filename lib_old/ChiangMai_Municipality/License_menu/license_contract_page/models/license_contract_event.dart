// ============================================================================
// license_contract_event.dart
// ============================================================================
// Event ที่ ViewModel ส่งออกมาให้ View ฟัง (ผ่าน Stream)
// - errorMessage: ให้ View แสดง SnackBar
// - saved:        ให้ View ปิด Dialog พร้อมส่ง result กลับ
// ============================================================================

import 'license_contract_result.dart';

sealed class LicenseContractEvent {
  const LicenseContractEvent();
}

class LicenseContractErrorEvent extends LicenseContractEvent {
  final String message;
  const LicenseContractErrorEvent(this.message);
}

class LicenseContractSavedEvent extends LicenseContractEvent {
  final LicenseContractResult result;
  const LicenseContractSavedEvent(this.result);
}
