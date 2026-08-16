// ============================================================================
// customer_picker_dialog.dart
// ============================================================================
// Dialog เลือก "รายชื่อจากทะเบียน" (copy pattern จาก new_contract_cmm.dart)
// - Tab 1: ค้นหาจากทะเบียน (search + pagination)
// - Tab 2: เพิ่มทะเบียนใหม่ (Add_Custo_Screen)
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../../Bureau_Registration/Add_Custo_Screen.dart';
import '../../../../../Constant/Myconstant.dart';
import '../../../../../Model/GetCustomer_Model.dart';
import '../../../../../Responsive/responsive.dart';
import '../../../../../Style/colors.dart';
import '../theme/license_contract_theme.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Public API
/// ═══════════════════════════════════════════════════════════════════════
class CustomerPickerDialog extends StatefulWidget {
  final String title;

  const CustomerPickerDialog(
      {super.key, this.title = 'เลือกรายชื่อจากทะเบียน'});

  static Future<CustomerModel?> show(
    BuildContext context, {
    String title = 'เลือกรายชื่อจากทะเบียน',
  }) {
    return showDialog<CustomerModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CustomerPickerDialog(title: title),
    );
  }

  @override
  State<CustomerPickerDialog> createState() => _CustomerPickerDialogState();
}

class _CustomerPickerDialogState extends State<CustomerPickerDialog> {
  // ─── Tab state ───
  int _currentPageTab = 1;

  // ─── Search state ───
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  // ─── Pagination ───
  String? _linksPrev;
  String? _linksNext;
  int? _currentPage;
  int? _lastPage;
  int? _total;

