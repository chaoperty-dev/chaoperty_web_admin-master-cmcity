// ============================================================================
// license_request_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ============================================================================

sealed class LicenseRequestEvent {
  const LicenseRequestEvent();
}

class LicenseRequestErrorEvent extends LicenseRequestEvent {
  final String message;
  const LicenseRequestErrorEvent(this.message);
}

/// ให้ View เปิด popup สร้างคำขอ (LicenseContractPage)
class LicenseRequestOpenCreatePopupEvent extends LicenseRequestEvent {
  const LicenseRequestOpenCreatePopupEvent();
}

class LicenseRequestNavigateEvent extends LicenseRequestEvent {
  final String route;
  final String? routeData;
  const LicenseRequestNavigateEvent(this.route, {this.routeData});
}
