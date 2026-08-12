// ============================================================================
// license_announce_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ============================================================================

sealed class LicenseAnnounceEvent {
  const LicenseAnnounceEvent();
}

class LicenseAnnounceErrorEvent extends LicenseAnnounceEvent {
  final String message;
  const LicenseAnnounceErrorEvent(this.message);
}

class LicenseAnnounceSuccessEvent extends LicenseAnnounceEvent {
  final String message;
  const LicenseAnnounceSuccessEvent(this.message);
}

class LicenseAnnounceOpenAddEvent extends LicenseAnnounceEvent {
  const LicenseAnnounceOpenAddEvent();
}

class LicenseAnnounceOpenEditEvent extends LicenseAnnounceEvent {
  final String announcementSer;
  const LicenseAnnounceOpenEditEvent(this.announcementSer);
}

class LicenseAnnounceOpenViewEvent extends LicenseAnnounceEvent {
  final String announcementUuid;
  const LicenseAnnounceOpenViewEvent(this.announcementUuid);
}

class LicenseAnnounceOpenAddZoneEvent extends LicenseAnnounceEvent {
  const LicenseAnnounceOpenAddZoneEvent();
}
