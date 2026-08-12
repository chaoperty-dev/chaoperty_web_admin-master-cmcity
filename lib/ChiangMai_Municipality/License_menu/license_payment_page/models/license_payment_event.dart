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

/// นำทางไปหน้า detail (Payment Detail Step 1 / Step 2)
class LicensePaymentNavigateDetailEvent extends LicensePaymentEvent {
  final String paymentUuid;
  final String title;
  const LicensePaymentNavigateDetailEvent({
    required this.paymentUuid,
    this.title = 'รายละเอียดการรับชำระ',
  });
}

/// แจ้งเตือนเมื่อสร้าง Payment draft สำเร็จ
class LicensePaymentCreatedEvent extends LicensePaymentEvent {
  final dynamic payment; // PaymentDetail (หลีกเลี่ยง circular import)
  const LicensePaymentCreatedEvent(this.payment);
}

/// แจ้งเตือนเมื่อบันทึกการรับชำระ (pay) สำเร็จ
class LicensePaymentPaidEvent extends LicensePaymentEvent {
  final dynamic payment; // PaymentDetail
  const LicensePaymentPaidEvent(this.payment);
}
