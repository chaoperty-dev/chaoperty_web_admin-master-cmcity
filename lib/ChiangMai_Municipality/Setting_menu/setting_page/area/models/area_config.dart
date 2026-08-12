// ============================================================================
// area_config.dart
// ============================================================================
// Config / Params สำหรับหน้า "จัดการ Area"
// ============================================================================

class AreaConfig {
  final String title;
  final String? routeData;
  final bool readOnly;

  const AreaConfig({
    this.title = 'จัดการ Area',
    this.routeData,
    this.readOnly = false,
  });
}
