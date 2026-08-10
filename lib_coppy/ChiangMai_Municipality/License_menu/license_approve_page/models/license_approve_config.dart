// ============================================================================
// license_approve_config.dart
// ============================================================================
// Config / Params
// ============================================================================

class LicenseApproveConfig {
  final String title;
  final String? routeData;
  final int? serTitle;
  final bool readOnly;

  const LicenseApproveConfig({
    this.title = 'อนุมัติคำขอ',
    this.routeData,
    this.serTitle,
    this.readOnly = false,
  });
}
