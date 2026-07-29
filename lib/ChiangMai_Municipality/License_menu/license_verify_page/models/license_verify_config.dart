// ============================================================================
// license_verify_config.dart
// ============================================================================
// Config / Params
// ============================================================================

class LicenseverifyConfig {
  final String title;
  final String? routeData;
  final int? serTitle;
  final bool readOnly;

  const LicenseverifyConfig({
    this.title = 'อนุมัติคำขอ',
    this.routeData,
    this.serTitle,
    this.readOnly = false,
  });
}
