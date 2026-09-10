// ============================================================================
// license_payment_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ============================================================================

sealed class LicensePaymentEvent {
  const LicensePaymentEvent();
}

class LicensePaymentErrorEvent extends LicensePaymentEvent {
  final String message;
  const LicensePaymentErrorEvent(this.message);
}


class LicensePaymentNavigateEvent extends LicensePaymentEvent {
  final String route;
  final String? routeData;
  const LicensePaymentNavigateEvent(this.route, {this.routeData});
}
