// ============================================================================
// tenant_license_config.dart
// ============================================================================
// Config / Params
// ============================================================================

class TenantLicenseConfig {
  final String title;
  final String? routeData;
  final int? serTitle;
  final bool readOnly;

  const TenantLicenseConfig({
    this.title = 'ผู้ได้รับใบอนุญาต',
    this.routeData,
    this.serTitle,
    this.readOnly = false,
  });
}
