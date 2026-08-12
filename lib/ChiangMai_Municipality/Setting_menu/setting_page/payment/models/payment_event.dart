// ============================================================================
// payment_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ============================================================================

sealed class PaymentEvent {
  const PaymentEvent();
}

class PaymentErrorEvent extends PaymentEvent {
  final String message;
  const PaymentErrorEvent(this.message);
}

class PaymentSuccessEvent extends PaymentEvent {
  final String message;
  const PaymentSuccessEvent(this.message);
}

class PaymentOpenAddEvent extends PaymentEvent {
  const PaymentOpenAddEvent();
}

class PaymentOpenEditEvent extends PaymentEvent {
  final String paymentSer;
  const PaymentOpenEditEvent(this.paymentSer);
}

class PaymentOpenSlipEvent extends PaymentEvent {
  final String paymentSer;
  const PaymentOpenSlipEvent(this.paymentSer);
}

class PaymentOpenAddPayTypeEvent extends PaymentEvent {
  const PaymentOpenAddPayTypeEvent();
}

class PaymentOpenAddBankEvent extends PaymentEvent {
  const PaymentOpenAddBankEvent();
}

class PaymentOpenAddBankTypeEvent extends PaymentEvent {
  const PaymentOpenAddBankTypeEvent();
}
