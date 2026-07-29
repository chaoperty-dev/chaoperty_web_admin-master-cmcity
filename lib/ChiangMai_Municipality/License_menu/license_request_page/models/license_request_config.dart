// ============================================================================
// license_request_config.dart
// ============================================================================
// Config / Params
// ============================================================================

class LicenseRequestConfig {
  final String title;
  final String? routeData;
  final int? serTitle;
  final bool readOnly;

  const LicenseRequestConfig({
    this.title = 'คำขอต่อสัญญา',
    this.routeData,
    this.serTitle,
    this.readOnly = false,
  });
}
