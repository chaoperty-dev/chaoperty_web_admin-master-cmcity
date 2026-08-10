// ============================================================================
// area_menu_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ============================================================================

sealed class AreaMenuEvent {
  const AreaMenuEvent();
}

class AreaMenuErrorEvent extends AreaMenuEvent {
  final String message;
  const AreaMenuErrorEvent(this.message);
}


class AreaMenuNavigateEvent extends AreaMenuEvent {
  final String route;
  final String? routeData;
  const AreaMenuNavigateEvent(this.route, {this.routeData});
}
