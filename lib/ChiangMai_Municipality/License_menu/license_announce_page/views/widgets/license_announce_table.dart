// Widgets
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/license_announce_item.dart';
import '../theme/license_announce_theme.dart';
import '../../viewmodels/license_announce_view_model.dart';

// ─────────────────────────────────────────────────────────────
// LicenseAnnounceSearchBar ย้ายไปอยู่ใน license_announce_search_bar.dart
// LicenseAnnounceZoneFilter ย้ายไปอยู่ใน license_announce_zone_filter.dart
// ─────────────────────────────────────────────────────────────

/// Breakpoint: < 900px = โทรศัพท์/แท็บเล็ต → ใช้ card layout
const double kLicenseMenuMobileBreakpoint = 900;

bool _isLicenseListMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < kLicenseMenuMobileBreakpoint;

class LicenseAnnounceTable extends StatelessWidget {
  const LicenseAnnounceTable({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseAnnounceViewModel>();

    if (vm.isLoading && vm.items.isEmpty) {
      return const _LoadingState();
    }
    if (vm.filtered.isEmpty) {
      return _EmptyState(
        hasFilter: vm.searchQuery.isNotEmpty || vm.selectedZoneSer != null,
        onRefresh: vm.refresh,
      );
    }

    // ─── Mobile (card layout) ───
    if (_isLicenseListMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (vm.isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: LrColors.surfaceMuted,
              valueColor:
                  AlwaysStoppedAnimation<Color>(LrColors.primary),
            ),
          for (int i = 0; i < vm.filtered.length; i++) ...[
            _AnnounceCard(
              index: i,
              item: vm.filtered[i],
              onTap: () => vm.onView(vm.filtered[i].announcementUuid),
            ),
            if (i < vm.filtered.length - 1)
              const SizedBox(height: LrSpace.sm),
          ],
        ],
      );
    }

