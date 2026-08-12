// ============================================================================
// access_rights_config.dart
// ============================================================================
// Config / Params สำหรับหน้า "สิทธิ์การเข้าถึง"
// ============================================================================

class AccessRightsConfig {
  final String title;
  final String? routeData;
  final bool readOnly;

  const AccessRightsConfig({
    this.title = 'สิทธิ์การเข้าถึง',
    this.routeData,
    this.readOnly = false,
  });
}
