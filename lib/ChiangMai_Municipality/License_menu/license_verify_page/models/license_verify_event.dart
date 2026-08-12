// ============================================================================
// license_verify_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ============================================================================

sealed class LicenseVerifyEvent {
  const LicenseVerifyEvent();
}

class LicenseVerifyErrorEvent extends LicenseVerifyEvent {
  final String message;
  const LicenseVerifyErrorEvent(this.message);
}


class LicenseVerifyNavigateEvent extends LicenseVerifyEvent {
  final String route;
  final String? routeData;
  const LicenseVerifyNavigateEvent(this.route, {this.routeData});
}
