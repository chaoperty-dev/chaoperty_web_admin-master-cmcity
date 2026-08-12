// ============================================================================
// license_verify_config.dart
// ============================================================================
// Config / Params
// ============================================================================

class LicenseVerifyConfig {
  final String title;
  final String? routeData;
  final int? serTitle;
  final bool readOnly;

  const LicenseVerifyConfig({
    this.title = 'ตรวจสอบหลักฐาน',
    this.routeData,
    this.serTitle,
    this.readOnly = false,
  });
}