    return Container(
      decoration: LrDecor.card(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row (sticky ด้านบน)
          _headerRow(),
          const Divider(height: 1, color: LrColors.border),
          // Rows — outer SingleChildScrollView (จาก page wrapper) จัดการ scroll
          if (vm.isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: LrColors.surfaceMuted,
              valueColor:
                  AlwaysStoppedAnimation<Color>(LrColors.primary),
            ),
          for (int i = 0; i < vm.filtered.length; i++)
            _dataRow(context, vm, vm.filtered[i], i),
        ],
      ),
    );
  }

  Widget _headerRow() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LrSpace.md, vertical: LrSpace.md),
      decoration: const BoxDecoration(
        color: LrColors.surfaceMuted,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(LrRadius.lg),
          topRight: Radius.circular(LrRadius.lg),
        ),
      ),
      child: const Row(
        children: [
          _HeaderCell(label: '', flex: 0, width: 110),
          _HeaderCell(label: 'หัวข้อ', flex: 4),
          _HeaderCell(label: 'โซน', flex: 2),
          _HeaderCell(label: 'วันเริ่ม', flex: 2),
          _HeaderCell(label: 'วันสิ้นสุด', flex: 2),
          _HeaderCell(label: 'วันที่ประกาศ', flex: 2),
          _HeaderCell(label: 'สถานะ', flex: 2),
        ],
      ),
    );
  }

  Widget _dataRow(BuildContext context, LicenseAnnounceViewModel vm,
      LicenseAnnounceItem p, int index) {
    final f = DateFormat('dd-MM-yyyy');
    DateTime parse(String s) => DateTime.tryParse(s) ?? DateTime.now();
    String safeDate(String s) => s.isEmpty ? '-' : f.format(parse(s));
    final palette =
        StatusPalette.of(p.computedStatus.isEmpty ? null : p.computedStatus);
    return _HoverableRow(
      index: index,
      onTap: () => vm.onView(p.announcementUuid),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: LrSpace.md, vertical: LrSpace.md),
        child: Row(
          children: [
            // Action column — ปุ่ม "เรียกดู"
            SizedBox(
              width: 110,
              child: Center(
                child: _ViewButton(onTap: () => vm.onView(p.announcementUuid)),
              ),
            ),
            Expanded(
              flex: 4,
              child: Tooltip(
                message: p.title,
                child: AutoSizeText(
                  p.title.isEmpty ? '-' : p.title,
                  minFontSize: 11,
                  maxFontSize: 14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LrText.tableCell.copyWith(fontFamily: LrText.fontBold),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: AutoSizeText(
                (p.zonePn ?? '-').isEmpty ? '-' : p.zonePn!,
                minFontSize: 11,
                maxFontSize: 13,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LrText.tableCell.copyWith(color: LrColors.textSecondary),
              ),
            ),
            Expanded(
              flex: 2,
              child: AutoSizeText(
                safeDate(p.sdate),
                minFontSize: 11,
                maxFontSize: 13,
                maxLines: 1,
                style: LrText.tableCell.copyWith(fontFamily: 'monospace'),
              ),
            ),
            Expanded(
              flex: 2,
              child: AutoSizeText(
                safeDate(p.edate),
                minFontSize: 11,
                maxFontSize: 13,
                maxLines: 1,
                style: LrText.tableCell.copyWith(fontFamily: 'monospace'),
              ),
            ),
            Expanded(
              flex: 2,
              child: AutoSizeText(
                safeDate(p.announceDate),
                minFontSize: 11,
                maxFontSize: 13,
                maxLines: 1,
                style: LrText.tableCell.copyWith(fontFamily: 'monospace'),
              ),
            ),
            Expanded(
              flex: 2,
              child: _StatusPill(
                label: p.computedStatus.isEmpty
                    ? (p.isActive ? 'ใช้งาน' : 'ปิด')
                    : p.computedStatus,
                palette: palette,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Internal widgets
// ============================================================================

/// Card layout สำหรับ mobile/tablet — ใช้เมื่อ viewport < 900px
class _AnnounceCard extends StatelessWidget {
  final int index;
  final LicenseAnnounceItem item;
  final VoidCallback onTap;
  const _AnnounceCard({
    required this.index,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('dd-MM-yyyy');
    DateTime parse(String s) => DateTime.tryParse(s) ?? DateTime.now();
    String safeDate(String s) => s.isEmpty ? '-' : f.format(parse(s));
    final palette =
        StatusPalette.of(item.computedStatus.isEmpty ? null : item.computedStatus);
    final statusLabel = item.computedStatus.isEmpty
        ? (item.isActive ? 'ใช้งาน' : 'ปิด')
        : item.computedStatus;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LrRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(LrSpace.md),
          decoration: LrDecor.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Row 1: ลำดับ + หัวข้อ + status pill ───
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: LrColors.primaryLight,
                      borderRadius: BorderRadius.circular(LrRadius.pill),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: LrText.tableCell.copyWith(
                        color: LrColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: LrSpace.sm),
                  Expanded(
                    child: Text(
                      item.title.isEmpty ? '-' : item.title,
                      style: LrText.tableCell.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: LrSpace.sm),
                  _StatusPill(label: statusLabel, palette: palette),
                ],
              ),
              const Divider(height: LrSpace.lg, color: LrColors.border),
              // ─── Row 2: รายละเอียด (label/value grid) ───
              if ((item.zonePn ?? '').isNotEmpty)
                _CardRow(label: 'โซน', value: item.zonePn!),
              _CardRow(label: 'วันเริ่ม', value: safeDate(item.sdate), isMono: true),
              _CardRow(label: 'วันสิ้นสุด', value: safeDate(item.edate), isMono: true),
              _CardRow(label: 'วันที่ประกาศ', value: safeDate(item.announceDate), isMono: true),
              const SizedBox(height: LrSpace.sm),
              // ─── Row 3: ปุ่ม ───
              Align(
                alignment: Alignment.centerRight,
                child: _ViewButton(onTap: onTap),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMono;
  final bool muted;
  const _CardRow({
    required this.label,
    required this.value,
    this.isMono = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: LrText.bodyMuted.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: LrText.tableCell.copyWith(
                color: muted ? LrColors.textSecondary : LrColors.textPrimary,
                fontFamily: isMono ? 'monospace' : LrText.fontRegular,
                fontFamilyFallback: const [LrText.fontRegular],
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final double? width;
  const _HeaderCell({required this.label, this.flex = 1, this.width});
  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: LrText.tableHeader,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (width != null) {
      return SizedBox(width: width, child: Center(child: child));
    }
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: child,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final StatusPalette palette;
  const _StatusPill({required this.label, required this.palette});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: LrDecor.pill(palette.bg, palette.fg),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: palette.fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: AutoSizeText(
                label.isEmpty ? '-' : label,
                minFontSize: 10,
                maxFontSize: 12,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: LrText.fontBold,
                  fontSize: 11,
                  color: palette.fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverableRow extends StatefulWidget {
  final int index;
  final Widget child;
  final VoidCallback onTap;
  const _HoverableRow(
      {required this.index, required this.child, required this.onTap});
  @override
  State<_HoverableRow> createState() => _HoverableRowState();
}

class _HoverableRowState extends State<_HoverableRow> {
  bool _hover = false;
  @override
  void didUpdateWidget(_HoverableRow old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) _hover = false;
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.index.isEven ? Colors.white : LrColors.surfaceMuted;
    final hoverColor = widget.index.isEven
        ? LrColors.primary.withOpacity(.05)
        : LrColors.primary.withOpacity(.08);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (h) {
          if (h != _hover) setState(() => _hover = h);
        },
        hoverColor: hoverColor,
        splashColor: LrColors.primary.withOpacity(.12),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: LrAnimations.fast,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _hover ? null : base,
            border: const Border(
              bottom: BorderSide(color: LrColors.border, width: 1),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _IconAction extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });
  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: LrAnimations.fast,
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _hover ? widget.color : Colors.transparent,
              borderRadius: BorderRadius.circular(LrRadius.sm),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: _hover ? Colors.white : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ViewButton({required this.onTap});

  @override
  State<_ViewButton> createState() => _ViewButtonState();
}

class _ViewButtonState extends State<_ViewButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: LrAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hover ? LrColors.primary : LrColors.surfaceMuted,
            borderRadius: BorderRadius.circular(LrRadius.pill),
            border: Border.all(
              color: _hover ? LrColors.primary : LrColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 13,
                color: _hover ? Colors.white : LrColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'เรียกดู',
                style: TextStyle(
                  fontFamily: LrText.fontBold,
                  fontSize: 11,
                  color: _hover ? Colors.white : LrColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LrDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(LrColors.primary),
          ),
          SizedBox(height: LrSpace.md),
          Text('กำลังโหลดประกาศ...', style: LrText.bodyMuted),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onRefresh;
  const _EmptyState({required this.hasFilter, required this.onRefresh});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LrDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: LrColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.campaign_outlined,
              size: 36,
              color: LrColors.primaryDark,
            ),
          ),
          const SizedBox(height: LrSpace.md),
          Text(
            hasFilter ? 'ไม่พบประกาศที่ตรงกับเงื่อนไข' : 'ยังไม่มีประกาศ',
            style: LrText.h2.copyWith(color: LrColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            hasFilter
                ? 'ลองเปลี่ยนคำค้นหรือโซน แล้วลองอีกครั้ง'
                : 'กดปุ่ม "เพิ่มประกาศ" เพื่อสร้างประกาศใหม่',
            style: LrText.bodyMuted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LrSpace.lg),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('รีเฟรช'),
            style: OutlinedButton.styleFrom(
              foregroundColor: LrColors.primary,
              side: const BorderSide(color: LrColors.primary, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LrRadius.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum LicenseAnnounceDialogMode { create, edit }

class LicenseAnnounceFormDialog extends StatefulWidget {
  final LicenseAnnounceDialogMode mode;
  final LicenseAnnounceItem? initial;
  final LicenseAnnounceViewModel viewModel;
  const LicenseAnnounceFormDialog(
      {super.key, required this.mode, required this.viewModel, this.initial});
  @override
  State<LicenseAnnounceFormDialog> createState() => _FD();
}

class _FD extends State<LicenseAnnounceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _sdate = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final _edate = TextEditingController(
      text: DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 7))));
  final _adate = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final _cdateStart = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final _cdateEnd = TextEditingController(
      text: DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 365))));

  // ── Multi-zone selection (เหมือนของเดิม) ──
  List<bool> _zoneChecked = [];
  bool _checkAll = false;
  String _selectedZonesZn = '';
  List<String> _selectedSer = [];
  final TextEditingController _zoneSearchCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final i = widget.initial!;
      _title.text = i.title;
      _body.text = i.content;
      _sdate.text = _normalizeDate(i.sdate, fallback: _sdate.text);
      _edate.text = _normalizeDate(i.edate, fallback: _edate.text);
      _adate.text = _normalizeDate(i.announceDate, fallback: _adate.text);
      _cdateStart.text =
          _normalizeDate(i.cDateStart, fallback: _cdateStart.text);
      _cdateEnd.text = _normalizeDate(i.cDateEnd, fallback: _cdateEnd.text);
    }
    _initZoneChecked();
  }

  /// Normalize date string จาก API → `yyyy-MM-dd`
  /// - รองรับ ISO datetime (2026-08-11T00:00:00Z)
  /// - รองรับ date-only (2026-08-11)
  /// - ถ้า parse ไม่ได้ → ใช้ fallback
  static String _normalizeDate(String? raw, {required String fallback}) {
    if (raw == null || raw.isEmpty) return fallback;
    final dt = DateTime.tryParse(raw);
    if (dt == null) {
      // ถ้าเป็น yyyy-MM-dd อยู่แล้ว ใช้ตรงๆ
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) return raw;
      return fallback;
    }
    return DateFormat('yyyy-MM-dd').format(dt.toLocal());
  }

  void _initZoneChecked() {
    final zones = widget.viewModel.zones;
    _zoneChecked = List.filled(zones.length, false);
    if (widget.initial != null) {
      final i = widget.initial!;
      for (int idx = 0; idx < zones.length; idx++) {
        final zId = int.tryParse(zones[idx].ser ?? '');
        if (zId != null && zId == i.zoneId) {
          _zoneChecked[idx] = true;
          _selectedSer.add(zones[idx].ser!);
          _selectedZonesZn = zones[idx].zn ?? '';
        }
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _sdate.dispose();
    _edate.dispose();
    _adate.dispose();
    _cdateStart.dispose();
    _cdateEnd.dispose();
    _zoneSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final initial = DateTime.tryParse(ctrl.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2124),
      locale: const Locale('th', 'TH'),
    );
    if (picked != null) {
      ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  /// Toggle ทั้งหมด (check_all)
  void _toggleCheckAll() {
    setState(() {
      _checkAll = !_checkAll;
      for (var i = 0; i < _zoneChecked.length; i++) {
        _zoneChecked[i] = _checkAll;
      }
      _rebuildSelectedZones();
    });
  }

  /// Toggle checkbox แต่ละโซน
  void _onZoneToggle(int index, bool? value) {
    setState(() {
      _zoneChecked[index] = value ?? false;
      _rebuildSelectedZones();
    });
  }

  /// สร้าง _selectedSer + _selectedZonesZn ใหม่จาก checkbox state
  void _rebuildSelectedZones() {
    final zones = widget.viewModel.zones;
    _selectedSer = [];
    final names = <String>{};
    for (int i = 0; i < _zoneChecked.length; i++) {
      if (_zoneChecked[i] && i < zones.length) {
        _selectedSer.add(zones[i].ser ?? '');
        names.add(zones[i].zn ?? '');
      }
    }
    final sorted = names.toList()..sort();
    _selectedZonesZn = sorted.join(', ');
  }

  /// Filter zones จาก search
  List<LicenseAnnounceZone> _filteredZones() {
    final q = _zoneSearchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return widget.viewModel.zones;
    return widget.viewModel.zones.where((z) {
      return (z.zn ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกโซนอย่างน้อย 1 โซน'),
          backgroundColor: LrColors.statusRejectedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    final vm = widget.viewModel;
    // ส่งเป็น list ของ zone id
    final zoneIds = _selectedSer
        .map((s) => int.tryParse(s) ?? 0)
        .where((id) => id > 0)
        .toList();
    final ok = widget.initial == null
        ? await vm.addAnnouncement(
            title: _title.text.trim(),
            sdate: _sdate.text.trim(),
            edate: _edate.text.trim(),
            announceDate: _adate.text.trim(),
            body: _body.text.trim(),
            zoneIds: zoneIds,
            cDateStart: _cdateStart.text.trim(),
            cDateEnd: _cdateEnd.text.trim(),
          )
        : await vm.updateAnnouncement(
            ser: widget.initial!.announcementUuid,
            title: _title.text.trim(),
            sdate: _sdate.text.trim(),
            edate: _edate.text.trim(),
            announceDate: _adate.text.trim(),
            body: _body.text.trim(),
            zoneIds: zoneIds,
            cDateStart: _cdateStart.text.trim(),
            cDateEnd: _cdateEnd.text.trim(),
          );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Dialog(
      backgroundColor: LrColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LrRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(LrSpace.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.mode == LicenseAnnounceDialogMode.create
                              ? 'เพิ่มประกาศ'
                              : 'แก้ไขประกาศ',
                          style: LrText.h1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: LrSpace.sm),

                  // ─── Section: ข้อมูลประกาศ ───
                  _AnnounceSectionTitle(
                    icon: Icons.assignment_rounded,
                    title: 'ข้อมูลประกาศ',
                    subtitle: 'หัวข้อและรายละเอียดของประกาศ',
                  ),
                  TextFormField(
                    controller: _title,
                    decoration: _inputDeco(
                      label: 'หัวข้อ',
                      icon: Icons.title_rounded,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'กรุณากรอกหัวข้อ'
                        : null,
                  ),
                  const SizedBox(height: LrSpace.sm),
                  TextFormField(
                    controller: _body,
                    maxLines: 4,
                    decoration: _inputDeco(
                      label: 'รายละเอียด',
                      icon: Icons.description_rounded,
                    ),
                  ),
                  const SizedBox(height: LrSpace.md),

                  // ─── Section: ช่วงเวลารับคำร้อง ───
                  _AnnounceSectionTitle(
                    icon: Icons.event_available_rounded,
                    title: 'ช่วงเวลารับคำร้อง',
                    subtitle: 'วันเริ่ม - วันสิ้นสุด',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          controller: _sdate,
                          label: 'วันเริ่ม',
                          onTap: () => _pickDate(_sdate),
                        ),
                      ),
                      const SizedBox(width: LrSpace.sm),
                      Expanded(
                        child: _DateField(
                          controller: _edate,
                          label: 'วันสิ้นสุด',
                          onTap: () => _pickDate(_edate),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: LrSpace.md),

                  // ─── Section: ใบอนุญาต ───
                  _AnnounceSectionTitle(
                    icon: Icons.verified_rounded,
                    title: 'ใบอนุญาตฉบับใหม่',
                    subtitle: 'ช่วงเวลาออกใบอนุญาต',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          controller: _cdateStart,
                          label: 'วันที่ออก',
                          onTap: () => _pickDate(_cdateStart),
                        ),
                      ),
                      const SizedBox(width: LrSpace.sm),
                      Expanded(
                        child: _DateField(
                          controller: _cdateEnd,
                          label: 'วันหมดอายุ',
                          onTap: () => _pickDate(_cdateEnd),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: LrSpace.md),

                  // ─── Section: วันเผยแพร่ ───
                  _AnnounceSectionTitle(
                    icon: Icons.publish_rounded,
                    title: 'การเผยแพร่',
                    subtitle: 'วันที่เผยแพร่',
                  ),
                  _DateField(
                    controller: _adate,
                    label: 'วันที่ประกาศ',
                    onTap: () => _pickDate(_adate),
                  ),
                  const SizedBox(height: LrSpace.md),

                  // ─── Section: โซน (เลือกได้หลายโซน - checkbox grid) ───
                  _AnnounceSectionTitle(
                    icon: Icons.place_rounded,
                    title: 'โซนพื้นที่',
                    subtitle: 'เลือกโซนที่ต้องการแจ้งประกาศ (เลือกได้หลายโซน)',
                  ),
                  _ZoneCheckboxPanel(
                    vm: vm,
                    searchCtrl: _zoneSearchCtrl,
                    zoneChecked: _zoneChecked,
                    checkAll: _checkAll,
                    onCheckAll: _toggleCheckAll,
                    onZoneToggle: _onZoneToggle,
                    onSearchChanged: () => setState(() {}),
                    filteredZones: _filteredZones(),
                    selectedZonesZn: _selectedZonesZn,
                  ),
                  const SizedBox(height: LrSpace.lg),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Text('ยกเลิก'),
                      ),
                      const SizedBox(width: LrSpace.sm),
                      _SaveButton(
                        submitting: _submitting,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 16, color: LrColors.primaryDark),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LrRadius.sm),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LrRadius.sm),
        borderSide: const BorderSide(color: LrColors.primary, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LrRadius.sm),
        borderSide: const BorderSide(color: LrColors.border, width: 1),
      ),
      isDense: true,
    );
  }
}

// ─── Internal widgets ───
class _AnnounceSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const _AnnounceSectionTitle({
    required this.icon,
    required this.title,
    this.subtitle,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LrSpace.xs),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: LrColors.primaryLight,
              borderRadius: BorderRadius.circular(LrRadius.sm),
              border: Border.all(
                color: LrColors.primaryAccent.withOpacity(.35),
                width: 1,
              ),
            ),
            child: Icon(icon, size: 16, color: LrColors.primaryDark),
          ),
          const SizedBox(width: LrSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: LrText.h2.copyWith(fontSize: 14)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: LrText.caption),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback onTap;
  const _DateField({
    required this.controller,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LrRadius.sm),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_rounded,
              size: 16, color: LrColors.primaryDark),
          suffixIcon: const Icon(Icons.arrow_drop_down_rounded,
              color: LrColors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LrRadius.sm),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LrRadius.sm),
            borderSide: const BorderSide(color: LrColors.primary, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LrRadius.sm),
            borderSide: const BorderSide(color: LrColors.border, width: 1),
          ),
          isDense: true,
        ),
      ),
    );
  }
}

