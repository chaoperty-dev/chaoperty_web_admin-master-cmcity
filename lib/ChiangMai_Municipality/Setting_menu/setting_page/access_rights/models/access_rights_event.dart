// ============================================================================
// access_rights_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ใช้ sealed class เพื่อให้ exhaustive switch ได้
// ============================================================================

sealed class AccessRightsEvent {
  const AccessRightsEvent();
}

/// แจ้งเตือน error (เช่น โหลด/บันทึกล้มเหลว)
class AccessRightsErrorEvent extends AccessRightsEvent {
  final String message;
  const AccessRightsErrorEvent(this.message);
}

/// แจ้งเตือน success (เช่น บันทึกสำเร็จ)
class AccessRightsSuccessEvent extends AccessRightsEvent {
  final String message;
  const AccessRightsSuccessEvent(this.message);
}

/// ให้ View เปิด dialog เพิ่มผู้ใช้
class AccessRightsOpenCreateEvent extends AccessRightsEvent {
  const AccessRightsOpenCreateEvent();
}

/// ให้ View เปิด dialog แก้ไขผู้ใช้
class AccessRightsOpenEditEvent extends AccessRightsEvent {
  final String userUuid;
  const AccessRightsOpenEditEvent(this.userUuid);
}

/// ให้ View เปิด dialog จัดการลายเซ็น
class AccessRightsOpenSignatureEvent extends AccessRightsEvent {
  final String userUuid;
  const AccessRightsOpenSignatureEvent(this.userUuid);
}
