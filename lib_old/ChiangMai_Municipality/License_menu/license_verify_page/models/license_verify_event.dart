// ============================================================================
// license_verify_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ============================================================================

sealed class LicenseverifyEvent {
  const LicenseverifyEvent();
}

class LicenseverifyErrorEvent extends LicenseverifyEvent {
  final String message;
  const LicenseverifyErrorEvent(this.message);
}


class LicenseverifyNavigateEvent extends LicenseverifyEvent {
  final String route;
  final String? routeData;
  const LicenseverifyNavigateEvent(this.route, {this.routeData});
}
