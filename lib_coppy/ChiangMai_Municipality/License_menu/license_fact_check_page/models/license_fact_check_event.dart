// ============================================================================
// license_fact_check_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ============================================================================

sealed class LicensefactcheckEvent {
  const LicensefactcheckEvent();
}

class LicensefactcheckErrorEvent extends LicensefactcheckEvent {
  final String message;
  const LicensefactcheckErrorEvent(this.message);
}


class LicensefactcheckNavigateEvent extends LicensefactcheckEvent {
  final String route;
  final String? routeData;
  const LicensefactcheckNavigateEvent(this.route, {this.routeData});
}
