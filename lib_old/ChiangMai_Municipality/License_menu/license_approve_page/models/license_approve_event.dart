// ============================================================================
// license_approve_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ============================================================================

sealed class LicenseApproveEvent {
  const LicenseApproveEvent();
}

class LicenseApproveErrorEvent extends LicenseApproveEvent {
  final String message;
  const LicenseApproveErrorEvent(this.message);
}


class LicenseApproveNavigateEvent extends LicenseApproveEvent {
  final String route;
  final String? routeData;
  const LicenseApproveNavigateEvent(this.route, {this.routeData});
}
