// ============================================================================
// registration_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ============================================================================

sealed class RegistrationEvent {
  const RegistrationEvent();
}

class RegistrationErrorEvent extends RegistrationEvent {
  final String message;
  const RegistrationErrorEvent(this.message);
}

class RegistrationNavigateEvent extends RegistrationEvent {
  final String route;
  final String? routeData;
  const RegistrationNavigateEvent(this.route, {this.routeData});
}
