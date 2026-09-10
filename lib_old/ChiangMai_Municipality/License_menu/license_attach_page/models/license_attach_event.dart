// ============================================================================
// license_attach_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ============================================================================

sealed class LicenseAttachEvent {
  const LicenseAttachEvent();
}

class LicenseAttachErrorEvent extends LicenseAttachEvent {
  final String message;
  const LicenseAttachErrorEvent(this.message);
}


class LicenseAttachNavigateEvent extends LicenseAttachEvent {
  final String route;
  final String? routeData;
  const LicenseAttachNavigateEvent(this.route, {this.routeData});
}