class _ZoneCheckboxPanel extends StatelessWidget {
  final LicenseAnnounceViewModel vm;
  final TextEditingController searchCtrl;
  final List<bool> zoneChecked;
  final bool checkAll;
  final VoidCallback onCheckAll;
  final void Function(int, bool?) onZoneToggle;
  final VoidCallback onSearchChanged;
  final List<LicenseAnnounceZone> filteredZones;
  final String selectedZonesZn;

  const _ZoneCheckboxPanel({
    required this.vm,
    required this.searchCtrl,
    required this.zoneChecked,
    required this.checkAll,
    required this.onCheckAll,
    required this.onZoneToggle,
    required this.onSearchChanged,
    required this.filteredZones,
    required this.selectedZonesZn,
  });

  @override
  Widget build(BuildContext context) {
    final allZones = vm.zones;
    return Container(
      decoration: BoxDecoration(
        color: LrColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LrRadius.sm),
        border: Border.all(color: LrColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(LrSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: check-all + search box
          Row(
            children: [
              // Check-all icon button
              InkWell(
                onTap: onCheckAll,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color:
                        checkAll ? LrColors.primaryLight : Colors.transparent,
                    border: Border.all(
                      color:
                          checkAll ? LrColors.primary : LrColors.borderStrong,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.done_all,
                    size: 18,
                    color: checkAll ? LrColors.primaryDark : LrColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: LrSpace.sm),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: (_) => onSearchChanged(),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      hintText: 'ค้นหาโซน...',
                      hintStyle: LrText.caption,
                      prefixIcon: const Icon(Icons.search,
                          size: 14, color: LrColors.textMuted),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(LrRadius.sm),
                        borderSide: BorderSide(color: LrColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(LrRadius.sm),
                        borderSide: BorderSide(color: LrColors.border),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LrSpace.sm),
          // Selected preview
          if (selectedZonesZn.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: LrSpace.sm, vertical: 4),
              decoration: BoxDecoration(
                color: LrColors.primaryLight,
                borderRadius: BorderRadius.circular(LrRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place_rounded,
                      size: 14, color: LrColors.primaryDark),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'เลือก: $selectedZonesZn',
                      style: const TextStyle(
                        fontSize: 11,
                        color: LrColors.primaryDark,
                        fontFamily: LrText.fontBold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          if (selectedZonesZn.isNotEmpty) const SizedBox(height: LrSpace.sm),
          // Zone checkbox grid
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: filteredZones.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(LrSpace.sm),
                    child: Text('ไม่พบโซน',
                        style: LrText.bodyMuted, textAlign: TextAlign.center),
                  )
                : SingleChildScrollView(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: List.generate(filteredZones.length, (i) {
                        // หา index จริงใน allZones
                        final realIndex = allZones.indexOf(filteredZones[i]);
                        if (realIndex < 0) return const SizedBox.shrink();
                        final checked = zoneChecked.length > realIndex
                            ? zoneChecked[realIndex]
                            : false;
                        return _ZoneChip(
                          label: filteredZones[i].zn ?? '-',
                          checked: checked,
                          onTap: () => onZoneToggle(realIndex, !checked),
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback onTap;
  const _ZoneChip({
    required this.label,
    required this.checked,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LrRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: checked ? LrColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(LrRadius.sm),
          border: Border.all(
            color: checked ? LrColors.primary : LrColors.border,
            width: checked ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              checked
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 14,
              color: checked ? LrColors.primaryDark : LrColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: checked ? LrColors.primaryDark : LrColors.textPrimary,
                fontFamily: checked ? LrText.fontBold : LrText.fontRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final bool submitting;
  final VoidCallback onPressed;
  const _SaveButton({required this.submitting, required this.onPressed});
  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.submitting ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: LrAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [LrColors.primaryAccent, LrColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(LrRadius.md),
            boxShadow: [
              BoxShadow(
                color: LrColors.primary.withOpacity(_hover ? .55 : .35),
                blurRadius: _hover ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.submitting)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              else
                const Icon(Icons.save_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'บันทึก',
                style: TextStyle(
                  fontFamily: LrText.fontBold,
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
