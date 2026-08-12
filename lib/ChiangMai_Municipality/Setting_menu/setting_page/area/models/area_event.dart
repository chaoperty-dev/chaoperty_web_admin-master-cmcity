// ============================================================================
// area_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ใช้ sealed class เพื่อให้ exhaustive switch ได้
// ============================================================================

sealed class AreaEvent {
  const AreaEvent();
}

class AreaErrorEvent extends AreaEvent {
  final String message;
  const AreaErrorEvent(this.message);
}

class AreaSuccessEvent extends AreaEvent {
  final String message;
  const AreaSuccessEvent(this.message);
}
