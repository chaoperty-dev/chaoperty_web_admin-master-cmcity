// ============================================================================
// license_payment_config.dart
// ============================================================================
// Config / Params
// ============================================================================

class LicensePaymentConfig {
  final String title;
  final String? routeData;
  final int? serTitle;
  final bool readOnly;

  const LicensePaymentConfig({
    this.title = 'อนุมัติคำขอ',
    this.routeData,
    this.serTitle,
    this.readOnly = false,
  });
}