  // ─── Data ───
  final List<CustomerModel> _customers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────
  // Fetch customers (search + pagination)
  // ─────────────────────────────────────────────────────────────────────
  Future<void> _fetchCustomers({String? urlCustom, String query = ''}) async {
    if (mounted) setState(() => _isLoading = true);

    String baseUrl = urlCustom ??
        '${MyConstant().domain_v2}/lookup/customers'
            '${query.isNotEmpty ? Uri(queryParameters: {
                    'q': query
                  }).toString() : ''}';

    // HTTPS enforcement
    if (MyConstant().domain_v2.startsWith('https://') &&
        baseUrl.startsWith('http://')) {
      baseUrl = baseUrl.replaceFirst('http://', 'https://');
    }

    final Uri url = Uri.parse(baseUrl);

    try {
      final headers = await MyHeaders.build();
      final res = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final result = json.decode(res.body);
      if (result is! Map) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Meta
      final meta = result['meta'];
      if (meta is Map) {
        _currentPage = int.tryParse(meta['current_page']?.toString() ?? '') ??
            _currentPage;
        _lastPage =
            int.tryParse(meta['last_page']?.toString() ?? '') ?? _lastPage;
        _total = int.tryParse(meta['total']?.toString() ?? '') ?? _total;
      }

      // Links
      final links = result['links'];
      if (links is Map) {
        _linksPrev = links['prev']?.toString();
        _linksNext = links['next']?.toString();
      }

      // Data
      final parsed = <CustomerModel>[];
      if (result['data'] is List) {
        final list = result['data'] as List;
        for (final item in list) {
          try {
            final map = Map<String, dynamic>.from(item as Map);
            // Coerce numeric fields to string (ตาม pattern ของ new_contract_cmm)
            _coerceStringFields(map, const [
              'custno',
              'scname',
              'stype',
              'tser',
              'type',
              'cname',
              'tel',
              'tax',
              'zip',
              'uuid',
              'national',
            ]);
            parsed.add(CustomerModel.fromJson(map));
          } catch (_) {
            // skip invalid row
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _customers
            ..clear()
            ..addAll(parsed);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Helper: บังคับให้ key ที่ควรเป็น String แปลงจาก List/num/bool → String
  void _coerceStringFields(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = map[k];
      if (v == null) continue;
      if (v is String) continue;
      if (v is num || v is bool) {
        map[k] = v.toString();
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Search handlers
  // ─────────────────────────────────────────────────────────────────────
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchCustomers(query: value);
    });
  }

  void _onClearSearch() {
    _searchCtrl.clear();
    _debounce?.cancel();
    _fetchCustomers();
    setState(() {});
  }

  // ─────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = Responsive.isDesktop(context);

    // หัก sidebar width (~240px) + margin ออก
    // เพื่อให้ dialog อยู่ในกรอบ content area ไม่เลยไปทับแท็บเมนู
    final sidebarWidth = isDesktop ? 240.0 : 0.0;
    final dialogMaxWidth = isDesktop
        ? (screenWidth - sidebarWidth - 32).clamp(640.0, 1100.0)
        : 1100.0;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.fromLTRB(
        isDesktop ? sidebarWidth + 16 : 16,
        16,
        16,
        16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogMaxWidth,
          maxHeight: screenHeight * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildTabs(),
            const Divider(height: 1),
            Flexible(
              child: _currentPageTab == 1
                  ? _buildSearchTab(isDesktop, dialogMaxWidth, screenHeight)
                  : _buildAddNewTab(isDesktop, dialogMaxWidth, screenHeight),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ───
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
      decoration: const BoxDecoration(
        color: LcColors.surfaceMuted,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: LcColors.primaryLight,
              borderRadius: BorderRadius.all(Radius.circular(LcRadius.sm)),
            ),
            child: const Icon(
              Icons.contact_page_rounded,
              size: 18,
              color: LcColors.primaryDark,
            ),
          ),
          const SizedBox(width: LcSpace.sm),
          Expanded(
            child: Text(
              _currentPageTab == 2 ? 'เพิ่มข้อมูลทะเบียนลูกค้า' : widget.title,
              style: LcText.h2.copyWith(fontSize: 15),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: LcColors.textSecondary),
            tooltip: 'ปิด',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // ─── Tabs ───
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: LcSpace.lg, vertical: LcSpace.sm),
      child: Row(
        children: [
          _buildTabButton(
            label: 'ค้นจากทะเบียน',
            icon: Icons.search_rounded,
            tab: 1,
          ),
          const SizedBox(width: LcSpace.sm),
          _buildTabButton(
            label: 'เพิ่มทะเบียนใหม่',
            icon: Icons.person_add_alt_1_rounded,
            tab: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required int tab,
  }) {
    final isActive = _currentPageTab == tab;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentPageTab = tab),
        borderRadius: BorderRadius.circular(LcRadius.sm),
        child: AnimatedContainer(
          duration: LcAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? LcColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(LcRadius.sm),
            border: Border.all(
              color: isActive ? LcColors.primary : LcColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : LcColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: LcText.label.copyWith(
                  color: isActive ? Colors.white : LcColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Tab 1: Search ───
  Widget _buildSearchTab(bool isDesktop, double dialogMaxWidth, double screenH) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search bar + pagination row
        Padding(
          padding:
              const EdgeInsets.fromLTRB(LcSpace.lg, 0, LcSpace.lg, LcSpace.sm),
          child: Row(
            children: [
              Expanded(child: _buildSearchBar()),
              const SizedBox(width: LcSpace.sm),
              _buildPaginationInline(),
            ],
          ),
        ),
        // Table
        Flexible(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: isDesktop ? dialogMaxWidth - 32 : 1000,
                child: _buildTable(isDesktop),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: LcColors.surfaceMuted.withOpacity(.6),
        borderRadius: BorderRadius.circular(LcRadius.sm),
        border: Border.all(color: LcColors.border, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: LcColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                setState(() {});
                _onSearchChanged(v);
              },
              style: LcText.input,
              cursorColor: LcColors.primary,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'ค้นหา (ชื่อ, รหัส, เลขบัตร...)',
                hintStyle: LcText.caption.copyWith(
                  fontFamily: LcText.fontRegular,
                  color: LcColors.textMuted,
                ),
              ),
            ),
          ),
          if (_searchCtrl.text.isNotEmpty)
            IconButton(
              tooltip: 'ล้าง',
              icon: const Icon(Icons.close, size: 16),
              color: LcColors.textMuted,
              onPressed: _onClearSearch,
            )
          else if (_isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(LcColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaginationInline() {
    final canPrev = (_linksPrev?.isNotEmpty ?? false);
    final canNext = (_linksNext?.isNotEmpty ?? false);

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: LcColors.surfaceMuted.withOpacity(.6),
        borderRadius: BorderRadius.circular(LcRadius.sm),
        border: Border.all(color: LcColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillIconButton(
            icon: Icons.chevron_left_rounded,
            enabled: canPrev && !_isLoading,
            onTap: () => _fetchCustomers(urlCustom: _linksPrev),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'หน้า ${_currentPage ?? '-'} / ${_lastPage ?? '-'}',
              style: LcText.label.copyWith(
                fontSize: 12,
                color: LcColors.primaryDark,
              ),
            ),
          ),
          _PillIconButton(
            icon: Icons.chevron_right_rounded,
            enabled: canNext && !_isLoading,
            onTap: () => _fetchCustomers(urlCustom: _linksNext),
          ),
        ],
      ),
    );
  }

  // ─── Table ───
  Widget _buildTable(bool isDesktop) {
    if (_isLoading && _customers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(LcColors.primary),
              ),
            ),
            SizedBox(height: 12),
            Text('กำลังโหลด...', style: LcText.bodyMuted),
          ],
        ),
      );
    }
    if (_customers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined,
                size: 36, color: LcColors.textMuted),
            SizedBox(height: 8),
            Text('ไม่พบข้อมูลลูกค้า', style: LcText.bodyMuted),
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _tableHeader(isDesktop),
        const Divider(height: 1, color: LcColors.border),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _customers.length,
            itemBuilder: (_, i) => _tableRow(i, _customers[i], isDesktop),
          ),
        ),
      ],
    );
  }

  Widget _tableHeader(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LcSpace.md, vertical: LcSpace.sm),
      decoration: const BoxDecoration(color: LcColors.surfaceMuted),
      child: const Row(
        children: [
          _TableCell(
              label: '#', width: 40, align: TextAlign.center, isHeader: true),
          _TableCell(label: 'รหัส', width: 100, isHeader: true, isMono: true),
          _TableCell(label: 'ชื่อ-นามสกุล', flex: 2, isHeader: true),
          _TableCell(label: 'ชื่อร้าน', flex: 2, isHeader: true),
          _TableCell(
              label: 'เลขบัตร', width: 120, isHeader: true, isMono: true),
          _TableCell(label: 'ที่อยู่', flex: 3, isHeader: true),
          _TableCell(
              label: 'เลือก',
              width: 80,
              isHeader: true,
              align: TextAlign.center),
        ],
      ),
    );
  }

  Widget _tableRow(int index, CustomerModel m, bool isDesktop) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        hoverColor: LcColors.primary.withOpacity(.05),
        onTap: () => Navigator.of(context).pop(m),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: LcSpace.md, vertical: LcSpace.sm),
          decoration: BoxDecoration(
            color: index.isEven
                ? Colors.white
                : LcColors.surfaceMuted.withOpacity(.4),
            border: const Border(
              bottom: BorderSide(color: LcColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              _TableCell(
                label: '${index + 1}',
                width: 40,
                align: TextAlign.center,
              ),
              _TableCell(label: m.custno ?? '-', width: 100, isMono: true),
              _TableCell(label: m.cname ?? '-', flex: 2),
              _TableCell(label: m.scname ?? '-', flex: 2),
              _TableCell(label: m.tax ?? '-', width: 120, isMono: true),
              _TableCell(label: m.addr1 ?? '-', flex: 3, muted: true),
              SizedBox(
                width: 80,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: LcColors.primary,
                      borderRadius: BorderRadius.circular(LcRadius.pill),
                    ),
                    child: const Text(
                      'เลือก',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: LcText.fontBold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Tab 2: Add new ───
  Widget _buildAddNewTab(bool isDesktop, double dialogMaxWidth, double screenH) {
    return SizedBox(
      width: double.infinity,
      height: screenH * 0.65,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        child: Add_Custo_Screen(
          addForForm: 'license_contract_page.dart',
          onSaveSuccess: (newName) async {
            // Refresh search list (ใช้ชื่อที่เพิ่งบันทึก)
            setState(() {
              _searchCtrl.text = newName;
              _currentPageTab = 1;
            });
            await _fetchCustomers(query: newName);
          },
        ),
      ),
    );
  }
}

// ============================================================================
// Internal widgets
// ============================================================================

class _PillIconButton extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _PillIconButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_PillIconButton> createState() => _PillIconButtonState();
}

class _PillIconButtonState extends State<_PillIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (widget.enabled) setState(() => _hover = true);
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: LcAnimations.fast,
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hover ? LcColors.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: !widget.enabled
                ? LcColors.textMuted
                : (_hover ? Colors.white : LcColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String label;
  final int? flex;
  final double? width;
  final TextAlign align;
  final bool isHeader;
  final bool isMono;
  final bool muted;

  const _TableCell({
    required this.label,
    this.flex,
    this.width,
    this.align = TextAlign.left,
    this.isHeader = false,
    this.isMono = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: isHeader
          ? LcText.tableHeader
          : LcText.tableCell.copyWith(
              color: muted ? LcColors.textSecondary : LcColors.textPrimary,
              fontFamily: isMono ? 'monospace' : LcText.fontRegular,
              fontFamilyFallback: const [LcText.fontRegular],
            ),
    );

    if (width != null) {
      return SizedBox(width: width, child: text);
    }
    return Expanded(flex: flex ?? 1, child: text);
  }
}

// Silence analyzer (kept for parity with new_contract_cmm.dart)
// ignore: unused_element
const _kFontRegular = Font_.Fonts_T;
