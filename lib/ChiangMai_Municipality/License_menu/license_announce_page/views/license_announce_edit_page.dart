// ============================================================================
// license_announce_edit_page.dart
// ============================================================================
// Full-page edit route — form editable เต็มจอ
// UI สไตล์เดียวกับ license_announce_detail_page (title bar + form card)
// Layout 2 column (เหมือน detail): ซ้าย title/body, ขวา dates, ล่าง zones
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/license_announce_item.dart';
import '../viewmodels/license_announce_view_model.dart';
import 'theme/license_announce_theme.dart';
import 'widgets/announce_detail_header.dart';

class LicenseAnnounceEditPage extends StatefulWidget {
  final LicenseAnnounceItem item;
  const LicenseAnnounceEditPage({super.key, required this.item});

  @override
  State<LicenseAnnounceEditPage> createState() =>
      _LicenseAnnounceEditPageState();
}

class _LicenseAnnounceEditPageState extends State<LicenseAnnounceEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _body;
  late final TextEditingController _sdate;
  late final TextEditingController _edate;
  late final TextEditingController _adate;
  late final TextEditingController _cdateStart;
  late final TextEditingController _cdateEnd;
  final TextEditingController _zoneSearchCtrl = TextEditingController();

  List<bool> _zoneChecked = [];
  bool _checkAll = false;
  String _selectedZonesZn = '';
  List<String> _selectedSer = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    final today = DateTime.now();
    final f = DateFormat('yyyy-MM-dd');
    _title = TextEditingController(text: i.title);
    _body = TextEditingController(text: i.content);
    _sdate = TextEditingController(text: _norm(i.sdate, f.format(today)));
    _edate = TextEditingController(
        text: _norm(i.edate, f.format(today.add(const Duration(days: 7)))));
    _adate =
        TextEditingController(text: _norm(i.announceDate, f.format(today)));
    _cdateStart =
        TextEditingController(text: _norm(i.cDateStart, f.format(today)));
    _cdateEnd = TextEditingController(
        text:
            _norm(i.cDateEnd, f.format(today.add(const Duration(days: 365)))));
    WidgetsBinding.instance.addPostFrameCallback((_) => _initZoneChecked());
  }

  static String _norm(String? raw, String fallback) {
    if (raw == null || raw.isEmpty) return fallback;
    final dt = DateTime.tryParse(raw);
    if (dt != null) return DateFormat('yyyy-MM-dd').format(dt.toLocal());
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) return raw;
    return fallback;
  }

  void _initZoneChecked() {
    final vm = context.read<LicenseAnnounceViewModel>();
    final zones = vm.zones;
    _zoneChecked = List.filled(zones.length, false);
    for (int idx = 0; idx < zones.length; idx++) {
      final zId = int.tryParse(zones[idx].ser ?? '');
      if (zId != null && zId == widget.item.zoneId) {
        setState(() {
          _zoneChecked[idx] = true;
          _selectedSer.add(zones[idx].ser!);
          _selectedZonesZn = zones[idx].zn ?? '';
        });
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

  void _toggleCheckAll() {
    setState(() {
      _checkAll = !_checkAll;
      final vm = context.read<LicenseAnnounceViewModel>();
      final zones = vm.zones;
      for (var i = 0; i < _zoneChecked.length; i++) {
        // ข้ามโซน "ทั้งหมด" (ser == "0")
        final isAll = i < zones.length && zones[i].ser == '0';
        _zoneChecked[i] = isAll ? false : _checkAll;
      }
      _rebuildSelectedZones();
    });
  }

  void _onZoneToggle(int index, bool? value) {
    setState(() {
      _zoneChecked[index] = value ?? false;
      _rebuildSelectedZones();
    });
  }

  void _rebuildSelectedZones() {
    final vm = context.read<LicenseAnnounceViewModel>();
    final zones = vm.zones;
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

  List<LicenseAnnounceZone> _filteredZones() {
    final vm = context.read<LicenseAnnounceViewModel>();
    final q = _zoneSearchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return vm.zones;
    return vm.zones.where((z) {
      return (z.zn ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('กรุณาเลือกโซนอย่างน้อย 1 โซน'),
        backgroundColor: LrColors.statusRejectedFg,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _submitting = true);
    final vm = context.read<LicenseAnnounceViewModel>();
    final zones = vm.zones;
    final List<Map<String, dynamic>> zoneData = [];
    for (final ser in _selectedSer) {
      final id = int.tryParse(ser) ?? 0;
      if (id <= 0) continue;
      final z = zones.firstWhere(
        (z) => z.ser == ser,
        orElse: () => LicenseAnnounceZone(ser: ser, zn: '', subZone: '0'),
      );
      final subzoneId = int.tryParse(z.subZone ?? '0') ?? 0;
      zoneData.add({
        'zone_id': id,
        'zone_pn': z.zn ?? '',
        'subzone_id': subzoneId,
      });
    }
    final ok = await vm.updateAnnouncement(
      ser: widget.item.announcementUuid,
      title: _title.text.trim(),
      sdate: _sdate.text.trim(),
      edate: _edate.text.trim(),
      announceDate: _adate.text.trim(),
      body: _body.text.trim(),
      zoneData: zoneData,
      cDateStart: _cdateStart.text.trim(),
      cDateEnd: _cdateEnd.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('บันทึกการแก้ไขสำเร็จ'),
        behavior: SnackBarBehavior.floating,
      ));
      if (Navigator.of(context).canPop()) Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('บันทึกล้มเหลว'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Breakpoints:
  //   mobile  : < 700
  //   tablet  : 700..1099
  //   desktop : >= 1100
  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth < 700;
  final isTablet = screenWidth >= 700 && screenWidth < 1100;
  final isCompact = isMobile || isTablet;  // single-column mode
    return Scaffold(
      backgroundColor: LrColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnnounceDetailHeader(
              title: 'แก้ไขประกาศ',
              subtitle: 'แก้ไขข้อมูลประกาศ',
              currentStep: 1,
              totalSteps: 1,
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(false);
                }
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ─── Title bar (เหมือน detail) ───
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7).withOpacity(.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.edit_note_rounded,
                                    size: 18, color: Color(0xFF15803D)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'แก้ไขประกาศ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          const SizedBox(height: 16),
                          _SectionTitle(
                              icon: Icons.place_rounded, title: 'โซนพื้นที่'),
                          _ZonePanel(
                            searchCtrl: _zoneSearchCtrl,
                            zoneChecked: _zoneChecked,
                            checkAll: _checkAll,
                            onCheckAll: _toggleCheckAll,
                            onZoneToggle: _onZoneToggle,
                            onSearchChanged: () => setState(() {}),
                            filteredZones: _filteredZones(),
                            selectedZonesZn: _selectedZonesZn,
                          ),
                          // ─── Form card (เหมือน detail) ───
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: isCompact
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _SectionTitle(
                                          icon: Icons.title,
                                          title: 'หัวข้อประกาศ'),
                                      TextFormField(
                                        controller: _title,
                                        style: LrText.body,
                                        decoration: _inputDeco(
                                            hint: 'พิมพ์หัวข้อประกาศ'),
                                        validator: (v) =>
                                            (v == null || v.trim().isEmpty)
                                                ? 'กรุณากรอกหัวข้อ'
                                                : null,
                                      ),
                                      const SizedBox(height: 16),
                                      _SectionTitle(
                                          icon: Icons.article,
                                          title: 'เนื้อหาประกาศ'),
                                      TextFormField(
                                        controller: _body,
                                        maxLines: 6,
                                        style: LrText.body,
                                        decoration: _inputDeco(
                                            hint: 'พิมพ์รายละเอียดประกาศ'),
                                      ),
                                      const SizedBox(height: 16),
                                      _SectionTitle(
                                          icon: Icons.event,
                                          title: 'ช่วงวันที่'),
                                      _DateField(
                                          controller: _sdate,
                                          label: 'วันเริ่ม',
                                          onTap: () => _pickDate(_sdate)),
                                      const SizedBox(height: 12),
                                      _DateField(
                                          controller: _edate,
                                          label: 'วันสิ้นสุด',
                                          onTap: () => _pickDate(_edate)),
                                      const SizedBox(height: 12),
                                      _DateField(
                                          controller: _cdateStart,
                                          label: 'วันออกใบอนุญาต',
                                          onTap: () => _pickDate(_cdateStart)),
                                      const SizedBox(height: 12),
                                      _DateField(
                                          controller: _cdateEnd,
                                          label: 'วันหมดอายุใบอนุญาต',
                                          onTap: () => _pickDate(_cdateEnd)),
                                      const SizedBox(height: 12),
                                      _DateField(
                                          controller: _adate,
                                          label: 'วันที่ประกาศ',
                                          onTap: () => _pickDate(_adate)),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _SectionTitle(
                                                icon: Icons.title,
                                                title: 'หัวข้อประกาศ'),
                                            TextFormField(
                                              controller: _title,
                                              style: LrText.body,
                                              decoration: _inputDeco(
                                                  hint: 'พิมพ์หัวข้อประกาศ'),
                                              validator: (v) => (v == null ||
                                                      v.trim().isEmpty)
                                                  ? 'กรุณากรอกหัวข้อ'
                                                  : null,
                                            ),
                                            const SizedBox(height: 16),
                                            _SectionTitle(
                                                icon: Icons.event,
                                                title: 'ช่วงวันที่'),
                                            _DateField(
                                                controller: _sdate,
                                                label: 'วันเริ่ม',
                                                onTap: () => _pickDate(_sdate)),
                                            const SizedBox(height: 12),
                                            _DateField(
                                                controller: _edate,
                                                label: 'วันสิ้นสุด',
                                                onTap: () => _pickDate(_edate)),
                                            const SizedBox(height: 12),
                                            _DateField(
                                                controller: _cdateStart,
                                                label: 'วันออกใบอนุญาต',
                                                onTap: () =>
                                                    _pickDate(_cdateStart)),
                                            const SizedBox(height: 12),
                                            _DateField(
                                                controller: _cdateEnd,
                                                label: 'วันหมดอายุใบอนุญาต',
                                                onTap: () =>
                                                    _pickDate(_cdateEnd)),
                                            const SizedBox(height: 12),
                                            _DateField(
                                                controller: _adate,
                                                label: 'วันที่ประกาศ',
                                                onTap: () => _pickDate(_adate)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        flex: 6,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _SectionTitle(
                                                icon: Icons.article,
                                                title: 'เนื้อหาประกาศ'),
                                            TextFormField(
                                              controller: _body,
                                              maxLines: 12,
                                              style: LrText.body,
                                              decoration: _inputDeco(
                                                  hint:
                                                      'พิมพ์รายละเอียดประกาศ'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),

                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              Icon(Icons.edit_note_rounded,
                                  size: 14, color: Color(0xFF94A3B8)),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'กรอกข้อมูลให้ครบถ้วนก่อนกดบันทึก',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _EditFooter(submitting: _submitting, onSave: _save),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: LrText.body.copyWith(color: LrColors.textMuted),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: LrColors.primary, width: 1.5),
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// _SectionTitle — ตรงกับ detail page
// ───────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF15803D)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// _DateField — สไตล์ detail page (border slate + icon calendar)
// ───────────────────────────────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback onTap;
  const _DateField(
      {required this.controller, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    String _fmt(String raw) {
      if (raw.isEmpty) return '-';
      try {
        final dt = DateTime.parse(raw).toLocal();
        return DateFormat('dd-MM-yyyy').format(dt);
      } catch (_) {
        return raw;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 14, color: const Color(0xFF15803D)),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    _fmt(controller.text),
                    style: LrText.body.copyWith(
                      fontFamily: LrText.fontBold,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down_rounded,
                size: 18, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// _ZonePanel — เหมือน detail page (พื้นขาว + border + check_all + search)
// ───────────────────────────────────────────────────────────────────────────
class _ZonePanel extends StatelessWidget {
  final TextEditingController searchCtrl;
  final List<bool> zoneChecked;
  final bool checkAll;
  final VoidCallback onCheckAll;
  final void Function(int, bool?) onZoneToggle;
  final VoidCallback onSearchChanged;
  final List<LicenseAnnounceZone> filteredZones;
  final String selectedZonesZn;

  const _ZonePanel({
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
    final vm = context.watch<LicenseAnnounceViewModel>();
    final allZones = vm.zones;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InkWell(
                onTap: onCheckAll,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: checkAll ? const Color(0xFFDCFCE7) : Colors.white,
                    border: Border.all(
                      color:
                          checkAll ? LrColors.primary : const Color(0xFF94A3B8),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.done_all,
                    size: 18,
                    color: checkAll
                        ? const Color(0xFF15803D)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: (_) => onSearchChanged(),
                    style: LrText.body,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      hintText: 'พิมพ์เพื่อค้นหา...',
                      hintStyle: LrText.caption,
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 16, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                            color: LrColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (selectedZonesZn.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place_rounded,
                      size: 14, color: Color(0xFF15803D)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'เลือก: $selectedZonesZn',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF15803D),
                        fontFamily: LrText.fontBold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: filteredZones.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('ไม่พบโซน',
                        style: LrText.bodyMuted, textAlign: TextAlign.center),
                  )
                : SingleChildScrollView(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: List.generate(filteredZones.length, (i) {
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
  const _ZoneChip(
      {required this.label, required this.checked, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: checked ? const Color(0xFFDCFCE7) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: checked ? LrColors.primary : const Color(0xFFE2E8F0),
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
              color:
                  checked ? const Color(0xFF15803D) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color:
                    checked ? const Color(0xFF15803D) : const Color(0xFF0F172A),
                fontFamily: checked ? LrText.fontBold : LrText.fontRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// _EditFooter — ยกเลิก + บันทึก (เหมือน detail footer structure)
// ───────────────────────────────────────────────────────────────────────────
class _EditFooter extends StatelessWidget {
  final bool submitting;
  final VoidCallback onSave;
  const _EditFooter({required this.submitting, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
              submitting
                  ? Icons.hourglass_top_rounded
                  : Icons.edit_note_rounded,
              size: 14,
              color: const Color(0xFF94A3B8)),
          const SizedBox(width: 6),
          Text(
            submitting ? 'กำลังบันทึก...' : 'กรอกข้อมูลให้ครบถ้วนก่อนกดบันทึก',
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const Spacer(),
          _CancelBtn(
            disabled: submitting,
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(false);
              }
            },
          ),
          const SizedBox(width: 8),
          _SaveBtn(submitting: submitting, onTap: onSave),
        ],
      ),
    );
  }
}

class _CancelBtn extends StatefulWidget {
  final bool disabled;
  final VoidCallback onTap;
  const _CancelBtn({required this.disabled, required this.onTap});
  @override
  State<_CancelBtn> createState() => _CancelBtnState();
}

class _CancelBtnState extends State<_CancelBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) {
        if (!widget.disabled) setState(() => _hover = true);
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.disabled ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFFFEE2E2) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hover ? const Color(0xFFB91C1C) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.close_rounded,
                  size: 16,
                  color: _hover
                      ? const Color(0xFFB91C1C)
                      : const Color(0xFF475569)),
              const SizedBox(width: 6),
              Text(
                'ยกเลิก',
                style: TextStyle(
                  color: _hover
                      ? const Color(0xFFB91C1C)
                      : const Color(0xFF475569),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveBtn extends StatefulWidget {
  final bool submitting;
  final VoidCallback onTap;
  const _SaveBtn({required this.submitting, required this.onTap});
  @override
  State<_SaveBtn> createState() => _SaveBtnState();
}

class _SaveBtnState extends State<_SaveBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.submitting
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) {
        if (!widget.submitting) setState(() => _hover = true);
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.submitting ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFF166534) : const Color(0xFF15803D),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF15803D).withOpacity(_hover ? .35 : .25),
                blurRadius: _hover ? 12 : 8,
                offset: const Offset(0, 4),
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
                      valueColor: AlwaysStoppedAnimation(Colors.white)),
                )
              else
                const Icon(Icons.save_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              const Text(
                'บันทึก',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
