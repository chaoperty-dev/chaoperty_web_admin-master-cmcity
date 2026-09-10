// ============================================================================
// license_attach_config.dart
// ============================================================================
// Config / Params
// ============================================================================

class LicenseAttachConfig {
  final String title;
  final String? routeData;
  final int? serTitle;
  final bool readOnly;

  const LicenseAttachConfig({
    this.title = 'อนุมัติคำขอ',
    this.routeData,
    this.serTitle,
    this.readOnly = false,
  });
}
