// ============================================================================
// license_fact_check_config.dart
// ============================================================================
// Config / Params
// ============================================================================

class LicensefactcheckConfig {
  final String title;
  final String? routeData;
  final int? serTitle;
  final bool readOnly;

  const LicensefactcheckConfig({
    this.title = 'อนุมัติคำขอ',
    this.routeData,
    this.serTitle,
    this.readOnly = false,
  });
}
