// ============================================================================
// license_announce_search_bar.dart
// ============================================================================
// Search bar แบบ modern — focus ring + clear button + loading (คัดลอก 100% จาก license_request_search_bar)
// - debounce 500ms ก่อนยิง API
// - hint chip แสดงฟิลด์ที่ auto-detect (UUID / เบอร์โทร / ชื่อ)
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_announce_theme.dart';
import '../../viewmodels/license_announce_view_model.dart';

class LicenseAnnounceSearchBar extends StatefulWidget {
  const LicenseAnnounceSearchBar({super.key});

  @override
  State<LicenseAnnounceSearchBar> createState() =>
      _LicenseAnnounceSearchBarState();
}

class _LicenseAnnounceSearchBarState extends State<LicenseAnnounceSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    // Sync ค่าเริ่มต้นจาก VM (ถ้ามี routeData)
    final vm = context.read<LicenseAnnounceViewModel>();
    if (vm.searchQuery.isNotEmpty) {
      _controller.text = vm.searchQuery;
    }
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final vm = context.read<LicenseAnnounceViewModel>();
    vm.setSearch(value);
    setState(() {}); // rebuild เพื่อ update hint chip + clear button

    // Debounce 500ms
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      vm.executeSearch();
    });
  }

  void _onClear() {
    _controller.clear();
    _debounce?.cancel();
    final vm = context.read<LicenseAnnounceViewModel>();
    vm.setSearch('');
    vm.executeSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseAnnounceViewModel>();
    final hasText = _controller.text.isNotEmpty;
    final fieldLabel = _fieldLabelFor(vm.searchQuery);

    return AnimatedContainer(
      duration: LrAnimations.medium,
      curve: Curves.easeOut,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LrRadius.md),
        border: Border.all(
          color: _focused ? LrColors.primary : LrColors.border,
          width: _focused ? 1.6 : 1,
        ),
        boxShadow: [
          if (_focused)
            BoxShadow(
              color: LrColors.primary.withOpacity(.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(.02),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: LrAnimations.fast,
            child: Icon(
              _focused ? Icons.search_rounded : Icons.search,
              key: ValueKey(_focused),
              color: _focused ? LrColors.primary : LrColors.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              onSubmitted: (v) {
                _debounce?.cancel();
                final vm = context.read<LicenseAnnounceViewModel>();
                vm.setSearch(v);
                vm.executeSearch();
              },
              style: LrText.body,
              cursorColor: LrColors.primary,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hasText
                    ? 'ค้นหา "${_controller.text}"'
                    : 'ค้นหา... (หัวข้อ, เนื้อหา, โซน)',
                hintStyle: LrText.bodyMuted.copyWith(
                  color: LrColors.textMuted,
                ),
              ),
            ),
          ),
          // Hint chip — แสดง field ที่ auto-detect
          if (hasText && fieldLabel != null)
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: LrColors.primaryLight,
                  borderRadius: BorderRadius.circular(LrRadius.pill),
                ),
                child: Text(
                  fieldLabel,
                  style: const TextStyle(
                    fontFamily: LrText.fontBold,
                    fontSize: 10,
                    color: LrColors.primaryDark,
                    letterSpacing: .4,
                  ),
                ),
              ),
            ),
          // Loading / Clear button
          if (vm.isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation(LrColors.primary),
              ),
            )
          else if (hasText)
            _IconChip(
              icon: Icons.close_rounded,
              tooltip: 'ล้าง',
              onTap: _onClear,
            ),
        ],
      ),
    );
  }

  /// Auto-detect field label สำหรับแสดง chip
  String? _fieldLabelFor(String value) {
    final v = value.trim();
    if (v.isEmpty) return null;
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    if (uuidRegex.hasMatch(v)) return 'UUID';
    final phoneRegex = RegExp(r'^[0-9]{8,12}$');
    if (phoneRegex.hasMatch(v.replaceAll(RegExp(r'[\s\-]'), ''))) {
      return 'เบอร์โทร';
    }
    return 'ชื่อ';
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconChip({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LrRadius.pill),
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: LrColors.surfaceMuted,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: LrColors.textSecondary),
        ),
      ),
    );
  }
}
