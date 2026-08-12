// ============================================================================
// payment_config.dart
// ============================================================================
// Config / Params สำหรับหน้า "การรับชำระ"
// ============================================================================

class PaymentConfig {
  final String title;
  final String? routeData;
  final bool readOnly;

  const PaymentConfig({
    this.title = 'การรับชำระ',
    this.routeData,
    this.readOnly = false,
  });
}
