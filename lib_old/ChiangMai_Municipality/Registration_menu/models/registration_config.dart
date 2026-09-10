// ============================================================================
// registration_config.dart
// ============================================================================
// Config / Params สำหรับเมนู "ทะเบียน" (Registration)
// ============================================================================

class RegistrationConfig {
  final String title;
  final String? routeData;
  final int? serTitle;
  final bool readOnly;

  const RegistrationConfig({
    this.title = 'ทะเบียน',
    this.routeData,
    this.serTitle,
    this.readOnly = false,
  });
}
