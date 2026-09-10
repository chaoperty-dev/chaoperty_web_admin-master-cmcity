// ============================================================================
// registration_config.dart
// ============================================================================
// Config / Params
// ============================================================================

class RegistrationConfig {
  final String title;
  final String? routeData;
  final int? serTitle;
  final bool readOnly;

  const RegistrationConfig({
    this.title = 'อนุมัติคำขอ',
    this.routeData,
    this.serTitle,
    this.readOnly = false,
  });
}
