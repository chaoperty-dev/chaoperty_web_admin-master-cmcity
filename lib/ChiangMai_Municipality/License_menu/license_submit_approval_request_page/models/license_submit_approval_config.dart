// ============================================================================
// license_submit_approval_config.dart
// ============================================================================
// Config / Params
// ============================================================================

class LicenseSubmitApprovalConfig {
  final String title;
  final String? routeData;
  final int? serTitle;
  final bool readOnly;

  const LicenseSubmitApprovalConfig({
    this.title = 'อนุมัติคำขอ',
    this.routeData,
    this.serTitle,
    this.readOnly = false,
  });
}
