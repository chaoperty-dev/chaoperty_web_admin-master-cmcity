// ============================================================================
// license_submit_approval_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ============================================================================

sealed class LicenseSubmitApprovalEvent {
  const LicenseSubmitApprovalEvent();
}

class LicenseSubmitApprovalErrorEvent extends LicenseSubmitApprovalEvent {
  final String message;
  const LicenseSubmitApprovalErrorEvent(this.message);
}

class LicenseSubmitApprovalNavigateEvent extends LicenseSubmitApprovalEvent {
  final String route;
  final String? routeData;
  const LicenseSubmitApprovalNavigateEvent(this.route, {this.routeData});
}

/// นำทางไปหน้า detail (Payment Detail Step 1 / Step 2)
class LicenseSubmitApprovalNavigateDetailEvent extends LicenseSubmitApprovalEvent {
  final String paymentUuid;
  final String title;
  const LicenseSubmitApprovalNavigateDetailEvent({
    required this.paymentUuid,
    this.title = 'รายละเอียดส่งคำร้องขออนุมัติ',
  });
}

/// แจ้งเตือนเมื่อสร้าง Payment draft สำเร็จ
class LicenseSubmitApprovalCreatedEvent extends LicenseSubmitApprovalEvent {
  final dynamic payment; // SubmitApprovalDetail (หลีกเลี่ยง circular import)
  const LicenseSubmitApprovalCreatedEvent(this.payment);
}

/// แจ้งเตือนเมื่อบันทึกส่งคำร้องขออนุมัติ (pay) สำเร็จ
class LicenseSubmitApprovalPaidEvent extends LicenseSubmitApprovalEvent {
  final dynamic payment; // SubmitApprovalDetail
  const LicenseSubmitApprovalPaidEvent(this.payment);
}
