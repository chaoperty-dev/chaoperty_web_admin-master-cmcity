// ============================================================================
// area_menu_config.dart
// ============================================================================
// Config / Params
// ============================================================================

class AreaMenuConfig {
  final String title;
  final String? routeData;
  final int? serTitle;
  final bool readOnly;

  const AreaMenuConfig({
    this.title = 'อนุมัติคำขอ',
    this.routeData,
    this.serTitle,
    this.readOnly = false,
  });
}
