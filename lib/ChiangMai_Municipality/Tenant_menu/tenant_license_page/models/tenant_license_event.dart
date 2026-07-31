// ============================================================================
// tenant_license_event.dart
// ============================================================================
// Events ที่ ViewModel ส่งให้ View ฟัง (ผ่าน Stream)
// ============================================================================

sealed class TenantLicenseEvent {
  const TenantLicenseEvent();
}

class TenantLicenseErrorEvent extends TenantLicenseEvent {
  final String message;
  const TenantLicenseErrorEvent(this.message);
}

class TenantLicenseNavigateEvent extends TenantLicenseEvent {
  final String route;
  final String? routeData;
  final String? nameShopIndex;
  final String? status;

  const TenantLicenseNavigateEvent(
    this.route, {
    this.routeData,
    this.nameShopIndex,
    this.status,
  });
}
